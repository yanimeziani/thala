import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_theme.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/feed_controller.dart';
import '../../../data/effect_presets.dart';
import '../../../data/sample_tracks.dart';
import '../../../l10n/app_translations.dart';
import '../../../models/video_effect.dart';
import '../../../models/music_track.dart';
import '../../../models/video_post.dart';
import '../../../ui/widgets/thela_snackbar.dart';
import '../../profile/user_profile_page.dart';

class VideoStoryPage extends StatefulWidget {
  const VideoStoryPage({
    super.key,
    required this.post,
    required this.isActive,
    required this.isMuted,
    required this.onToggleMute,
    this.topInset = 20,
    required this.bottomInset,
  });

  final VideoPost post;
  final bool isActive;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final double topInset;
  final double bottomInset;

  @override
  State<VideoStoryPage> createState() => _VideoStoryPageState();
}

class _VideoStoryPageState extends State<VideoStoryPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  VideoPlayerController? _controller;
  Future<void>? _initialization;
  bool _showControls = false;
  late final AnimationController _likeAnimationController;
  late final Animation<double> _likeScaleAnimation;
  late final Animation<double> _likeOpacityAnimation;
  late final AnimationController _sharePulseController;
  late final Animation<double> _sharePulseScale;
  late final Animation<double> _sharePulseGlow;
  Offset? _longPressStartPosition;
  Duration? _longPressInitialVideoPosition;
  bool _isLongPressSeeking = false;
  bool _longPressShouldShare = false;
  bool _longPressWasPlaying = false;

  static const double _longPressSeekActivationThreshold = 16;
  static const double _longPressSeekSecondsPerPixel = 0.06;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.7,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_likeAnimationController);
    _likeOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem<double>(tween: ConstantTween<double>(1.0), weight: 30),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_likeAnimationController);
    _sharePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _sharePulseScale = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 55,
      ),
    ]).animate(_sharePulseController);
    _sharePulseGlow = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(_sharePulseController);
    _initializeController(widget.post);
  }

  @override
  void didUpdateWidget(covariant VideoStoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPost = widget.post;
    final oldPost = oldWidget.post;
    final bool postChanged =
        newPost.id != oldPost.id ||
        newPost.mediaKind != oldPost.mediaKind ||
        newPost.videoUrl != oldPost.videoUrl;

    if (postChanged) {
      _showControls = false;
      _disposeController();
      _initializeController(newPost);
      return;
    }

    if (widget.isMuted != oldWidget.isMuted) {
      final controller = _controller;
      if (controller != null && newPost.isVideo) {
        _applyMuteState(controller);
      }
    }

    if (widget.isActive != oldWidget.isActive) {
      final controller = _controller;
      if (controller == null || !newPost.isVideo) {
        return;
      }
      if (widget.isActive) {
        if (controller.value.isInitialized && !controller.value.isPlaying) {
          controller.play();
        }
      } else {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          controller.pause();
        }
        if (_showControls) {
          setState(() => _showControls = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _disposeController();
    _likeAnimationController.dispose();
    _sharePulseController.dispose();
    super.dispose();
  }

  void _initializeController(VideoPost post) {
    if (!post.isVideo) {
      _disposeController();
      return;
    }
    final controller = _createController(post)..setLooping(true);
    _controller = controller;
    _initialization = controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _applyMuteState(controller);
      if (widget.isActive) {
        controller.play();
      }
      setState(() {});
    });
    _applyMuteState(controller);
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    _initialization = null;
    controller?.dispose();
  }

  void _applyMuteState(VideoPlayerController controller) {
    final double targetVolume = widget.isMuted ? 0.0 : 1.0;
    if (!controller.value.isInitialized) {
      final initialization = _initialization;
      if (initialization != null) {
        initialization.then((_) {
          if (!mounted) {
            return;
          }
          if (_controller != controller) {
            return;
          }
          unawaited(controller.setVolume(targetVolume));
        });
      }
      return;
    }
    unawaited(controller.setVolume(targetVolume));
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  void _resetVideoLongPressState() {
    _longPressStartPosition = null;
    _longPressInitialVideoPosition = null;
    _isLongPressSeeking = false;
    _longPressShouldShare = false;
    _longPressWasPlaying = false;
  }

  VideoPlayerController _createController(VideoPost post) {
    if (post.videoSource == VideoSource.asset ||
        post.videoUrl.startsWith('assets/')) {
      return VideoPlayerController.asset(post.videoUrl);
    }
    if (post.videoSource == VideoSource.localFile ||
        post.videoUrl.startsWith('/')) {
      return VideoPlayerController.file(File(post.videoUrl));
    }
    final uri = Uri.tryParse(post.videoUrl);
    if (uri == null || !uri.hasScheme || uri.scheme == 'file') {
      return VideoPlayerController.file(File(post.videoUrl));
    }
    return VideoPlayerController.networkUrl(uri);
  }

  void _handleVideoLongPressStart(LongPressStartDetails details) {
    _longPressStartPosition = details.globalPosition;
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      _longPressInitialVideoPosition = controller.value.position;
      _longPressWasPlaying = controller.value.isPlaying;
    } else {
      _longPressInitialVideoPosition = null;
      _longPressWasPlaying = false;
    }
    _isLongPressSeeking = false;
    _longPressShouldShare = true;
  }

  void _handleVideoLongPressMove(LongPressMoveUpdateDetails details) {
    final controller = _controller;
    final startPosition = _longPressStartPosition;
    if (controller == null ||
        startPosition == null ||
        !controller.value.isInitialized) {
      return;
    }

    final double dx = details.globalPosition.dx - startPosition.dx;
    if (!_isLongPressSeeking) {
      if (dx.abs() < _longPressSeekActivationThreshold) {
        return;
      }
      _isLongPressSeeking = true;
      _longPressShouldShare = false;
      if (_longPressWasPlaying) {
        controller.pause();
      }
      if (!_showControls && mounted) {
        setState(() => _showControls = true);
      }
    }

    final Duration basePosition =
        _longPressInitialVideoPosition ?? controller.value.position;
    final double deltaSeconds = dx * _longPressSeekSecondsPerPixel;
    final Duration targetPosition =
        basePosition + Duration(milliseconds: (deltaSeconds * 1000).round());
    final Duration duration = controller.value.duration;
    final Duration clampedPosition = _clampDuration(
      targetPosition,
      Duration.zero,
      duration > Duration.zero ? duration : controller.value.position,
    );
    unawaited(controller.seekTo(clampedPosition));
  }

  Future<void> _handleVideoLongPressEnd(
    LongPressEndDetails details,
    FeedController feed,
    AuthController auth,
  ) async {
    final bool performedSeek = _isLongPressSeeking;
    final bool shouldShare = _longPressShouldShare;
    final bool wasPlaying = _longPressWasPlaying;
    _resetVideoLongPressState();

    if (performedSeek) {
      final controller = _controller;
      if (controller != null && controller.value.isInitialized) {
        if (wasPlaying && widget.isActive) {
          controller.play();
        }
      }
      if (mounted && wasPlaying && _showControls) {
        setState(() => _showControls = false);
      }
      return;
    }

    if (shouldShare) {
      await _handleLongPressShare(feed, auth);
    }
  }

  void _handleVideoLongPressCancel() {
    final bool performedSeek = _isLongPressSeeking;
    final bool wasPlaying = _longPressWasPlaying;
    _resetVideoLongPressState();

    if (!performedSeek) {
      return;
    }

    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      if (wasPlaying && widget.isActive) {
        controller.play();
      }
    }
    if (mounted && wasPlaying && _showControls) {
      setState(() => _showControls = false);
    }
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final wasPlaying = controller.value.isPlaying;
    setState(() {
      if (wasPlaying) {
        controller.pause();
        _showControls = true;
      } else {
        if (widget.isActive) {
          controller.play();
        }
        _showControls = false;
      }
    });
  }

  Future<void> _handleLongPressShare(
    FeedController feed,
    AuthController auth,
  ) async {
    _sharePulseController.forward(from: 0);
    final controller = _controller;
    bool shouldResumePlayback = false;

    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
        shouldResumePlayback = true;
        setState(() => _showControls = true);
      }
    }

    await _handleNativeShare(feed, auth);

    if (!mounted) {
      return;
    }

    final currentController = _controller;
    if (shouldResumePlayback &&
        currentController != null &&
        currentController.value.isInitialized &&
        widget.isActive) {
      currentController.play();
      setState(() => _showControls = false);
    }
  }

  void _handleDoubleTap(FeedController feed, bool isLiked) {
    _likeAnimationController.forward(from: 0);
    HapticFeedback.mediumImpact();
    if (feed.isBusy(widget.post.id) || isLiked) {
      return;
    }
    unawaited(feed.toggleLike(widget.post));
  }

  Future<void> _handleLike(FeedController feed) async {
    HapticFeedback.mediumImpact();
    await feed.toggleLike(widget.post);
  }

  Future<void> _handleComment(FeedController feed, AuthController auth) async {
    final session = auth.session;
    if (session == null) {
      _showAuthRequiredMessage();
      return;
    }
    if (!feed.isRemoteEnabled) {
      _showSupabaseRequiredMessage();
      return;
    }

    HapticFeedback.selectionClick();
    final comment = await _promptForComment();
    if (!mounted || comment == null) {
      return;
    }

    final success = await feed.submitComment(
      post: widget.post,
      userId: session.user.id,
      comment: comment,
    );

    if (!success || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = AppTranslations.of(context, AppText.feedCommentSent);
    messenger?.showSnackBar(
      buildThelaSnackBar(
        context,
        icon: Icons.mode_comment_outlined,
        iconColor: Theme.of(context).colorScheme.secondary,
        semanticsLabel: message,
      ),
    );
  }

  Future<void> _handleShare(FeedController feed, AuthController auth) async {
    HapticFeedback.selectionClick();
    final action = await _showShareSheet();
    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _ShareAction.copyLink:
        await _copyLinkAndRecordShare(feed, auth);
        break;
    }
  }

  Future<void> _handleNativeShare(
    FeedController feed,
    AuthController auth,
  ) async {
    final link = widget.post.primaryMediaUrl;
    if (link.isEmpty) {
      await _copyLinkAndRecordShare(feed, auth);
      return;
    }

    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final title = widget.post.title.resolve(locale).trim();
    final description = widget.post.description.resolve(locale).trim();

    final shareSections = <String>[];
    if (title.isNotEmpty) {
      shareSections.add(title);
    }
    if (description.isNotEmpty) {
      shareSections.add(description);
    }
    shareSections.add(link);

    final shareText = shareSections.join('\n\n');
    final subject = title.isNotEmpty ? title : null;
    final fallbackText = description.isNotEmpty
        ? description
        : (title.isNotEmpty ? title : link);

    ShareResult? result;
    final ui.Rect? shareOrigin = _resolveShareOriginRect();
    try {
      final uri = Uri.tryParse(link);
      if (!kIsWeb) {
        if (uri != null && uri.scheme == 'file') {
          final file = File.fromUri(uri);
          if (await file.exists()) {
            result = await Share.shareXFiles(
              [XFile(file.path)],
              text: fallbackText,
              subject: subject,
            );
          }
        } else if ((uri == null || uri.scheme.isEmpty) && link.isNotEmpty) {
          final file = File(link);
          if (await file.exists()) {
            result = await Share.shareXFiles(
              [XFile(file.path)],
              text: fallbackText,
              subject: subject,
            );
          }
        }
      }

      if (shareOrigin != null) {
        result ??= await Share.shareWithResult(
          shareText,
          subject: subject,
          sharePositionOrigin: shareOrigin,
        );
      } else {
        result ??= await Share.shareWithResult(shareText, subject: subject);
      }
    } on UnimplementedError {
      await Share.share(shareText, subject: subject);
      result = null;
    } on MissingPluginException {
      await Share.share(shareText, subject: subject);
      result = null;
    } on PlatformException catch (error) {
      if (error.code == 'unavailable' ||
          error.code == 'missing_plugin' ||
          error.code == 'Unimplemented') {
        await Share.share(shareText, subject: subject);
        result = null;
      } else {
        rethrow;
      }
    } catch (_) {
      await Share.share(shareText, subject: subject);
      result = null;
    }

    if (!mounted) {
      return;
    }

    if (result == null) {
      await feed.recordShare(post: widget.post, userId: auth.session?.user.id);
      return;
    }

    switch (result.status) {
      case ShareResultStatus.success:
        await feed.recordShare(
          post: widget.post,
          userId: auth.session?.user.id,
        );
        break;
      case ShareResultStatus.unavailable:
        await _copyLinkAndRecordShare(feed, auth);
        break;
      case ShareResultStatus.dismissed:
        break;
    }
  }

  Future<void> _copyLinkAndRecordShare(
    FeedController feed,
    AuthController auth,
  ) async {
    final success = await feed.recordShare(
      post: widget.post,
      userId: auth.session?.user.id,
    );
    if (!success || !mounted) {
      return;
    }

    final link = widget.post.primaryMediaUrl;
    await Clipboard.setData(ClipboardData(text: link));
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = AppTranslations.of(context, AppText.feedLinkCopied);
    messenger?.showSnackBar(
      buildThelaSnackBar(
        context,
        icon: Icons.link,
        iconColor: Theme.of(context).colorScheme.secondary,
        semanticsLabel: message,
      ),
    );
  }

  Future<_ShareAction?> _showShareSheet() {
    return showModalBottomSheet<_ShareAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final palette = sheetContext.thelaPalette;
        final surface = theme.colorScheme.surface;
        final backgroundColor = Color.alphaBlend(
          palette.surfaceBright.withOpacity(
            theme.brightness == Brightness.dark ? 0.55 : 0.85,
          ),
          surface,
        );

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: palette.borderStrong),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: palette.borderStrong.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Icon(
                        Icons.link,
                        color: theme.colorScheme.secondary,
                      ),
                      title: Text(
                        AppTranslations.of(sheetContext, AppText.feedCopyLink),
                      ),
                      subtitle: Text(
                        AppTranslations.of(
                          sheetContext,
                          AppText.feedCopyLinkSubtitle,
                        ),
                      ),
                      onTap: () =>
                          Navigator.of(sheetContext).pop(_ShareAction.copyLink),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _promptForComment() async {
    final textController = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets;
        final theme = Theme.of(context);
        final palette = context.thelaPalette;
        final surface = theme.colorScheme.surface;
        final backgroundColor = Color.alphaBlend(
          palette.surfaceBright.withOpacity(
            theme.brightness == Brightness.dark ? 0.6 : 0.9,
          ),
          surface,
        );
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.borderStrong),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 4,
                  minLines: 2,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: AppTranslations.of(
                      context,
                      AppText.feedCommentHint,
                    ),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.textMuted,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: palette.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: theme.colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: palette.surfaceBright,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        AppTranslations.of(context, AppText.feedCommentCancel),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        final value = textController.text.trim();
                        if (value.isNotEmpty) {
                          Navigator.of(context).pop(value);
                        }
                      },
                      child: Text(
                        AppTranslations.of(context, AppText.feedCommentSend),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    textController.dispose();
    return result;
  }

  ui.Rect? _resolveShareOriginRect() {
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final Offset topLeft = renderObject.localToGlobal(Offset.zero);
      final Size size = renderObject.size;
      if (size.width > 0 && size.height > 0) {
        return ui.Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy,
          size.width,
          size.height,
        );
      }
    }

    final OverlayState? overlay = Overlay.maybeOf(context);
    if (overlay != null) {
      renderObject = overlay.context.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize) {
        final Offset topLeft = renderObject.localToGlobal(Offset.zero);
        final Size size = renderObject.size;
        if (size.width > 0 && size.height > 0) {
          return ui.Rect.fromLTWH(
            topLeft.dx,
            topLeft.dy,
            size.width,
            size.height,
          );
        }
      }
    }

    return null;
  }

  void _showAuthRequiredMessage() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = AppTranslations.of(context, AppText.feedAuthRequired);
    messenger?.showSnackBar(
      buildThelaSnackBar(
        context,
        icon: Icons.lock_outline,
        iconColor: Theme.of(context).colorScheme.error,
        badgeColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.24),
        semanticsLabel: message,
      ),
    );
  }

  void _showSupabaseRequiredMessage() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = AppTranslations.of(context, AppText.feedSupabaseRequired);
    messenger?.showSnackBar(
      buildThelaSnackBar(
        context,
        icon: Icons.cloud_off,
        iconColor: Theme.of(context).colorScheme.error,
        badgeColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.22),
        semanticsLabel: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final feed = context.watch<FeedController>();
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final mediaQuery = MediaQuery.of(context);
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final post = widget.post;
    final effect = effectForId(post.effectId);
    final isLiked = feed.isLiked(post);
    final likeBusy = feed.isBusy(post.id);
    final commentBusy = feed.isUpdatePending('${post.id}-comment');
    final shareBusy = feed.isUpdatePending('${post.id}-share');
    final explanations = feed.explanationFor(post) ?? const <String>[];

    final bool useCompactLayout =
        mediaQuery.size.height < 720 || mediaQuery.size.width < 420;
    final double topPadding = mediaQuery.padding.top + widget.topInset;
    final double horizontalPadding = mediaQuery.size.width < 380 ? 16 : 20;
    final double overlayBottom =
        widget.bottomInset + (useCompactLayout ? 18 : 24);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: post.isVideo ? _togglePlayback : null,
            onDoubleTap: () => _handleDoubleTap(feed, isLiked),
            onLongPressStart: post.isVideo ? _handleVideoLongPressStart : null,
            onLongPressMoveUpdate: post.isVideo
                ? _handleVideoLongPressMove
                : null,
            onLongPressEnd: post.isVideo
                ? (details) =>
                      unawaited(_handleVideoLongPressEnd(details, feed, auth))
                : null,
            onLongPressCancel: post.isVideo
                ? _handleVideoLongPressCancel
                : null,
            onLongPress: post.isVideo
                ? null
                : () => _handleLongPressShare(feed, auth),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _VideoStoryBackground(
                  post: post,
                  controller: _controller,
                  initialization: _initialization,
                  effect: effect,
                  locale: locale,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: AnimatedBuilder(
                      animation: _likeAnimationController,
                      builder: (context, child) {
                        final opacity = _likeOpacityAnimation.value;
                        if (opacity <= 0) {
                          return const SizedBox.shrink();
                        }
                        return Center(
                          child: Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: _likeScaleAnimation.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _LikeHeart(
                        size: useCompactLayout ? 96 : 128,
                        accentColor: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding, left: horizontalPadding),
            child: post.isLocalDraft
                ? _DraftPill(theme: theme)
                : const SizedBox.shrink(),
          ),
        ),
        if (post.isVideo)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                right: horizontalPadding,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: _MuteToggleButton(
                  isMuted: widget.isMuted,
                  onPressed: widget.onToggleMute,
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: true,
            child: _BottomBlend(height: overlayBottom + 220),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              overlayBottom,
            ),
            child: Column(
              children: [
                const Spacer(),
                _VideoStoryOverlay(
                  post: post,
                  locale: locale,
                  explanations: explanations,
                  isLiked: isLiked,
                  likeBusy: likeBusy,
                  commentBusy: commentBusy,
                  shareBusy: shareBusy,
                  palette: palette,
                  useCompactLayout: useCompactLayout,
                  sharePulseScale: _sharePulseScale,
                  sharePulseGlow: _sharePulseGlow,
                  onLike: () => _handleLike(feed),
                  onComment: () => _handleComment(feed, auth),
                  onShare: () => _handleShare(feed, auth),
                ),
              ],
            ),
          ),
        ),
        if (_controller != null &&
            (_showControls || !_controller!.value.isPlaying))
          const _CenterPlayIndicator(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _VideoStoryBackground extends StatelessWidget {
  const _VideoStoryBackground({
    required this.post,
    required this.controller,
    required this.initialization,
    required this.effect,
    required this.locale,
  });

  final VideoPost post;
  final VideoPlayerController? controller;
  final Future<void>? initialization;
  final VideoEffect effect;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (post.isVideo) {
      return _VideoMediaBackground(
        post: post,
        controller: controller,
        initialization: initialization,
        effect: effect,
      );
    }
    if (post.isImage) {
      return _ImageMediaBackground(post: post);
    }
    return _PostMediaBackground(post: post, locale: locale);
  }
}

class _VideoMediaBackground extends StatelessWidget {
  const _VideoMediaBackground({
    required this.post,
    required this.controller,
    required this.initialization,
    required this.effect,
  });

  final VideoPost post;
  final VideoPlayerController? controller;
  final Future<void>? initialization;
  final VideoEffect effect;

  @override
  Widget build(BuildContext context) {
    final videoController = controller;
    final double fallbackAspectRatio =
        (post.aspectRatio != null && post.aspectRatio! > 0)
        ? post.aspectRatio!
        : 9 / 16;

    if (videoController == null) {
      return _buildFramedPlaceholder(aspectRatio: fallbackAspectRatio);
    }

    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        final bool isInitialized = videoController.value.isInitialized;
        if (!isInitialized) {
          final bool showProgress =
              snapshot.connectionState == ConnectionState.waiting;
          return _buildFramedPlaceholder(
            aspectRatio: fallbackAspectRatio,
            showProgress: showProgress,
          );
        }

        final Size size = videoController.value.size;
        final double aspectRatio = (size.width <= 0 || size.height <= 0)
            ? fallbackAspectRatio
            : size.width / size.height;

        return LayoutBuilder(
          builder: (context, constraints) {
            final frame = _StoryMediaFrame.calculate(
              constraints: constraints,
              aspectRatio: aspectRatio,
            );

            Widget media = FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: VideoPlayer(videoController),
              ),
            );

            if (effect.filter != null) {
              media = ColorFiltered(colorFilter: effect.filter!, child: media);
            }

            if (effect.overlay != null) {
              media = Stack(
                fit: StackFit.expand,
                children: [
                  media,
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: effect.overlay),
                  ),
                ],
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                _VideoBackdrop(
                  controller: videoController,
                  fallbackUrl: post.thumbnailUrl,
                ),
                Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(frame.borderRadius),
                    child: SizedBox(
                      width: frame.width,
                      height: frame.height,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: Colors.black),
                        child: media,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFramedPlaceholder({
    required double aspectRatio,
    bool showProgress = false,
  }) {
    String? poster = post.thumbnailUrl;
    if (poster == null || poster.trim().isEmpty) {
      poster = post.imageUrl;
    }
    if ((poster == null || poster.trim().isEmpty) &&
        post.galleryUrls.isNotEmpty) {
      poster = post.galleryUrls.first;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final frame = _StoryMediaFrame.calculate(
          constraints: constraints,
          aspectRatio: aspectRatio,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            _StoryBackdrop(imageUrl: post.thumbnailUrl),
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(frame.borderRadius),
                child: SizedBox(
                  width: frame.width,
                  height: frame.height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (poster != null && poster.trim().isNotEmpty)
                        _buildMediaImage(poster, fit: BoxFit.cover)
                      else
                        const ColoredBox(color: Colors.black),
                      if (showProgress)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ImageMediaBackground extends StatefulWidget {
  const _ImageMediaBackground({required this.post});

  final VideoPost post;

  @override
  State<_ImageMediaBackground> createState() => _ImageMediaBackgroundState();
}

class _ImageMediaBackgroundState extends State<_ImageMediaBackground> {
  static const double _kPageViewportFraction = 0.9;

  late PageController _pageController;
  late List<String> _gallery;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _gallery = _resolveGallery(widget.post);
    _pageController = PageController(viewportFraction: _kPageViewportFraction);
  }

  @override
  void didUpdateWidget(covariant _ImageMediaBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.id != oldWidget.post.id ||
        widget.post.galleryUrls.length != oldWidget.post.galleryUrls.length ||
        widget.post.thumbnailUrl != oldWidget.post.thumbnailUrl ||
        widget.post.imageUrl != oldWidget.post.imageUrl) {
      final List<String> updatedGallery = _resolveGallery(widget.post);
      if (!listEquals(_gallery, updatedGallery)) {
        setState(() {
          _gallery = updatedGallery;
          _currentIndex = 0;
        });
        if (_pageController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_pageController.hasClients) {
              return;
            }
            _pageController.jumpToPage(0);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPost post = widget.post;
    final double aspectRatio =
        (post.aspectRatio != null && post.aspectRatio! > 0)
        ? post.aspectRatio!
        : 9 / 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        final frame = _StoryMediaFrame.calculate(
          constraints: constraints,
          aspectRatio: aspectRatio,
        );

        final String? activeImage = _activeImageUrl(post);

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              child: _StoryBackdrop(
                key: ValueKey<String?>(activeImage),
                imageUrl: activeImage,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: frame.width,
                height: frame.height,
                child: _gallery.length <= 1
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(frame.borderRadius),
                        child: activeImage != null
                            ? _buildMediaImage(activeImage, fit: BoxFit.cover)
                            : const ColoredBox(color: Colors.black),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemCount: _gallery.length,
                        itemBuilder: (context, index) {
                          final imageUrl = _gallery[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                frame.borderRadius,
                              ),
                              child: _buildMediaImage(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> _resolveGallery(VideoPost post) {
    final List<String> gallery = post.galleryUrls
        .where((url) => url.trim().isNotEmpty)
        .toList(growable: true);

    if (gallery.isEmpty) {
      final String? fallback = _resolveFallback(post);
      if (fallback != null && fallback.trim().isNotEmpty) {
        gallery.add(fallback);
      }
    }

    return gallery;
  }

  String? _activeImageUrl(VideoPost post) {
    if (_gallery.isEmpty) {
      return _resolveFallback(post);
    }
    final int safeIndex = _currentIndex.clamp(0, _gallery.length - 1);
    return _gallery[safeIndex];
  }

  String? _resolveFallback(VideoPost post) {
    final String? thumbnail = post.thumbnailUrl;
    if (thumbnail != null && thumbnail.trim().isNotEmpty) {
      return thumbnail;
    }
    final String? image = post.imageUrl;
    if (image != null && image.trim().isNotEmpty) {
      return image;
    }
    final MusicTrack? track = trackForId(post.musicTrackId);
    final String? artwork = track?.artworkUrl;
    if (artwork != null && artwork.trim().isNotEmpty) {
      return artwork;
    }
    return null;
  }
}

class _PostMediaBackground extends StatefulWidget {
  const _PostMediaBackground({required this.post, required this.locale});

  final VideoPost post;
  final Locale locale;

  @override
  State<_PostMediaBackground> createState() => _PostMediaBackgroundState();
}

class _PostMediaBackgroundState extends State<_PostMediaBackground> {
  static const Duration _kBackdropTransition = Duration(milliseconds: 400);

  int _activeSlide = 0;

  @override
  void didUpdateWidget(covariant _PostMediaBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.id != oldWidget.post.id ||
        widget.post.textSlides.length != oldWidget.post.textSlides.length) {
      _activeSlide = 0;
    }
  }

  void _handleSlideChanged(int index) {
    if (index == _activeSlide) {
      return;
    }
    setState(() => _activeSlide = index);
  }

  @override
  Widget build(BuildContext context) {
    final VideoPost post = widget.post;
    final ThemeData theme = Theme.of(context);
    final Locale locale = widget.locale;

    final String title = post.title.resolve(locale);
    final String description = post.description.resolve(locale);
    final String textCardKey = '$title|$description';
    final List<String> slides = post.textSlides
        .map((slide) => slide.resolve(locale).trim())
        .where((text) => text.isNotEmpty)
        .toList(growable: false);
    final bool hasSlides = slides.isNotEmpty;

    final MusicTrack? track = trackForId(post.musicTrackId);
    final String? baseBackdrop = _firstNonEmpty([
      post.thumbnailUrl,
      post.imageUrl,
      track?.artworkUrl,
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final _TextDeckGeometry geometry = _TextDeckGeometry.fromMaxWidth(
          constraints.maxWidth,
        );

        final List<Widget> backgroundLayers = <Widget>[
          if (baseBackdrop != null)
            _StoryBackdrop(imageUrl: baseBackdrop)
          else
            ColoredBox(color: theme.colorScheme.background),
        ];

        if (hasSlides) {
          final String? activeSlideText = slides.isEmpty
              ? null
              : slides[_activeSlide.clamp(0, slides.length - 1)];
          if (activeSlideText != null && activeSlideText.isNotEmpty) {
            backgroundLayers.add(
              AnimatedSwitcher(
                duration: _kBackdropTransition,
                child: _BlurredTextSlide(
                  key: ValueKey<String>(activeSlideText),
                  text: activeSlideText,
                  deckWidth: geometry.deckWidth,
                  cardWidth: geometry.cardWidth,
                  cardHeight: geometry.cardHeight,
                ),
              ),
            );
          }
        } else {
          backgroundLayers.add(
            AnimatedSwitcher(
              duration: _kBackdropTransition,
              child: _BlurredTextCard(
                key: ValueKey<String>(textCardKey),
                title: title,
                description: description,
              ),
            ),
          );
        }

        final Widget foreground = hasSlides
            ? SizedBox(
                width: geometry.deckWidth,
                height: geometry.cardHeight + 24,
                child: _TextSlideDeck(
                  slides: slides,
                  deckWidth: geometry.deckWidth,
                  cardWidth: geometry.cardWidth,
                  cardHeight: geometry.cardHeight,
                  onActiveSlideChanged: _handleSlideChanged,
                ),
              )
            : _StoryTextCard(
                key: ValueKey<String>(textCardKey),
                title: title,
                description: description,
              );

        return Stack(
          fit: StackFit.expand,
          children: [
            for (final Widget layer in backgroundLayers) layer,
            Align(alignment: Alignment.center, child: foreground),
          ],
        );
      },
    );
  }

  String? _firstNonEmpty(List<String?> candidates) {
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }
}

const double _kTextSlideSpacing = 18;

class _TextDeckGeometry {
  const _TextDeckGeometry({
    required this.deckWidth,
    required this.cardWidth,
    required this.cardHeight,
  });

  final double deckWidth;
  final double cardWidth;
  final double cardHeight;

  static _TextDeckGeometry fromMaxWidth(double maxWidth) {
    final num deckClamp = maxWidth.clamp(320.0, 560.0);
    final double deckWidth = deckClamp.toDouble();
    final num widthClamp = (deckWidth * 0.72).clamp(220.0, 340.0);
    final double cardWidth = widthClamp.toDouble();
    final num heightClamp = (cardWidth * 0.95).clamp(180.0, 280.0);
    final double cardHeight = heightClamp.toDouble();
    return _TextDeckGeometry(
      deckWidth: deckWidth,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
    );
  }
}

class _TextSlideDeck extends StatefulWidget {
  const _TextSlideDeck({
    required this.slides,
    required this.deckWidth,
    required this.cardWidth,
    required this.cardHeight,
    this.onActiveSlideChanged,
  });

  final List<String> slides;
  final double deckWidth;
  final double cardWidth;
  final double cardHeight;
  final ValueChanged<int>? onActiveSlideChanged;

  @override
  State<_TextSlideDeck> createState() => _TextSlideDeckState();
}

class _TextSlideDeckState extends State<_TextSlideDeck> {
  late final ScrollController _controller;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onActiveSlideChanged?.call(0);
    });
  }

  @override
  void didUpdateWidget(covariant _TextSlideDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.slides, oldWidget.slides)) {
      _activeIndex = 0;
      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        widget.onActiveSlideChanged?.call(0);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) {
      return false;
    }

    final double offset = (notification.metrics.pixels - 24).clamp(
      0.0,
      double.infinity,
    );
    final double extent = widget.cardWidth + _kTextSlideSpacing;
    if (extent <= 0) {
      return false;
    }

    final int index = (offset / extent).round().clamp(
      0,
      widget.slides.length - 1,
    );
    if (index != _activeIndex) {
      _activeIndex = index;
      widget.onActiveSlideChanged?.call(index);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.deckWidth,
      height: widget.cardHeight + 24,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: widget.slides.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: _kTextSlideSpacing),
          itemBuilder: (context, index) {
            final String text = widget.slides[index];
            return SizedBox(
              width: widget.cardWidth,
              height: widget.cardHeight,
              child: _TextSlideCard(text: text),
            );
          },
        ),
      ),
    );
  }
}

class _TextSlideCard extends StatelessWidget {
  const _TextSlideCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(_kStoryMediaBorderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 24,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            height: 1.5,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

class _BlurredTextSlide extends StatelessWidget {
  const _BlurredTextSlide({
    super.key,
    required this.text,
    required this.deckWidth,
    required this.cardWidth,
    required this.cardHeight,
  });

  final String text;
  final double deckWidth;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: deckWidth,
        height: cardHeight + 24,
        child: Center(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Opacity(
              opacity: 0.6,
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _TextSlideCard(text: text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryTextCard extends StatelessWidget {
  const _StoryTextCard({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasDescription = description.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(_kStoryMediaBorderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          if (hasDescription) ...[
            const SizedBox(height: 18),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.88),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlurredTextCard extends StatelessWidget {
  const _BlurredTextCard({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Opacity(
          opacity: 0.6,
          child: _StoryTextCard(title: title, description: description),
        ),
      ),
    );
  }
}

class _VideoBackdrop extends StatelessWidget {
  const _VideoBackdrop({required this.controller, this.fallbackUrl});

  final VideoPlayerController controller;
  final String? fallbackUrl;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return _StoryBackdrop(imageUrl: fallbackUrl);
        }

        final theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;
        final Size size = value.size;
        final double width = size.width <= 0 ? 1 : size.width;
        final double height = size.height <= 0 ? 1 : size.height;

        final String? backgroundImage =
            (fallbackUrl != null && fallbackUrl!.trim().isNotEmpty)
            ? fallbackUrl
            : null;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImage != null)
              _StoryBackdrop(imageUrl: backgroundImage)
            else
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: VideoPlayer(controller),
                ),
              ),
            ColoredBox(color: Colors.black.withOpacity(isDark ? 0.35 : 0.45)),
          ],
        );
      },
    );
  }
}

class _StoryBackdrop extends StatelessWidget {
  const _StoryBackdrop({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? url = imageUrl;
    if (url == null || url.isEmpty) {
      return ColoredBox(color: theme.colorScheme.background);
    }

    final bool isDark = theme.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: _buildMediaImage(url, fit: BoxFit.cover),
        ),
        ColoredBox(color: Colors.black.withOpacity(isDark ? 0.35 : 0.45)),
      ],
    );
  }
}

