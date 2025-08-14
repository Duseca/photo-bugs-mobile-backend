import 'package:photo_bug/app/data/models/event_model.dart';

class Folder {
  final String? id;
  final String name;
  final String? creatorId;
  final String? eventId;
  final List<String>? photoIds;
  final List<String>? bundleIds;
  final List<FolderRecipient>? recipients;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final FolderStatus status;

  Folder({
    this.id,
    required this.name,
    this.creatorId,
    this.eventId,
    this.photoIds,
    this.bundleIds,
    this.recipients,
    this.createdAt,
    this.updatedAt,
    this.status = FolderStatus.active,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      creatorId: json['creatorId'] ?? json['creator_id'],
      eventId: json['event_id'] ?? json['eventId'],
      photoIds:
          json['photo_ids'] != null
              ? List<String>.from(json['photo_ids'])
              : null,
      bundleIds:
          json['bundle_ids'] != null
              ? List<String>.from(json['bundle_ids'])
              : null,
      recipients:
          json['recipients'] != null
              ? List<FolderRecipient>.from(
                json['recipients'].map((x) => FolderRecipient.fromJson(x)),
              )
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      status: FolderStatusExtension.fromString(json['status'] ?? 'active'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (creatorId != null) 'creatorId': creatorId,
      if (eventId != null) 'event_id': eventId,
      if (photoIds != null) 'photo_ids': photoIds,
      if (bundleIds != null) 'bundle_ids': bundleIds,
      if (recipients != null)
        'recipients': recipients!.map((x) => x.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'status': status.value,
    };
  }

  Folder copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? eventId,
    List<String>? photoIds,
    List<String>? bundleIds,
    List<FolderRecipient>? recipients,
    DateTime? createdAt,
    DateTime? updatedAt,
    FolderStatus? status,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      eventId: eventId ?? this.eventId,
      photoIds: photoIds ?? this.photoIds,
      bundleIds: bundleIds ?? this.bundleIds,
      recipients: recipients ?? this.recipients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Folder{id: $id, name: $name, eventId: $eventId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Folder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class FolderRecipient {
  final String? userId;
  final String? email;
  final RecipientStatus status;

  FolderRecipient({
    this.userId,
    this.email,
    this.status = RecipientStatus.pending,
  });

  factory FolderRecipient.fromJson(Map<String, dynamic> json) {
    return FolderRecipient(
      userId: json['user_id'] ?? json['userId'],
      email: json['email'],
      status: RecipientStatusExtension.fromString(json['status'] ?? 'pending'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      'status': status.value,
    };
  }

  FolderRecipient copyWith({
    String? userId,
    String? email,
    RecipientStatus? status,
  }) {
    return FolderRecipient(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'FolderRecipient{userId: $userId, email: $email, status: $status}';
  }
}

// Create Folder Request Model
class CreateFolderRequest {
  final String name;
  final String? eventId;
  final List<String>? photoIds;
  final List<String>? bundleIds;
  final List<FolderRecipient>? recipients;

  CreateFolderRequest({
    required this.name,
    this.eventId,
    this.photoIds,
    this.bundleIds,
    this.recipients,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (eventId != null) 'event_id': eventId,
      if (photoIds != null) 'photo_ids': photoIds,
      if (bundleIds != null) 'bundle_ids': bundleIds,
      if (recipients != null)
        'recipients': recipients!.map((r) => r.toJson()).toList(),
    };
  }
}

// Folder Status Enum
enum FolderStatus { active, archived, deleted }

extension FolderStatusExtension on FolderStatus {
  String get value {
    switch (this) {
      case FolderStatus.active:
        return 'active';
      case FolderStatus.archived:
        return 'archived';
      case FolderStatus.deleted:
        return 'deleted';
    }
  }

  static FolderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'archived':
        return FolderStatus.archived;
      case 'deleted':
        return FolderStatus.deleted;
      default:
        return FolderStatus.active;
    }
  }
}
