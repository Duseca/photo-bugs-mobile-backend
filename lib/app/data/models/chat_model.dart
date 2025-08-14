class Chat {
  final String? id;
  final List<String> participants;
  final Message? lastMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Chat({
    this.id,
    required this.participants,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? json['id'],
      participants:
          json['participants'] != null
              ? List<String>.from(json['participants'])
              : [],
      lastMessage:
          json['lastMessage'] != null
              ? Message.fromJson(json['lastMessage'])
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'participants': participants,
      if (lastMessage != null) 'lastMessage': lastMessage!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isActive': isActive,
    };
  }

  Chat copyWith({
    String? id,
    List<String>? participants,
    Message? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Chat{id: $id, participants: $participants, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chat && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Message {
  final String? id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime? createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  Message({
    this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'],
      chatId: json['chatId'] ?? json['chat_id'] ?? '',
      senderId: json['senderId'] ?? json['sender_id'] ?? '',
      content: json['content'] ?? '',
      type: MessageTypeExtension.fromString(json['type'] ?? 'text'),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.value,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'isRead': isRead,
      if (metadata != null) 'metadata': metadata,
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Message{id: $id, senderId: $senderId, content: $content, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Create Chat Request Model
class CreateChatRequest {
  final String participantId;

  CreateChatRequest({required this.participantId});

  Map<String, dynamic> toJson() {
    return {'participantId': participantId};
  }
}

// Message Types Enum
enum MessageType { text, image, file, photo }

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.photo:
        return 'photo';
    }
  }

  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'photo':
        return MessageType.photo;
      default:
        return MessageType.text;
    }
  }
}
