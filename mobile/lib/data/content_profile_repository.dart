import 'dart:developer' as developer;
import '../models/content_profile.dart';
import '../services/api_client.dart';

class ContentProfileRepository {
  ContentProfileRepository({this.accessToken});

  final String? accessToken;

  bool get isRemoteEnabled => accessToken != null && accessToken!.isNotEmpty;

  Future<Map<String, ContentProfile>> fetchProfiles() async {
    if (!isRemoteEnabled) {
      developer.log('Content profiles: No auth token, returning empty map', name: 'ContentProfileRepository');
      return {};
    }

    try {
      final response = await ApiClient.get(
        '/content/profiles',
        headers: ApiClient.authHeaders(accessToken!),
      );

      final profiles = <String, ContentProfile>{};
      if (response['profiles'] is Map) {
        (response['profiles'] as Map).forEach((key, value) {
          profiles[key.toString()] = _mapProfile(value as Map<String, dynamic>);
        });
      }

      return profiles;
    } catch (e) {
      developer.log('Failed to fetch content profiles: $e', name: 'ContentProfileRepository', level: 1000);
      return {};
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
