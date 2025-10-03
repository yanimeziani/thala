class SearchHit {
  SearchHit({
    required this.id,
    required this.title,
    required this.kind,
    this.subtitle,
    this.imageUrl,
    this.payload = const {},
  });

  factory SearchHit.fromHit(Map<String, dynamic> hit) {
    final normalized = Map<String, dynamic>.from(hit);

    String resolveTitle() {
      final candidates = [
        normalized['title_en'],
        normalized['title_fr'],
        normalized['title'],
        normalized['name_en'],
        normalized['name_fr'],
        normalized['name'],
      ];
      for (final value in candidates) {
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return 'Untitled';
    }

    String? resolveSubtitle() {
      final candidates = [
        normalized['creator_name_en'],
        normalized['creator_handle'],
        normalized['description_en'],
        normalized['description_fr'],
        normalized['location_en'],
        normalized['location_fr'],
        normalized['subtitle'],
      ];
      for (final value in candidates) {
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return null;
    }

    String resolveKind() {
      final value = normalized['kind'] ?? normalized['type'] ?? normalized['category'];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      return 'content';
    }

    String? resolveImage() {
      final candidates = [
        normalized['thumbnail_url'],
        normalized['image_url'],
        normalized['poster_url'],
        normalized['cover_url'],
      ];
      for (final value in candidates) {
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return null;
    }

    return SearchHit(
      id: normalized['id']?.toString() ?? normalized['_id']?.toString() ?? '',
      title: resolveTitle(),
      subtitle: resolveSubtitle(),
      kind: resolveKind(),
      imageUrl: resolveImage(),
      payload: normalized,
    );
  }

  final String id;
  final String title;
  final String kind;
  final String? subtitle;
  final String? imageUrl;
  final Map<String, dynamic> payload;
}
