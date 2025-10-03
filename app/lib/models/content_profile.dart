class ContentProfile {
  const ContentProfile({
    required this.contentId,
    this.culturalFamilies = const [],
    this.regions = const [],
    this.languages = const [],
    this.topics = const [],
    this.energy,
    this.sacredLevel,
    this.isGuardianApproved = false,
  });

  final String contentId;
  final List<String> culturalFamilies;
  final List<String> regions;
  final List<String> languages;
  final List<String> topics;
  final String? energy;
  final String? sacredLevel;
  final bool isGuardianApproved;
}
