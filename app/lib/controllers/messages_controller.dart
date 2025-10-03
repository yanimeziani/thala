import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/messages_repository.dart';
import '../models/contact_handle.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import '../services/supabase_manager.dart';

class MessagesController extends ChangeNotifier {
  MessagesController({MessagesRepository? repository})
    : _repository = repository ?? MessagesRepository() {
    _threadsSubscription = _repository.watchThreads().listen(
      _handleThreadsUpdate,
      onError: (Object error, StackTrace stackTrace) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  final MessagesRepository _repository;
  final Map<String, _ThreadSession> _sessions = <String, _ThreadSession>{};

  StreamSubscription<List<MessageThread>>? _threadsSubscription;
  List<MessageThread> _threads = <MessageThread>[];
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  bool _isSearching = false;
  String _searchQuery = '';
  List<ContactHandle> _searchResults = <ContactHandle>[];

  List<MessageThread> get threads => List<MessageThread>.unmodifiable(_threads);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _threads.isNotEmpty;
  bool get isSupabaseEnabled => SupabaseManager.isConfigured;

  int get unreadCount => _threads.fold<int>(0, (int acc, MessageThread thread) {
    final int count = thread.unreadCount;
    return acc + (count > 0 ? count : 0);
  });

  MessageThread? get highlightedThread {
    if (_threads.isEmpty) {
      return null;
    }
    return _threads.first;
  }

  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  List<ContactHandle> get searchResults =>
      List<ContactHandle>.unmodifiable(_searchResults);

  ContactHandle get currentUser => _repository.currentUser;

  Future<void> ensureLoaded() async {
    if (_initialized) {
      return;
    }
    await refresh();
    _initialized = true;
  }

  Future<void> refresh() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.fetchThreads();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureThreadLoaded(String threadId) async {
    final _ThreadSession session = _sessions.putIfAbsent(
      threadId,
      () => _ThreadSession(threadId: threadId),
    );
    if (session.subscription != null) {
      return;
    }
    session.isLoading = true;
    notifyListeners();

    session.subscription = _repository
        .watchThread(threadId)
        .listen(
          (List<Message> messages) {
            session.messages
              ..clear()
              ..addAll(messages);
            session.isLoading = false;
            session.errorMessage = null;
            notifyListeners();
          },
          onError: (Object error, StackTrace stackTrace) {
            session.errorMessage = error.toString();
            session.isLoading = false;
            notifyListeners();
          },
        );
  }

  List<Message> messagesForThread(String threadId) {
    final _ThreadSession? session = _sessions[threadId];
    if (session == null) {
      return _repository.messagesForThread(threadId);
    }
    return List<Message>.unmodifiable(session.messages);
  }

  bool isThreadLoading(String threadId) =>
      _sessions[threadId]?.isLoading ?? false;

  bool isThreadSending(String threadId) =>
      _sessions[threadId]?.isSending ?? false;

  String? threadError(String threadId) => _sessions[threadId]?.errorMessage;

  Future<MessageThread?> threadById(String threadId) async {
    final MessageThread? thread = _repository.threadById(threadId);
    if (thread != null) {
      return thread;
    }
    await refresh();
    return _repository.threadById(threadId);
  }

  Future<void> sendMessage(String threadId, String text) async {
    final _ThreadSession session = _sessions.putIfAbsent(
      threadId,
      () => _ThreadSession(threadId: threadId),
    );
    final String trimmed = text.trim();
    if (trimmed.isEmpty || session.isSending) {
      return;
    }

    session.isSending = true;
    session.errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendMessage(threadId, trimmed);
    } catch (error) {
      session.errorMessage = 'Unable to send message. Please try again.';
      if (error is ArgumentError) {
        session.errorMessage = error.message;
      }
    } finally {
      session.isSending = false;
      notifyListeners();
    }
  }

  Future<MessageThread> startThreadWithHandles(
    List<String> participantHandles, {
    String? title,
  }) async {
    final MessageThread thread = await _repository.startThread(
      participantHandles: participantHandles,
      title: title,
    );
    return thread;
  }

  Future<MessageThread> startThreadWithHandle(ContactHandle handle) {
    return startThreadWithHandles(<String>[handle.handle]);
  }

  Future<void> markThreadRead(String threadId) async {
    await _repository.markThreadRead(threadId);
  }

  Future<void> searchHandles(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = <ContactHandle>[];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final List<ContactHandle> results = await _repository.searchHandles(
        query,
      );
      _searchResults = results;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    if (_searchQuery.isEmpty && _searchResults.isEmpty) {
      return;
    }
    _searchQuery = '';
    _searchResults = <ContactHandle>[];
    _isSearching = false;
    notifyListeners();
  }

  void clearThreadError(String threadId) {
    final _ThreadSession? session = _sessions[threadId];
    if (session == null || session.errorMessage == null) {
      return;
    }
    session.errorMessage = null;
    notifyListeners();
  }

  void _handleThreadsUpdate(List<MessageThread> next) {
    _threads = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _threadsSubscription?.cancel();
    for (final _ThreadSession session in _sessions.values) {
      session.dispose();
    }
    _repository.dispose();
    super.dispose();
  }
}

class _ThreadSession {
  _ThreadSession({required this.threadId});

  final String threadId;
  final List<Message> messages = <Message>[];
  bool isLoading = false;
  bool isSending = false;
  String? errorMessage;
  StreamSubscription<List<Message>>? subscription;

  void dispose() {
    subscription?.cancel();
  }
}
