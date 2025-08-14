class Notification {
  final String? id;
  final String userId;
  final String description;
  final bool isSeen;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final NotificationType? type;
  final Map<String, dynamic>? data;

  Notification({
    this.id,
    required this.userId,
    required this.description,
    this.isSeen = false,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] ?? json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      description: json['description'] ?? '',
      isSeen: json['isSeen'] ?? json['is_seen'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      type:
          json['type'] != null
              ? NotificationTypeExtension.fromString(json['type'])
              : null,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user_id': userId,
      'description': description,
      'isSeen': isSeen,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (type != null) 'type': type!.value,
      if (data != null) 'data': data,
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? description,
    bool? isSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    NotificationType? type,
    Map<String, dynamic>? data,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'Notification{id: $id, userId: $userId, description: $description, isSeen: $isSeen}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Send Notification Request Model
class SendNotificationRequest {
  final String userId;
  final String description;
  final NotificationType? type;
  final Map<String, dynamic>? data;

  SendNotificationRequest({
    required this.userId,
    required this.description,
    this.type,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'description': description,
      if (type != null) 'type': type!.value,
      if (data != null) 'data': data,
    };
  }
}

// Notification Types Enum
enum NotificationType {
  eventInvite,
  folderInvite,
  photoUpload,
  purchase,
  review,
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.eventInvite:
        return 'event_invite';
      case NotificationType.folderInvite:
        return 'folder_invite';
      case NotificationType.photoUpload:
        return 'photo_upload';
      case NotificationType.purchase:
        return 'purchase';
      case NotificationType.review:
        return 'review';
      case NotificationType.general:
        return 'general';
    }
  }

  static NotificationType? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'event_invite':
        return NotificationType.eventInvite;
      case 'folder_invite':
        return NotificationType.folderInvite;
      case 'photo_upload':
        return NotificationType.photoUpload;
      case 'purchase':
        return NotificationType.purchase;
      case 'review':
        return NotificationType.review;
      case 'general':
        return NotificationType.general;
      default:
        return null;
    }
  }
}
