import 'localized_text.dart';

/// Describes the type of media rendered inside the vertical story player.
enum StoryMediaKind { video, image, post }

/// Domain model that represents an Amazigh video story in the feed.
enum VideoSource { network, asset, localFile }

class VideoPost {
  const VideoPost({
    required this.id,
    required this.videoUrl,
    this.videoSource = VideoSource.network,
    this.mediaKind = StoryMediaKind.video,
    this.imageUrl,
    this.aspectRatio,
    this.thumbnailUrl,
    this.textSlides = const <LocalizedText>[],
    this.galleryUrls = const <String>[],
    required this.title,
    required this.description,
    required this.location,
    required this.creatorName,
    required this.creatorHandle,
    required this.likes,
    required this.comments,
    required this.shares,
    this.musicTrackId,
    this.effectId,
    this.tags = const [],
    this.isLocalDraft = false,
  });

  final String id;
  final String videoUrl;
  final VideoSource videoSource;
  final StoryMediaKind mediaKind;
  final String? imageUrl;
  final double? aspectRatio;
  final String? thumbnailUrl;
  final List<LocalizedText> textSlides;
  final List<String> galleryUrls;
  final LocalizedText title;
  final LocalizedText description;
  final LocalizedText location;
  final LocalizedText creatorName;
  final String creatorHandle;
  final int likes;
  final int comments;
  final int shares;
  final String? musicTrackId;
  final String? effectId;
  final List<String> tags;
  final bool isLocalDraft;

  bool get isLocal => videoSource == VideoSource.localFile;
  bool get isVideo => mediaKind == StoryMediaKind.video;
  bool get isImage => mediaKind == StoryMediaKind.image;
  bool get isPost => mediaKind == StoryMediaKind.post;

  /// Primary media source. Falls back to [videoUrl] for backward compatibility.
  String get primaryMediaUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    if (galleryUrls.isNotEmpty && galleryUrls.first.isNotEmpty) {
      return galleryUrls.first;
    }
    return videoUrl;
  }

  VideoPost copyWith({
    String? id,
    String? videoUrl,
    VideoSource? videoSource,
    StoryMediaKind? mediaKind,
    String? imageUrl,
    double? aspectRatio,
    String? thumbnailUrl,
    List<LocalizedText>? textSlides,
    List<String>? galleryUrls,
    LocalizedText? title,
    LocalizedText? description,
    LocalizedText? location,
    LocalizedText? creatorName,
    String? creatorHandle,
    int? likes,
    int? comments,
    int? shares,
    String? musicTrackId,
    String? effectId,
    List<String>? tags,
    bool? isLocalDraft,
  }) {
    return VideoPost(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      videoSource: videoSource ?? this.videoSource,
      mediaKind: mediaKind ?? this.mediaKind,
      imageUrl: imageUrl ?? this.imageUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      textSlides: textSlides ?? this.textSlides,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      creatorName: creatorName ?? this.creatorName,
      creatorHandle: creatorHandle ?? this.creatorHandle,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      musicTrackId: musicTrackId ?? this.musicTrackId,
      effectId: effectId ?? this.effectId,
      tags: tags ?? this.tags,
      isLocalDraft: isLocalDraft ?? this.isLocalDraft,
    );
  }
}
