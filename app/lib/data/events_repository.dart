import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cultural_event.dart';
import '../models/localized_text.dart';
import '../services/backend_auth_service.dart';
import 'sample_events.dart';

class EventsRepository {
  EventsRepository({this.accessToken});

  final String? accessToken;

  bool get isRemoteEnabled => true;

  Future<List<CulturalEvent>> fetchUpcomingEvents() async {
    try {
      final url = Uri.parse('${BackendAuthService.apiUrl}/events?upcoming_only=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => _eventFromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Fallback to sample data on error
        return sampleEvents;
      }
    } catch (e) {
      // Fallback to sample data on network error
      return sampleEvents;
    }
  }

  Future<void> toggleInterest(String eventId) async {
    if (accessToken == null) {
      throw Exception('Must be authenticated to toggle interest');
    }

    try {
      final url = Uri.parse('${BackendAuthService.apiUrl}/events/$eventId/interested');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle interest');
      }
    } catch (e) {
      rethrow;
    }
  }

  CulturalEvent _eventFromJson(Map<String, dynamic> json) {
    return CulturalEvent(
      id: json['id'] as String,
      title: _localizedTextFromJson(json['title']),
      dateLabel: _localizedTextFromJson(json['date_label']),
      location: _localizedTextFromJson(json['location']),
      description: _localizedTextFromJson(json['description']),
      additionalDetail: json['additional_detail'] != null
          ? _localizedTextFromJson(json['additional_detail'])
          : null,
      mode: modeFromString(json['mode'] as String),
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => _localizedTextFromJson(tag as Map<String, dynamic>))
              .toList() ??
          [],
      ctaLabel: _localizedTextFromJson(json['cta_label']),
      ctaNote: _localizedTextFromJson(json['cta_note']),
      backgroundColorHex: (json['background_colors'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      heroImageUrl: json['hero_image_url'] as String?,
      hostName: json['host_name'] as String?,
      hostHandle: json['host_handle'] as String?,
      isHostVerified: json['is_host_verified'] as bool? ?? false,
      interestedCount: json['interested_count'] as int? ?? 0,
    );
  }

  LocalizedText _localizedTextFromJson(Map<String, dynamic> json) {
    return LocalizedText(
      en: json['en'] as String? ?? '',
      fr: json['fr'] as String? ?? '',
    );
  }
}
