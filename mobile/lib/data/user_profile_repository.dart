import 'dart:developer' as developer;
import '../models/user_profile.dart';
import '../services/api_client.dart';

/// Repository for managing user profiles
class UserProfileRepository {
  UserProfileRepository({this.accessToken});

  final String? accessToken;

  bool get isRemoteEnabled => accessToken != null && accessToken!.isNotEmpty;

  Future<UserProfile?> refreshProfile({UserProfile? fallback}) async {
    if (!isRemoteEnabled) {
      developer.log('User profile: No auth token, returning fallback', name: 'UserProfileRepository');
      return fallback;
    }

    try {
      final response = await ApiClient.get(
        '/users/me',
        headers: ApiClient.authHeaders(accessToken!),
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      developer.log('Failed to refresh profile: $e', name: 'UserProfileRepository', level: 1000);
      return fallback;
    }
  }

  Future<UserProfile?> saveProfile(UserProfile profile) async {
    if (!isRemoteEnabled) {
      throw Exception('Must be authenticated to save profile');
    }

    try {
      final response = await ApiClient.put(
        '/users/me',
        headers: ApiClient.authHeaders(accessToken!),
        body: profile.toJson(),
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      developer.log('Failed to save profile: $e', name: 'UserProfileRepository', level: 1000);
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String handle) async {
    if (!isRemoteEnabled) {
      developer.log('User profile: No auth token, cannot fetch user', name: 'UserProfileRepository');
      return null;
    }

    try {
      final response = await ApiClient.get(
        '/users/$handle',
        headers: ApiClient.authHeaders(accessToken!),
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      developer.log('Failed to get user profile: $e', name: 'UserProfileRepository', level: 1000);
      return null;
    }
  }
}