const double _kStoryMediaBorderRadius = 32.0;

class _StoryMediaFrame {
  const _StoryMediaFrame({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  static _StoryMediaFrame calculate({
    required BoxConstraints constraints,
    required double aspectRatio,
  }) {
    final double safeAspect = aspectRatio <= 0 ? 9 / 16 : aspectRatio;
    final double maxWidth = constraints.maxWidth;
    final double maxHeight = constraints.maxHeight;

    double width = maxWidth.isFinite && maxWidth > 0
        ? maxWidth
        : constraints.minWidth > 0
        ? constraints.minWidth
        : double.nan;

    double height = maxHeight.isFinite && maxHeight > 0
        ? maxHeight
        : constraints.minHeight > 0
        ? constraints.minHeight
        : double.nan;

    if ((!width.isFinite || width <= 0) && height.isFinite && height > 0) {
      width = height * safeAspect;
    } else if ((!height.isFinite || height <= 0) &&
        width.isFinite &&
        width > 0) {
      height = width / safeAspect;
    }

    if (!width.isFinite || width <= 0) {
      width = safeAspect >= 1 ? safeAspect : 1.0;
    }
    if (!height.isFinite || height <= 0) {
      height = safeAspect >= 1 ? 1.0 : (1.0 / safeAspect);
    }

    return _StoryMediaFrame(width: width, height: height, borderRadius: 0);
  }
}

Widget _buildMediaImage(String url, {BoxFit fit = BoxFit.cover}) {
  if (url.startsWith('assets/')) {
    return Image.asset(url, fit: fit);
  }
  if (url.startsWith('/')) {
    return Image.file(File(url), fit: fit);
  }
  return Image.network(
    url,
    fit: fit,
    loadingBuilder: (context, child, progress) {
      if (progress == null) {
        return child;
      }
      return const ColoredBox(color: Colors.black26);
    },
    errorBuilder: (context, error, stackTrace) =>
        const ColoredBox(color: Colors.black45),
  );
}

class _BottomBlend extends StatelessWidget {
  const _BottomBlend({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color mid = Colors.black.withOpacity(isDark ? 0.35 : 0.4);
    final Color base = Colors.black.withOpacity(isDark ? 0.65 : 0.7);
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, mid, base],
          ),
        ),
      ),
    );
  }
}

