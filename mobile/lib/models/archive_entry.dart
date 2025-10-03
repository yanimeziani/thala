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
}
