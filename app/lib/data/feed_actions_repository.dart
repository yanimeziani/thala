import 'dart:developer' as developer;

/// Persists engagement events for feed items.
class FeedActionsRepository {
  FeedActionsRepository();

  bool get isRemoteEnabled => false;

  Future<void> updateCounters(
    String videoId, {
    int? likes,
    int? comments,
    int? shares,
  }) async {
    // Backend integration pending - no-op
    developer.log(
      'Update counters (backend integration pending)',
      name: 'FeedActionsRepository',
    );
  }

  Future<void> recordComment({
    required String videoId,
    required String userId,
    required String content,
  }) async {
    // Backend integration pending - no-op
    developer.log(
      'Record comment (backend integration pending)',
      name: 'FeedActionsRepository',
    );
  }

  Future<void> recordShare({
    required String videoId,
    required String userId,
  }) async {
    // Backend integration pending - no-op
    developer.log(
      'Record share (backend integration pending)',
      name: 'FeedActionsRepository',
    );
  }

  Future<void> setFollow({
    required String creatorHandle,
    required String userId,
    required bool follow,
  }) async {
    // Backend integration pending - no-op
    developer.log(
      'Set follow (backend integration pending)',
      name: 'FeedActionsRepository',
    );
  }
}
