import 'package:flutter/material.dart';

import 'localized_text.dart';

enum CulturalEventMode { inPerson, online, hybrid }

CulturalEventMode modeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'in_person':
    case 'inperson':
      return CulturalEventMode.inPerson;
    case 'online':
      return CulturalEventMode.online;
    case 'hybrid':
      return CulturalEventMode.hybrid;
    default:
      return CulturalEventMode.inPerson;
  }
}

class CulturalEvent {
  const CulturalEvent({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.location,
    required this.description,
    required this.mode,
    required this.startAt,
    required this.tags,
    required this.ctaLabel,
    required this.ctaNote,
    this.additionalDetail,
    this.endAt,
    this.backgroundColorHex = const <String>[],
    this.heroImageUrl,
    this.hostName,
    this.hostHandle,
    this.isHostVerified = false,
    this.interestedCount = 0,
    this.isUserInterested = false,
    this.interestedUsers = const <String>[],
  });

  final String id;
  final LocalizedText title;
  final LocalizedText dateLabel;
  final LocalizedText location;
  final LocalizedText description;
  final LocalizedText? additionalDetail;
  final CulturalEventMode mode;
  final DateTime startAt;
  final DateTime? endAt;
  final List<LocalizedText> tags;
  final LocalizedText ctaLabel;
  final LocalizedText ctaNote;
  final List<String> backgroundColorHex;
  final String? heroImageUrl;

  // Community/host info
  final String? hostName;
  final String? hostHandle;
  final bool isHostVerified;

  // Attendance tracking
  final int interestedCount;
  final bool isUserInterested;
  final List<String> interestedUsers; // User IDs or handles

  List<Color> resolveBackgroundColors() {
    return backgroundColorHex
        .where((value) => value.trim().isNotEmpty)
        .map((value) {
          final hex = value.replaceAll('#', '').padLeft(6, '0');
          final parsed = int.tryParse(hex, radix: 16) ?? 0x000000;
          return Color(0xFF000000 | parsed);
        })
        .toList(growable: false);
  }

  CulturalEvent copyWith({
    String? id,
    LocalizedText? title,
    LocalizedText? dateLabel,
    LocalizedText? location,
    LocalizedText? description,
    LocalizedText? additionalDetail,
    CulturalEventMode? mode,
    DateTime? startAt,
    DateTime? endAt,
    List<LocalizedText>? tags,
    LocalizedText? ctaLabel,
    LocalizedText? ctaNote,
    List<String>? backgroundColorHex,
    String? heroImageUrl,
    String? hostName,
    String? hostHandle,
    bool? isHostVerified,
    int? interestedCount,
    bool? isUserInterested,
    List<String>? interestedUsers,
  }) {
    return CulturalEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      dateLabel: dateLabel ?? this.dateLabel,
      location: location ?? this.location,
      description: description ?? this.description,
      additionalDetail: additionalDetail ?? this.additionalDetail,
      mode: mode ?? this.mode,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      tags: tags ?? this.tags,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      ctaNote: ctaNote ?? this.ctaNote,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      hostName: hostName ?? this.hostName,
      hostHandle: hostHandle ?? this.hostHandle,
      isHostVerified: isHostVerified ?? this.isHostVerified,
      interestedCount: interestedCount ?? this.interestedCount,
      isUserInterested: isUserInterested ?? this.isUserInterested,
      interestedUsers: interestedUsers ?? this.interestedUsers,
    );
  }
}
