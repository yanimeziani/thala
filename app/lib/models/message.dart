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
}
