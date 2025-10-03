import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../app/app_theme.dart';
import '../../ui/widgets/thala_logo.dart';

/// Warm, community-focused splash screen with animated welcome
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Continuous pulse for community feel
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A1628),
                    const Color(0xFF1A4AA8).withValues(alpha: 0.15),
                    const Color(0xFF050607),
                  ]
                : [
                    const Color(0xFFF5F6FA),
                    const Color(0xFFEB6A3B).withValues(alpha: 0.06),
                    const Color(0xFFE8EBF5),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background patterns
            ...List.generate(6, (index) {
              return AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final offset = (index * 60.0) + (_pulseAnimation.value * 40);
                  return Positioned(
                    top: 100 + (index * 120.0) - offset,
                    left: 20 + (index % 2 * 200.0),
                    child: Opacity(
                      opacity: 0.03 + (math.sin(_pulseAnimation.value * math.pi) * 0.02),
                      child: Transform.rotate(
                        angle: (index * 0.3) + (_pulseAnimation.value * 0.1),
                        child: Icon(
                          [
                            Icons.language,
                            Icons.music_note,
                            Icons.people,
                            Icons.favorite,
                            Icons.festival,
                            Icons.explore,
                          ][index],
                          size: 80,
                          color: isDark
                              ? const Color(0xFFEB6A3B)
                              : const Color(0xFF1A4AA8),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                            ? const Color(0xFFEB6A3B)
                                            : const Color(0xFF1A4AA8))
                                        .withValues(alpha: 0.2 + (math.sin(_pulseAnimation.value * math.pi) * 0.1)),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const ThalaLogo(size: 120),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Animated welcome text
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlide,
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                Text(
                                  'Thala',
                                  style: theme.textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1.5,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Connect • Share • Celebrate',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: palette.textSecondary,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Amazigh culture, together',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: palette.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 64),

                    // Animated loading indicator
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark
                                  ? const Color(0xFFEB6A3B)
                                  : const Color(0xFF1A4AA8),
                            ),
                            backgroundColor: palette.border,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
