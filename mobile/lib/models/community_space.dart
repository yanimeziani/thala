import 'localized_text.dart';

class CommunitySpace {
  const CommunitySpace({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.memberCount,
    required this.location,
    this.tags = const [],
  });

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText location;
  final String imageUrl;
  final int memberCount;
  final List<String> tags;
}
