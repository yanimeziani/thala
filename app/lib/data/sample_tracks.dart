import '../models/music_track.dart';

const sampleTracks = <MusicTrack>[
  MusicTrack(
    id: 'imzad-dawn',
    title: 'Imzad Dawn',
    artist: 'Tassili Ensemble',
    artworkUrl:
        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=600&q=80',
    duration: Duration(minutes: 4, seconds: 12),
    previewUrl: 'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
  ),
  MusicTrack(
    id: 'rif-waves',
    title: 'Rif Coast Waves',
    artist: 'Taziri',
    artworkUrl:
        'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=600&q=80',
    duration: Duration(minutes: 5, seconds: 8),
    previewUrl: 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3',
  ),
  MusicTrack(
    id: 'kabyle-strings',
    title: 'Kabyle Strings',
    artist: 'Ayen Collective',
    artworkUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80',
    duration: Duration(minutes: 3, seconds: 46),
    previewUrl: 'https://samplelib.com/lib/preview/mp3/sample-9s.mp3',
  ),
  MusicTrack(
    id: 'desert-heartbeat',
    title: 'Desert Heartbeat',
    artist: 'Amayas',
    artworkUrl:
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=600&q=80',
    duration: Duration(minutes: 6, seconds: 2),
    previewUrl: 'https://samplelib.com/lib/preview/mp3/sample-12s.mp3',
  ),
];

MusicTrack? trackForId(String? id) {
  if (id == null) {
    return null;
  }
  for (final track in sampleTracks) {
    if (track.id == id) {
      return track;
    }
  }
  return null;
}
