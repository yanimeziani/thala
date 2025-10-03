import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../../ui/widgets/thala_logo.dart';

enum AuthMode { login, register }

class EmailPasswordLoginPage extends StatefulWidget {
  const EmailPasswordLoginPage({super.key});

  @override
  State<EmailPasswordLoginPage> createState() => _EmailPasswordLoginPageState();
}

class _EmailPasswordLoginPageState extends State<EmailPasswordLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  AuthMode _authMode = AuthMode.login;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
      context.read<AuthController>().clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = theme.brightness == Brightness.dark;
    final isAuthenticating = auth.isAuthenticating;
    final error = auth.errorMessage;
    final isLogin = _authMode == AuthMode.login;

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

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
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
                                    padding: const EdgeInsets.all(20),
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
                                    child: const ThalaLogo(size: 80),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          Text(
                            isLogin ? 'Welcome back!' : 'Join our community',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.5,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isLogin
                                ? 'Connect • Share • Celebrate'
                                : 'Connect • Share • Celebrate',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: palette.textSecondary,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin
                                ? 'Sign in to continue your journey'
                                : 'Create an account to get started',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: palette.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Auth form card
                          ThalaGlassSurface(
                            cornerRadius: 28,
                            backgroundOpacity: isDark ? 0.3 : 0.75,
                            padding: const EdgeInsets.all(28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Name field for registration
                                  if (!isLogin) ...[
                                    TextFormField(
                                      controller: _nameController,
                                      enabled: !isAuthenticating,
                                      keyboardType: TextInputType.name,
                                      autofillHints: const [AutofillHints.name],
                                      style: theme.textTheme.bodyLarge,
                                      decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        hintText: 'Your name',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: palette.iconPrimary,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (!isLogin && (value == null || value.trim().isEmpty)) {
                                          return 'Please enter your name.';
                                        }
                                        return null;
                                      },
                                      onChanged: (_) =>
                                          context.read<AuthController>().clearError(),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    enabled: !isAuthenticating,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    style: theme.textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'you@example.com',
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: palette.iconPrimary,
                                      ),
                                    ),
                                    validator: _validateEmail,
                                    onChanged: (_) =>
                                        context.read<AuthController>().clearError(),
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field
                                  TextFormField(
                                    controller: _passwordController,
                                    enabled: !isAuthenticating,
                                    autofillHints: isLogin
                                        ? const [AutofillHints.password]
                                        : const [AutofillHints.newPassword],
                                    obscureText: _obscurePassword,
                                    style: theme.textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: palette.iconPrimary,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        }),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: palette.iconPrimary,
                                        ),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                    onChanged: (_) =>
                                        context.read<AuthController>().clearError(),
                                    onFieldSubmitted: (_) => _submit(context),
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

                                  const SizedBox(height: 28),

                                  // Submit button
                                  FilledButton(
                                    onPressed: isAuthenticating
                                        ? null
                                        : () => _submit(context),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.colorScheme.secondary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: isAuthenticating
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                            ),
                                          )
                                        : Text(isLogin ? 'Sign in' : 'Create account'),
                                  ),

                                  const SizedBox(height: 16),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: palette.border)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'or',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: palette.textMuted,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: palette.border)),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Google Sign-In button
                                  OutlinedButton.icon(
                                    onPressed: isAuthenticating
                                        ? null
                                        : () => _signInWithGoogle(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(color: palette.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(Icons.g_mobiledata, size: 28),
                                    label: Text(
                                      'Continue with Google',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Toggle auth mode
                          TextButton(
                            onPressed: isAuthenticating ? null : _toggleAuthMode,
                            child: RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: palette.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: isLogin
                                        ? "Don't have an account? "
                                        : "Already have an account? ",
                                  ),
                                  TextSpan(
                                    text: isLogin ? 'Sign up' : 'Sign in',
                                    style: TextStyle(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.';
    }
    final email = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();

    final authController = context.read<AuthController>();

    if (_authMode == AuthMode.register) {
      await authController.registerWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
      );
    } else {
      await authController.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '622637204479-afmv3jontq583poaqefe1r0vlinjembo.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

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
}
