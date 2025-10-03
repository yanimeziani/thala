import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_theme.dart';
import '../../l10n/app_translations.dart';
import '../../ui/widgets/thela_glass_surface.dart';
import '../archive/archive_page.dart';
import '../community/community_page.dart';
import '../events/events_page.dart';
import '../explore/explore_hub_page.dart';
import '../music/music_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  List<_ResolvedSearchOption> get _resolvedOptions {
    final options = _SearchCatalog.options;
    return options.map((option) => option.resolve(context)).toList();
  }

  void focusSearchField() {
    if (!mounted) {
      return;
    }
    if (_focusNode.hasPrimaryFocus) {
      return;
    }
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleQueryChanged(String value) {
    setState(() => _query = value.trim());
  }

  void _handleSubmitted(String value) {
    final results = _filteredOptions;
    if (results.isEmpty) {
      HapticFeedback.selectionClick();
      return;
    }
    _openOption(results.first);
  }

  List<_ResolvedSearchOption> get _filteredOptions {
    final options = _resolvedOptions;
    final query = _query.toLowerCase();
    if (query.isEmpty) {
      return options;
    }
    return options.where((option) {
      final haystack = '${option.title} ${option.subtitle ?? ''}'
          .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  void _openOption(_ResolvedSearchOption option) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: option.builder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final query = _query;
    final filteredOptions = _filteredOptions;

    return ThelaPageBackground(
      padding: const EdgeInsets.only(bottom: 96),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThelaGlassSurface(
                cornerRadius: 26,
                backgroundOpacity: isDark ? 0.18 : 0.34,
                enableBorder: false,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Material(
                  type: MaterialType.transparency,
                  child: Row(
                    children: [
                      _SearchActionButton(
                        icon: Icons.search,
                        color: palette.iconPrimary,
                        onTap: focusSearchField,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _handleQueryChanged,
                          onSubmitted: _handleSubmitted,
                          textInputAction: TextInputAction.search,
                          cursorColor: theme.colorScheme.secondary,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: AppTranslations.of(
                              context,
                              AppText.archiveSearchPlaceholder,
                            ),
                          ),
                        ),
                      ),
                      if (query.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        _SearchActionButton(
                          icon: Icons.close,
                          color: palette.iconPrimary,
                          onTap: () {
                            _controller.clear();
                            _handleQueryChanged('');
                            focusSearchField();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: filteredOptions.isEmpty
                      ? _SearchEmptyState(query: query)
                      : ListView.separated(
                          key: ValueKey('results-${filteredOptions.length}-$query'),
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: filteredOptions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final option = filteredOptions[index];
                            return _SearchOptionCard(
                              option: option,
                              onTap: () => _openOption(option),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchOption {
  const _SearchOption({
    required this.icon,
    required this.titleText,
    this.subtitleText,
    required this.builder,
  });

  final IconData icon;
  final AppText titleText;
  final AppText? subtitleText;
  final WidgetBuilder builder;

  _ResolvedSearchOption resolve(BuildContext context) {
    final translations = AppTranslations.of;
    return _ResolvedSearchOption(
      icon: icon,
      title: translations(context, titleText),
      subtitle: subtitleText != null ? translations(context, subtitleText!) : null,
      builder: builder,
    );
  }
}

class _ResolvedSearchOption {
  const _ResolvedSearchOption({
    required this.icon,
    required this.title,
    required this.builder,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final WidgetBuilder builder;
}

class _SearchOptionCard extends StatelessWidget {
  const _SearchOptionCard({
    required this.option,
    required this.onTap,
  });

  final _ResolvedSearchOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textSecondary,
    );

    return ThelaGlassSurface(
      cornerRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
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
                alignment: Alignment.center,
                child: Icon(option.icon, color: palette.iconPrimary, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title, style: titleStyle),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(option.subtitle!, style: bodyStyle),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios, color: palette.iconMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final message = AppTranslations.of(context, AppText.archiveSearchEmpty);

    return Column(
      key: ValueKey('empty-$query'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.travel_explore, color: palette.iconMuted, size: 48),
        const SizedBox(height: 18),
        Text(
          message,
          style: theme.textTheme.titleMedium?.copyWith(
            color: palette.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SearchActionButton extends StatelessWidget {
  const _SearchActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;

    return SizedBox(
      height: 40,
      width: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.overlay.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18),
            highlightColor: Colors.transparent,
            child: Center(child: Icon(icon, color: color, size: 20)),
          ),
        ),
      ),
    );
  }
}

class _SearchCatalog {
  static List<_SearchOption> get options => [
        _SearchOption(
          icon: Icons.explore_outlined,
          titleText: AppText.exploreTab,
          subtitleText: AppText.browseCommunities,
          builder: (_) => const ExploreHubPage(),
        ),
        _SearchOption(
          icon: Icons.collections_bookmark_outlined,
          titleText: AppText.discoverArchive,
          subtitleText: AppText.archiveSearchPlaceholder,
          builder: (_) => const ArchivePage(),
        ),
        _SearchOption(
          icon: Icons.event_outlined,
          titleText: AppText.eventsTab,
          subtitleText: AppText.eventsSubtitle,
          builder: (_) => const EventsPage(),
        ),
        _SearchOption(
          icon: Icons.library_music_outlined,
          titleText: AppText.musicTitle,
          subtitleText: AppText.musicSubtitle,
          builder: (_) => const MusicPage(),
        ),
        _SearchOption(
          icon: Icons.groups_outlined,
          titleText: AppText.communityTab,
          subtitleText: AppText.browseCommunities,
          builder: (_) => const CommunityPage(),
        ),
      ];
}
