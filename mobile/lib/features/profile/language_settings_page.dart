import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/localization_controller.dart';
import '../../l10n/app_translations.dart';
import '../../ui/widgets/thala_glass_surface.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const LanguageSettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = context.watch<LocalizationController>();
    final language = localization.language;
    String tr(AppText key) => AppTranslations.of(context, key);

    final palette = context.thalaPalette;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(tr(AppText.languageTitle)),
        backgroundColor: Colors.transparent,
      ),
      body: ThalaPageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              ThalaGlassSurface(
                cornerRadius: 26,
                backgroundOpacity: theme.brightness == Brightness.dark
                    ? 0.22
                    : 0.62,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(AppText.languageDescription),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _LanguageTile(
                      title: AppTranslations.of(
                        context,
                        AppText.languageEnglish,
                      ),
                      subtitle: tr(AppText.languageEnglishSubtitle),
                      value: AppLanguage.english,
                      groupValue: language,
                      onChanged: (value) => localization.setLanguage(value),
                    ),
                    const SizedBox(height: 12),
                    _LanguageTile(
                      title: tr(AppText.languageFrenchTitle),
                      subtitle: tr(AppText.languageFrenchSubtitle),
                      value: AppLanguage.french,
                      groupValue: language,
                      onChanged: (value) => localization.setLanguage(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final AppLanguage value;
  final AppLanguage groupValue;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = context.isDarkMode;
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? palette.surfaceStrong : palette.surfaceBright)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : palette.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? theme.colorScheme.secondary
                  : palette.iconMuted,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
