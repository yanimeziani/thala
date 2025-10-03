import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/user_profile_controller.dart';
import '../../models/user_profile.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../../ui/widgets/thala_snackbar.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  static Future<void> push(BuildContext context) {
    final controller = context.read<UserProfileController>();
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const ProfileDetailsPage(),
        ),
      ),
    );
  }

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _communityController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _bioController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _communityController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserProfileController>();
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final profile = controller.profile;
    final isSaving = controller.isSaving;

    if (profile != null && !_initialized) {
      _displayNameController.text = profile.displayName ?? '';
      _communityController.text = profile.community ?? '';
      _pronounsController.text = profile.pronouns ?? '';
      _bioController.text = profile.bio ?? '';
      _initialized = true;
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile details'),
        backgroundColor: Colors.transparent,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ThalaPageBackground(
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    children: [
                      ThalaGlassSurface(
                        cornerRadius: 28,
                        backgroundOpacity: theme.brightness == Brightness.dark
                            ? 0.24
                            : 0.68,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share how you show up in the Thala community.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _ThalaTextField(
                              controller: _displayNameController,
                              label: 'Display name',
                              hint: 'e.g. Tiziri Aït',
                              maxLength: 48,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please tell us how to address you.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _ThalaTextField(
                              controller: _pronounsController,
                              label: 'Pronouns (optional)',
                              hint: 'they / she / he',
                              maxLength: 24,
                            ),
                            const SizedBox(height: 16),
                            _ThalaTextField(
                              controller: _communityController,
                              label: 'Community ties',
                              hint:
                                  'Which village, city or collective holds you?',
                              maxLength: 80,
                            ),
                            const SizedBox(height: 16),
                            _ThalaTextField(
                              controller: _bioController,
                              label: 'Short bio',
                              hint:
                                  'Tell us about your role as a guardian or storyteller.',
                              maxLength: 220,
                              minLines: 3,
                              maxLines: 5,
                            ),
                            const SizedBox(height: 28),
                            FilledButton.icon(
                              onPressed: isSaving
                                  ? null
                                  : () => _handleSave(profile),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
                              ),
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_circle_outline),
                              label: Text(
                                isSaving ? 'Saving...' : 'Save changes',
                              ),
                            ),
                            if (!isSaving && controller.error != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                controller.error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
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
    );
  }

  Future<void> _handleSave(UserProfile? currentProfile) async {
    if (currentProfile == null) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final controller = context.read<UserProfileController>();
    final updated = currentProfile.copyWith(
      displayName: _normalize(_displayNameController.text),
      community: _normalize(_communityController.text),
      pronouns: _normalize(_pronounsController.text),
      bio: _normalize(_bioController.text),
    );

    final success = await controller.save(updated);
    if (!mounted) {
      return;
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildThalaSnackBar(
          context,
          icon: Icons.check_circle,
          iconColor: Theme.of(context).colorScheme.secondary,
          semanticsLabel: 'Profile updated.',
        ),
      );
      Navigator.of(context).pop();
    } else {
      final error = controller.error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildThalaSnackBar(
            context,
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            badgeColor: Theme.of(
              context,
            ).colorScheme.error.withValues(alpha: 0.24),
            semanticsLabel: error,
          ),
        );
      }
    }
  }

  String? _normalize(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

class _ThalaTextField extends StatelessWidget {
  const _ThalaTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    return TextFormField(
      controller: controller,
      validator: validator,
      style: theme.textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
        ),
        hintText: hint,
        hintStyle: theme.textTheme.bodySmall?.copyWith(
          color: palette.textMuted,
        ),
        counterStyle: theme.textTheme.bodySmall?.copyWith(
          color: palette.textMuted,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.secondary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
      ),
      cursorColor: theme.colorScheme.secondary,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.newline,
    );
  }
}