class _LikeHeart extends StatelessWidget {
  const _LikeHeart({required this.size, required this.accentColor});

  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final Color strokeColor = Colors.white.withOpacity(0.55);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _HeartFillPainter(fillColor: accentColor)),
          CustomPaint(
            painter: _HeartStrokePainter(
              color: strokeColor,
              strokeWidth: size * 0.045,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartFillPainter extends CustomPainter {
  const _HeartFillPainter({required this.fillColor});

  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Path heart = _buildHeartPath(size);
    final Rect bounds = Offset.zero & size;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [fillColor.withOpacity(0.95), fillColor.withOpacity(0.8)],
      ).createShader(bounds);

    canvas.drawPath(heart, fillPaint);

    canvas.save();
    canvas.clipPath(heart);
    final Paint highlightPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.3),
        radius: 0.85,
        colors: [Color.fromARGB(102, 255, 255, 255), Colors.transparent],
      ).createShader(bounds);
    canvas.drawRect(bounds, highlightPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeartFillPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor;
  }
}

class _HeartStrokePainter extends CustomPainter {
  const _HeartStrokePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Path heart = _buildHeartPath(size);
    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.srcOver;

    canvas.drawPath(heart, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _HeartStrokePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

Path _buildHeartPath(
  Size size, {
  double topFactor = _heartTopFactor,
  double controlFactor = _heartControlFactor,
  double shoulderFactor = _heartShoulderFactor,
  double shoulderOffsetFactor = _heartShoulderOffsetFactor,
  double lobeRadiusFactor = _heartLobeRadiusFactor,
}) {
  final double width = size.width;
  final double height = size.height;

  final double controlHeight = height * controlFactor;
  final double topHeight = height * topFactor;
  final double shoulderHeight = height * shoulderFactor;
  final double shoulderRight = width * shoulderOffsetFactor;
  final double shoulderLeft = width * (1 - shoulderOffsetFactor);
  final Radius lobeRadius = Radius.circular(width * lobeRadiusFactor);

  final Path path = Path()
    ..moveTo(width / 2, height)
    ..quadraticBezierTo(width, controlHeight, shoulderRight, shoulderHeight)
    ..arcToPoint(
      Offset(width / 2, topHeight),
      radius: lobeRadius,
      clockwise: false,
    )
    ..arcToPoint(
      Offset(shoulderLeft, shoulderHeight),
      radius: lobeRadius,
      clockwise: false,
    )
    ..quadraticBezierTo(0, controlHeight, width / 2, height)
    ..close();

  return path;
}

const double _heartTopFactor = 0.32;
const double _heartControlFactor = 0.72;
const double _heartShoulderFactor = 0.42;
const double _heartShoulderOffsetFactor = 0.78;
const double _heartLobeRadiusFactor = 0.28;

class _VideoStoryOverlay extends StatelessWidget {
  const _VideoStoryOverlay({
    required this.post,
    required this.locale,
    required this.explanations,
    required this.isLiked,
    required this.likeBusy,
    required this.commentBusy,
    required this.shareBusy,
    required this.palette,
    required this.useCompactLayout,
    required this.sharePulseScale,
    required this.sharePulseGlow,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final VideoPost post;
  final Locale locale;
  final List<String> explanations;
  final bool isLiked;
  final bool likeBusy;
  final bool commentBusy;
  final bool shareBusy;
  final ThelaPalette palette;
  final bool useCompactLayout;
  final Animation<double> sharePulseScale;
  final Animation<double> sharePulseGlow;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool denseSpacing =
            useCompactLayout || constraints.maxWidth < 420;
        final double railSpacing = denseSpacing ? 12 : 16;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _StoryDetails(
                post: post,
                locale: locale,
                explanations: explanations,
                dense: denseSpacing,
              ),
            ),
            SizedBox(width: railSpacing),
            _VideoStoryActionRail(
              likes: post.likes,
              comments: post.comments,
              shares: post.shares,
              isLiked: isLiked,
              likeBusy: likeBusy,
              commentBusy: commentBusy,
              shareBusy: shareBusy,
              onLike: onLike,
              onComment: onComment,
              onShare: onShare,
              palette: palette,
              sharePulseScale: sharePulseScale,
              sharePulseGlow: sharePulseGlow,
            ),
          ],
        );
      },
    );
  }
}

