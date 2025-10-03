import 'localized_text.dart';

/// Lightweight view of a conversation used for the messaging header surface.
class MessageThread {
  const MessageThread({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
    this.participants = const <String>[],
    this.avatarUrl,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText lastMessage;
  final DateTime? updatedAt;
  final int unreadCount;
  final List<String> participants;
  final String? avatarUrl;

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    final participantsValue = json['participants'];
    final participants = participantsValue is List
        ? participantsValue.whereType<String>().toList(growable: false)
        : const <String>[];

    final updatedAtValue = json['updated_at'];
    DateTime? updatedAt;
    if (updatedAtValue is String && updatedAtValue.isNotEmpty) {
      updatedAt = DateTime.tryParse(updatedAtValue)?.toLocal();
    } else if (updatedAtValue is DateTime) {
      updatedAt = updatedAtValue.toLocal();
    }

    return MessageThread(
      id: json['id']?.toString() ?? 'thread-${json.hashCode}',
      title: LocalizedText(
        en: json['title_en'] as String? ?? '',
        fr: json['title_fr'] as String? ?? '',
      ),
      lastMessage: LocalizedText(
        en: json['last_message_en'] as String? ?? '',
        fr: json['last_message_fr'] as String? ?? '',
      ),
      updatedAt: updatedAt,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      participants: participants,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
