import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../l10n/app_translations.dart';
import '../../ui/widgets/thela_glass_surface.dart';
import '../profile/profile_page.dart';

class RightsPage extends StatelessWidget {
  const RightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    final title = AppTranslations.of(context, AppText.rightsTitle);
    final intro = AppTranslations.of(context, AppText.rightsIntro);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ThelaPageBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              ThelaGlassSurface(
                enableBorder: false,
                cornerRadius: 28,
                backgroundOpacity: theme.brightness == Brightness.dark
                    ? 0.24
                    : 0.68,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_moon_outlined,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.headlineSmall?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                intro,
                style: textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _RightsInfoBlock(
                titleKey: AppText.rightsBeforeTitle,
                itemKeys: const [
                  AppText.rightsBeforeItem1,
                  AppText.rightsBeforeItem2,
                  AppText.rightsBeforeItem3,
                ],
              ),
              const SizedBox(height: 24),
              _RightsInfoBlock(
                titleKey: AppText.rightsSendTitle,
                itemKeys: const [
                  AppText.rightsSendItem1,
                  AppText.rightsSendItem2,
                  AppText.rightsSendItem3,
                  AppText.rightsSendItem4,
                  AppText.rightsSendItem5,
                ],
              ),
              const SizedBox(height: 24),
              _RightsInfoBlock(
                titleKey: AppText.rightsNextTitle,
                itemKeys: const [
                  AppText.rightsNextItem1,
                  AppText.rightsNextItem2,
                  AppText.rightsNextItem3,
                  AppText.rightsNextItem4,
                ],
              ),
              const SizedBox(height: 36),
              _EmergencyCard(),
              const SizedBox(height: 28),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  AppTranslations.of(context, AppText.rightsOpenAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightsInfoBlock extends StatelessWidget {
  const _RightsInfoBlock({required this.titleKey, required this.itemKeys});

  final AppText titleKey;
  final List<AppText> itemKeys;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final textTheme = theme.textTheme;
    return ThelaGlassSurface(
      cornerRadius: 24,
      backgroundOpacity: context.isDarkMode ? 0.24 : 0.62,
      borderColor: palette.border,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.of(context, titleKey),
            style: textTheme.titleMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in itemKeys) _RightsBullet(textKey: item),
        ],
      ),
    );
  }
}

class _RightsBullet extends StatelessWidget {
  const _RightsBullet({required this.textKey});

  final AppText textKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: theme.colorScheme.secondary)),
          Expanded(
            child: Text(
              AppTranslations.of(context, textKey),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final textTheme = theme.textTheme;
    final gradient = LinearGradient(
      colors: context.isDarkMode
          ? const [Color(0xFF1D3C41), Color(0xFF06090E)]
          : [palette.surfaceBright, palette.surfaceDim],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ThelaGlassSurface(
      enableBorder: false,
      cornerRadius: 24,
      backgroundOpacity: context.isDarkMode ? 0.2 : 0.5,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.32),
          ),
          gradient: gradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.of(context, AppText.rightsEmergencyTitle),
              style: textTheme.titleMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTranslations.of(context, AppText.rightsEmergencyDescription),
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Deprecated('Use RightsPage instead.')
class CopyrightPage extends StatelessWidget {
  const CopyrightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RightsPage();
  }
}