class _MuteToggleButton extends StatelessWidget {
  const _MuteToggleButton({required this.isMuted, required this.onPressed});

  final bool isMuted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color background = Colors.black.withOpacity(isDark ? 0.45 : 0.55);
    final Color borderColor = Colors.white.withOpacity(0.18);
    final IconData icon = isMuted ? Icons.volume_off : Icons.volume_up;
    final String tooltipMessage = isMuted
        ? AppTranslations.of(context, AppText.feedUnmute)
        : AppTranslations.of(context, AppText.feedMute);

    return Semantics(
      button: true,
      toggled: !isMuted,
      child: Tooltip(
        message: tooltipMessage,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryDetails extends StatelessWidget {
  const _StoryDetails({
    required this.post,
    required this.locale,
    required this.explanations,
    required this.dense,
  });

  final VideoPost post;
  final Locale locale;
  final List<String> explanations;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MusicTrack? track = trackForId(post.musicTrackId);
    final String name = post.creatorName.resolve(locale);
    final String title = post.title.resolve(locale);
    final String description = post.description.resolve(locale);
    final String location = post.location.resolve(locale);

    final bool hasDescription = description.trim().isNotEmpty;
    final bool hasLocation = location.trim().isNotEmpty;
    final bool hasTags = post.tags.isNotEmpty;
    final bool hasExplanation = explanations.isNotEmpty;

    final Color primaryText = Colors.white;
    final Color secondaryText = Colors.white.withOpacity(0.78);
    final Color mutedText = Colors.white.withOpacity(0.6);

    final List<Widget> children = <Widget>[
      _CreatorHeader(
        post: post,
        name: name,
        handle: post.creatorHandle,
        textColor: primaryText,
        subtleColor: mutedText,
      ),
      const SizedBox(height: 8),
      Text(
        title,
        maxLines: dense ? 2 : 3,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    ];

    if (hasDescription) {
      children
        ..add(const SizedBox(height: 8))
        ..add(
          Text(
            description,
            maxLines: dense ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: secondaryText,
              height: 1.5,
            ),
          ),
        );
    }

    if (track != null) {
      children
        ..add(const SizedBox(height: 10))
        ..add(_StoryMusicPill(track: track, dense: dense));
    }

    if (hasLocation) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.place_outlined, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedText,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        );
    }

    if (hasTags) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          _TagWrap(
            values: post.tags,
            color: Colors.white.withOpacity(0.08),
            borderColor: Colors.white.withOpacity(0.18),
            textStyle: theme.textTheme.labelMedium?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }

    if (hasExplanation) {
      children
        ..add(const SizedBox(height: 10))
        ..add(_ExplanationWrap(values: explanations));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _CreatorHeader extends StatelessWidget {
  const _CreatorHeader({
    required this.post,
    required this.name,
    required this.handle,
    required this.textColor,
    required this.subtleColor,
  });

  final VideoPost post;
  final String name;
  final String handle;
  final Color textColor;
  final Color subtleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String trimmedHandle = handle.trim();
    final String displayHandle = trimmedHandle.isEmpty
        ? ''
        : (trimmedHandle.startsWith('@') ? trimmedHandle : '@$trimmedHandle');

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        if (displayHandle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            displayHandle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtleColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => UserProfilePage.push(context, post: post),
        borderRadius: BorderRadius.circular(12),
        mouseCursor: SystemMouseCursors.click,
        child: content,
      ),
    );
  }
}

class _StoryMusicPill extends StatelessWidget {
  const _StoryMusicPill({required this.track, required this.dense});

