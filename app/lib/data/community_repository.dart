import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_manager.dart';

class CommunityRepository {
  CommunityRepository({SupabaseClient? client})
    : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<void> recordCommunityView({
    required String communityId,
    required String? userId,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      await client.from('community_views').insert(<String, dynamic>{
        'community_id': communityId,
        'user_id': userId,
      });
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Failed to record community view',
        name: 'CommunityRepository',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> submitHostRequest({
    required String name,
    required String email,
    required String message,
    String? userId,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      await client.from('community_host_requests').insert(<String, dynamic>{
        'name': name,
        'email': email,
        'message': message,
        'user_id': userId,
      });
    } on PostgrestException catch (error, stackTrace) {
      developer.log(
        'Failed to submit host request',
        name: 'CommunityRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
