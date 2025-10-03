class OnboardingAnswers {
  OnboardingAnswers({
    this.isAmazigh,
    this.country,
    this.culturalFamily,
    this.isInterested,
    this.discoverySource,
  });

  bool? isAmazigh;
  String? country;
  String? culturalFamily;
  bool? isInterested;
  String? discoverySource;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isAmazigh': isAmazigh,
      'country': country,
      'culturalFamily': culturalFamily,
      'isInterested': isInterested,
      'discoverySource': discoverySource,
    };
  }

  static OnboardingAnswers fromJson(Map<String, dynamic> json) {
    return OnboardingAnswers(
      isAmazigh: json['isAmazigh'] as bool?,
      country: json['country'] as String?,
      culturalFamily: json['culturalFamily'] as String?,
      isInterested: json['isInterested'] as bool?,
      discoverySource: json['discoverySource'] as String?,
    );
  }

  OnboardingAnswers copyWith({
    bool? isAmazigh,
    String? country,
    String? culturalFamily,
    bool? isInterested,
    String? discoverySource,
  }) {
    return OnboardingAnswers(
      isAmazigh: isAmazigh ?? this.isAmazigh,
      country: country ?? this.country,
      culturalFamily: culturalFamily ?? this.culturalFamily,
      isInterested: isInterested ?? this.isInterested,
      discoverySource: discoverySource ?? this.discoverySource,
    );
  }

  bool get hasCulturalSignals {
    return (culturalFamily != null && culturalFamily!.isNotEmpty) ||
        (country != null && country!.isNotEmpty) ||
        (isAmazigh != null) ||
        (isInterested != null);
  }
}
