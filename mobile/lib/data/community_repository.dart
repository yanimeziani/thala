import 'dart:developer' as developer;
import '../services/api_client.dart';

/// Repository for community-related operations
class CommunityRepository {
  CommunityRepository({this.accessToken});

  final String? accessToken;

  bool get isRemoteEnabled => accessToken != null && accessToken!.isNotEmpty;

  Future<void> recordCommunityView({
    required String communityId,
    required String? userId,
  }) async {
    if (!isRemoteEnabled) {
      developer.log('Community: No auth token, skipping view record', name: 'CommunityRepository');
      return;
    }

    try {
      await ApiClient.post(
        '/communities/$communityId/view',
        headers: ApiClient.authHeaders(accessToken!),
      );
    } catch (e) {
      developer.log('Failed to record community view: $e', name: 'CommunityRepository', level: 1000);
    }
  }

  Future<void> submitHostRequest({
    required String name,
    required String email,
    required String message,
    String? userId,
  }) async {
    if (!isRemoteEnabled) {
      throw Exception('Must be authenticated to submit host request');
    }

    try {
      await ApiClient.post(
        '/communities/host-request',
        headers: ApiClient.authHeaders(accessToken!),
        body: {
          'name': name,
          'email': email,
          'message': message,
        },
      );
    } catch (e) {
      developer.log('Failed to submit host request: $e', name: 'CommunityRepository', level: 1000);
      rethrow;
    }
  }
}
