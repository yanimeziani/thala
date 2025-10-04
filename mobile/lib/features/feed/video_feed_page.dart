import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../app/app_theme.dart';
import '../../controllers/feed_controller.dart';
import '../../l10n/app_translations.dart';
import '../../models/video_post.dart';
import '../profile/profile_page.dart';
import '../profile/user_profile_page.dart';
import 'widgets/video_story_page.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../../ui/widgets/thala_snackbar.dart';
import '../../ui/widgets/thala_logo.dart';

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  late final PageController _pageController;
  int _activeIndex = 0;
  bool _isMuted = false;
  final GlobalKey _headerKey = GlobalKey(debugLabel: 'feedHeader');
  double _headerHeight = 0;
  final Map<String, VideoPlayerController> _preloadedControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    for (final controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _preloadVideo(VideoPost post) {
    if (_preloadedControllers.containsKey(post.id)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(post.videoUrl));
    _preloadedControllers[post.id] = controller;

    controller.initialize().then((_) {
      // Keep only last 3 preloaded videos to save memory
      if (_preloadedControllers.length > 3) {
        final firstKey = _preloadedControllers.keys.first;
        _preloadedControllers[firstKey]?.dispose();
        _preloadedControllers.remove(firstKey);
      }
    }).catchError((error) {
      _preloadedControllers.remove(post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final BuildContext? headerContext = _headerKey.currentContext;
      if (headerContext == null) {
        if (_headerHeight != 0) {
          setState(() => _headerHeight = 0);
        }
        return;
      }
      final RenderBox? box = headerContext.findRenderObject() as RenderBox?;
      if (box == null) {
        return;
      }
      final double measuredHeight = box.size.height;
      if (!measuredHeight.isFinite) {
        return;
      }
      if ((measuredHeight - _headerHeight).abs() > 0.5) {
        setState(() => _headerHeight = measuredHeight);
      }
    });

    final feed = context.watch<FeedController>();
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final topPadding = mediaQuery.padding.top + 16;
    const double bottomNavHeight = 88;
    const double bottomNavMinPadding = 16;
    final bottomPadding = math.max(
      mediaQuery.padding.bottom,
      bottomNavMinPadding,
    );
    final bottomOverlayInset = bottomPadding + bottomNavHeight;
    final posts = feed.posts;
    final actionError = feed.actionErrorMessage;
    final bool showWelcome = true;
    final int itemCount = posts.length + (showWelcome ? 1 : 0);
    final double storyTopInset = _headerHeight > 0 ? (_headerHeight + 28) : 20;

    if (actionError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.showSnackBar(
            buildThalaSnackBar(
              context,
              icon: Icons.error_outline,
              iconColor: Theme.of(context).colorScheme.error,
              badgeColor: Theme.of(
                context,
              ).colorScheme.error.withValues(alpha: 0.22),
              semanticsLabel: actionError,
            ),
          );
        }
        feed.clearActionError();
      });
    }

    final scaffoldColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            if (feed.isLoading && posts.isEmpty)
              const Center(child: CircularProgressIndicator()),
            if (itemCount > 0)
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: itemCount,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) => setState(() => _activeIndex = index),
                itemBuilder: (context, index) {
                  if (showWelcome && index == 0) {
                    final nextHandle = posts.isNotEmpty
                        ? posts.first.creatorHandle
                        : null;
                    return _FeedWelcomePage(nextHandle: nextHandle);
                  }
                  final postIndex = showWelcome ? index - 1 : index;
                  final post = posts[postIndex];
                  final isActive = index == _activeIndex && feed.isFeedVisible;

                  // Preload adjacent videos
                  if (isActive) {
                    if (postIndex + 1 < posts.length) {
                      final nextPost = posts[postIndex + 1];
                      _preloadVideo(nextPost);
                    }
                    if (postIndex - 1 >= 0) {
                      final prevPost = posts[postIndex - 1];
                      _preloadVideo(prevPost);
                    }
                  }

                  return VideoStoryPage(
                    key: ValueKey(post.id),
                    post: post,
                    isActive: isActive,
                    isMuted: _isMuted,
                    onToggleMute: _toggleMute,
                    topInset: storyTopInset,
                    bottomInset: bottomOverlayInset,
                  );
                },
              ),
            Positioned(
              top: topPadding,
              left: 20,
              right: 20,
              child: _FeedHeader(
                key: _headerKey,
                onRefresh: feed.refresh,
                showWelcome: showWelcome && _activeIndex == 0,
                activePost: _resolveActivePost(showWelcome, posts),
                locale: locale,
                isMuted: _isMuted,
                onToggleMute: _toggleMute,
              ),
            ),
            if (feed.error != null)
              Positioned(
                top: topPadding + 100,
                left: 24,
                right: 24,
                child: _ErrorBanner(message: feed.error!),
              ),
          ],
        ),
      ),
    );
  }

  VideoPost? _resolveActivePost(bool showWelcome, List<VideoPost> posts) {
    if (posts.isEmpty) {
      return null;
    }
    if (showWelcome) {
      final postIndex = _activeIndex - 1;
      if (postIndex >= 0 && postIndex < posts.length) {
        return posts[postIndex];
      }
      return null;
    }
    if (_activeIndex >= 0 && _activeIndex < posts.length) {
      return posts[_activeIndex];
    }
    return null;
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({
    super.key,
    required this.onRefresh,
    required this.showWelcome,
    required this.activePost,
    required this.locale,
    required this.isMuted,
    required this.onToggleMute,
  });

  final VoidCallback onRefresh;
  final bool showWelcome;
  final VideoPost? activePost;
  final Locale locale;
  final bool isMuted;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showTagline = constraints.maxWidth > 420;
        final Widget brandView = Row(
          key: const ValueKey('brand'),
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThalaLogo(
                  size: 32,
                  semanticLabel: AppTranslations.of(context, AppText.appName),
                ),
                const SizedBox(width: 8),
                Text(
                  AppTranslations.of(context, AppText.appName),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            if (showTagline)
              Expanded(
                child: Text(
                  AppTranslations.of(context, AppText.tagline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              )
            else
              const Spacer(),
          ],
        );

        final Widget storyView = _ActiveStoryChip(
          key: const ValueKey('story'),
          post: activePost,
          locale: locale,
        );

        final Widget actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FeedActionIcon(
              icon: isMuted ? Icons.volume_off : Icons.volume_up,
              tooltip: isMuted ? 'Unmute' : 'Mute',
              onPressed: onToggleMute,
            ),
            const SizedBox(width: 8),
            _FeedActionIcon(
              icon: Icons.person_outline,
              tooltip: AppTranslations.of(context, AppText.viewProfile),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        );

        final headerRow = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: showWelcome
                    ? brandView
                    : (activePost != null ? storyView : brandView),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Align(alignment: Alignment.centerRight, child: actions),
            ),
          ],
        );

        final useLiquidGlass =
            !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

        return SizedBox(
          width: constraints.maxWidth,
          child: ThalaGlassSurface(
            enableLiquid: useLiquidGlass,
            enableBorder: false,
            cornerRadius: 24,
            backgroundColor: palette.surfaceBright,
            backgroundOpacity: theme.brightness == Brightness.dark
                ? 0.12
                : 0.52,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: headerRow,
          ),
        );
      },
    );
  }
}

