import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../l10n/app_translations.dart';
import '../../models/localized_text.dart';
import '../../ui/widgets/thala_glass_surface.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom + 96;

    String tr(AppText key) => AppTranslations.of(context, key);

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
                cornerRadius: 28,
                backgroundOpacity: theme.brightness == Brightness.dark
                    ? 0.24
                    : 0.62,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: palette.surfaceSubtle,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: palette.border),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.event_available,
                        color: palette.iconPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(AppText.eventsTitle),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr(AppText.eventsSubtitle),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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

  final _Event event;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final modeLabel = _modeLabel(context, event.mode);
    final pills = <Widget>[
      _EventPill(icon: _modeIcon(event.mode), label: modeLabel),
      ...event.tags.map(
        (tag) =>
            _EventPill(label: tag.resolve(locale), icon: Icons.label_outline),
      ),
    ];

    final borderRadius = BorderRadius.circular(26);
    final Color surfaceTint = palette.surfaceBright.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.52 : 0.68,
    );

    void _handleAction() {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(event.ctaNote.resolve(locale)),
          ),
        );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: event.backgroundColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: surfaceTint),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: palette.border.withValues(alpha: 0.35),
              ),
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _handleAction,
                    icon: const Icon(Icons.event_available_outlined),
                    label: Text(event.ctaLabel.resolve(locale)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: palette.iconPrimary),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum _EventMode { inPerson, online, hybrid }

IconData _modeIcon(_EventMode mode) {
  switch (mode) {
    case _EventMode.inPerson:
      return Icons.groups_2_outlined;
    case _EventMode.online:
      return Icons.wifi_tethering;
    case _EventMode.hybrid:
      return Icons.hub_outlined;
  }
}

String _modeLabel(BuildContext context, _EventMode mode) {
  switch (mode) {
    case _EventMode.inPerson:
      return AppTranslations.of(context, AppText.eventsInPersonLabel);
    case _EventMode.online:
      return AppTranslations.of(context, AppText.eventsOnlineLabel);
    case _EventMode.hybrid:
      return AppTranslations.of(context, AppText.eventsHybridLabel);
  }
}

class _Event {
  const _Event({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.location,
    required this.description,
    required this.mode,
    required this.ctaLabel,
    required this.ctaNote,
    required this.backgroundColors,
    this.additionalDetail,
    this.tags = const <LocalizedText>[],
  });

  final String id;
  final LocalizedText title;
  final LocalizedText dateLabel;
  final LocalizedText location;
  final LocalizedText description;
  final LocalizedText ctaLabel;
  final LocalizedText ctaNote;
  final LocalizedText? additionalDetail;
  final _EventMode mode;
  final List<LocalizedText> tags;
  final List<Color> backgroundColors;
}

