import '../models/community_profile.dart';
import '../models/community_space.dart';
import '../models/localized_text.dart';
import 'sample_community_profiles.dart';

class CommunityProfilesRepository {
  CommunityProfilesRepository();

  bool get isRemoteEnabled => false;

  Future<List<CommunityProfile>> fetchProfiles() async {
    // Backend integration pending - return sample data
    return sampleCommunityProfiles;
  }

  CommunityProfile _mapProfile(Map<String, dynamic> row) {
    final spaceValue = row['space'];
    final space = _parseSpace(_stringKeyedMap(spaceValue));
    final languages = (row['languages'] as List?)
            ?.whereType<String>()
            .toList(growable: false) ??
        const <String>[];
    final cardsValue = row['cards'];
    final List<CommunityDetailCard> cards = <CommunityDetailCard>[];
    if (cardsValue is List) {
      for (final item in cardsValue) {
        if (item is Map<String, dynamic>) {
          cards.add(_parseCard(item));
        }
      }
    }

    return CommunityProfile(
      space: space,
      region: row['region']?.toString() ?? '',
      languages: languages,
      cards: cards,
      priority: (row['priority'] as num?)?.toDouble() ?? 0,
    );
  }

  CommunitySpace _parseSpace(Map<String, dynamic> map) {
    final tagsValue = map['tags'];
    final tags = (tagsValue is List)
        ? tagsValue.whereType<String>().toList(growable: false)
        : const <String>[];
    return CommunitySpace(
      id: map['id']?.toString() ?? '',
      name: _parseLocalized(map['name']),
      description: _parseLocalized(map['description']),
      location: _parseLocalized(map['location']),
      imageUrl: map['imageUrl']?.toString() ?? '',
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
      tags: tags,
    );
  }

  CommunityDetailCard _parseCard(Map<String, dynamic> map) {
    final itemsValue = map['items'];
    final List<LocalizedText> items;
    if (itemsValue is List) {
      items = itemsValue
          .map((value) => _parseLocalized(value))
          .toList(growable: false);
    } else {
      items = const <LocalizedText>[];
    }

    final linksValue = map['links'];
    final List<CommunityLink> links;
    if (linksValue is List) {
      links = linksValue
          .whereType<Map<String, dynamic>>()
          .map(_parseLink)
          .toList(growable: false);
    } else {
      links = const <CommunityLink>[];
    }

    final kindValue = map['kind']?.toString() ?? '';

    return CommunityDetailCard(
      id: map['id']?.toString() ?? '',
      kind: _parseCardKind(kindValue),
      title: _parseLocalized(map['title']),
      subtitle: map['subtitle'] != null ? _parseLocalized(map['subtitle']) : null,
      body: map['body'] != null ? _parseLocalized(map['body']) : null,
      items: items,
      links: links,
    );
  }

  CommunityCardKind _parseCardKind(String value) {
    switch (value.toLowerCase()) {
      case 'landing':
        return CommunityCardKind.landing;
      case 'mission':
        return CommunityCardKind.mission;
      case 'activities':
        return CommunityCardKind.activities;
      case 'resources':
        return CommunityCardKind.resources;
      case 'contact':
        return CommunityCardKind.contact;
      case 'timeline':
        return CommunityCardKind.timeline;
      case 'highlights':
        return CommunityCardKind.highlights;
      case 'tags':
        return CommunityCardKind.tags;
      case 'spotlight':
        return CommunityCardKind.spotlight;
      default:
        return CommunityCardKind.landing;
    }
  }

  CommunityLink _parseLink(Map<String, dynamic> map) {
    final typeValue = map['type']?.toString() ?? '';
    return CommunityLink(
      type: _parseLinkType(typeValue),
      label: map['label']?.toString() ?? typeValue,
      value: map['value']?.toString() ?? '',
    );
  }

  CommunityLinkType _parseLinkType(String value) {
    switch (value.toLowerCase()) {
      case 'email':
        return CommunityLinkType.email;
      case 'phone':
        return CommunityLinkType.phone;
      case 'website':
        return CommunityLinkType.website;
      case 'facebook':
        return CommunityLinkType.facebook;
      case 'instagram':
        return CommunityLinkType.instagram;
      case 'link':
        return CommunityLinkType.link;
      default:
        return CommunityLinkType.link;
    }
  }

  LocalizedText _parseLocalized(dynamic value) {
    if (value is Map) {
      final en = value['en']?.toString() ?? '';
      final fr = value['fr']?.toString() ?? en;
      return LocalizedText(en: en, fr: fr);
    }
    final fallback = value?.toString() ?? '';
    return LocalizedText(en: fallback, fr: fallback);
  }

  Map<String, dynamic> _stringKeyedMap(dynamic value) {
    if (value is Map) {
      return value.map((key, dynamic v) => MapEntry(key.toString(), v));
    }
    return <String, dynamic>{};
  }
}
