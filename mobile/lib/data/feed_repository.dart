import 'dart:developer' as developer;
import '../models/video_post.dart';
import '../services/api_client.dart';

/// Repository for managing video feed content
class FeedRepository {
  const FeedRepository({this.accessToken});

  final String? accessToken;

  bool get isRemoteEnabled => accessToken != null && accessToken!.isNotEmpty;

  Future<List<VideoPost>> fetchFeed() async {
    if (!isRemoteEnabled) {
      developer.log('Feed: No auth token, returning empty feed', name: 'FeedRepository');
      return [];
    }

    try {
      final response = await ApiClient.getList(
        '/videos/feed',
        headers: ApiClient.authHeaders(accessToken!),
      );

      return response
          .map((json) => VideoPost.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Failed to fetch feed: $e', name: 'FeedRepository', level: 1000);
      return [];
    }
  }

  Future<void> likeVideo(String videoId) async {
    if (!isRemoteEnabled) {
      throw Exception('Must be authenticated to like videos');
    }

    try {
      await ApiClient.post(
        '/videos/$videoId/like',
        headers: ApiClient.authHeaders(accessToken!),
      );
    } catch (e) {
      developer.log('Failed to like video: $e', name: 'FeedRepository', level: 1000);
      rethrow;
    }
  }

  Future<void> unlikeVideo(String videoId) async {
    if (!isRemoteEnabled) {
      throw Exception('Must be authenticated to unlike videos');
    }

    try {
      await ApiClient.delete(
        '/videos/$videoId/like',
        headers: ApiClient.authHeaders(accessToken!),
      );
    } catch (e) {
      developer.log('Failed to unlike video: $e', name: 'FeedRepository', level: 1000);
      rethrow;
    }
  }

  Future<void> shareVideo(String videoId) async {
    if (!isRemoteEnabled) {
      throw Exception('Must be authenticated to share videos');
    }

    try {
      await ApiClient.post(
        '/videos/$videoId/share',
        headers: ApiClient.authHeaders(accessToken!),
      );
    } catch (e) {
      developer.log('Failed to share video: $e', name: 'FeedRepository', level: 1000);
      rethrow;
    }
  }
}