class _FeedActionIcon extends StatelessWidget {
  const _FeedActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 18,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: Icon(icon, color: palette.iconPrimary.withOpacity(0.9), size: 20),
    );
  }
}

class _ActiveStoryChip extends StatelessWidget {
  const _ActiveStoryChip({super.key, required this.post, required this.locale});

  final VideoPost? post;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final fallBackTitle = AppTranslations.of(context, AppText.appName);
    final title = post?.creatorName.resolve(locale).trim();
    final handle = _formatHandle(post?.creatorHandle ?? '');
    final displayTitle = (title == null || title.isEmpty)
        ? fallBackTitle
        : title;
    final String initials = _initialsFor(displayTitle);

    final row = Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: palette.surfaceSubtle.withOpacity(0.6),
          child: Text(
            initials,
            style: theme.textTheme.labelLarge?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.05,
                  fontSize: 15,
                ),
              ),
              if (handle.isNotEmpty)
                Text(
                  handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary.withOpacity(0.8),
                    letterSpacing: 0.1,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    if (post == null) {
      return row;
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => UserProfilePage.push(context, post: post!),
        borderRadius: BorderRadius.circular(24),
        mouseCursor: SystemMouseCursors.click,
        child: row,
      ),
    );
  }

  static String _initialsFor(String value) {
    final parts = value.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) {
      if (parts.first.isEmpty) {
        return 'T';
      }
      return parts.first.characters.take(1).toString().toUpperCase();
    }
    final first = parts.first.characters.take(1).toString().toUpperCase();
    final last = parts.last.characters.take(1).toString().toUpperCase();
    return '$first$last';
  }

  static String _formatHandle(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.startsWith('@') ? trimmed : '@$trimmed';
  }
}

