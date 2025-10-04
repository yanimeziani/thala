import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../app/app_theme.dart';
import '../../controllers/create_post_controller.dart';
import '../../data/effect_presets.dart';
import '../../l10n/app_translations.dart';
import '../../models/video_effect.dart';
import '../../models/video_post.dart';
import '../../models/music_track.dart';
import '../../ui/widgets/thala_snackbar.dart';
import '../../controllers/music_library.dart';

enum _CreateStage { capture, review }

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  static Future<VideoPost?> push(BuildContext context) {
    return Navigator.of(context).push<VideoPost>(
      MaterialPageRoute<VideoPost>(
        builder: (_) => ChangeNotifierProvider<CreatePostController>(
          create: (_) => CreatePostController(),
          child: const _CreatePostView(),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _CreatePostView extends StatefulWidget {
  const _CreatePostView();

  @override
  State<_CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<_CreatePostView>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _creatorNameController = TextEditingController(text: 'You');
  final _creatorHandleController = TextEditingController(text: '@you');

  // Language toggle: 'en' or 'fr'
  String _selectedLanguage = 'en';

  VideoPlayerController? _videoController;
  Future<void>? _videoInitialization;
  String? _currentVideoPath;

  _CreateStage _stage = _CreateStage.capture;
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  Future<void>? _cameraInitialization;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  FlashMode _flashMode = FlashMode.off;
  String? _cameraErrorMessage;
  bool _showEffectTray = false;

  bool _isRecording = false;
  Duration _recordedDuration = Duration.zero;
  Timer? _recordingTicker;
  DateTime? _recordingStartedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.watch<CreatePostController>();
    final path = controller.videoPath;
    if (path != _currentVideoPath) {
      _swapVideoController(path);
      if (path != null && _stage != _CreateStage.review) {
        setState(() {
          _stage = _CreateStage.review;
          _showEffectTray = false;
        });
        _pauseCameraPreview();
      }
      if (path == null && _stage == _CreateStage.review) {
        setState(() => _stage = _CreateStage.capture);
        _resumeCameraPreview();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.pausePreview();
    } else if (state == AppLifecycleState.resumed &&
        _stage == _CreateStage.capture) {
      controller.resumePreview();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _creatorNameController.dispose();
    _creatorHandleController.dispose();
    _videoController?.dispose();
    _recordingTicker?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreatePostController>();
    final mediaQuery = MediaQuery.of(context);
    final effect = controller.selectedEffect;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        child: _stage == _CreateStage.capture
            ? _buildCaptureStage(context, mediaQuery, effect, controller)
            : _buildReviewStage(context, mediaQuery, effect, controller),
      ),
    );
  }

  Widget _buildCaptureStage(
    BuildContext context,
    MediaQueryData mediaQuery,
    VideoEffect effect,
    CreatePostController controller,
  ) {
    String tr(AppText key) => AppTranslations.of(context, key);

    final palette = context.thalaPalette;
    final MusicTrack? track = controller.selectedTrack;

    return Stack(
      key: const ValueKey<_CreateStage>(_CreateStage.capture),
      children: [
        Positioned.fill(child: _buildCameraPreview(effect)),
        // Top controls
        Positioned(
          top: mediaQuery.padding.top + 12,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassIconButton(
                icon: Icons.close,
                tooltip: tr(AppText.createCaptureClose),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              _GlassIconButton(
                icon: Icons.cameraswitch,
                tooltip: tr(AppText.createCaptureFlip),
                onPressed: _switchCamera,
              ),
            ],
          ),
        ),
        // Right action rail
        Positioned(
          right: 16,
          bottom: 180,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleIconButton(
                icon: _flashIconForMode(_flashMode),
                onTap: _toggleFlashMode,
              ),
              const SizedBox(height: 20),
              _CircleIconButton(
                icon: Icons.auto_awesome,
                onTap: () => setState(() => _showEffectTray = !_showEffectTray),
              ),
              const SizedBox(height: 20),
              _CircleIconButton(
                icon: Icons.music_note,
                onTap: () => _showMusicPeek(context),
              ),
            ],
          ),
        ),
        // Bottom controls
        Positioned(
          bottom: mediaQuery.padding.bottom + 24,
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (_isRecording)
                _RecordingTicker(duration: _recordedDuration),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleIconButton(
                    icon: Icons.photo_library_outlined,
                    onTap: _pickFromGallery,
                    size: 48,
                  ),
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: _RecordButton(isRecording: _isRecording),
                  ),
                  _CircleIconButton(
                    icon: Icons.stop,
                    onTap: _isRecording ? _stopRecording : null,
                    size: 48,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Effect tray overlay
        if (_showEffectTray)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _EffectTray(
              visible: _showEffectTray,
              selectedEffect: effect,
              onSelect: (value) {
                setState(() => _showEffectTray = false);
                controller.selectEffect(value);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReviewStage(
    BuildContext context,
    MediaQueryData mediaQuery,
    VideoEffect effect,
    CreatePostController controller,
  ) {
    final padding = mediaQuery.padding;

    return Stack(
      key: const ValueKey<_CreateStage>(_CreateStage.review),
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF050A10), Color(0xFF0C141C)],
              ),
            ),
            child: _StoryPreview(
              controller: controller,
              videoController: _videoController,
              initialization: _videoInitialization,
              effect: effect,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: Icons.arrow_back,
                    tooltip: AppTranslations.of(
                      context,
                      AppText.createBackToCamera,
                    ),
                    onPressed: () {
                      controller.clearVideo();
                      _swapVideoController(null);
                      setState(() => _stage = _CreateStage.capture);
                      _resumeCameraPreview();
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        // Big quick publish button at bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick publish button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: controller.isProcessing
                          ? null
                          : () => _handlePublish(controller),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle),
                                const SizedBox(width: 12),
                                Text(
                                  'Publish',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: padding.top + 96,
          child: Column(
            children: [
              _GlassIconButton(
                icon: Icons.music_note,
                tooltip: AppTranslations.of(context, AppText.createChangeTrack),
                onPressed: () => _showMusicPeek(context),
              ),
              const SizedBox(height: 16),
              _GlassIconButton(
                icon: Icons.edit,
                tooltip: AppTranslations.of(context, AppText.createReplaceClip),
                onPressed: _showVideoSourceSheet,
              ),
              const SizedBox(height: 16),
              _GlassIconButton(
                icon: Icons.play_arrow,
                tooltip: AppTranslations.of(context, AppText.createPreview),
                onPressed: () {
                  final player = _videoController;
                  if (player == null) {
                    return;
                  }
                  if (player.value.isPlaying) {
                    player.pause();
                  } else {
                    player
                      ..seekTo(Duration.zero)
                      ..play();
                  }
                },
              ),
            ],
          ),
        ),
        _DetailSheet(
          formKey: _formKey,
          titleController: _titleController,
          descriptionController: _descriptionController,
          locationController: _locationController,
          creatorNameController: _creatorNameController,
          creatorHandleController: _creatorHandleController,
          selectedLanguage: _selectedLanguage,
          onLanguageChanged: (lang) => setState(() => _selectedLanguage = lang),
          isPublishing: controller.isProcessing,
          onPublish: () => _handlePublish(controller),
          onShowEffects: () =>
              setState(() => _showEffectTray = !_showEffectTray),
        ),
        _EffectTray(
          visible: _showEffectTray,
          selectedEffect: effect,
          onSelect: (value) {
            setState(() => _showEffectTray = false);
            controller.selectEffect(value);
          },
        ),
      ],
    );
  }

  Widget _buildCameraPreview(VideoEffect effect) {
    final controller = _cameraController;
    final initialization = _cameraInitialization;

    if (controller == null || initialization == null) {
      return const ColoredBox(color: Colors.black);
    }

    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              AppTranslations.of(context, AppText.createCameraUnavailable),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
          );
        }

        Widget preview = CameraPreview(controller);
        final previewSize = controller.value.previewSize;

        // Force 9:16 aspect ratio crop
        if (previewSize != null &&
            previewSize.width != 0 &&
            previewSize.height != 0) {
          final cameraPreview = preview;
          final orientation = MediaQuery.of(context).orientation;
          double previewWidth = previewSize.width;
          double previewHeight = previewSize.height;

          final bool shouldSwapDimensions =
              (orientation == Orientation.portrait &&
                  previewWidth > previewHeight) ||
              (orientation == Orientation.landscape &&
                  previewHeight > previewWidth);
          if (shouldSwapDimensions) {
            final double temp = previewWidth;
            previewWidth = previewHeight;
            previewHeight = temp;
          }

          // Crop to 9:16 aspect ratio
          preview = Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: previewWidth,
                  height: previewHeight,
                  child: cameraPreview,
                ),
              ),
            ),
          );
        }

        if (effect.filter != null) {
          preview = ColorFiltered(colorFilter: effect.filter!, child: preview);
        }
        if (effect.overlay != null) {
          preview = Stack(
            fit: StackFit.expand,
            children: [
              preview,
              DecoratedBox(decoration: BoxDecoration(gradient: effect.overlay)),
            ],
          );
        }

        return preview;
      },
    );
  }

  void _prepareCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) {
        return;
      }
      setState(() {
        _cameras = cameras;
        _cameraErrorMessage = null;
      });
      if (cameras.isEmpty) {
        setState(() {
          _cameraErrorMessage = AppTranslations.of(
            context,
            AppText.createCameraNotFound,
          );
        });
        return;
      }
      final preferred = _findCamera(_lensDirection) ?? cameras.first;
      await _initializeCamera(preferred);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraErrorMessage = AppTranslations.of(
          context,
          AppText.createCameraError,
        ).replaceFirst('{error}', '$error');
      });
    }
  }

  Future<void> _initializeCamera(CameraDescription description) async {
    _recordingTicker?.cancel();
    await _cameraController?.dispose();

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
    );

    setState(() {
      _cameraController = controller;
      _cameraInitialization = controller.initialize().then((_) async {
        if (!mounted) {
          return;
        }
        try {
          await controller.setFlashMode(_flashMode);
        } catch (_) {
          if (mounted) {
            setState(() => _flashMode = FlashMode.off);
          }
        }
        setState(() => _lensDirection = description.lensDirection);
      });
    });
  }

  CameraDescription? _findCamera(CameraLensDirection direction) {
    final cameras = _cameras;
    if (cameras == null) {
      return null;
    }
    for (final camera in cameras) {
      if (camera.lensDirection == direction) {
        return camera;
      }
    }
    return null;
  }

  Future<void> _switchCamera() async {
    final cameras = _cameras;
    if (cameras == null || cameras.length < 2) {
      _showSoonToast(
        context,
        AppTranslations.of(context, AppText.createCameraSingle),
      );
      return;
    }
    final desired = _lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final next =
        _findCamera(desired) ??
        cameras.firstWhere((cam) => cam != _cameraController?.description);
    await _initializeCamera(next);
  }

  Future<void> _toggleFlashMode() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final next = _flashMode == FlashMode.off
        ? FlashMode.auto
        : _flashMode == FlashMode.auto
        ? FlashMode.torch
        : FlashMode.off;
    try {
      await controller.setFlashMode(next);
      setState(() => _flashMode = next);
    } catch (error) {
      final message = AppTranslations.of(
        context,
        AppText.createFlashUnavailable,
      ).replaceFirst('{error}', '$error');
      _showError(message);
    }
  }

  void _pauseCameraPreview() {
    final controller = _cameraController;
    if (controller == null) {
      return;
    }
    if (!controller.value.isInitialized) {
      return;
    }
    controller.pausePreview();
  }

  void _resumeCameraPreview() {
    final controller = _cameraController;
    if (controller == null) {
      return;
    }
    if (!controller.value.isInitialized) {
      return;
    }
    controller.resumePreview();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (controller.value.isRecordingVideo) {
      return;
    }
    try {
      await controller.prepareForVideoRecording();
    } catch (_) {
      // prepare may not be supported on all platforms, ignore.
    }
    try {
      await controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordedDuration = Duration.zero;
        _recordingStartedAt = DateTime.now();
      });
      _recordingTicker?.cancel();
      _recordingTicker = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => _tickRecording(),
      );
    } catch (error) {
      setState(() {
        _isRecording = false;
        _recordedDuration = Duration.zero;
      });
      final message = AppTranslations.of(
        context,
        AppText.createRecordingStartFailed,
      ).replaceFirst('{error}', '$error');
      _showError(message);
    }
  }

  Future<void> _stopRecording() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isRecordingVideo) {
      return;
    }
    try {
      final file = await controller.stopVideoRecording();
      _recordingTicker?.cancel();
      setState(() {
        _isRecording = false;
        _recordedDuration = Duration.zero;
      });
      await _handleClipReady(file);
    } catch (error) {
      final message = AppTranslations.of(
        context,
        AppText.createRecordingFailed,
      ).replaceFirst('{error}', '$error');
      _showError(message);
    }
  }

  void _tickRecording() {
    final startedAt = _recordingStartedAt;
    if (!_isRecording || startedAt == null) {
      return;
    }
    setState(() {
      _recordedDuration = DateTime.now().difference(startedAt);
    });
  }

  Future<void> _handleClipReady(XFile file) async {
    if (!mounted) {
      return;
    }
    context.read<CreatePostController>().setVideoFile(file);
    _swapVideoController(file.path);
    setState(() {
      _stage = _CreateStage.review;
      _showEffectTray = false;
    });
    _pauseCameraPreview();
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await context.read<CreatePostController>().pickVideo(
        ImageSource.gallery,
      );
      if (file != null) {
        await _handleClipReady(file);
      }
    } catch (error) {
      final message = AppTranslations.of(
        context,
        AppText.createStoryVideoSelectionError,
      ).replaceFirst('{error}', '$error');
      _showError(message);
    }
  }

  Future<void> _showVideoSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white70,
                ),
                title: Text(
                  AppTranslations.of(
                    context,
                    AppText.createStoryChooseFromLibrary,
                  ),
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.videocam_outlined,
                  color: Colors.white70,
                ),
                title: Text(
                  AppTranslations.of(context, AppText.createStoryRecordAgain),
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || source == null) {
      return;
    }

    if (source == ImageSource.camera) {
      context.read<CreatePostController>().clearVideo();
      _swapVideoController(null);
      setState(() => _stage = _CreateStage.capture);
      _resumeCameraPreview();
      return;
    }

    await _pickFromGallery();
  }

  void _swapVideoController(String? path) {
    _currentVideoPath = path;
    final previous = _videoController;
    previous?.pause();
    previous?.dispose();

    if (path == null) {
      setState(() {
        _videoController = null;
        _videoInitialization = null;
      });
      return;
    }

    final file = File(path);
    final controller = VideoPlayerController.file(file)
      ..setLooping(true)
      ..setVolume(0.7);

    setState(() {
      _videoController = controller;
      _videoInitialization = controller.initialize().then((_) {
        if (mounted) {
          controller.play();
          setState(() {});
        }
      });
    });
  }

  void _showMusicPeek(BuildContext context) {
    final controller = context.read<CreatePostController>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTranslations.of(
                    context,
                    AppText.createMusicSuggestionsTitle,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                for (final track in context.read<MusicLibrary>().tracks)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(track.artworkUrl),
                    ),
                    title: Text(
                      track.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      track.artist,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: controller.selectedTrack?.id == track.id
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                    onTap: () {
                      controller.selectTrack(track);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      buildThalaSnackBar(
        context,
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        badgeColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.24),
        semanticsLabel: message,
      ),
    );
  }

  void _showSoonToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      buildThalaSnackBar(
        context,
        icon: Icons.auto_awesome,
        iconColor: Theme.of(context).colorScheme.secondary,
        semanticsLabel: message,
      ),
    );
  }

  IconData _flashIconForMode(FlashMode mode) {
    switch (mode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.torch:
        return Icons.flash_on;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
      default:
        return Icons.flash_off;
    }
  }

  Future<void> _handlePublish(CreatePostController controller) async {
    if (!controller.hasVideo) {
      _showError(
        AppTranslations.of(context, AppText.createStorySelectVideoFirst),
      );
      return;
    }

    try {
      // Auto-generate defaults for quick publish
      final now = DateTime.now();
      final defaultTitle = 'Story ${now.month}/${now.day}';
      final defaultCreator = 'Creator';
      final defaultLocation = _selectedLanguage == 'fr'
          ? AppTranslations.of(context, AppText.createStoryDefaultLocationFr)
          : AppTranslations.of(context, AppText.createStoryDefaultLocationEn);

      final title = _titleController.text.trim().isEmpty
          ? defaultTitle
          : _titleController.text.trim();

      final description = _descriptionController.text.trim();

      final location = _locationController.text.trim().isEmpty
          ? defaultLocation
          : _locationController.text.trim();

      final creatorName = _creatorNameController.text.trim().isEmpty
          ? defaultCreator
          : _creatorNameController.text.trim();

      final creatorHandle = _creatorHandleController.text.trim().isEmpty
          ? '@creator'
          : _creatorHandleController.text.trim();

      // Use the same text for both languages (users can add translations later via backend)
      final post = await controller.buildPost(
        titleEn: _selectedLanguage == 'en' ? title : '',
        titleFr: _selectedLanguage == 'fr' ? title : '',
        descriptionEn: _selectedLanguage == 'en' ? description : '',
        descriptionFr: _selectedLanguage == 'fr' ? description : '',
        locationEn: _selectedLanguage == 'en' ? location : defaultLocation,
        locationFr: _selectedLanguage == 'fr' ? location : defaultLocation,
        creatorNameEn: _selectedLanguage == 'en' ? creatorName : '',
        creatorNameFr: _selectedLanguage == 'fr' ? creatorName : '',
        creatorHandle: creatorHandle,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(post);
    } catch (error) {
      final template = AppTranslations.of(
        context,
        AppText.createStoryPublishError,
      );
      _showError(template.replaceFirst('{error}', '$error'));
    }
  }
}

