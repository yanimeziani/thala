import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_theme.dart';
import '../../controllers/search_experience_controller.dart';
import '../../l10n/app_translations.dart';
import '../../models/search_hit.dart';
import '../../ui/widgets/thala_glass_surface.dart';
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
  late final SearchExperienceController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = SearchExperienceController();
    _searchController.addListener(_handleSearchStateChanged);
  }

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
    _searchController.removeListener(_handleSearchStateChanged);
    _searchController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearchStateChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _handleQueryChanged(String value) {
    setState(() => _query = value.trim());
    _searchController.updateQuery(value);
  }

  void _handleSubmitted(String value) {
    if (_searchController.isRemoteEnabled) {
      unawaited(_searchController.submitQuery(value));
      return;
    }
    // Just submit the search, don't navigate away
    HapticFeedback.selectionClick();
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

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final query = _query;
    final filteredOptions = _filteredOptions;
    final searchState = _searchController;
    final showRemote = searchState.isRemoteEnabled && query.isNotEmpty;

    return ThalaPageBackground(
      padding: const EdgeInsets.only(bottom: 96),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThalaGlassSurface(
                cornerRadius: 22,
                backgroundOpacity: isDark ? 0.14 : 0.28,
                enableBorder: false,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Material(
                  type: MaterialType.transparency,
                  child: Row(
                    children: [
                      Icon(Icons.search, color: palette.iconPrimary.withOpacity(0.7), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _handleQueryChanged,
                          onSubmitted: _handleSubmitted,
                          textInputAction: TextInputAction.search,
                          cursorColor: theme.colorScheme.secondary,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: 'Search everything...',
                          ),
                        ),
                      ),
                      if (query.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.close, color: palette.iconPrimary.withOpacity(0.6), size: 20),
                          onPressed: () {
                            _controller.clear();
                            _handleQueryChanged('');
                            focusSearchField();
                          },
                          splashRadius: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: query.isEmpty
                      ? _SearchPlaceholder(key: const ValueKey('placeholder'))
                      : showRemote
                          ? _RemoteSearchResults(
                              key: ValueKey(
                                'remote-${searchState.results.length}-${searchState.isLoading}-${searchState.errorMessage}-$query',
                              ),
                              controller: searchState,
                              query: query,
                            )
                          : Center(
                              key: ValueKey('empty-$query'),
                              child: _SearchEmptyState(query: query),
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

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 72,
            color: palette.iconMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Search all of Thala',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Videos, Events, Music, Archive & Communities',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteSearchResults extends StatelessWidget {
  const _RemoteSearchResults({
    super.key,
    required this.controller,
    required this.query,
  });

  final SearchExperienceController controller;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = controller.errorMessage;
    if (error != null) {
      return _SearchErrorState(
        message: error,
        onRetry: controller.retry,
      );
    }

    final results = controller.results;
    if (results.isEmpty) {
      return Center(
        child: _SearchEmptyState(query: query),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultCard(result: result);
      },
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: palette.iconMuted, size: 48),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.textSecondary,
                  ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry search'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result});

  final SearchHit result;

  IconData _iconForKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill;
      case 'music':
      case 'track':
        return Icons.music_note;
      case 'event':
        return Icons.event;
      case 'community':
        return Icons.groups;
      default:
        return Icons.travel_explore;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textSecondary,
    );

    final imageUrl = result.imageUrl;

    Widget leading;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackIcon(
            icon: _iconForKind(result.kind),
          ),
        ),
      );
    } else {
      leading = _FallbackIcon(icon: _iconForKind(result.kind));
    }

    return ThalaGlassSurface(
      cornerRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.title, style: titleStyle),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: palette.surfaceSubtle,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        result.kind.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                    if (result.subtitle != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          result.subtitle!,
                          style: subtitleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: palette.iconPrimary, size: 28),
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
    final palette = context.thalaPalette;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textSecondary,
    );

    return ThalaGlassSurface(
      cornerRadius: 20,
      backgroundOpacity: theme.brightness == Brightness.dark ? 0.16 : 0.28,
      enableBorder: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(option.icon, color: palette.iconPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title, style: titleStyle),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(option.subtitle!, style: bodyStyle),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios, color: palette.iconMuted.withOpacity(0.5), size: 16),
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
    final palette = context.thalaPalette;
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
    final palette = context.thalaPalette;

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
