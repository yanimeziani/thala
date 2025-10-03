class NotificationSettings {
  const NotificationSettings({
    this.storyAlerts = true,
    this.communityHighlights = true,
    this.productUpdates = false,
  });

  final bool storyAlerts;
  final bool communityHighlights;
  final bool productUpdates;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      storyAlerts: (json['storyAlerts'] as bool?) ?? true,
      communityHighlights: (json['communityHighlights'] as bool?) ?? true,
      productUpdates: (json['productUpdates'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'storyAlerts': storyAlerts,
      'communityHighlights': communityHighlights,
      'productUpdates': productUpdates,
    };
  }

  NotificationSettings copyWith({
    bool? storyAlerts,
    bool? communityHighlights,
    bool? productUpdates,
  }) {
    return NotificationSettings(
      storyAlerts: storyAlerts ?? this.storyAlerts,
      communityHighlights: communityHighlights ?? this.communityHighlights,
      productUpdates: productUpdates ?? this.productUpdates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.storyAlerts == storyAlerts &&
        other.communityHighlights == communityHighlights &&
        other.productUpdates == productUpdates;
  }

  @override
  int get hashCode => Object.hash(
        storyAlerts,
        communityHighlights,
        productUpdates,
      );
}