class _StoryPreview extends StatelessWidget {
  const _StoryPreview({
    required this.controller,
    required this.videoController,
    required this.initialization,
    required this.effect,
  });

  final CreatePostController controller;
  final VideoPlayerController? videoController;
  final Future<void>? initialization;
  final VideoEffect effect;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.black),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (videoController != null && initialization != null)
                  FutureBuilder<void>(
                    future: initialization,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      Widget player = VideoPlayer(videoController!);
                      if (effect.filter != null) {
                        player = ColorFiltered(
                          colorFilter: effect.filter!,
                          child: player,
                        );
                      }
                      if (effect.overlay != null) {
                        player = Stack(
                          fit: StackFit.expand,
                          children: [
                            player,
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: effect.overlay,
                              ),
                            ),
                          ],
                        );
                      }
                      return player;
                    },
                  )
                else
                  const _ReviewPlaceholder(),
                Positioned(
                  bottom: 16 + media.padding.bottom,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedTrack?.title ??
                            AppTranslations.of(
                              context,
                              AppText.createMusicNoTrackSelected,
                            ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (controller.selectedTrack != null)
                        Text(
                          controller.selectedTrack!.artist,
                          style: const TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewPlaceholder extends StatelessWidget {
  const _ReviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppTranslations.of(context, AppText.createReviewPlaceholder),
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}

class _RecordingTicker extends StatelessWidget {
  const _RecordingTicker({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.isRecording});

  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isRecording ? 84 : 96,
      height: isRecording ? 84 : 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRecording ? Colors.redAccent : Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 8),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isRecording ? 42 : 80,
        height: isRecording ? 42 : 80,
        decoration: BoxDecoration(
          color: isRecording ? Colors.white : Colors.redAccent,
          borderRadius: BorderRadius.circular(isRecording ? 12 : 80),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 54,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null
            ? Colors.black.withOpacity(0.15)
            : Colors.black.withOpacity(0.32),
        ),
        child: Icon(
          icon,
          color: onTap == null
            ? Colors.white.withOpacity(0.3)
            : Colors.white,
          size: size * 0.45,
        ),
      ),
    );
  }
}

