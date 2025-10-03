import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../data/events_repository.dart';
import '../../l10n/app_translations.dart';
import '../../models/cultural_event.dart';
import '../../ui/widgets/thala_glass_surface.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventsRepository _repository = EventsRepository();
  List<CulturalEvent> _events = const <CulturalEvent>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!_repository.isRemoteEnabled) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Supabase is not configured. Events will appear once connected.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final remote = await _repository.fetchUpcomingEvents();
      setState(() {
        _events = remote;
        _isLoading = false;
        if (remote.isEmpty) {
          _errorMessage = 'No events published yet. Add events in Supabase to showcase them here.';
        }
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load cultural events: $error\n$stackTrace');
      setState(() {
        _events = const <CulturalEvent>[];
        _isLoading = false;
        _errorMessage = 'Unable to reach Supabase. Events will return once the connection recovers.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom + 96;

    String tr(AppText key) => AppTranslations.of(context, key);

    if (_isLoading) {
      return const Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_events.isEmpty) {
      return Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: ThalaPageBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage ?? 'No gatherings are scheduled yet. Add events in Supabase to light up this space.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ThalaPageBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            children: [
              ThalaGlassSurface(
                enableBorder: false,
                cornerRadius: 24,
                backgroundOpacity: theme.brightness == Brightness.dark
                    ? 0.16
                    : 0.48,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.iconPrimary.withOpacity(0.12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.event_available,
                        color: palette.iconPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(AppText.eventsTitle),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr(AppText.eventsSubtitle),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (final event in _events) ...[
                _EventCard(event: event, locale: locale),
                const SizedBox(height: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.locale});

  final CulturalEvent event;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final modeLabel = _modeLabel(context, event.mode);
    final pills = <Widget>[
      _EventPill(icon: _modeIcon(event.mode), label: modeLabel),
      ...event.tags.map(
        (tag) => _EventPill(
          label: tag.resolve(locale),
          icon: Icons.label_outline,
        ),
      ),
    ];

    final borderRadius = BorderRadius.circular(22);

    void _handleAction() {
      // TODO: Implement interest toggle logic with controller
      // Removed SnackBar to prevent off-screen presentation errors
    }

    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.32),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                if (event.hostName != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: palette.surfaceSubtle,
                        child: Icon(
                          Icons.groups,
                          size: 16,
                          color: palette.iconPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          event.hostName!,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      if (event.isHostVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  event.title.resolve(locale),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: palette.iconPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.dateLabel.resolve(locale),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: palette.iconPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location.resolve(locale),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  event.description.resolve(locale),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (event.additionalDetail != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    event.additionalDetail!.resolve(locale),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(spacing: 10, runSpacing: 10, children: pills),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (event.interestedCount > 0) ...[
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: palette.iconPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${event.interestedCount} interested',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _handleAction,
                        icon: Icon(
                          event.isUserInterested
                              ? Icons.star
                              : Icons.star_border,
                        ),
                        label: Text(
                          event.isUserInterested ? 'Interested' : 'Mark Interested',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (event.isUserInterested && event.isHostVerified) ...[
                      IconButton(
                        onPressed: _handleAction,
                        icon: const Icon(Icons.info_outline),
                        tooltip: 'Event details',
                        style: IconButton.styleFrom(
                          backgroundColor: palette.surfaceSubtle.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventPill extends StatelessWidget {
  const _EventPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: palette.iconPrimary.withOpacity(0.8)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _modeIcon(CulturalEventMode mode) {
  switch (mode) {
    case CulturalEventMode.inPerson:
      return Icons.groups_2_outlined;
    case CulturalEventMode.online:
      return Icons.wifi_tethering;
    case CulturalEventMode.hybrid:
      return Icons.hub_outlined;
  }
}

String _modeLabel(BuildContext context, CulturalEventMode mode) {
  switch (mode) {
    case CulturalEventMode.inPerson:
      return AppTranslations.of(context, AppText.eventsInPersonLabel);
    case CulturalEventMode.online:
      return AppTranslations.of(context, AppText.eventsOnlineLabel);
    case CulturalEventMode.hybrid:
      return AppTranslations.of(context, AppText.eventsHybridLabel);
  }
}
