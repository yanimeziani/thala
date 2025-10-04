import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../../ui/widgets/thala_logo.dart';

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    // Initialize Google Sign-In early
    _initializeGoogleSignIn();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      // Initialize Google Sign-In with web client ID for backend
      await GoogleSignIn.instance.initialize(
        serverClientId: '622637204479-fji413j8q5eu3glpvmqr3rao78ggo9l3.apps.googleusercontent.com',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google Sign-In initialization error: $e');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      print('Starting Google Sign-In...');
      // Use authenticate() in v7+ (replaces signIn())
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      print('Google Sign-In result: ${googleUser?.email}');

      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get authentication token'),
            ),
          );
        }
        return;
      }

      // Sign in with the backend
      if (mounted) {
        final authController = context.read<AuthController>();
        final success = await authController.signInWithGoogle(idToken);

        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authController.errorMessage ?? 'Sign in failed'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = theme.brightness == Brightness.dark;
    final isAuthenticating = auth.isAuthenticating;
    final error = auth.errorMessage;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Gradient background matching splash screen
          Container(
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
          ),

          // Animated background patterns matching splash screen
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

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo matching splash screen
                        AnimatedBuilder(
                          animation: _animationController,
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
                                  child: const ThalaLogo(size: 100),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Title - More premium, generous spacing
                        Text(
                          'Thala',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2.0,
                            fontSize: 56,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle - Cleaner, more refined
                        Text(
                          'Connect • Share • Celebrate',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: palette.textSecondary,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Amazigh culture, together',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: palette.textMuted,
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 64),

                        // Login card - More premium with softer edges
                        ThalaGlassSurface(
                          cornerRadius: 24,
                          padding: const EdgeInsets.all(36),
                          backgroundOpacity: isDark ? 0.35 : 0.80,
                          child: Column(
                            children: [
                              Text(
                                'Sign in to continue',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Google Sign-In Button - More premium design
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: isAuthenticating ? null : _handleGoogleSignIn,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1F1F1F),
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.black.withOpacity(0.08),
                                  ),
                                  icon: Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 28,
                                    width: 28,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.g_mobiledata, size: 32);
                                    },
                                  ),
                                  label: Text(
                                    'Continue with Google',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF1F1F1F),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                              // Error message
                              if (error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: theme.colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          error,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Loading indicator
                              if (isAuthenticating) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? const Color(0xFFEB6A3B)
                                          : const Color(0xFF1A4AA8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