class _BottomPillButton extends StatelessWidget {
  const _BottomPillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = dense
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 12);
    final double iconSize = dense ? 17 : 18;
    final TextStyle textStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(color: Colors.white);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: iconSize),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CaptureTopBar extends StatelessWidget {
  const _CaptureTopBar({
    required this.useLiquidGlass,
    required this.closeTooltip,
    required this.title,
    required this.flipTooltip,
    required this.effectsTooltip,
    required this.onClose,
    required this.onFlipCamera,
    required this.onToggleLenses,
  });

  final bool useLiquidGlass;
  final String closeTooltip;
  final String title;
  final String flipTooltip;
  final String effectsTooltip;
  final VoidCallback onClose;
  final VoidCallback onFlipCamera;
  final VoidCallback onToggleLenses;

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;
    final theme = Theme.of(context);

    final header = Row(
      children: [
        _GlassIconButton(
          icon: Icons.close,
          tooltip: closeTooltip,
          onPressed: onClose,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.inverseText,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Swipe up, instant share',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.inverseTextSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _GlassIconButton(
          icon: Icons.auto_awesome,
          tooltip: effectsTooltip,
          onPressed: onToggleLenses,
        ),
        const SizedBox(width: 12),
        _GlassIconButton(
          icon: Icons.cameraswitch,
          tooltip: flipTooltip,
          onPressed: onFlipCamera,
        ),
      ],
    );

    Widget surface = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: header,
    );

    if (useLiquidGlass) {
      surface = LiquidGlass(
        glassContainsChild: false,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(28),
        ),
        settings: const LiquidGlassSettings(
          thickness: 9,
          blur: 18,
          glassColor: Color(0x28FFFFFF),
          ambientStrength: 0.24,
          lightIntensity: 1.08,
          blend: 18,
          saturation: 1.02,
          lightness: 1.03,
        ),
        child: surface,
      );
    }

    return surface;
  }
}