const List<_Event> _events = <_Event>[
  _Event(
    id: 'agadir-film-night',
    title: LocalizedText(
      en: 'Agadir Amazigh Film Night',
      fr: 'Soirée cinéma amazighe à Agadir',
    ),
    dateLabel: LocalizedText(
      en: 'March 23, 2024 · 19:00',
      fr: '23 mars 2024 · 19 h 00',
    ),
    location: LocalizedText(en: 'Agadir, Morocco', fr: 'Agadir, Maroc'),
    description: LocalizedText(
      en: 'Screenings of shorts celebrating Amazigh storytellers followed by a Q&A with local directors.',
      fr: 'Projection de courts métrages mettant en lumière des conteurs amazighs, suivie d’une discussion avec des réalisateurs locaux.',
    ),
    additionalDetail: LocalizedText(
      en: 'Hosted at Dar Lfenn. Doors open at 18:30. Seats are limited—RSVP required.',
      fr: 'Organisé à Dar Lfenn. Ouverture des portes à 18 h 30. Places limitées : réservation obligatoire.',
    ),
    mode: _EventMode.inPerson,
    ctaLabel: LocalizedText(en: 'Reserve a seat', fr: 'Réserver une place'),
    ctaNote: LocalizedText(
      en: 'We will follow up with availability details for Agadir Amazigh Film Night.',
      fr: 'Nous vous contacterons avec les détails de disponibilité pour la soirée cinéma amazighe d’Agadir.',
    ),
    backgroundColors: <Color>[
      Color(0xFF2A1B4A),
      Color(0xFF36254F),
      Color(0xFF4B2C6B),
    ],
    tags: <LocalizedText>[
      LocalizedText(en: 'Cinema', fr: 'Cinéma'),
      LocalizedText(en: 'Community', fr: 'Communauté'),
    ],
  ),
  _Event(
    id: 'language-lab-livestream',
    title: LocalizedText(
      en: 'Amazigh Language Lab Livestream',
      fr: 'Laboratoire de langue amazighe en direct',
    ),
    dateLabel: LocalizedText(
      en: 'April 5, 2024 · 16:00 GMT',
      fr: '5 avril 2024 · 16 h 00 GMT',
    ),
    location: LocalizedText(en: 'Online broadcast', fr: 'Diffusion en ligne'),
    description: LocalizedText(
      en: 'Interactive session on new teaching tools for Tamazight educators, streamed with live captions.',
      fr: 'Session interactive sur les nouveaux outils pédagogiques pour les enseignants de tamazight, diffusée avec sous-titres en direct.',
    ),
    additionalDetail: LocalizedText(
      en: 'Featuring guests from the Kabylia Language Cooperative and the Atlas Cultural Lab.',
      fr: 'Avec la participation de la Coopérative linguistique kabyle et du Laboratoire culturel de l’Atlas.',
    ),
    mode: _EventMode.online,
    ctaLabel: LocalizedText(en: 'Get streaming link', fr: 'Recevoir le lien'),
    ctaNote: LocalizedText(
      en: 'We will email the livestream link 24 hours before the Language Lab session.',
      fr: 'Nous enverrons le lien de diffusion 24 heures avant la session du Laboratoire de langue.',
    ),
    backgroundColors: <Color>[
      Color(0xFF0F2027),
      Color(0xFF203A43),
      Color(0xFF2C5364),
    ],
    tags: <LocalizedText>[
      LocalizedText(en: 'Education', fr: 'Éducation'),
      LocalizedText(en: 'Livestream', fr: 'Diffusion en direct'),
    ],
  ),
  _Event(
    id: 'montreal-tifawin-week',
    title: LocalizedText(
      en: 'Tifawin Cultural Week',
      fr: 'Semaine culturelle Tifawin',
    ),
    dateLabel: LocalizedText(en: 'April 18–21, 2024', fr: '18–21 avril 2024'),
    location: LocalizedText(
      en: 'Montreal & online sessions',
      fr: 'Montréal et sessions en ligne',
    ),
    description: LocalizedText(
      en: 'Four days of talks, culinary workshops, and live music bridging Amazigh communities and allies.',
      fr: 'Quatre jours de conférences, d’ateliers culinaires et de concerts rapprochant communautés amazighes et alliés.',
    ),
    additionalDetail: LocalizedText(
      en: 'Hybrid program with limited in-person passes and open virtual circles each evening.',
      fr: 'Programme hybride avec places limitées sur site et cercles virtuels ouverts chaque soir.',
    ),
    mode: _EventMode.hybrid,
    ctaLabel: LocalizedText(en: 'Join the program', fr: 'Participer au programme'),
    ctaNote: LocalizedText(
      en: 'Hybrid access links and venue passes will be delivered after confirmation.',
      fr: 'Les liens d’accès hybrides et les laissez-passer seront envoyés après confirmation.',
    ),
    backgroundColors: <Color>[
      Color(0xFF42275A),
      Color(0xFF734B6D),
      Color(0xFF8F6B8F),
    ],
    tags: <LocalizedText>[
      LocalizedText(en: 'Festival', fr: 'Festival'),
      LocalizedText(en: 'Heritage', fr: 'Patrimoine'),
    ],
  ),
];
