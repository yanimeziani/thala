import '../models/video_post.dart';
import 'sample_posts.dart';

/// Loads stories for the feed. Falls back to curated sample data when backend
/// is not configured.
class FeedRepository {
  const FeedRepository();

  Future<List<VideoPost>> fetchFeed() async {
    // Backend integration pending - return sample data
    return samplePosts;
  }
}