class _FeedWelcomePage extends StatefulWidget {
  const _FeedWelcomePage({this.nextHandle});

  final String? nextHandle;

  @override
  State<_FeedWelcomePage> createState() => _FeedWelcomePageState();
}

class _FeedWelcomePageState extends State<_FeedWelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _backgroundController;
  late final AnimationController _pulseController;
  late final AnimationController _typographyController;
  late final AnimationController _particleController;
  late final AnimationController _shimmerController;
  late final Animation<double> _typographyAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _typographyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _typographyAnimation = CurvedAnimation(
      parent: _typographyController,
      curve: Curves.easeOutCubic,
    );
    _typographyController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _particleController.dispose();
    _typographyController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagline = AppTranslations.of(context, AppText.tagline);

    return Stack(
      fit: StackFit.expand,
      children: [
        _MeshGradientBackground(animation: _backgroundController),
        _ParticleField(animation: _particleController),
        _AnimatedGlowLayer(animation: _backgroundController),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _EnhancedPulsingLogo(animation: _pulseController),
                const SizedBox(height: 64),
                AnimatedBuilder(
                  animation: Listenable.merge([_typographyAnimation, _shimmerController]),
                  builder: (context, child) {
                    final fadeT = _typographyAnimation.value;
                    final shimmerT = _shimmerController.value;

                    return Opacity(
                      opacity: fadeT,
                      child: Transform.translate(
                        offset: Offset(0, (1 - fadeT) * 30),
                        child: Transform.scale(
                          scale: 0.8 + (fadeT * 0.2),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              final sweepPos = (shimmerT * 1.5) % 1.0;
                              return LinearGradient(
                                begin: Alignment(-1 + (sweepPos * 2.0), -0.5),
                                end: Alignment(1 + (sweepPos * 2.0), 0.5),
                                colors: const [
                                  Color(0xFFFFFFFF),
                                  Color(0xFF00D9A8),
                                  Color(0xFF6366F1),
                                  Color(0xFFFFFFFF),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              tagline,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                fontSize: 42,
                                height: 1.15,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF00D9A8).withOpacity(0.5),
                                    blurRadius: 20,
                                  ),
                                  Shadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 72),
                AnimatedBuilder(
                  animation: _typographyAnimation,
                  builder: (context, child) {
                    final delayedProgress = (_typographyAnimation.value - 0.6).clamp(0.0, 1.0) / 0.4;
                    return Opacity(
                      opacity: delayedProgress,
                      child: Transform.translate(
                        offset: Offset(0, (1 - delayedProgress) * 20),
                        child: Column(
                          children: [
                            _FloatingArrow(animation: _pulseController),
                            const SizedBox(height: 12),
                            Text(
                              'Swipe Up',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatHandle(String? value) {
    if (value == null) {
      return '';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.startsWith('@') ? trimmed : '@$trimmed';
  }
}

class _MeshGradientBackground extends StatelessWidget {
  const _MeshGradientBackground({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(painter: _MeshGradientPainter(animation.value));
      },
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  const _MeshGradientPainter(this.value);

  final double value;

  static const _baseColor = Color(0xFF0A1A1F);
  static const List<_MeshNode> _nodes = [
    _MeshNode(
      color: Color(0xFF00D9A8),
      origin: Offset(0.15, 0.20),
      offset: Offset(0.10, 0.08),
      radiusFactor: 1.1,
      phase: 0.0,
    ),
    _MeshNode(
      color: Color(0xFF6366F1),
      origin: Offset(0.80, 0.18),
      offset: Offset(0.08, 0.06),
      radiusFactor: 1.0,
      phase: 1.3,
    ),
    _MeshNode(
      color: Color(0xFFA855F7),
      origin: Offset(0.70, 0.80),
      offset: Offset(0.06, 0.09),
      radiusFactor: 1.05,
      phase: 2.6,
    ),
    _MeshNode(
      color: Color(0xFFFFB84D),
      origin: Offset(0.25, 0.82),
      offset: Offset(0.09, 0.07),
      radiusFactor: 0.95,
      phase: 3.5,
    ),
    _MeshNode(
      color: Color(0xFFFF6B9D),
      origin: Offset(0.50, 0.45),
      offset: Offset(0.05, 0.10),
      radiusFactor: 0.85,
      phase: 4.8,
    ),
    _MeshNode(
      color: Color(0xFF22D3EE),
      origin: Offset(0.35, 0.55),
      offset: Offset(0.07, 0.05),
      radiusFactor: 0.75,
      phase: 5.2,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    canvas.drawRect(Offset.zero & size, Paint()..color = _baseColor);

    final angle = value * 2 * math.pi;
    final maxDimension = math.max(size.width, size.height);

    for (final node in _nodes) {
      final center = Offset(
        size.width *
            (node.origin.dx + math.cos(angle + node.phase) * node.offset.dx),
        size.height *
            (node.origin.dy + math.sin(angle + node.phase) * node.offset.dy),
      );
      final radius = maxDimension * node.radiusFactor;

      final gradient = RadialGradient(
        colors: [
          node.color.withOpacity(0.88),
          Color.lerp(node.color, Colors.white, 0.3)!.withOpacity(0.42),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _MeshNode {
  const _MeshNode({
    required this.color,
    required this.origin,
    required this.offset,
    required this.radiusFactor,
    required this.phase,
  });

  final Color color;
  final Offset origin;
  final Offset offset;
  final double radiusFactor;
  final double phase;
}

class _AnimatedGlowLayer extends StatelessWidget {
  const _AnimatedGlowLayer({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value * 2 * math.pi;
        final alignment = Alignment(math.cos(t) * 0.7, math.sin(t) * 0.7);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: alignment,
              radius: 1.1,
              colors: [
                Colors.white.withOpacity(0.22),
                Colors.white.withOpacity(0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingLogo extends StatelessWidget {
  const _PulsingLogo({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 0.96 + (animation.value * 0.04);
        final glow = 0.2 + animation.value * 0.15;
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(glow * 0.4),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(glow * 0.8),
                blurRadius: 28 + (animation.value * 16),
                spreadRadius: 1 + (animation.value * 2),
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: const Center(
              child: ThalaLogo(size: 84, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedPulsingLogo extends StatelessWidget {
  const _EnhancedPulsingLogo({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 0.94 + (animation.value * 0.06);
        final glow = 0.3 + animation.value * 0.25;
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF00D9A8).withOpacity(glow * 0.6),
                const Color(0xFF6366F1).withOpacity(glow * 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9A8).withOpacity(glow * 0.7),
                blurRadius: 40 + (animation.value * 30),
                spreadRadius: 2 + (animation.value * 4),
              ),
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(glow * 0.5),
                blurRadius: 60 + (animation.value * 40),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(glow),
                blurRadius: 25 + (animation.value * 20),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: const Center(
              child: ThalaLogo(size: 92, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingArrow extends StatelessWidget {
  const _FloatingArrow({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final offset = math.sin(animation.value * math.pi * 2) * 8;
        final glow = 0.5 + animation.value * 0.3;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(glow * 0.4),
                  blurRadius: 20 + (animation.value * 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.white.withOpacity(0.95),
              size: 56,
            ),
          ),
        );
      },
    );
  }
}

class _ParticleField extends StatelessWidget {
  const _ParticleField({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(animation.value),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter(this.value);

  final double value;

  static const int _particleCount = 35;
  static const List<_Particle> _particles = [
    _Particle(startX: 0.15, startY: 0.25, speedY: 0.08, speedX: 0.02, size: 3.5, opacity: 0.6, phase: 0.0),
    _Particle(startX: 0.82, startY: 0.15, speedY: 0.12, speedX: -0.015, size: 2.8, opacity: 0.5, phase: 0.3),
    _Particle(startX: 0.45, startY: 0.75, speedY: 0.10, speedX: 0.025, size: 4.0, opacity: 0.7, phase: 0.6),
    _Particle(startX: 0.68, startY: 0.35, speedY: 0.09, speedX: -0.02, size: 3.2, opacity: 0.55, phase: 0.9),
    _Particle(startX: 0.28, startY: 0.55, speedY: 0.11, speedX: 0.018, size: 3.0, opacity: 0.65, phase: 1.2),
    _Particle(startX: 0.90, startY: 0.68, speedY: 0.07, speedX: -0.022, size: 3.8, opacity: 0.6, phase: 1.5),
    _Particle(startX: 0.12, startY: 0.88, speedY: 0.13, speedX: 0.015, size: 2.5, opacity: 0.5, phase: 1.8),
    _Particle(startX: 0.55, startY: 0.12, speedY: 0.08, speedX: 0.028, size: 3.6, opacity: 0.68, phase: 2.1),
    _Particle(startX: 0.38, startY: 0.42, speedY: 0.10, speedX: -0.018, size: 2.9, opacity: 0.58, phase: 2.4),
    _Particle(startX: 0.75, startY: 0.58, speedY: 0.09, speedX: 0.020, size: 3.3, opacity: 0.62, phase: 2.7),
    _Particle(startX: 0.20, startY: 0.72, speedY: 0.11, speedX: -0.025, size: 4.2, opacity: 0.72, phase: 3.0),
    _Particle(startX: 0.62, startY: 0.22, speedY: 0.12, speedX: 0.016, size: 2.7, opacity: 0.52, phase: 3.3),
    _Particle(startX: 0.48, startY: 0.85, speedY: 0.08, speedX: -0.019, size: 3.4, opacity: 0.64, phase: 3.6),
    _Particle(startX: 0.85, startY: 0.48, speedY: 0.10, speedX: 0.024, size: 3.1, opacity: 0.60, phase: 3.9),
    _Particle(startX: 0.32, startY: 0.18, speedY: 0.09, speedX: -0.017, size: 3.7, opacity: 0.66, phase: 4.2),
    _Particle(startX: 0.08, startY: 0.62, speedY: 0.13, speedX: 0.021, size: 2.6, opacity: 0.54, phase: 4.5),
    _Particle(startX: 0.72, startY: 0.92, speedY: 0.07, speedX: -0.023, size: 3.9, opacity: 0.70, phase: 4.8),
    _Particle(startX: 0.52, startY: 0.32, speedY: 0.11, speedX: 0.019, size: 3.0, opacity: 0.59, phase: 5.1),
    _Particle(startX: 0.95, startY: 0.28, speedY: 0.08, speedX: -0.026, size: 3.5, opacity: 0.63, phase: 5.4),
    _Particle(startX: 0.18, startY: 0.48, speedY: 0.12, speedX: 0.022, size: 2.8, opacity: 0.56, phase: 5.7),
    _Particle(startX: 0.65, startY: 0.08, speedY: 0.10, speedX: -0.020, size: 3.3, opacity: 0.61, phase: 6.0),
    _Particle(startX: 0.42, startY: 0.68, speedY: 0.09, speedX: 0.027, size: 4.1, opacity: 0.69, phase: 0.2),
    _Particle(startX: 0.88, startY: 0.82, speedY: 0.11, speedX: -0.016, size: 2.9, opacity: 0.57, phase: 0.5),
    _Particle(startX: 0.25, startY: 0.38, speedY: 0.08, speedX: 0.018, size: 3.6, opacity: 0.67, phase: 0.8),
    _Particle(startX: 0.58, startY: 0.52, speedY: 0.13, speedX: -0.024, size: 2.7, opacity: 0.53, phase: 1.1),
    _Particle(startX: 0.35, startY: 0.78, speedY: 0.09, speedX: 0.021, size: 3.4, opacity: 0.65, phase: 1.4),
    _Particle(startX: 0.78, startY: 0.42, speedY: 0.10, speedX: -0.019, size: 3.1, opacity: 0.59, phase: 1.7),
    _Particle(startX: 0.05, startY: 0.95, speedY: 0.12, speedX: 0.025, size: 3.8, opacity: 0.68, phase: 2.0),
    _Particle(startX: 0.92, startY: 0.55, speedY: 0.08, speedX: -0.022, size: 3.2, opacity: 0.62, phase: 2.3),
    _Particle(startX: 0.50, startY: 0.05, speedY: 0.11, speedX: 0.017, size: 2.9, opacity: 0.58, phase: 2.6),
    _Particle(startX: 0.68, startY: 0.72, speedY: 0.09, speedX: -0.020, size: 3.5, opacity: 0.64, phase: 2.9),
    _Particle(startX: 0.22, startY: 0.62, speedY: 0.10, speedX: 0.023, size: 4.0, opacity: 0.70, phase: 3.2),
    _Particle(startX: 0.85, startY: 0.18, speedY: 0.12, speedX: -0.018, size: 2.8, opacity: 0.55, phase: 3.5),
    _Particle(startX: 0.40, startY: 0.92, speedY: 0.08, speedX: 0.026, size: 3.3, opacity: 0.63, phase: 3.8),
    _Particle(startX: 0.60, startY: 0.28, speedY: 0.09, speedX: -0.021, size: 3.7, opacity: 0.66, phase: 4.1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    for (final particle in _particles) {
      final progress = (value + particle.phase) % 1.0;
      final x = size.width * (particle.startX + particle.speedX * progress);
      final y = size.height * ((particle.startY - particle.speedY * progress) % 1.0);

      final fadeIn = progress < 0.1 ? progress / 0.1 : 1.0;
      final fadeOut = progress > 0.9 ? (1.0 - progress) / 0.1 : 1.0;
      final opacity = particle.opacity * fadeIn * fadeOut;

      final gradient = RadialGradient(
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(
            center: Offset(x, y),
            radius: particle.size,
          ),
        );

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _Particle {
  const _Particle({
    required this.startX,
    required this.startY,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.opacity,
    required this.phase,
  });

  final double startX;
  final double startY;
  final double speedY;
  final double speedX;
  final double size;
  final double opacity;
  final double phase;
}

class _AnimatedGradientHeadline extends StatelessWidget {
  const _AnimatedGradientHeadline({
    required this.text,
    required this.animation,
    this.style,
  });

  final String text;
  final Animation<double> animation;
  final TextStyle? style;

  static const List<Color> _colors = [
    Color(0xFFFFFFFF),
    Color(0xFFE1FFFC),
    Color(0xFFE5C7FF),
  ];

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.headlineMedium;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 2 * math.pi;
        final gradient = LinearGradient(
          colors: _colors,
          transform: GradientRotation(angle),
        );
        return ShaderMask(
          shaderCallback: (Rect bounds) => gradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(text, textAlign: TextAlign.center, style: baseStyle),
        );
      },
    );
  }
}

class _CinematicTypeLine extends StatelessWidget {
  const _CinematicTypeLine({
    required this.text,
    required this.animation,
    this.shimmer,
    this.style,
  });

  final String text;
  final Animation<double> animation;
  final Animation<double>? shimmer;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseStyle =
        style ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        );
    final glyphs = text.characters.toList(growable: false);

    final listenable = shimmer == null
        ? animation
        : Listenable.merge(<Listenable>[animation, shimmer!]);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, child) {
        final revealT = animation.value.clamp(0.0, 1.0);
        final shimmerT = shimmer?.value ?? revealT;
        final total = glyphs.length;
        if (total == 0) {
          return const SizedBox.shrink();
        }

        final double timelineSpan = 0.7;
        final double perGlyphDelay = timelineSpan / math.max(total, 1);
        final double shimmerOffset = (shimmerT * 1.25) % 1.0;

        final spans = <InlineSpan>[];
        final double letterSpacing = baseStyle.letterSpacing ?? 0.0;

        for (var index = 0; index < total; index++) {
          final char = glyphs[index];

          if (char.trim().isEmpty) {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Text(' ', style: baseStyle),
              ),
            );
            continue;
          }

          final double normalizedIndex = total == 1 ? 0.5 : index / (total - 1);
          final double start = index * perGlyphDelay;
          final double end = start + 0.35;
          final double rawProgress = ((revealT - start) / (end - start)).clamp(
            0.0,
            1.0,
          );
          final double eased = Curves.easeOutCubic.transform(rawProgress);
          final double pop = rawProgress == 0.0
              ? 0.0
              : Curves.elasticOut.transform(rawProgress).clamp(0.0, 1.24);
          final double fade = Curves.easeInExpo
              .transform(rawProgress)
              .clamp(0.0, 1.0);

          final double highlightDelta = (normalizedIndex - shimmerOffset).abs();
          final double highlight = math
              .pow(math.max(0.0, 1.0 - highlightDelta * 2.8), 2.4)
              .toDouble();
          final double glowStrength = (fade * 0.5) + (highlight * 0.9);

          final Color baseColor = baseStyle.color ?? Colors.white;
          final Color primaryColor =
              Color.lerp(
                baseColor.withOpacity(0.65),
                Colors.white,
                glowStrength.clamp(0.0, 1.0),
              ) ??
              Colors.white;
          final Color accentGlow =
              Color.lerp(
                const Color(0xFF6CFFE4),
                Colors.white,
                1 - glowStrength.clamp(0.0, 1.0),
              ) ??
              const Color(0xFF6CFFE4);

          final double yOffset = (1 - pop.clamp(0.0, 1.0)) * 28.0;
          final double shimmerWave = math.sin(
            (shimmerT * 2.0 + index) * math.pi,
          );
          final double xJitter =
              (1 - eased) * (index.isEven ? -8.0 : 8.0) +
              shimmerWave * (1 - eased) * 2.4;
          final double rotation = (1 - eased) * 0.18 * (index.isOdd ? 1 : -1);
          final double scale = 0.9 + pop * 0.12 + highlight * 0.04;

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: letterSpacing * 0.5),
                child: Opacity(
                  opacity: fade,
                  child: Transform.translate(
                    offset: Offset(xJitter, yOffset),
                    child: Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          char,
                          style: baseStyle.copyWith(
                            color: primaryColor,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(
                                  0.14 + highlight * 0.38,
                                ),
                                blurRadius: 20 + highlight * 28,
                              ),
                              Shadow(
                                color: accentGlow.withOpacity(highlight * 0.45),
                                blurRadius: 24 + highlight * 32,
                              ),
                              Shadow(
                                color: const Color(
                                  0xFF0E352F,
                                ).withOpacity(fade * 0.35),
                                offset: const Offset(0, 3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: spans),
            ),
            IgnorePointer(
              child: Opacity(
                opacity: math.min(1.0, revealT * 1.4),
                child: ShaderMask(
                  blendMode: BlendMode.softLight,
                  shaderCallback: (Rect bounds) {
                    final double sweepHead = (shimmerT * 1.35) % 1.0;
                    return LinearGradient(
                      begin: Alignment(-1 + (sweepHead * 2.0), -1),
                      end: Alignment(1 + (sweepHead * 2.0), 1),
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  child: Container(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingTip extends StatelessWidget {
  const _FloatingTip({required this.text, required this.animation, this.style});

  final String text;
  final Animation<double> animation;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final offset = math.sin(animation.value * math.pi * 2) * 6;
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.32)),
          color: Colors.white.withOpacity(0.12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(text, textAlign: TextAlign.center, style: baseStyle),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Material(
      color: theme.colorScheme.error.withOpacity(0.85),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: theme.colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.inverseText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
