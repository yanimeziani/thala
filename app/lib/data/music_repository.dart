import '../models/music_track.dart';
import 'sample_tracks.dart';

class MusicRepository {
  MusicRepository();

  bool get isRemoteEnabled => false;

  Future<List<MusicTrack>> fetchTracks() async {
    // Backend integration pending - return sample data
    return sampleTracks;
  }
}
