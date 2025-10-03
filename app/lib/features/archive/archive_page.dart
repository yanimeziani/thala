import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../data/archive_repository.dart';
import '../../data/sample_archive_entries.dart';
import '../../l10n/app_translations.dart';
import '../../models/archive_entry.dart';
import '../../ui/widgets/thala_glass_surface.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';
  final ArchiveRepository _repository = ArchiveRepository();
  List<ArchiveEntry> _allEntries = const <ArchiveEntry>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleQueryListener);
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleQueryListener);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleQueryListener() {
    final nextQuery = _searchController.text;
    if (nextQuery == _query) {
      return;
    }
    setState(() => _query = nextQuery);
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _repository.fetchEntries();
      setState(() {
        _allEntries = entries;
        _isLoading = false;
        if (!_repository.isRemoteEnabled) {
          _errorMessage = 'Backend is not configured. Showing curated examples.';
        }
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load archive entries: $error\n$stackTrace');
      setState(() {
        _allEntries = const <ArchiveEntry>[];
        _isLoading = false;
        _errorMessage = 'Unable to load archive entries.';
      });
    }
  }

  List<ArchiveEntry> _filteredEntries(Locale locale) {
    final query = _normalize(_query);
    final entries = _allEntries
        .where((entry) => entry.meetsCommunityThreshold)
        .where((entry) {
          if (query.isEmpty) {
            return false;
          }
          return _buildSearchCandidates(
            entry,
            locale,
          ).any((candidate) => candidate.contains(query));
        })
        .toList();
    entries.sort(
      (a, b) =>
          b.communityApprovalPercent.compareTo(a.communityApprovalPercent),
    );
    return entries;
  }

  Iterable<ArchiveEntry> _suggestions(String rawQuery, Locale locale) {
    final query = _normalize(rawQuery);
    if (query.isEmpty) {
      return const Iterable<ArchiveEntry>.empty();
    }
    final matches = _allEntries.where((entry) {
      return _buildSearchCandidates(
        entry,
        locale,
      ).any((candidate) => candidate.startsWith(query));
    }).toList();
    matches.sort(
      (a, b) => a.title
          .resolve(locale)
          .toLowerCase()
          .compareTo(b.title.resolve(locale).toLowerCase()),
    );
    return matches.take(6);
  }

  List<String> _buildSearchCandidates(ArchiveEntry entry, Locale locale) {
    final resolvedTitle = entry.title.resolve(locale);
    final resolvedSummary = entry.summary.resolve(locale);
    return <String?>[
          resolvedTitle,
          resolvedSummary,
          entry.title.en,
          entry.title.fr,
          entry.summary.en,
          entry.summary.fr,
          entry.category,
          entry.era.resolve(locale),
        ]
        .whereType<String>()
        .map(_normalize)
        .where((value) => value.isNotEmpty)
        .toList();
  }

  String _normalize(String value) => value.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final entries = _filteredEntries(locale);
    final hasQuery = _query.trim().isNotEmpty;
    final hasResults = entries.isNotEmpty;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = keyboardInset > 0
        ? 12.0
        : mediaQuery.padding.bottom + 12.0;

    if (_isLoading) {
      return const Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ThalaPageBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: RawAutocomplete<ArchiveEntry>(
                    textEditingController: _searchController,
                    focusNode: _searchFocusNode,
                    displayStringForOption: (option) =>
                        option.title.resolve(locale),
                    optionsBuilder: (textEditingValue) =>
                        _suggestions(textEditingValue.text, locale),
                    optionsViewBuilder: (context, onSelected, options) {
                      final materialTheme = Theme.of(context);
                      final palette = materialTheme.colorScheme;
                      final list = options.toList();
                      if (list.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ThalaGlassSurface(
                            enableBorder: false,
                            cornerRadius: 20,
                            backgroundOpacity:
                                palette.brightness == Brightness.dark
                                ? 0.34
                                : 0.78,
                            child: Material(
                              type: MaterialType.transparency,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: math.min(
                                    320,
                                    mediaQuery.size.height * 0.4,
                                  ),
                                  maxWidth: mediaQuery.size.width - 40,
                                ),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final option = list[index];
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: palette.secondary
                                            .withValues(alpha: 0.18),
                                        child: Icon(
                                          Icons.explore_outlined,
                                          color: palette.secondary,
                                        ),
                                      ),
                                      title: Text(
                                        option.title.resolve(locale),
                                        style: materialTheme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      subtitle: option.category != null
                                          ? Text(
                                              option.category!,
                                              style: materialTheme
                                                  .textTheme
                                                  .bodySmall,
                                            )
                                          : null,
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemCount: list.length,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (option) {
                      _searchFocusNode.unfocus();
                      _searchController.text = option.title.resolve(locale);
                      _searchController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _searchController.text.length),
                      );
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return _ArchiveSearchBar(
                            controller: controller,
                            focusNode: focusNode,
                            isActive:
                                focusNode.hasFocus ||
                                controller.text.isNotEmpty,
                            hasResults: hasResults,
                            onSubmitted: (_) => onFieldSubmitted(),
                          );
                        },
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: hasQuery
                        ? (hasResults
                              ? _ArchiveResultsView(
                                  key: ValueKey(
                                    'results-${entries.length}-${_query.trim()}',
                                  ),
                                  entries: entries,
                                  locale: locale,
                                )
                              : _ArchiveEmptyState(
                                  key: ValueKey('empty-${_query.trim()}'),
                                  query: _query,
                                ))
                        : _ArchiveIdleState(message: _errorMessage),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveSearchBar extends StatefulWidget {
  const _ArchiveSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.hasResults,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final bool hasResults;
  final ValueChanged<String> onSubmitted;

  @override
  State<_ArchiveSearchBar> createState() => _ArchiveSearchBarState();
}

class _ArchiveSearchBarState extends State<_ArchiveSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _ArchiveSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final double opacity = widget.isActive ? 0.34 : 0.24;
    final List<BoxShadow>? shadows;
    if (widget.hasResults) {
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.18),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
    } else if (widget.isActive) {
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.12),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];
    } else {
      shadows = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: ThalaGlassSurface(
        cornerRadius: 22,
        backgroundOpacity: opacity * 0.8,
        enableBorder: false,
        shadows: shadows,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.search, color: colorScheme.onSurfaceVariant.withOpacity(0.7), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                onSubmitted: widget.onSubmitted,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: colorScheme.secondary,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: AppTranslations.of(
                    context,
                    AppText.archiveSearchPlaceholder,
                  ),
                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.55),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  widget.controller.clear();
                },
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  size: 20,
                ),
                splashRadius: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveIdleState extends StatelessWidget {
  const _ArchiveIdleState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = AppTranslations.of(context, AppText.discoverArchive);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ThalaGlassSurface(
          cornerRadius: 24,
          enableBorder: false,
          backgroundOpacity: context.isDarkMode ? 0.16 : 0.42,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.search_outlined,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message ??
                    'Begin typing to surface cultural treasures curated by the community.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveEmptyState extends StatelessWidget {
  const _ArchiveEmptyState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = AppTranslations.of(context, AppText.archiveSearchEmpty);
    final cleanedQuery = query.trim();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ThalaGlassSurface(
          cornerRadius: 28,
          enableBorder: false,
          backgroundOpacity: context.isDarkMode ? 0.22 : 0.55,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.24,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.28),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.search_off_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (cleanedQuery.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Try a different keyword or refine your spelling.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveResultsView extends StatefulWidget {
  const _ArchiveResultsView({
    super.key,
    required this.entries,
    required this.locale,
  });

  final List<ArchiveEntry> entries;
  final Locale locale;

  @override
  State<_ArchiveResultsView> createState() => _ArchiveResultsViewState();
}

class _ArchiveResultsViewState extends State<_ArchiveResultsView> {
  static const double _kMinPagerHeight = 520.0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didUpdateWidget(covariant _ArchiveResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewportPadding = mediaQuery.size.width >= 600 ? 32.0 : 20.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double topPadding = 8.0;
        const double betweenPadding = 18.0;
        const double bottomPadding = 24.0;
        final double minViewportHeight =
            _kMinPagerHeight + topPadding + bottomPadding;
        final bool useListView = constraints.maxHeight < minViewportHeight;

        if (useListView) {
          return ListView.builder(
            padding: EdgeInsets.only(
              left: viewportPadding,
              right: viewportPadding,
              top: topPadding,
              bottom: bottomPadding,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.entries.length,
            itemBuilder: (context, index) {
              final entry = widget.entries[index];
              final double spacing = index == widget.entries.length - 1
                  ? 0
                  : betweenPadding;
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: _ArchivePlayerCard(entry: entry, locale: widget.locale),
              );
            },
          );
        }

        return PageView.builder(
          key: ValueKey(widget.entries.length),
          controller: _controller,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.entries.length,
          itemBuilder: (context, index) {
            final entry = widget.entries[index];
            return Padding(
              padding: EdgeInsets.fromLTRB(
                viewportPadding,
                index == 0 ? topPadding : betweenPadding,
                viewportPadding,
                index == widget.entries.length - 1
                    ? bottomPadding
                    : betweenPadding,
              ),
              child: _ArchivePlayerCard(entry: entry, locale: widget.locale),
            );
          },
        );
      },
    );
  }
}

class _ArchivePlayerCard extends StatelessWidget {
  const _ArchivePlayerCard({required this.entry, required this.locale});

  final ArchiveEntry entry;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedTitle = entry.title.resolve(locale);
    final resolvedSummary = entry.summary.resolve(locale);
    final resolvedEra = entry.era.resolve(locale);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final cardHeight = math.min(maxHeight, 640.0);
        final playerHeight = cardHeight * 0.6;

        final isDark = colorScheme.brightness == Brightness.dark;

        return Align(
          alignment: Alignment.topCenter,
          child: ThalaGlassSurface(
            cornerRadius: 24,
            backgroundOpacity: isDark ? 0.22 : 0.62,
            enableBorder: false,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.14),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
            child: SizedBox(
              height: cardHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: playerHeight,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              entry.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: colorScheme.surfaceContainerHigh,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.photo_library_outlined,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                            ),
                          ),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black54, Colors.transparent],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.36),
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.graphic_eq,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    entry.category ?? 'Cultural artefact',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resolvedTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              resolvedSummary,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  size: 18,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppTranslations.of(
                                    context,
                                    AppText.archiveApprovalLabel,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${entry.communityApprovalPercent.toStringAsFixed(1)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (entry.communityApprovalPercent / 100)
                                  .clamp(0.0, 1.0)
                                  .toDouble(),
                              minHeight: 6,
                              backgroundColor: colorScheme.secondary.withValues(
                                alpha: 0.15,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  resolvedEra,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${entry.communityUpvotes} / ${entry.registeredUsers}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }
}
