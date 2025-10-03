import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/video_post.dart';
import '../models/localized_text.dart';
import 'supabase_manager.dart';

/// Handles publishing a locally captured story to Supabase storage + metadata.
class StoryPublishingService {
  StoryPublishingService({SupabaseClient? client})
    : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<VideoPost?> publish(VideoPost draft) async {
    final client = _client;
    if (client == null) {
      return null;
    }

    if (draft.videoSource != VideoSource.localFile) {
      return draft.copyWith(isLocalDraft: false);
    }

    final file = File(draft.videoUrl);
    if (!await file.exists()) {
      throw const StoryPublishException('Draft video file no longer exists.');
    }

    final storagePath = 'stories/${draft.id}.mp4';
    final bytes = await file.readAsBytes();

    await client.storage
        .from(_bucket)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'video/mp4',
            upsert: true,
          ),
        );

    final publicUrl = client.storage.from(_bucket).getPublicUrl(storagePath);

    final payload = _buildPayload(draft, publicUrl);

    await client.from('videos').upsert(payload);

    return draft.copyWith(
      videoUrl: publicUrl,
      videoSource: VideoSource.network,
      isLocalDraft: false,
    );
  }

  Map<String, dynamic> _buildPayload(VideoPost post, String remoteUrl) {
    return <String, dynamic>{
      'id': post.id,
      'video_url': remoteUrl,
      'thumbnail_url': post.thumbnailUrl,
      'image_url': post.imageUrl,
      'gallery_urls': post.galleryUrls,
      'text_slides': _encodeSlides(post.textSlides),
      'media_kind': _mediaKindString(post.mediaKind),
      'aspect_ratio': post.aspectRatio,
      'video_source': 'network',
      'music_track_id': post.musicTrackId,
      'effect_id': post.effectId,
      'title_en': post.title.en,
      'title_fr': post.title.fr,
      'description_en': post.description.en,
      'description_fr': post.description.fr,
      'location_en': post.location.en,
      'location_fr': post.location.fr,
      'creator_name_en': post.creatorName.en,
      'creator_name_fr': post.creatorName.fr,
      'creator_handle': post.creatorHandle,
      'likes': post.likes,
      'comments': post.comments,
      'shares': post.shares,
      'tags': post.tags,
    };
  }

  List<Map<String, String>> _encodeSlides(List<LocalizedText> slides) {
    return slides
        .map((slide) => <String, String>{'en': slide.en, 'fr': slide.fr})
        .toList(growable: false);
  }

  String _mediaKindString(StoryMediaKind kind) {
    switch (kind) {
      case StoryMediaKind.image:
        return 'image';
      case StoryMediaKind.post:
        return 'post';
      case StoryMediaKind.video:
        return 'video';
    }
  }

  static const String _bucket = 'stories';
}

class StoryPublishException implements Exception {
  const StoryPublishException(this.message);

  final String message;

  @override
  String toString() => 'StoryPublishException: $message';
}
