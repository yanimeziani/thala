import 'dart:async';
import 'dart:math';

import '../models/contact_handle.dart';
import '../models/localized_text.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import 'sample_messages.dart';

class MessagesLocalStore {
  MessagesLocalStore({
    List<MessageThread>? threads,
    Map<String, List<Message>>? threadMessages,
    List<ContactHandle>? handles,
    this.currentUserHandle = sampleCurrentUserHandle,
    Map<String, List<String>>? autoReplies,
  }) : _handles = handles ?? sampleContactHandles,
       _autoRepliesSeed = autoReplies ?? sampleThreadAutoReplies,
       _messagesByThread = <String, List<Message>>{},
       _threads = <MessageThread>[],
       _random = Random() {
    _hydrateInitialData(
      threads ?? sampleMessageThreads,
      threadMessages ?? sampleThreadMessages,
    );
  }

  final List<ContactHandle> _handles;
  final Map<String, List<String>> _autoRepliesSeed;
  final Map<String, List<Message>> _messagesByThread;
  final List<MessageThread> _threads;
  final Map<String, StreamController<List<Message>>> _threadMessageControllers =
      <String, StreamController<List<Message>>>{};
  final StreamController<List<MessageThread>> _threadsController =
      StreamController<List<MessageThread>>.broadcast();
  final Map<String, String> _threadKeyIndex = <String, String>{};

  final Random _random;
  final Map<String, List<String>> _autoReplyCache = <String, List<String>>{};
  bool _disposed = false;

  final String currentUserHandle;

  ContactHandle get currentUser {
    return sampleHandlesIndex[currentUserHandle] ?? sampleCurrentUser;
  }

  Stream<List<MessageThread>> watchThreads() {
    return _threadsController.stream;
  }

  Future<List<MessageThread>> fetchThreads() async {
    return List<MessageThread>.unmodifiable(_threads);
  }

  Stream<List<Message>> watchThread(String threadId) {
    _ensureMessageController(threadId);
    return _threadMessageControllers[threadId]!.stream;
  }

  MessageThread? threadById(String threadId) {
    try {
      return _threads.firstWhere(
        (MessageThread thread) => thread.id == threadId,
      );
    } catch (_) {
      return null;
    }
  }

  List<Message> messagesForThread(String threadId) {
    final List<Message>? messages = _messagesByThread[threadId];
    if (messages == null) {
      return const <Message>[];
    }
    return List<Message>.unmodifiable(messages);
  }

  Future<Message> sendMessage(String threadId, String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    final MessageThread? thread = threadById(threadId);
    if (thread == null) {
      throw StateError('Thread "$threadId" does not exist.');
    }

    final DateTime now = DateTime.now();
    final Message message = Message(
      id: _buildMessageId(threadId),
      threadId: threadId,
      authorHandle: currentUserHandle,
      authorDisplayName: currentUser.displayName,
      text: trimmed,
      createdAt: now,
      deliveryStatus: MessageDeliveryStatus.pending,
      isMine: true,
    );

    _appendMessage(threadId, message);
    _markThreadUpdated(threadId, message);
    _emitThreadMessages(threadId);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_disposed) {
      return message;
    }

    _updateMessageStatus(threadId, message.id, MessageDeliveryStatus.sent);
    _emitThreadMessages(threadId);

    final List<String> participants = thread.participants;
    if (participants.isEmpty) {
      return message;
    }