class _CaptureSoundBadge extends StatelessWidget {
  const _CaptureSoundBadge({
    required this.useLiquidGlass,
    required this.palette,
    required this.title,
    required this.subtitle,
    this.artworkUrl,
    required this.onTap,
  });

  final bool useLiquidGlass;
  final ThalaPalette palette;
  final String title;
  final String subtitle;
  final String? artworkUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget contents = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surfaceBright.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (artworkUrl != null)
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(artworkUrl!))
          else
            CircleAvatar(
              radius: 20,
              backgroundColor: palette.surfaceSubtle.withValues(alpha: 0.4),
              child: Icon(Icons.music_note, color: palette.textSecondary),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: palette.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right, color: palette.iconMuted, size: 20),
        ],
      ),
    );

    if (useLiquidGlass) {
      contents = LiquidGlass(
        glassContainsChild: false,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(24),
        ),
        settings: const LiquidGlassSettings(
          thickness: 7,
          blur: 16,
          glassColor: Color(0x1FFFFFFF),
          ambientStrength: 0.22,
          lightIntensity: 1.05,
          blend: 14,
          saturation: 1.02,
          lightness: 1.02,
        ),
        child: contents,
      );
    }

    return GestureDetector(onTap: onTap, child: contents);
  }
}

class _CaptureAction {
  const _CaptureAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _CaptureActionRail extends StatelessWidget {
  const _CaptureActionRail({
    required this.useLiquidGlass,
    required this.palette,
    required this.actions,
  });

  final bool useLiquidGlass;
  final ThalaPalette palette;
  final List<_CaptureAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: actions
          .map(
            (action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: _CaptureActionButton(
                action: action,
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: palette.inverseTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );

    Widget surface = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: column,
    );

    if (useLiquidGlass) {
      surface = LiquidGlass(
        glassContainsChild: false,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(32),
        ),
        settings: const LiquidGlassSettings(
          thickness: 8,
          blur: 18,
          glassColor: Color(0x24FFFFFF),
          ambientStrength: 0.26,
          lightIntensity: 1.06,
          blend: 16,
          saturation: 1.02,
          lightness: 1.02,
        ),
        child: surface,
      );
    }

    return surface;
  }
}

