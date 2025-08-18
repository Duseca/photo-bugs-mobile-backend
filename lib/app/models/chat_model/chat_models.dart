// ==================== MODELS ====================

// models/chat_message.dart
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImage: json['senderImage'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['isMe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
    };
  }
}

// models/chat_head.dart
class ChatHead {
  final String id;
  final String userId;
  final String name;
  final String image;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;
  final bool hasNewMessage;
  final int unreadCount;

  ChatHead({
    required this.id,
    required this.userId,
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isOnline,
    required this.hasNewMessage,
    this.unreadCount = 0,
  });

  factory ChatHead.fromJson(Map<String, dynamic> json) {
    return ChatHead(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      image: json['image'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      isOnline: json['isOnline'],
      hasNewMessage: json['hasNewMessage'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'image': image,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'isOnline': isOnline,
      'hasNewMessage': hasNewMessage,
      'unreadCount': unreadCount,
    };
  }

  ChatHead copyWith({
    String? id,
    String? userId,
    String? name,
    String? image,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isOnline,
    bool? hasNewMessage,
    int? unreadCount,
  }) {
    return ChatHead(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      image: image ?? this.image,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isOnline: isOnline ?? this.isOnline,
      hasNewMessage: hasNewMessage ?? this.hasNewMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}