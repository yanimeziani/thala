import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_theme.dart';
import '../../l10n/app_translations.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../archive/archive_page.dart';
import '../events/events_page.dart';
import '../music/music_page.dart';

class ExploreHubPage extends StatelessWidget {
  const ExploreHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = theme.brightness == Brightness.dark;
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textSecondary,
    );

    final options = [
      _HubOption(
        icon: Icons.event_outlined,
        title: AppTranslations.of(context, AppText.eventsTab),
        description:
            'Discover upcoming gatherings, festivals, and workshops across the Amazigh world.',
        builder: (_) => const EventsPage(),
      ),
      _HubOption(
        icon: Icons.collections_bookmark_outlined,
        title: AppTranslations.of(context, AppText.archiveTab),
        description: 'Explore the cultural archive curated by the community.',
        builder: (_) => const ArchivePage(),
      ),
      _HubOption(
        icon: Icons.graphic_eq,
        title: 'Music',
        description: 'Listen to playlists celebrating Amazigh voices.',
        builder: (_) => const MusicPage(),
      ),
    ];

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [palette.surfaceDim, theme.scaffoldBackgroundColor]
          : [palette.surfaceBright, theme.scaffoldBackgroundColor],
    );

    return ThalaPageBackground(
      colors: gradient.colors,
      begin: gradient.begin,
      end: gradient.end,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            ThalaGlassSurface(
              cornerRadius: 26,
              backgroundOpacity: theme.brightness == Brightness.dark
                  ? 0.22
                  : 0.62,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: palette.surfaceSubtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.border),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.explore_outlined,
                      color: palette.iconPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore', style: titleStyle),
                        const SizedBox(height: 4),
                        Text(
                          'Choose a space to keep exploring Amazigh culture.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            for (final option in options) ...[
              _HubCard(option: option),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _HubOption {
  const _HubOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String description;
  final WidgetBuilder builder;
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.option});

  final _HubOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textSecondary,
    );

    return ThalaGlassSurface(
      cornerRadius: 24,
      backgroundOpacity: theme.brightness == Brightness.dark ? 0.22 : 0.62,
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(
              context,
            ).push<void>(MaterialPageRoute<void>(builder: option.builder));
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: palette.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.border),
                  ),
                  child: Icon(
                    option.icon,
                    color: palette.iconPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.title, style: titleStyle),
                      const SizedBox(height: 6),
                      Text(option.description, style: bodyStyle),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: palette.iconMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
