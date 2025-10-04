import '../models/contact_handle.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import '../services/messages_api_service.dart';
import 'messages_local_store.dart';

class MessagesRepository {
  MessagesRepository({
    MessagesLocalStore? localStore,
    this.authToken,
    this.useBackend = false,
  }) : _store = localStore ?? MessagesLocalStore();

  final MessagesLocalStore _store;
  final String? authToken;
  final bool useBackend;

  Stream<List<MessageThread>> watchThreads() => _store.watchThreads();

  Future<List<MessageThread>> fetchThreads() async {
    if (useBackend && authToken != null) {
      try {
        final threads = await MessagesApiService.fetchThreads(
          authToken: authToken!,
        );
        _store.replaceThreads(threads);
        return threads;
      } catch (e) {
        // Fall back to local store on error
        return _store.fetchThreads();
      }
    }
    return _store.fetchThreads();
  }

  Stream<List<Message>> watchThread(String threadId) =>
      _store.watchThread(threadId);

  List<Message> messagesForThread(String threadId) =>
      _store.messagesForThread(threadId);

  Future<Message> sendMessage(String threadId, String text) async {
    if (useBackend && authToken != null) {
      try {
        return await MessagesApiService.sendMessage(
          authToken: authToken!,
          threadId: threadId,
          text: text,
          currentUserHandle: currentUserHandle,
        );
      } catch (e) {
        // Fall back to local store on error
        return _store.sendMessage(threadId, text);
      }
    }
    return _store.sendMessage(threadId, text);
  }

  Future<MessageThread> startThread({
    required List<String> participantHandles,
    String? title,
  }) async {
    if (useBackend && authToken != null) {
      try {
        return await MessagesApiService.createThread(
          authToken: authToken!,
          participantHandles: participantHandles,
          title: title,
        );
      } catch (e) {
        // Fall back to local store on error
        return _store.startThread(
          participantHandles: participantHandles,
          title: title,
        );
      }
    }
    return _store.startThread(
      participantHandles: participantHandles,
      title: title,
    );
  }

  Future<void> markThreadRead(String threadId) async {
    if (useBackend && authToken != null) {
      try {
        await MessagesApiService.markThreadRead(
          authToken: authToken!,
          threadId: threadId,
        );
      } catch (e) {
        // Fall back to local store on error
      }
    }
    return _store.markThreadRead(threadId);
  }

  Future<List<ContactHandle>> searchHandles(String query) async {
    if (useBackend && authToken != null) {
      try {
        return await MessagesApiService.searchHandles(
          authToken: authToken!,
          query: query,
        );
      } catch (e) {
        // Fall back to local store on error
        return _store.searchHandles(query);
      }
    }
    return _store.searchHandles(query);
  }

  MessageThread? threadById(String threadId) => _store.threadById(threadId);

  ContactHandle get currentUser => _store.currentUser;

  String get currentUserHandle => _store.currentUserHandle;

  void dispose() => _store.dispose();
}
