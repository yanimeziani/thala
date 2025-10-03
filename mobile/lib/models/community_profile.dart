import 'community_space.dart';
import 'localized_text.dart';

enum CommunityCardKind {
  landing,
  mission,
  activities,
  resources,
  contact,
  timeline,
  highlights,
  tags,
  spotlight,
}

enum CommunityLinkType { email, phone, website, facebook, instagram, link }

class CommunityLink {
  const CommunityLink({
    required this.type,
    required this.label,
    required this.value,
  });

  final CommunityLinkType type;
  final String label;
  final String value;
}

class CommunityDetailCard {
  const CommunityDetailCard({
    required this.id,
    required this.kind,
    required this.title,
    this.subtitle,
    this.body,
    this.items = const <LocalizedText>[],
    this.links = const <CommunityLink>[],
  });

  final String id;
  final CommunityCardKind kind;
  final LocalizedText title;
  final LocalizedText? subtitle;
  final LocalizedText? body;
  final List<LocalizedText> items;
  final List<CommunityLink> links;
}

class CommunityProfile {
  const CommunityProfile({
    required this.space,
    required this.region,
    required this.languages,
    required this.cards,
    this.priority = 0,
  });

  final CommunitySpace space;
  final String region;
  final List<String> languages;
  final List<CommunityDetailCard> cards;
  final double priority;
}
