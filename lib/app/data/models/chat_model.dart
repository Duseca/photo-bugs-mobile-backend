class Chat {
  final String? id;
  final List<Participant> participants;
  final List<LastSeen> lastSeen;
  final List<Message> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int unreadCount;

  Chat({
    this.id,
    required this.participants,
    this.lastSeen = const [],
    this.messages = const [],
    this.createdAt,
    this.updatedAt,
    this.unreadCount = 0,
  });

  // Get last message
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'],
      participants:
          (json['participants'] as List?)
              ?.map((e) => Participant.fromJson(e))
              .toList() ??
          [],
      lastSeen:
          (json['lastSeen'] as List?)
              ?.map((e) => LastSeen.fromJson(e))
              .toList() ??
          [],
      messages:
          (json['messages'] as List?)
              ?.map((e) => Message.fromJson(e))
              .toList() ??
          [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'participants': participants.map((e) => e.toJson()).toList(),
      'lastSeen': lastSeen.map((e) => e.toJson()).toList(),
      'messages': messages.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  Chat copyWith({
    String? id,
    List<Participant>? participants,
    List<LastSeen>? lastSeen,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastSeen: lastSeen ?? this.lastSeen,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  String toString() {
    return 'Chat{id: $id, participants: ${participants.length}, messages: ${messages.length}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chat && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Participant {
  final String id;
  final String name;
  final String userName;
  final String profilePicture;

  Participant({
    required this.id,
    required this.name,
    required this.userName,
    required this.profilePicture,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      userName: json['user_name'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'user_name': userName,
      'profile_picture': profilePicture,
    };
  }
}

class LastSeen {
  final User user;
  final DateTime timestamp;
  final String? id;

  LastSeen({required this.user, required this.timestamp, this.id});

  factory LastSeen.fromJson(Map<String, dynamic> json) {
    return LastSeen(
      user: User.fromJson(json['user']),
      timestamp: DateTime.tryParse(json['timestamp']) ?? DateTime.now(),
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'timestamp': timestamp.toIso8601String(),
      if (id != null) '_id': id,
    };
  }
}

class User {
  final String id;
  final String name;
  final String userName;

  User({required this.id, required this.name, required this.userName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      userName: json['user_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'user_name': userName};
  }
}

class Message {
  final String? id;
  final String chatId;
  final String createdBy;
  final String content;
  final String type;
  final DateTime? createdAt;
  final bool isRead;

  Message({
    this.id,
    required this.chatId,
    required this.createdBy,
    required this.content,
    this.type = 'Text',
    this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // CRITICAL FIX: Handle both String and Object for created_by
    String createdById;
    if (json['created_by'] is String) {
      // Case 1: created_by is just a String ID (in chat list)
      createdById = json['created_by'];
    } else if (json['created_by'] is Map) {
      // Case 2: created_by is an Object with _id (in send message response)
      createdById = json['created_by']['_id'] ?? '';
    } else {
      createdById = '';
    }

    // CRITICAL FIX: Handle both cases for chatId
    String chatIdValue;
    if (json['chat'] is Map) {
      // Case 1: chat is an object with _id
      chatIdValue = json['chat']['_id'] ?? '';
    } else if (json['chat'] is String) {
      // Case 2: chat is just a String ID
      chatIdValue = json['chat'];
    } else if (json['chatId'] != null) {
      // Case 3: chatId field exists
      chatIdValue = json['chatId'];
    } else {
      chatIdValue = '';
    }

    return Message(
      id: json['_id'],
      chatId: chatIdValue,
      createdBy: createdById,
      content: json['content'] ?? '',
      type: json['type'] ?? 'Text',
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'chatId': chatId,
      'created_by': createdBy,
      'content': content,
      'type': type,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'isRead': isRead,
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? createdBy,
    String? content,
    String? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      createdBy: createdBy ?? this.createdBy,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'Message{id: $id, content: $content, type: $type}';
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

// Send Message Request Model
class SendMessageRequest {
  final String content;
  final String type;

  SendMessageRequest({required this.content, this.type = 'Text'});

  Map<String, dynamic> toJson() {
    return {'content': content, 'type': type};
  }
}

// Mark as Read Request Model
class MarkAsReadRequest {
  final bool markAsRead;
  final String chatId;

  MarkAsReadRequest({this.markAsRead = true, required this.chatId});

  Map<String, dynamic> toJson() {
    return {'markAsRead': markAsRead, 'chatId': chatId};
  }
}
