import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/contact_handle.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import 'api_client.dart';

/// API service for messaging functionality with Thala backend
class MessagesApiService {
  MessagesApiService._();

  /// Fetch all message threads for the current user
  static Future<List<MessageThread>> fetchThreads({
    required String authToken,
  }) async {
    try {
      final response = await ApiClient.get(
        '/messages/threads',
        headers: {'Authorization': 'Bearer $authToken'},
      );

      final List<dynamic> threadsJson = response['threads'] as List<dynamic>;
      return threadsJson
          .map((json) => MessageThread.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to fetch threads: $e',
          name: 'MessagesApiService',
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Fetch messages for a specific thread
  static Future<List<Message>> fetchMessages({
    required String authToken,
    required String threadId,
    required String currentUserHandle,
    int? limit,
    String? beforeMessageId,
  }) async {
    try {
      final queryParams = <String, String>{
        if (limit != null) 'limit': limit.toString(),
        if (beforeMessageId != null) 'before': beforeMessageId,
      };

      final response = await ApiClient.get(
        '/messages/threads/$threadId/messages',
        headers: {'Authorization': 'Bearer $authToken'},
        queryParameters: queryParams,
      );

      final List<dynamic> messagesJson = response['messages'] as List<dynamic>;
      return messagesJson
          .map((json) => Message.fromJson(
                json as Map<String, dynamic>,
                currentUserHandle: currentUserHandle,
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to fetch messages: $e',
          name: 'MessagesApiService',
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Send a message in a thread
  static Future<Message> sendMessage({
    required String authToken,
    required String threadId,
    required String text,
    required String currentUserHandle,
  }) async {
    try {
      final response = await ApiClient.post(
        '/messages/threads/$threadId/messages',
        headers: {'Authorization': 'Bearer $authToken'},
        body: {'text': text},
      );

      return Message.fromJson(
        response['message'] as Map<String, dynamic>,
        currentUserHandle: currentUserHandle,
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to send message: $e',
          name: 'MessagesApiService',
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Create a new message thread
  static Future<MessageThread> createThread({
    required String authToken,
    required List<String> participantHandles,
    String? title,
  }) async {
    try {
      final response = await ApiClient.post(
        '/messages/threads',
        headers: {'Authorization': 'Bearer $authToken'},
        body: {
          'participant_handles': participantHandles,
          if (title != null) 'title': title,
        },
      );

      return MessageThread.fromJson(
          response['thread'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to create thread: $e',
          name: 'MessagesApiService',
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Mark a thread as read
  static Future<void> markThreadRead({
    required String authToken,
    required String threadId,
  }) async {
    try {
      await ApiClient.post(
        '/messages/threads/$threadId/read',
        headers: {'Authorization': 'Bearer $authToken'},
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to mark thread as read: $e',
          name: 'MessagesApiService',
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Search for users/handles to message
  static Future<List<ContactHandle>> searchHandles({
    required String authToken,
    required String query,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        if (limit != null) 'limit': limit.toString(),
      };

      final response = await ApiClient.get(
        '/messages/search-handles',
        headers: {'Authorization': 'Bearer $authToken'},
        queryParameters: queryParams,
      );

      final List<dynamic> handlesJson = response['handles'] as List<dynamic>;
      return handlesJson
          .map((json) => ContactHandle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to search handles: $e',
          name: 'MessagesApiService',
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Get unread message count
  static Future<int> getUnreadCount({
    required String authToken,
  }) async {
    try {
      final response = await ApiClient.get(
        '/messages/unread-count',
        headers: {'Authorization': 'Bearer $authToken'},
      );

      return response['count'] as int;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to get unread count: $e',
          name: 'MessagesApiService',
          level: 1000,
        );
      }
      return 0;
    }
  }
}
