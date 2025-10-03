import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/content_profile.dart';
import '../services/supabase_manager.dart';
import 'sample_content_profiles.dart';

class ContentProfileRepository {
  ContentProfileRepository({SupabaseClient? client})
      : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<Map<String, ContentProfile>> fetchProfiles() async {
    final client = _client;
    if (client == null) {
      return sampleContentProfiles;
    }

    try {
      final response = await client
          .from('content_profiles')
          .select(
            'content_id, cultural_families, regions, languages, topics, energy, sacred_level, is_guardian_approved',
          );

      return {
        for (final row in response.whereType<Map<String, dynamic>>())
          row['content_id']?.toString() ?? '': _mapProfile(row),
      };
    } on PostgrestException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Failed to fetch content profiles from Supabase',
          name: 'ContentProfileRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleContentProfiles;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Unexpected error loading content profiles',
          name: 'ContentProfileRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleContentProfiles;
    }
  }

  ContentProfile _mapProfile(Map<String, dynamic> row) {
    List<String> _stringList(dynamic value) {
      return (value is List)
          ? value.whereType<String>().toList(growable: false)
          : const <String>[];
    }

    return ContentProfile(
      contentId: row['content_id']?.toString() ?? '',
      culturalFamilies: _stringList(row['cultural_families']),
      regions: _stringList(row['regions']),
      languages: _stringList(row['languages']),
      topics: _stringList(row['topics']),
      energy: row['energy']?.toString(),
      sacredLevel: row['sacred_level']?.toString(),
      isGuardianApproved: row['is_guardian_approved'] == true,
    );
  }
}
