import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../data/effect_presets.dart';
import '../models/localized_text.dart';
import '../models/music_track.dart';
import '../models/video_effect.dart';
import '../models/video_post.dart';

class CreatePostController extends ChangeNotifier {
  CreatePostController({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  XFile? _selectedFile;
  VideoEffect _selectedEffect = videoEffects.first;
  MusicTrack? _selectedTrack;
  bool _isProcessing = false;
  double? _cachedAspectRatio;

  File? get videoFile =>
      _selectedFile == null ? null : File(_selectedFile!.path);
  String? get videoPath => _selectedFile?.path;
  VideoEffect get selectedEffect => _selectedEffect;
  MusicTrack? get selectedTrack => _selectedTrack;
  bool get hasVideo => _selectedFile != null;
  bool get isProcessing => _isProcessing;
  double? get cachedAspectRatio => _cachedAspectRatio;

  Future<XFile?> pickVideo(ImageSource source) async {
    try {
      final file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 3),
      );
      if (file == null) {
        return null;
      }
      _selectedFile = file;
      notifyListeners();
      return file;
    } catch (error, stackTrace) {
      debugPrint('Failed to pick video: $error\n$stackTrace');
      rethrow;
    }
  }

  void setVideoFile(XFile file) {
    _selectedFile = file;
    _cachedAspectRatio = null; // Clear cached aspect ratio when video changes
    notifyListeners();
  }

  /// Extracts aspect ratio from the video file
  Future<double?> _extractAspectRatio(File videoFile) async {
    if (_cachedAspectRatio != null) {
      return _cachedAspectRatio;
    }

    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      final size = controller.value.size;
      final aspectRatio = size.width > 0 && size.height > 0
          ? size.width / size.height
          : null;

      await controller.dispose();

      _cachedAspectRatio = aspectRatio;
      return aspectRatio;
    } catch (error) {
      debugPrint('Failed to extract aspect ratio: $error');
      return null;
    }
  }

  void selectEffect(VideoEffect effect) {
    if (_selectedEffect.id == effect.id) {
      return;
    }
    _selectedEffect = effect;
    notifyListeners();
  }

  void selectTrack(MusicTrack? track) {
    if (_selectedTrack?.id == track?.id) {
      return;
    }
    _selectedTrack = track;
    notifyListeners();
  }

  void clearVideo() {
    if (_selectedFile == null) {
      return;
    }
    _selectedFile = null;
    _cachedAspectRatio = null;
    notifyListeners();
  }

  Future<VideoPost> buildPost({
    required String titleEn,
    required String titleFr,
    required String descriptionEn,
    required String descriptionFr,
    required String locationEn,
    required String locationFr,
    required String creatorNameEn,
    required String creatorNameFr,
    required String creatorHandle,
    List<String> tags = const <String>[],
  }) async {
    final file = videoFile;
    if (file == null) {
      throw StateError('A video must be selected before publishing.');
    }

    _setProcessing(true);
    try {
      final id = 'local-${DateTime.now().millisecondsSinceEpoch}';
      final effectId = _selectedEffect.id == videoEffects.first.id
          ? null
          : _selectedEffect.id;

      // Extract aspect ratio from video
      final aspectRatio = await _extractAspectRatio(file);

      return VideoPost(
        id: id,
        videoUrl: file.path,
        videoSource: VideoSource.localFile,
        aspectRatio: aspectRatio,
        title: LocalizedText(en: titleEn, fr: titleFr),
        description: LocalizedText(en: descriptionEn, fr: descriptionFr),
        location: LocalizedText(en: locationEn, fr: locationFr),
        creatorName: LocalizedText(en: creatorNameEn, fr: creatorNameFr),
        creatorHandle: creatorHandle,
        likes: 0,
        comments: 0,
        shares: 0,
        tags: tags.isEmpty ? const <String>[] : List<String>.from(tags),
        musicTrackId: _selectedTrack?.id,
        effectId: effectId,
        isLocalDraft: true,
      );
    } finally {
      _setProcessing(false);
    }
  }

  void reset() {
    _selectedFile = null;
    _selectedTrack = null;
    _selectedEffect = videoEffects.first;
    _cachedAspectRatio = null;
    _setProcessing(false);
    notifyListeners();
  }

  void _setProcessing(bool value) {
    if (_isProcessing == value) {
      return;
    }
    _isProcessing = value;
    notifyListeners();
  }
}
