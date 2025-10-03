import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/localized_text.dart';
import '../models/video_post.dart';
import '../services/supabase_manager.dart';
import 'sample_posts.dart';

/// Loads stories for the feed. Falls back to curated sample data when Supabase
/// is not configured.
class FeedRepository {
  const FeedRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  Future<List<VideoPost>> fetchFeed() async {
    final client = _client ?? SupabaseManager.client;
    if (client == null) {
      return samplePosts;
    }

    try {
      final data = await client
          .from('videos')
          .select(
            'id, video_url, thumbnail_url, image_url, gallery_urls, text_slides, media_kind, aspect_ratio, video_source, music_track_id, effect_id, title_en, title_fr, description_en, description_fr, location_en, location_fr, creator_name_en, creator_name_fr, creator_handle, likes, comments, shares, tags',
          )
          .order('created_at', ascending: false);

      if (data.isEmpty) {
        return samplePosts;
      }

      return data
          .map<VideoPost>((row) {
            final tagsValue = row['tags'];
            final tags = tagsValue is List
                ? tagsValue.whereType<String>().toList()
                : <String>[];

            final mediaKindValue = row['media_kind'] as String?;
            final StoryMediaKind mediaKind;
            switch (mediaKindValue) {
              case 'image':
                mediaKind = StoryMediaKind.image;
                break;
              case 'post':
                mediaKind = StoryMediaKind.post;
                break;
              default:
                mediaKind = StoryMediaKind.video;
            }

            final videoSourceValue = row['video_source'] as String?;
            final VideoSource videoSource;
            switch (videoSourceValue) {
              case 'asset':
                videoSource = VideoSource.asset;
                break;
              case 'local':
                videoSource = VideoSource.localFile;
                break;
              default:
                videoSource = VideoSource.network;
            }

            final galleryValue = row['gallery_urls'];
            final List<String> galleryUrls = galleryValue is List
                ? galleryValue.whereType<String>().toList(growable: false)
                : const <String>[];

            final textSlidesValue = row['text_slides'];
            final List<LocalizedText> textSlides;
            if (textSlidesValue is List) {
              textSlides = textSlidesValue
                  .whereType<Map>()
                  .map<LocalizedText>((dynamic value) {
                    final map = value as Map;
                    return LocalizedText(
                      en: map['en'] as String? ?? '',
                      fr: map['fr'] as String? ?? '',
                    );
                  })
                  .toList(growable: false);
            } else {
              textSlides = const <LocalizedText>[];
            }

            final aspectRatioValue = row['aspect_ratio'];

            return VideoPost(
              id: row['id']?.toString() ?? 'video-${row.hashCode}',
              videoUrl:
                  row['video_url'] as String? ?? samplePosts.first.videoUrl,
              videoSource: videoSource,
              mediaKind: mediaKind,
              imageUrl: row['image_url'] as String?,
              galleryUrls: galleryUrls,
              textSlides: textSlides,
              aspectRatio: (aspectRatioValue is num)
                  ? aspectRatioValue.toDouble()
                  : null,
              thumbnailUrl: row['thumbnail_url'] as String?,
              title: LocalizedText(
                en: row['title_en'] as String? ?? 'Untitled story',
                fr: row['title_fr'] as String? ?? 'Histoire sans titre',
              ),
              description: LocalizedText(
                en: row['description_en'] as String? ?? '',
                fr: row['description_fr'] as String? ?? '',
              ),
              location: LocalizedText(
                en: row['location_en'] as String? ?? 'Amazigh lands',
                fr: row['location_fr'] as String? ?? 'Terres amazighes',
              ),
              creatorName: LocalizedText(
                en: row['creator_name_en'] as String? ?? 'Thala Creator',
                fr: row['creator_name_fr'] as String? ?? 'Créateur Thala',
              ),
              creatorHandle: row['creator_handle'] as String? ?? '@thala',
              likes: (row['likes'] as num?)?.toInt() ?? 0,
              comments: (row['comments'] as num?)?.toInt() ?? 0,
              shares: (row['shares'] as num?)?.toInt() ?? 0,
              tags: tags,
              musicTrackId: row['music_track_id'] as String?,
              effectId: row['effect_id'] as String?,
            );
          })
          .toList(growable: false);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Falling back to sample feed data',
          error: error,
          stackTrace: stackTrace,
          name: 'FeedRepository',
        );
      }
      return samplePosts;
    }
  }
}
