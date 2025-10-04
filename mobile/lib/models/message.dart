enum MessageDeliveryStatus { pending, sent, delivered, read, failed }

enum MessageType { text, image, video, audio }

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
    this.messageType = MessageType.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mediaWidth,
    this.mediaHeight,
    this.mediaDuration,
    this.mediaSize,
  });

  final String id;
  final String threadId;
  final String authorHandle;
  final String authorDisplayName;
  final String text;
  final DateTime createdAt;
  final MessageDeliveryStatus deliveryStatus;
  final bool isMine;

  // Multimedia fields
  final MessageType messageType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? mediaWidth;
  final int? mediaHeight;
  final int? mediaDuration; // Duration in seconds for audio/video
  final int? mediaSize; // File size in bytes

  Message copyWith({
    MessageDeliveryStatus? deliveryStatus,
    DateTime? createdAt,
    MessageType? messageType,
    String? mediaUrl,
    String? thumbnailUrl,
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
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaWidth: this.mediaWidth,
      mediaHeight: this.mediaHeight,
      mediaDuration: this.mediaDuration,
      mediaSize: this.mediaSize,
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

    final statusValue = json['delivery_status'] as String? ?? json['status'] as String?;
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

    // Parse message type
    final messageTypeValue = json['message_type'] as String? ?? 'text';
    MessageType messageType = MessageType.text;
    switch (messageTypeValue) {
      case 'text':
        messageType = MessageType.text;
        break;
      case 'image':
        messageType = MessageType.image;
        break;
      case 'video':
        messageType = MessageType.video;
        break;
      case 'audio':
        messageType = MessageType.audio;
        break;
    }

    final authorHandle = json['author_handle'] as String? ?? '';
    final isMine = authorHandle == currentUserHandle;

    return Message(
      id: json['id']?.toString() ?? 'message-${json.hashCode}',
      threadId: json['thread_id']?.toString() ?? '',
      authorHandle: authorHandle,
      authorDisplayName: json['author_display_name'] as String? ?? authorHandle,
      text: json['body'] as String? ?? json['text'] as String? ?? '',
      createdAt: createdAt,
      deliveryStatus: status,
      isMine: isMine,
      messageType: messageType,
      mediaUrl: json['media_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediaWidth: json['media_width'] as int?,
      mediaHeight: json['media_height'] as int?,
      mediaDuration: json['media_duration'] as int?,
      mediaSize: json['media_size'] as int?,
    );
  }
}
