import 'localized_text.dart';

class ArchiveEntry {
  const ArchiveEntry({
    required this.id,
    required this.title,
    required this.summary,
    required this.era,
    required this.thumbnailUrl,
    required this.communityUpvotes,
    required this.registeredUsers,
    required this.requiredApprovalPercent,
    this.category,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText summary;
  final LocalizedText era;
  final String? category;
  final String thumbnailUrl;
  final int communityUpvotes;
  final int registeredUsers;
  final double requiredApprovalPercent;

  double get communityApprovalPercent {
    if (registeredUsers <= 0) {
      return 0;
    }
    return (communityUpvotes / registeredUsers) * 100;
  }

  double get communityApprovalRatio {
    if (registeredUsers <= 0) {
      return 0;
    }
    return communityUpvotes / registeredUsers;
  }

  bool get meetsCommunityThreshold {
    return communityApprovalPercent >= requiredApprovalPercent;
  }

  factory ArchiveEntry.fromJson(Map<String, dynamic> json) {
    return ArchiveEntry(
      id: json['id'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>? ?? {}),
      summary: LocalizedText.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      era: LocalizedText.fromJson(json['era'] as Map<String, dynamic>? ?? {}),
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      communityUpvotes: json['community_upvotes'] as int? ?? 0,
      registeredUsers: json['registered_users'] as int? ?? 0,
      requiredApprovalPercent: (json['required_approval_percent'] as num?)?.toDouble() ?? 75.0,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title.toJson(),
      'summary': summary.toJson(),
      'era': era.toJson(),
      'thumbnail_url': thumbnailUrl,
      'community_upvotes': communityUpvotes,
      'registered_users': registeredUsers,
      'required_approval_percent': requiredApprovalPercent,
      'category': category,
    };
  }
}
