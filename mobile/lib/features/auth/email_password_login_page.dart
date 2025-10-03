import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

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
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Static background - no animation
    _backgroundAnimation = Tween<double>(begin: 0.5, end: 0.5).animate(
      _animationController,
    );

    _animationController.forward();
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
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF0A1628),
                            Color.lerp(
                              const Color(0xFF1A4AA8),
                              const Color(0xFFEB6A3B),
                              (math.sin(_backgroundAnimation.value * 2 * math.pi) + 1) / 2,
                            )!.withValues(alpha: 0.1),
                            const Color(0xFF050607),
                          ]
                        : [
                            const Color(0xFFF5F6FA),
                            Color.lerp(
                              const Color(0xFFEB6A3B),
                              const Color(0xFF1A4AA8),
                              (math.sin(_backgroundAnimation.value * 2 * math.pi) + 1) / 2,
                            )!.withValues(alpha: 0.08),
                            const Color(0xFFE8EBF5),
                          ],
                  ),
                ),
              );
            },
          ),

          // Decorative community icons
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                final offset = (index * 80.0) + (_backgroundAnimation.value * 50);
                return Positioned(
                  top: 120 + (index * 150.0) - offset,
                  right: index % 2 == 0 ? 20 : null,
                  left: index % 2 != 0 ? 20 : null,
                  child: Opacity(
                    opacity: 0.04,
                    child: Transform.rotate(
                      angle: (index * 0.4) + (_backgroundAnimation.value * 0.2),
                      child: Icon(
                        [
                          Icons.people,
                          Icons.favorite,
                          Icons.festival,
                          Icons.music_note,
                          Icons.language,
                        ][index],
                        size: 100,
                        color: isDark ? const Color(0xFFEB6A3B) : const Color(0xFF1A4AA8),
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
                          // Logo and welcome header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? const Color(0xFFEB6A3B)
                                          : const Color(0xFF1A4AA8))
                                      .withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const ThalaLogo(size: 80),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isLogin ? 'Welcome back!' : 'Join our community',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin
                                ? 'Sign in to continue your journey'
                                : 'Create an account to get started',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: palette.textSecondary,
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
    // TODO: Implement Google Sign-In flow
    // This requires platform-specific setup and getting the ID token
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
