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

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    final durationSeconds = json['duration'] as int? ?? 0;
    return MusicTrack(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      artworkUrl: json['artwork_url'] as String? ?? '',
      duration: Duration(seconds: durationSeconds),
      previewUrl: json['preview_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artwork_url': artworkUrl,
      'duration': duration.inSeconds,
      'preview_url': previewUrl,
    };
  }
}
