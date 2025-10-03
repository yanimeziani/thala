import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/music_track.dart';
import '../services/supabase_manager.dart';
import 'sample_tracks.dart';

class MusicRepository {
  MusicRepository({SupabaseClient? client})
      : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<List<MusicTrack>> fetchTracks() async {
    final client = _client;
    if (client == null) {
      return sampleTracks;
    }

    try {
      final result = await client
          .from('music_tracks')
          .select(
            'id, title, artist, artwork_url, duration_seconds, preview_url',
          )
          .order('title');

      return result
          .whereType<Map<String, dynamic>>()
          .map(_mapTrack)
          .toList(growable: false);
    } on PostgrestException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Failed to fetch music tracks from Supabase',
          name: 'MusicRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleTracks;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Unexpected error loading music tracks',
          name: 'MusicRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleTracks;
    }
  }

  MusicTrack _mapTrack(Map<String, dynamic> row) {
    final id = row['id']?.toString() ?? '';
    final title = row['title']?.toString() ?? 'Untitled track';
    final artist = row['artist']?.toString() ?? 'Unknown artist';
    final artworkUrl = row['artwork_url']?.toString() ?? '';
    final previewUrl = row['preview_url']?.toString();
    final durationSeconds = (row['duration_seconds'] as num?)?.toInt() ?? 0;

    return MusicTrack(
      id: id,
      title: title,
      artist: artist,
      artworkUrl: artworkUrl,
      duration: Duration(seconds: durationSeconds.clamp(0, 1 << 20)),
      previewUrl: previewUrl?.isEmpty == true ? null : previewUrl,
    );
  }
}
