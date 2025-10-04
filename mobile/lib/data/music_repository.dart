import 'dart:developer' as developer;
import '../models/music_track.dart';
import '../services/api_client.dart';

class MusicRepository {
  MusicRepository({this.accessToken});

  final String? accessToken;

  bool get isRemoteEnabled => accessToken != null && accessToken!.isNotEmpty;

  Future<List<MusicTrack>> fetchTracks() async {
    if (!isRemoteEnabled) {
      developer.log('Music: No auth token, returning empty list', name: 'MusicRepository');
      return [];
    }

    try {
      final response = await ApiClient.getList(
        '/music/tracks',
        headers: ApiClient.authHeaders(accessToken!),
      );

      return response
          .map((json) => MusicTrack.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Failed to fetch music tracks: $e', name: 'MusicRepository', level: 1000);
      return [];
    }
  }
}
