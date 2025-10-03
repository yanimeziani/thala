import 'dart:developer' as developer;

/// Repository for community-related operations
/// Currently uses local/sample data since backend integration is not yet implemented
class CommunityRepository {
  CommunityRepository();

  bool get isRemoteEnabled => false;

  Future<void> recordCommunityView({
    required String communityId,
    required String? userId,
  }) async {
    // Backend integration pending - no-op for now
    developer.log(
      'Community view recorded locally (backend integration pending)',
      name: 'CommunityRepository',
    );
  }

  Future<void> submitHostRequest({
    required String name,
    required String email,
    required String message,
    String? userId,
  }) async {
    // Backend integration pending - no-op for now
    developer.log(
      'Host request submitted locally (backend integration pending)',
      name: 'CommunityRepository',
    );
  }
}
