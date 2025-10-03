import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notification_settings_controller.dart';
import '../../controllers/user_profile_controller.dart';
import '../../l10n/app_translations.dart';
import '../../models/user_profile.dart';
import '../../services/preference_store.dart';
import '../../ui/widgets/thala_snackbar.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../auth/email_password_login_page.dart';
import '../legal/copyright_page.dart';
import 'help_center_page.dart';
import 'language_settings_page.dart';
import 'notification_settings_page.dart';
import 'profile_details_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final preferenceStore = context.read<PreferenceStore>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProfileController>(
          create: (_) => UserProfileController(
            authController: auth,
            preferenceStore: preferenceStore,
          ),
        ),
        ChangeNotifierProvider<NotificationSettingsController>(
          create: (_) =>
              NotificationSettingsController(preferenceStore: preferenceStore),
        ),
      ],
      child: const _ProfilePageBody(),
    );
  }
}

class _ProfilePageBody extends StatelessWidget {
  const _ProfilePageBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = context.isDarkMode;
    final profileController = context.watch<UserProfileController>();
    final auth = context.watch<AuthController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
            isDark ? const Color(0xFF000000) : const Color(0xFFF0F0F0),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
          children: [
            _ProfileHeader(
              profile: profileController.profile,
              isLoading: profileController.isLoading,
            ),
            const SizedBox(height: 48),
            _SettingsGroup(
              title: 'Account',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile details',
                  subtitle: 'Update your name, pronouns, and cultural ties.',
                  onTap: () {
                    if (profileController.isLoading) {
                      return;
                    }
                    if (profileController.profile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        buildThalaSnackBar(
                          context,
                          icon: Icons.lock_outline,
                          iconColor: theme.colorScheme.error,
                          badgeColor: theme.colorScheme.error.withValues(
                            alpha: 0.24,
                          ),
                          semanticsLabel: 'Sign in to edit your profile.',
                        ),
                      );
                      return;
                    }
                    ProfileDetailsPage.push(context);
                  },
                ),
                if (auth.status == AuthStatus.authenticated)
                  _SettingsTile(
                    icon: Icons.logout,
                    title: 'Sign out',
                    subtitle: 'Disconnect from this device.',
                    onTap: () async {
                      await auth.signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          buildThalaSnackBar(
                            context,
                            icon: Icons.logout,
                            iconColor: theme.colorScheme.secondary,
                            semanticsLabel: 'Signed out of Thala.',
                          ),
                        );
                      }
                    },
                  )
                else
                  _SettingsTile(
                    icon: Icons.login,
                    title: 'Sign in',
                    subtitle: 'Access saved stories and communities.',
                    onTap: () {
                      auth.clearError();
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const EmailPasswordLoginPage(),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 28),
            _SettingsGroup(
              title: 'Settings',
              children: [
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Switch between English and French.',
                  onTap: () => LanguageSettingsPage.push(context),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Choose how Thala reaches you.',
                  onTap: () => NotificationSettingsPage.push(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SettingsGroup(
              title: 'Support & safety',
              children: [
                _SettingsTile(
                  icon: Icons.gavel_outlined,
                  title: 'Claims & safety',
                  subtitle: 'Request takedowns or report cultural misuse.',
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const RightsPage(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help centre',
                  subtitle: 'Guides for storytellers and guardians.',
                  onTap: () => HelpCenterPage.push(context),
                ),
              ],
            ),
            if (profileController.error != null &&
                !profileController.isSaving) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(
                    isDark ? 0.22 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.error),
                ),
                child: Text(
                  profileController.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.isLoading});

  final UserProfile? profile;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final useLiquidGlass =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    Widget wrapWithGlass(Widget child) {
      final surfaceTint = palette.surfaceBright.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.18 : 0.7,
      );
      final borderColor = palette.border.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.4 : 0.24,
      );

      final decorated = DecoratedBox(
        decoration: BoxDecoration(
          color: surfaceTint,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: child,
        ),
      );

      if (!useLiquidGlass) {
        return decorated;
      }

      return LiquidGlass(
        glassContainsChild: false,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(28),
        ),
        settings: const LiquidGlassSettings(
          thickness: 8,
          blur: 14,
          glassColor: Color(0x24FFFFFF),
          ambientStrength: 0.28,
          lightIntensity: 1.1,
          blend: 18,
          saturation: 1.02,
          lightness: 1.01,
        ),
        child: decorated,
      );
    }

    if (isLoading && profile == null) {
      return wrapWithGlass(
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withOpacity(0.72),
                border: Border.all(color: palette.border),
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Loading profile...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final displayName = _resolveDisplayName(context, profile);
    final email = profile?.email ?? 'guest@thala.culture';
    final pronouns = _clean(profile?.pronouns);
    final community = _clean(profile?.community);
    final bio = _clean(profile?.bio);
    final initial = _initialFor(profile);

    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceBright.withOpacity(theme.brightness == Brightness.dark ? 0.08 : 0.4),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.2),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: palette.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          if (pronouns != null) ...[
            const SizedBox(height: 6),
            Text(
              pronouns,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary.withOpacity(0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
          if (community != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    community,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (bio != null) ...[
            const SizedBox(height: 18),
            Text(
              bio,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _resolveDisplayName(BuildContext context, UserProfile? profile) {
  final name = _clean(profile?.displayName);
  if (name != null) {
    return name;
  }
  final email = _clean(profile?.email);
  if (email != null) {
    final parts = email.split('@');
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first;
    }
    return email;
  }
  return AppTranslations.of(context, AppText.viewProfile);
}

String _initialFor(UserProfile? profile) {
  final name = _clean(profile?.displayName);
  if (name != null && name.isNotEmpty) {
    return name.substring(0, 1).toUpperCase();
  }
  final email = _clean(profile?.email);
  if (email != null && email.isNotEmpty) {
    return email.substring(0, 1).toUpperCase();
  }
  return 'ⵣ';
}

String? _clean(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<_SettingsTile> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.textSecondary.withOpacity(0.6),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: palette.surfaceBright.withOpacity(theme.brightness == Brightness.dark ? 0.06 : 0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.08),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: palette.iconMuted.withOpacity(0.4),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTileRow extends StatelessWidget {
  const _SettingsTileRow({required this.tile, required this.showDivider});

  final _SettingsTile tile;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        tile,
        if (showDivider)
          Divider(height: 1, indent: 72, color: context.thalaPalette.border),
      ],
    );
  }
}

// ignore: unused_element
void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    buildThalaSnackBar(
      context,
      icon: Icons.auto_awesome,
      iconColor: Theme.of(context).colorScheme.secondary,
      semanticsLabel: 'Coming soon to Thala.',
    ),
  );
}