    final String responderHandle = participants.first;
    await _scheduleAutoReply(threadId, responderHandle);
    return message;
  }

  Future<MessageThread> startThread({
    required List<String> participantHandles,
    String? title,
  }) async {
    final List<String> sanitized = participantHandles
        .map<String>((String handle) => handle.trim())
        .where((String handle) => handle.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (sanitized.isEmpty) {
      throw ArgumentError('A thread requires at least one participant.');
    }

    final String threadKey = _composeThreadKey(sanitized);
    final String? existingId = _threadKeyIndex[threadKey];
    if (existingId != null) {
      return threadById(existingId)!;
    }

    final String threadId = _buildThreadId();
    final String resolvedTitle = title ?? _buildThreadTitle(sanitized);

    final MessageThread thread = MessageThread(
      id: threadId,
      title: LocalizedText(en: resolvedTitle, fr: resolvedTitle),
      lastMessage: LocalizedText(en: '', fr: ''),
      updatedAt: DateTime.now(),
      unreadCount: 0,
      participants: sanitized,
      avatarUrl: null,
    );

    _threads.insert(0, thread);
    _threadKeyIndex[threadKey] = threadId;
    _messagesByThread.putIfAbsent(threadId, () => <Message>[]);
    _ensureMessageController(threadId);
    _emitThreads();
    _emitThreadMessages(threadId);
    return thread;
  }

  Future<void> markThreadRead(String threadId) async {
    final int index = _threads.indexWhere(
      (MessageThread thread) => thread.id == threadId,
    );
    if (index == -1) {
      return;
    }
    final MessageThread thread = _threads[index];
    if (thread.unreadCount == 0) {
      return;
    }
    _threads[index] = MessageThread(
      id: thread.id,
      title: thread.title,
      lastMessage: thread.lastMessage,
      updatedAt: thread.updatedAt,
      unreadCount: 0,
      participants: thread.participants,
      avatarUrl: thread.avatarUrl,
    );
    _emitThreads();
  }

  Future<List<ContactHandle>> searchHandles(String query) async {
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return const <ContactHandle>[];
    }

    final Iterable<ContactHandle> matches = _handles.where((
      ContactHandle handle,
    ) {
      if (handle.handle == currentUserHandle) {
        return false;
      }
      final String haystack = <String?>[
        handle.handle,
        handle.displayName,
        handle.bio,
        handle.location,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(trimmed);
    });

    final List<ContactHandle> sorted = matches.toList(
      growable: false,
    )..sort((ContactHandle a, ContactHandle b) => a.handle.compareTo(b.handle));
    return sorted.take(12).toList(growable: false);
  }

  void replaceThreads(List<MessageThread> threads) {
    final Map<String, List<Message>> nextMessages = <String, List<Message>>{};
    final Map<String, String> nextIndex = <String, String>{};

    for (final MessageThread thread in threads) {
      final List<Message> existing =
          _messagesByThread[thread.id] ?? <Message>[];
      existing.sort(
        (Message a, Message b) => a.createdAt.compareTo(b.createdAt),
      );
      nextMessages[thread.id] = List<Message>.from(existing);
      nextIndex[_composeThreadKey(thread.participants)] = thread.id;
    }

    _threads
      ..clear()
      ..addAll(threads);
    _threads.sort((MessageThread a, MessageThread b) {
      final DateTime aDate =
          a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bDate =
          b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    _messagesByThread
      ..clear()
      ..addAll(nextMessages);
    _threadKeyIndex
      ..clear()
      ..addAll(nextIndex);

    for (final String threadId in _messagesByThread.keys) {
      _ensureMessageController(threadId);
      _emitThreadMessages(threadId);
    }
    _emitThreads();
  }

  void dispose() {
    _disposed = true;
    for (final StreamController<List<Message>> controller
        in _threadMessageControllers.values) {
      controller.close();
    }
    _threadMessageControllers.clear();
    _threadsController.close();
  }

  void _hydrateInitialData(
    List<MessageThread> threads,
    Map<String, List<Message>> threadMessages,
  ) {
    final List<MessageThread> normalizedThreads = threads
        .map<MessageThread>(
          (MessageThread thread) => MessageThread(
            id: thread.id,
            title: thread.title,
            lastMessage: thread.lastMessage,
            updatedAt: thread.updatedAt?.toLocal(),
            unreadCount: thread.unreadCount,
            participants: List<String>.from(thread.participants),
            avatarUrl: thread.avatarUrl,
          ),
        )
        .toList();

    final Map<String, List<Message>> normalizedMessages =
        <String, List<Message>>{};
    for (final MapEntry<String, List<Message>> entry
        in threadMessages.entries) {
      final List<Message> messages = List<Message>.from(entry.value)
        ..sort((Message a, Message b) => a.createdAt.compareTo(b.createdAt));
      normalizedMessages[entry.key] = messages;
    }

    _messagesByThread
      ..clear()
      ..addAll(normalizedMessages);

    _threads
      ..clear()
      ..addAll(normalizedThreads);
    _threads.sort((MessageThread a, MessageThread b) {
      final DateTime aDate =
          a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bDate =
          b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    _threadKeyIndex
      ..clear()
      ..addEntries(
        _threads.map(
          (MessageThread thread) => MapEntry<String, String>(
            _composeThreadKey(thread.participants),
            thread.id,
          ),
        ),
      );

    for (final MessageThread thread in _threads) {
      _ensureMessageController(thread.id);
      _emitThreadMessages(thread.id);
    }

    _emitThreads();
  }

  void _ensureMessageController(String threadId) {
    if (_threadMessageControllers.containsKey(threadId)) {
      return;
    }
    late final StreamController<List<Message>> controller;
    controller = StreamController<List<Message>>.broadcast(
          onListen: () {
            final List<Message> snapshot = List<Message>.from(
              _messagesByThread[threadId] ?? const <Message>[],
            );
            controller.add(snapshot);
          },
        );
    _threadMessageControllers[threadId] = controller;
  }

  void _emitThreadMessages(String threadId) {
    final StreamController<List<Message>>? controller =
        _threadMessageControllers[threadId];
    if (controller == null || controller.isClosed) {
      return;
    }
    final List<Message> messages = List<Message>.from(
      _messagesByThread[threadId] ?? const <Message>[],
    );
    controller.add(messages);
  }

  void _emitThreads() {
    if (_threadsController.isClosed) {
      return;
    }
    _threadsController.add(List<MessageThread>.from(_threads));
  }

  void _appendMessage(String threadId, Message message) {
    final List<Message> messages = _messagesByThread.putIfAbsent(
      threadId,
      () => <Message>[],
    );
    messages.add(message);
    messages.sort((Message a, Message b) => a.createdAt.compareTo(b.createdAt));
  }

  void _updateMessageStatus(
    String threadId,
    String messageId,
    MessageDeliveryStatus status,
  ) {
    final List<Message>? messages = _messagesByThread[threadId];
    if (messages == null) {
      return;
    }
    for (int i = 0; i < messages.length; i++) {
      final Message message = messages[i];
      if (message.id == messageId) {
        messages[i] = message.copyWith(deliveryStatus: status);
        break;
      }
    }
  }

  void _markThreadUpdated(String threadId, Message message) {
    final int index = _threads.indexWhere(
      (MessageThread thread) => thread.id == threadId,
    );
    if (index == -1) {
      return;
    }

    final MessageThread thread = _threads[index];
    final int unread = message.isMine ? 0 : thread.unreadCount + 1;
    final MessageThread updated = MessageThread(
      id: thread.id,
      title: thread.title,
      lastMessage: LocalizedText(en: message.text, fr: message.text),
      updatedAt: message.createdAt,
      unreadCount: unread,
      participants: thread.participants,
      avatarUrl: thread.avatarUrl,
    );

    _threads[index] = updated;
    _threads.sort((MessageThread a, MessageThread b) {
      final DateTime aDate =
          a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bDate =
          b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    _emitThreads();
  }

  Future<void> _scheduleAutoReply(
    String threadId,
    String responderHandle,
  ) async {
    final ContactHandle responder =
        sampleHandlesIndex[responderHandle] ??
        _handles.firstWhere(
          (ContactHandle handle) => handle.handle != currentUserHandle,
          orElse: () => sampleCurrentUser,
        );
    final Duration delay = Duration(milliseconds: 1000 + _random.nextInt(1400));
    await Future<void>.delayed(delay);
    if (_disposed) {
      return;
    }

    final String replyText = _nextAutoReply(threadId, responderHandle);
    final DateTime now = DateTime.now();
    final Message reply = Message(
      id: _buildMessageId(threadId),
      threadId: threadId,
      authorHandle: responder.handle,
      authorDisplayName: responder.displayName,
      text: replyText,
      createdAt: now,
      deliveryStatus: MessageDeliveryStatus.delivered,
      isMine: false,
    );

    _appendMessage(threadId, reply);
    _markThreadUpdated(threadId, reply);
    _emitThreadMessages(threadId);
  }

  String _nextAutoReply(String threadId, String responderHandle) {
    final List<String> cached = _autoReplyCache.putIfAbsent(
      threadId,
      () => List<String>.from(_autoRepliesSeed[threadId] ?? const <String>[]),
    );

    if (cached.isEmpty) {
      final List<String> genericReplies = <String>[
        'Appreciate the update. Passing it to everyone now.',
        'Noted. I will weave this into tonight\'s plan.',
        'Hearing you loud and clear. Adjusting our setup.',
        'Perfect. I will keep the recordings ready.',
      ];
      final int index = _random.nextInt(genericReplies.length);
      return genericReplies[index];
    }

    final String reply = cached.removeAt(0);
    cached.add(reply);
    return reply;
  }

  String _composeThreadKey(List<String> participantHandles) {
    final List<String> sorted = <String>{
      ...participantHandles,
      currentUserHandle,
    }.toList()..sort();
    return sorted.join('|');
  }

  String _buildThreadId() {
    final int suffix = DateTime.now().microsecondsSinceEpoch;
    return 'thread-$suffix';
  }

  String _buildMessageId(String threadId) {
    final int suffix = DateTime.now().microsecondsSinceEpoch;
    return '$threadId-message-$suffix';
  }

  String _buildThreadTitle(List<String> handles) {
    final List<String> names = handles
        .map(
          (String handle) => sampleHandlesIndex[handle]?.displayName ?? handle,
        )
        .toList(growable: false);
    if (names.length == 1) {
      return names.first;
    }
    if (names.length == 2) {
      return '${names.first} & ${names.last}';
    }
    return names.take(3).join(', ');
  }
}
