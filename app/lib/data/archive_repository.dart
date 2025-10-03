import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/archive_entry.dart';
import '../models/localized_text.dart';
import '../services/supabase_manager.dart';
import 'sample_archive_entries.dart';

class ArchiveRepository {
  ArchiveRepository({SupabaseClient? client})
      : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<List<ArchiveEntry>> fetchEntries() async {
    final client = _client;
    if (client == null) {
      return sampleArchiveEntries;
    }

    try {
      final response = await client
          .from('archive_entries')
          .select(
            'id, title, summary, era, category, thumbnail_url, community_upvotes, registered_users, required_approval_percent',
          )
          .order('created_at', ascending: false);

      return response
          .whereType<Map<String, dynamic>>()
          .map(_mapEntry)
          .toList(growable: false);
    } on PostgrestException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Failed to load archive entries from Supabase',
          name: 'ArchiveRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleArchiveEntries;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Unexpected error loading archive entries',
          name: 'ArchiveRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleArchiveEntries;
    }
  }

  ArchiveEntry _mapEntry(Map<String, dynamic> row) {
    return ArchiveEntry(
      id: row['id']?.toString() ?? '',
      title: _parseLocalized(row['title']),
      summary: _parseLocalized(row['summary']),
      era: _parseLocalized(row['era']),
      category: row['category']?.toString(),
      thumbnailUrl: row['thumbnail_url']?.toString() ?? '',
      communityUpvotes: (row['community_upvotes'] as num?)?.toInt() ?? 0,
      registeredUsers: (row['registered_users'] as num?)?.toInt() ?? 0,
      requiredApprovalPercent:
          (row['required_approval_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  LocalizedText _parseLocalized(dynamic value) {
    if (value is Map) {
      final en = value['en']?.toString() ?? '';
      final fr = value['fr']?.toString() ?? en;
      return LocalizedText(en: en, fr: fr);
    }
    final fallback = value?.toString() ?? '';
    return LocalizedText(en: fallback, fr: fallback);
  }
}
