import '../models/content_profile.dart';
import 'sample_content_profiles.dart';

class ContentProfileRepository {
  ContentProfileRepository();

  bool get isRemoteEnabled => false;

  Future<Map<String, ContentProfile>> fetchProfiles() async {
    // Backend integration pending - return sample data
    return sampleContentProfiles;
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
