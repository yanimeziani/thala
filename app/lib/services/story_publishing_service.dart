import '../models/video_post.dart';

/// Handles publishing a locally captured story to backend storage + metadata.
class StoryPublishingService {
  StoryPublishingService();

  bool get isRemoteEnabled => false;

  Future<VideoPost?> publish(VideoPost draft) async {
    // Backend integration pending - return null for now
    return null;
  }
}

class StoryPublishException implements Exception {
  const StoryPublishException(this.message);

  final String message;

  @override
  String toString() => 'StoryPublishException: $message';
}