class _CaptureActionButton extends StatelessWidget {
  const _CaptureActionButton({required this.action, required this.labelStyle});

  final _CaptureAction action;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassIconButton(
          icon: action.icon,
          tooltip: action.label,
          onPressed: action.onTap,
        ),
        const SizedBox(height: 6),
        Text(action.label, style: labelStyle, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CaptureFooter extends StatelessWidget {
  const _CaptureFooter({
    required this.useLiquidGlass,
    required this.isRecording,
    required this.recordedDuration,
    required this.helperText,
    required this.galleryLabel,
    required this.timerLabel,
    required this.effectsLabel,
    required this.modes,
    required this.selectedModeIndex,
    required this.onModeSelected,
    required this.onRecordTap,
    required this.onGalleryTap,
    required this.onTimerTap,
    required this.selectedEffect,
    required this.onEffectSelected,
    required this.onOpenEffectLibrary,
  });

  final bool useLiquidGlass;
  final bool isRecording;
  final Duration recordedDuration;
  final String helperText;
  final String galleryLabel;
  final String timerLabel;
  final String effectsLabel;
  final List<_CaptureModeData> modes;
  final int selectedModeIndex;
  final ValueChanged<int> onModeSelected;
  final VoidCallback onRecordTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onTimerTap;
  final VideoEffect selectedEffect;
  final ValueChanged<VideoEffect> onEffectSelected;
  final VoidCallback onOpenEffectLibrary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 420;

        Widget buildRecordButton() => GestureDetector(
          onTap: onRecordTap,
          child: _RecordButton(isRecording: isRecording),
        );

        Widget buildGalleryButton() => _BottomPillButton(
          icon: Icons.photo_library_outlined,
          label: galleryLabel,
          onPressed: onGalleryTap,
          dense: isCompact,
        );

        Widget buildTimerButton() => _BottomPillButton(
          icon: Icons.hourglass_bottom,
          label: timerLabel,
          onPressed: onTimerTap,
          dense: isCompact,
        );

        final Widget captureControls = isCompact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildRecordButton(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: buildGalleryButton(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildTimerButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildGalleryButton(),
                  buildRecordButton(),
                  buildTimerButton(),
                ],
              );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: isRecording ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _RecordingTicker(duration: recordedDuration),
            ),
            const SizedBox(height: 16),
            captureControls,
            const SizedBox(height: 18),
            Text(
              helperText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            _LensCarousel(
              useLiquidGlass: useLiquidGlass,
              palette: palette,
              effectsLabel: effectsLabel,
              selectedEffect: selectedEffect,
              onEffectSelected: onEffectSelected,
              onOpenEffectLibrary: onOpenEffectLibrary,
            ),
            const SizedBox(height: 16),
            _CaptureModeSwitcher(
              useLiquidGlass: useLiquidGlass,
              modes: modes,
              selectedIndex: selectedModeIndex,
              onModeSelected: onModeSelected,
            ),
          ],
        );
      },
    );
  }
}

