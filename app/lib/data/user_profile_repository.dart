import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/supabase_manager.dart';

class UserProfileRepository {
  UserProfileRepository({SupabaseClient? client})
    : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<UserProfile?> refreshProfile({UserProfile? fallback}) async {
    final client = _client;
    if (client == null) {
      return fallback;
    }

    try {
      final response = await client.auth.getUser();
      final user = response.user;
      if (user == null) {
        return fallback;
      }
      return UserProfile.fromUser(user, fallback: fallback);
    } on AuthException catch (error, stackTrace) {
      developer.log(
        'Unable to fetch user profile from Supabase',
        name: 'UserProfileRepository',
        error: error,
        stackTrace: stackTrace,
      );
      return fallback;
    }
  }

  Future<UserProfile?> saveProfile(UserProfile profile) async {
    final client = _client;
    if (client == null) {
      return profile;
    }

    try {
      final attributes = UserAttributes(data: profile.toMetadata());
      final response = await client.auth.updateUser(attributes);
      final updated = response.user;
      if (updated == null) {
        return profile;
      }
      return UserProfile.fromUser(updated, fallback: profile);
    } on AuthException catch (error, stackTrace) {
      developer.log(
        'Failed to update Supabase user profile',
        name: 'UserProfileRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
