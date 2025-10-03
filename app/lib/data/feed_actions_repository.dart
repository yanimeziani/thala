import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_manager.dart';

/// Persists engagement events for feed items.
class FeedActionsRepository {
  FeedActionsRepository({SupabaseClient? client})
    : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<void> updateCounters(
    String videoId, {
    int? likes,
    int? comments,
    int? shares,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    final payload = <String, dynamic>{};
    if (likes != null) payload['likes'] = likes;
    if (comments != null) payload['comments'] = comments;
    if (shares != null) payload['shares'] = shares;

    if (payload.isEmpty) {
      return;
    }

    try {
      await client.from('videos').update(payload).eq('id', videoId);
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Failed to update video counters',
        name: 'FeedActionsRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> recordComment({
    required String videoId,
    required String userId,
    required String content,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      await client.from('video_comments').insert(<String, dynamic>{
        'video_id': videoId,
        'user_id': userId,
        'content': content,
      });
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Failed to insert video comment',
        name: 'FeedActionsRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> recordShare({
    required String videoId,
    required String userId,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      await client.from('video_shares').insert(<String, dynamic>{
        'video_id': videoId,
        'user_id': userId,
      });
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Failed to record share',
        name: 'FeedActionsRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> setFollow({
    required String creatorHandle,
    required String userId,
    required bool follow,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      if (follow) {
        await client.from('creator_followers').upsert(<String, dynamic>{
          'creator_handle': creatorHandle,
          'user_id': userId,
        });
      } else {
        await client
            .from('creator_followers')
            .delete()
            .eq('creator_handle', creatorHandle)
            .eq('user_id', userId);
      }
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Failed to update follow state',
        name: 'FeedActionsRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
