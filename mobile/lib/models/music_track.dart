class MusicTrack {
  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.duration,
    this.previewUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final Duration duration;
  final String? previewUrl;
}