  final MusicTrack track;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double width = dense ? 220 : 320;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.music_note, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${track.title} — ${track.artist}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({
    required this.values,
    required this.color,
    required this.borderColor,
    required this.textStyle,
  });

  final List<String> values;
  final Color color;
  final Color borderColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Text(tag, style: textStyle),
            ),
          )
          .toList(),
    );
  }
}

class _ExplanationWrap extends StatelessWidget {
  const _ExplanationWrap({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color background = Colors.white.withOpacity(0.12);
    final Color border = Colors.white.withOpacity(0.18);
    final TextStyle? labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Text(value, style: labelStyle),
            ),
          )
          .toList(),
    );
  }
}

class _VideoStoryActionRail extends StatelessWidget {
  const _VideoStoryActionRail({
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.likeBusy,
    required this.commentBusy,
    required this.shareBusy,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.palette,
    required this.sharePulseScale,
    required this.sharePulseGlow,
  });

  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool likeBusy;
  final bool commentBusy;
  final bool shareBusy;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final ThelaPalette palette;
  final Animation<double> sharePulseScale;
  final Animation<double> sharePulseGlow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color background = Colors.black.withOpacity(isDark ? 0.45 : 0.55);
    final Color borderColor = Colors.white.withOpacity(0.18);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VideoStoryRailButton(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              label: _formatCount(likes),
              highlighted: isLiked,
              busy: likeBusy,
              onPressed: onLike,
            ),
            const SizedBox(height: 14),
            _VideoStoryRailButton(
              icon: Icons.chat_bubble_outline,
              label: _formatCount(comments),
              highlighted: false,
              busy: commentBusy,
              onPressed: onComment,
            ),
            const SizedBox(height: 14),
            _VideoStoryRailButton(
              icon: Icons.share,
              label: _formatCount(shares),
              highlighted: false,
              busy: shareBusy,
              onPressed: onShare,
              scaleAnimation: sharePulseScale,
              glowAnimation: sharePulseGlow,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoStoryRailButton extends StatelessWidget {
  const _VideoStoryRailButton({
    required this.icon,
    required this.label,
    required this.highlighted,
    required this.busy,
    required this.onPressed,
    this.scaleAnimation,
    this.glowAnimation,
  });

  final IconData icon;
  final String label;
  final bool highlighted;
  final bool busy;
  final VoidCallback onPressed;
  final Animation<double>? scaleAnimation;
  final Animation<double>? glowAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color accent = colorScheme.secondary;
    final Color iconColor = highlighted ? accent : Colors.white;
    final textStyle = theme.textTheme.labelSmall?.copyWith(
      color: highlighted ? accent : Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    final Listenable? animationListenable = scaleAnimation ?? glowAnimation;
    Widget iconWidget = SizedBox(
      width: 36,
      height: 36,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: busy
              ? SizedBox(
                  key: const ValueKey('busy'),
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Icon(
                  icon,
                  key: ValueKey<int>(icon.codePoint),
                  color: iconColor,
                  size: 28,
                ),
        ),
      ),
    );

    if (animationListenable != null) {
      iconWidget = AnimatedBuilder(
        animation: animationListenable,
        builder: (context, child) {
          final double scale = scaleAnimation?.value ?? 1.0;
          final double halo =
              (glowAnimation?.value ?? 0.0).clamp(0.0, 1.0) as double;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (halo > 0)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12 * halo),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.2 * halo),
                        blurRadius: 28 * halo,
                      ),
                    ],
                  ),
                ),
              Transform.scale(scale: scale, child: child),
            ],
          );
        },
        child: iconWidget,
      );
    }

    return Semantics(
      button: true,
      selected: highlighted,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy ? null : onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: 6),
                Text(label, style: textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftPill extends StatelessWidget {
  const _DraftPill({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.secondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          'Draft',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CenterPlayIndicator extends StatelessWidget {
  const _CenterPlayIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    return IgnorePointer(
      ignoring: true,
      child: Container(
        color: theme.colorScheme.scrim.withOpacity(0.24),
        alignment: Alignment.center,
        child: Container(
          height: 76,
          width: 76,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(
              theme.brightness == Brightness.dark ? 0.7 : 0.85,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow, color: palette.inverseText, size: 40),
        ),
      ),
    );
  }
}

enum _ShareAction { copyLink }

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toString();
}
