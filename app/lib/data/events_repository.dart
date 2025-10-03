import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cultural_event.dart';
import '../models/localized_text.dart';
import '../services/supabase_manager.dart';
import 'sample_events.dart';

class EventsRepository {
  EventsRepository({SupabaseClient? client})
      : _client = client ?? SupabaseManager.client;

  final SupabaseClient? _client;

  bool get isRemoteEnabled => _client != null;

  Future<List<CulturalEvent>> fetchUpcomingEvents() async {
    final client = _client;
    if (client == null) {
      return sampleEvents;
    }

    try {
      final response = await client
          .from('cultural_events')
          .select(
            'id, title, date_label, location, description, additional_detail, mode, start_at, end_at, tags, cta_label, cta_note, background_colors, hero_image_url',
          )
          .order('start_at', ascending: true);

      return response
          .whereType<Map<String, dynamic>>()
          .map(_mapEvent)
          .toList(growable: false);
    } on PostgrestException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Failed to load cultural events from Supabase',
          name: 'EventsRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleEvents;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Unexpected error loading cultural events',
          name: 'EventsRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return sampleEvents;
    }
  }

  CulturalEvent _mapEvent(Map<String, dynamic> row) {
    final tagsValue = row['tags'];
    final tags = <LocalizedText>[];
    if (tagsValue is List) {
      for (final item in tagsValue) {
        tags.add(_parseLocalized(item));
      }
    }

    final colorsValue = row['background_colors'];
    final List<String> colors;
    if (colorsValue is List) {
      colors = colorsValue.whereType<String>().toList(growable: false);
    } else {
      colors = const <String>[];
    }

    return CulturalEvent(
      id: row['id']?.toString() ?? '',
      title: _parseLocalized(row['title']),
      dateLabel: _parseLocalized(row['date_label']),
      location: _parseLocalized(row['location']),
      description: _parseLocalized(row['description']),
      additionalDetail: _maybeLocalized(row['additional_detail']),
      mode: modeFromString(row['mode']?.toString() ?? ''),
      startAt: DateTime.tryParse(row['start_at']?.toString() ?? '') ??
          DateTime.now(),
      endAt: row['end_at'] != null
          ? DateTime.tryParse(row['end_at'].toString())
          : null,
      tags: tags,
      ctaLabel: _parseLocalized(row['cta_label']),
      ctaNote: _parseLocalized(row['cta_note']),
      backgroundColorHex: colors,
      heroImageUrl: row['hero_image_url']?.toString(),
    );
  }

  LocalizedText? _maybeLocalized(dynamic value) {
    if (value == null) {
      return null;
    }
    return _parseLocalized(value);
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