class _LensCarousel extends StatelessWidget {
  const _LensCarousel({
    required this.useLiquidGlass,
    required this.palette,
    required this.effectsLabel,
    required this.selectedEffect,
    required this.onEffectSelected,
    required this.onOpenEffectLibrary,
  });

  final bool useLiquidGlass;
  final ThalaPalette palette;
  final String effectsLabel;
  final VideoEffect selectedEffect;
  final ValueChanged<VideoEffect> onEffectSelected;
  final VoidCallback onOpenEffectLibrary;

  @override
  Widget build(BuildContext context) {
    Widget surface = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              effectsLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onOpenEffectLibrary,
              style: TextButton.styleFrom(
                foregroundColor: palette.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
              ),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: Text(effectsLabel),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final effect = videoEffects[index];
              final bool isSelected = effect.id == selectedEffect.id;
              return _LensChip(
                effect: effect,
                isSelected: isSelected,
                palette: palette,
                onTap: () => onEffectSelected(effect),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: videoEffects.length,
          ),
        ),
      ],
    );

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: surface,
    );

    if (useLiquidGlass) {
      surface = LiquidGlass(
        glassContainsChild: false,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(28),
        ),
        settings: const LiquidGlassSettings(
          thickness: 8,
          blur: 18,
          glassColor: Color(0x24FFFFFF),
          ambientStrength: 0.24,
          lightIntensity: 1.04,
          blend: 16,
          saturation: 1.02,
          lightness: 1.02,
        ),
        child: content,
      );
    } else {
      surface = content;
    }

    return surface;
  }
}

