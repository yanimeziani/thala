enum MessageDeliveryStatus { pending, sent, delivered, read, failed }

class Message {
  const Message({
    required this.id,
    required this.threadId,
    required this.authorHandle,
    required this.authorDisplayName,
    required this.text,
    required this.createdAt,
    required this.deliveryStatus,
    required this.isMine,
  });

  final String id;
  final String threadId;
  final String authorHandle;
  final String authorDisplayName;
  final String text;
  final DateTime createdAt;
  final MessageDeliveryStatus deliveryStatus;
  final bool isMine;

  Message copyWith({
    MessageDeliveryStatus? deliveryStatus,
    DateTime? createdAt,
  }) {
    return Message(
      id: id,
      threadId: threadId,
      authorHandle: authorHandle,
      authorDisplayName: authorDisplayName,
      text: text,
      createdAt: createdAt ?? this.createdAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      isMine: isMine,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json, {required String currentUserHandle}) {
    final createdAtValue = json['created_at'];
    DateTime createdAt = DateTime.now();
    if (createdAtValue is String && createdAtValue.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtValue)?.toLocal() ?? DateTime.now();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue.toLocal();
    }

    final statusValue = json['status'] as String?;
    MessageDeliveryStatus status = MessageDeliveryStatus.sent;
    switch (statusValue) {
      case 'pending':
        status = MessageDeliveryStatus.pending;
        break;
      case 'sent':
        status = MessageDeliveryStatus.sent;
        break;
      case 'delivered':
        status = MessageDeliveryStatus.delivered;
        break;
      case 'read':
        status = MessageDeliveryStatus.read;
        break;
      case 'failed':
        status = MessageDeliveryStatus.failed;
        break;
    }

    final authorHandle = json['author_handle'] as String? ?? '';
    final isMine = authorHandle == currentUserHandle;

    return Message(
      id: json['id']?.toString() ?? 'message-${json.hashCode}',
      threadId: json['thread_id']?.toString() ?? '',
      authorHandle: authorHandle,
      authorDisplayName: json['author_display_name'] as String? ?? authorHandle,
      text: json['text'] as String? ?? '',
      createdAt: createdAt,
      deliveryStatus: status,
      isMine: isMine,
    );
  }
}
