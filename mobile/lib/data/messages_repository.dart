import '../models/contact_handle.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import 'messages_local_store.dart';

class MessagesRepository {
  MessagesRepository({MessagesLocalStore? localStore})
    : _store = localStore ?? MessagesLocalStore();

  final MessagesLocalStore _store;

  Stream<List<MessageThread>> watchThreads() => _store.watchThreads();

  Future<List<MessageThread>> fetchThreads() async {
    // Backend integration pending - use local store
    return _store.fetchThreads();
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