class _LensChip extends StatelessWidget {
  const _LensChip({
    required this.effect,
    required this.isSelected,
    required this.palette,
    required this.onTap,
  });

  final VideoEffect effect;
  final bool isSelected;
  final ThalaPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradient =
        effect.overlay ??
        LinearGradient(
          colors: [
            palette.surfaceStrong.withValues(alpha: 0.8),
            palette.surfaceBright.withValues(alpha: 0.4),
          ],
        );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 78 : 64,
            height: isSelected ? 78 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white24,
                width: isSelected ? 3 : 1.2,
              ),
            ),
            child: ClipOval(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: gradient),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 80,
            child: Text(
              effect.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureModeSwitcher extends StatelessWidget {
  const _CaptureModeSwitcher({
    required this.useLiquidGlass,
    required this.modes,
    required this.selectedIndex,
    required this.onModeSelected,
  });

  final bool useLiquidGlass;
  final List<_CaptureModeData> modes;
  final int selectedIndex;
  final ValueChanged<int> onModeSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;
    final theme = Theme.of(context);

    final row = Row(
      children: [
        for (var i = 0; i < modes.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onModeSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: i == selectedIndex
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      modes[i].icon,
                      size: 20,
                      color: i == selectedIndex
                          ? palette.inverseText
                          : palette.inverseIconMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modes[i].label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: i == selectedIndex
                            ? palette.inverseText
                            : palette.inverseTextSecondary,
                        fontWeight: i == selectedIndex
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    Widget surface = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: row,
    );

    if (useLiquidGlass) {
      surface = LiquidGlass(
        glassContainsChild: false,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(28),
        ),
        settings: const LiquidGlassSettings(
          thickness: 8,
          blur: 18,
          glassColor: Color(0x24FFFFFF),
          ambientStrength: 0.24,
          lightIntensity: 1.05,
          blend: 16,
          saturation: 1.02,
          lightness: 1.02,
        ),
        child: surface,
      );
    }

    return surface;
  }
}

class _CaptureModeData {
  const _CaptureModeData({
    required this.label,
    required this.helper,
    required this.icon,
  });

  final String label;
  final String helper;
  final IconData icon;
}

class _EffectTray extends StatelessWidget {
  const _EffectTray({
    required this.visible,
    required this.selectedEffect,
    required this.onSelect,
  });

  final bool visible;
  final VideoEffect selectedEffect;
  final ValueChanged<VideoEffect> onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: !visible
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('effect-tray-open'),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: SizedBox(
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final effect = videoEffects[index];
                    final selected = effect.id == selectedEffect.id;
                    return _EffectChip(
                      effect: effect,
                      isSelected: selected,
                      onTap: () => onSelect(effect),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: videoEffects.length,
                ),
              ),
            ),
    );
  }
}

