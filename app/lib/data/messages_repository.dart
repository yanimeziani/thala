import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contact_handle.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import '../services/supabase_manager.dart';
import 'messages_local_store.dart';
import 'sample_messages.dart';

class MessagesRepository {
  MessagesRepository({SupabaseClient? client, MessagesLocalStore? localStore})
    : _client = client ?? SupabaseManager.client,
      _store = localStore ?? MessagesLocalStore();

  final SupabaseClient? _client;
  final MessagesLocalStore _store;

  Stream<List<MessageThread>> watchThreads() => _store.watchThreads();

  Future<List<MessageThread>> fetchThreads() async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return _store.fetchThreads();
    }

    try {
      final dynamic raw = await client
          .from('message_threads')
          .select(
            'id, title_en, title_fr, last_message_en, last_message_fr, unread_count, participants, avatar_url, updated_at',
          )
          .order('updated_at', ascending: false);

      if (raw is! List) {
        return _store.fetchThreads();
      }

      final Iterable<MessageThread> threads = raw
          .whereType<Map<String, dynamic>>()
          .map<MessageThread>(MessageThread.fromJson);

      final List<MessageThread> result = threads.toList(growable: false);
      if (result.isNotEmpty) {
        _store.replaceThreads(result);
      }
      return _store.fetchThreads();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Failed to fetch message threads from Supabase. Falling back to cached data.',
          name: 'MessagesRepository',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return _store.fetchThreads();
    }
  }

  Stream<List<Message>> watchThread(String threadId) =>
      _store.watchThread(threadId);

  List<Message> messagesForThread(String threadId) =>
      _store.messagesForThread(threadId);

  Future<Message> sendMessage(String threadId, String text) =>
      _store.sendMessage(threadId, text);

  Future<MessageThread> startThread({
    required List<String> participantHandles,
    String? title,
  }) =>
      _store.startThread(participantHandles: participantHandles, title: title);

  Future<void> markThreadRead(String threadId) =>
      _store.markThreadRead(threadId);

  Future<List<ContactHandle>> searchHandles(String query) =>
      _store.searchHandles(query);

  MessageThread? threadById(String threadId) => _store.threadById(threadId);

  ContactHandle get currentUser => _store.currentUser;

  String get currentUserHandle => _store.currentUserHandle;

  void dispose() => _store.dispose();
}