class _EffectChip extends StatelessWidget {
  const _EffectChip({
    required this.effect,
    required this.isSelected,
    required this.onTap,
  });

  final VideoEffect effect;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          gradient:
              effect.overlay ??
              const LinearGradient(
                colors: [Color(0xFF101820), Color(0xFF0A111A)],
              ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              effect.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.creatorNameController,
    required this.creatorHandleController,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.isPublishing,
    required this.onPublish,
    required this.onShowEffects,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController creatorNameController;
  final TextEditingController creatorHandleController;
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;
  final bool isPublishing;
  final VoidCallback onPublish;
  final VoidCallback onShowEffects;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreatePostController>();
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final musicTracks = context.watch<MusicLibrary>().tracks;
    final handleColor = context.elevatedOverlay(0.18);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: palette.textPrimary,
      fontWeight: FontWeight.w700,
    );
    final actionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.w600,
    );
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(
      color: palette.textPrimary,
      fontWeight: FontWeight.w600,
    );
    String tr(AppText key) => AppTranslations.of(context, key);
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      snap: true,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceStrong,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(color: palette.border),
          ),
          child: Form(
            key: formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(tr(AppText.createStoryDetails), style: titleStyle),
                    const Spacer(),
                    // Language toggle
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'fr', label: Text('FR')),
                      ],
                      selected: {selectedLanguage},
                      onSelectionChanged: (Set<String> selection) {
                        onLanguageChanged(selection.first);
                      },
                      style: ButtonStyle(
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailTextField(
                  controller: titleController,
                  label: 'Title',
                ),
                const SizedBox(height: 12),
                _DetailTextField(
                  controller: descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
                  required: false,
                ),
                const SizedBox(height: 12),
                _DetailTextField(
                  controller: locationController,
                  label: 'Location (optional)',
                  required: false,
                ),
                const SizedBox(height: 12),
                _DetailTextField(
                  controller: creatorNameController,
                  label: 'Creator Name',
                ),
                const SizedBox(height: 12),
                _DetailTextField(
                  controller: creatorHandleController,
                  label: 'Handle (e.g., @username)',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Handle is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(tr(AppText.createStoryMusicLibrary), style: sectionStyle),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ChoiceChip(
                      label: Text(tr(AppText.createStoryNoTrack)),
                      selected: controller.selectedTrack == null,
                      onSelected: (_) => controller.selectTrack(null),
                    ),
                    for (final track in musicTracks)
                      ChoiceChip(
                        avatar: CircleAvatar(
                          backgroundImage: NetworkImage(track.artworkUrl),
                        ),
                        label: Text(track.title),
                        selected: controller.selectedTrack?.id == track.id,
                        onSelected: (_) => controller.selectTrack(track),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isPublishing ? null : onPublish,
                  icon: isPublishing
                      ? SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.upload),
                  label: Text(
                    isPublishing
                        ? tr(AppText.createStoryPublishing)
                        : tr(AppText.createStoryPublishStory),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailTextField extends StatelessWidget {
  const _DetailTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.required = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool required;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    String? defaultValidator(String? value) {
      if (value == null || value.trim().isEmpty) {
        return AppTranslations.of(context, AppText.createStoryFieldRequired);
      }
      return null;
    }

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator ?? (required ? defaultValidator : null),
      style: theme.textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
        ),
      ),
    );
  }
}
