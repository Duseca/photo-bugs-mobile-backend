import 'package:photo_bug/app/data/models/location_model.dart';

class Event {
  final String? id;
  final String name;
  final String? creatorId;
  final String? photographerId;
  final String? image;
  final Location? location;
  final DateTime? date;
  final int? timeStart; // in HHMM format (e.g., 1200 for 12:00)
  final int? timeEnd; // in HHMM format (e.g., 1445 for 14:45)
  final String? type;
  final String? role;
  final bool matureContent;
  final List<EventRecipient>? recipients;
  final EventStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    this.id,
    required this.name,
    this.creatorId,
    this.photographerId,
    this.image,
    this.location,
    this.date,
    this.timeStart,
    this.timeEnd,
    this.type,
    this.role,
    this.matureContent = false,
    this.recipients,
    this.status = EventStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  // Helper methods for time formatting
  String? get formattedStartTime {
    if (timeStart == null) return null;
    final hours = timeStart! ~/ 100;
    final minutes = timeStart! % 100;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String? get formattedEndTime {
    if (timeEnd == null) return null;
    final hours = timeEnd! ~/ 100;
    final minutes = timeEnd! % 100;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      creatorId: json['creatorId'] ?? json['creator_id'],
      photographerId: json['photographer'],
      image: json['image'],
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      timeStart: json['time_start'] ?? json['timeStart'],
      timeEnd: json['time_end'] ?? json['timeEnd'],
      type: json['type'],
      role: json['role'],
      matureContent: json['mature_content'] ?? json['matureContent'] ?? false,
      recipients:
          json['recipients'] != null
              ? List<EventRecipient>.from(
                json['recipients'].map((x) => EventRecipient.fromJson(x)),
              )
              : null,
      status: EventStatusExtension.fromString(json['status'] ?? 'pending'),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (creatorId != null) 'creatorId': creatorId,
      if (photographerId != null) 'photographer': photographerId,
      if (image != null) 'image': image,
      if (location != null) 'location': location!.toJson(),
      if (date != null) 'date': date!.toIso8601String(),
      if (timeStart != null) 'time_start': timeStart,
      if (timeEnd != null) 'time_end': timeEnd,
      if (type != null) 'type': type,
      if (role != null) 'role': role,
      'mature_content': matureContent,
      if (recipients != null)
        'recipients': recipients!.map((x) => x.toJson()).toList(),
      'status': status.value,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? photographerId,
    String? image,
    Location? location,
    DateTime? date,
    int? timeStart,
    int? timeEnd,
    String? type,
    String? role,
    bool? matureContent,
    List<EventRecipient>? recipients,
    EventStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      photographerId: photographerId ?? this.photographerId,
      image: image ?? this.image,
      location: location ?? this.location,
      date: date ?? this.date,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      type: type ?? this.type,
      role: role ?? this.role,
      matureContent: matureContent ?? this.matureContent,
      recipients: recipients ?? this.recipients,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, name: $name, type: $type, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class EventRecipient {
  final String? id;
  final String? email;
  final RecipientStatus status;

  EventRecipient({this.id, this.email, this.status = RecipientStatus.pending});

  factory EventRecipient.fromJson(Map<String, dynamic> json) {
    return EventRecipient(
      id: json['id'] ?? json['user_id'],
      email: json['email'],
      status: RecipientStatusExtension.fromString(json['status'] ?? 'pending'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      'status': status.value,
    };
  }

  EventRecipient copyWith({
    String? id,
    String? email,
    RecipientStatus? status,
  }) {
    return EventRecipient(
      id: id ?? this.id,
      email: email ?? this.email,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'EventRecipient{id: $id, email: $email, status: $status}';
  }
}

// Create Event Request Model
class CreateEventRequest {
  final String name;
  final String? photographerId;
  final String? image;
  final Location? location;
  final DateTime? date;
  final int? timeStart;
  final int? timeEnd;
  final String? type;
  final String? role;
  final bool matureContent;

  CreateEventRequest({
    required this.name,
    this.photographerId,
    this.image,
    this.location,
    this.date,
    this.timeStart,
    this.timeEnd,
    this.type,
    this.role,
    this.matureContent = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (photographerId != null) 'photographer': photographerId,
      if (image != null) 'image': image,
      if (location != null) 'location': location!.coordinates,
      if (date != null) 'date': date!.toIso8601String(),
      if (timeStart != null) 'time_start': timeStart,
      if (timeEnd != null) 'time_end': timeEnd,
      if (type != null) 'type': type,
      if (role != null) 'role': role,
      'mature_content': matureContent,
    };
  }
}

// Add Recipients Request Model
class AddRecipientsRequest {
  final List<EventRecipient> recipients;

  AddRecipientsRequest({required this.recipients});

  Map<String, dynamic> toJson() {
    return {'recipients': recipients.map((r) => r.toJson()).toList()};
  }
}

// Event Search Parameters
class EventSearchParams {
  final Location? location;
  final String? role;
  final String? type;
  final double? distance; // in kilometers

  EventSearchParams({this.location, this.role, this.type, this.distance});

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (location != null) {
      params['location'] = '${location!.longitude},${location!.latitude}';
    }
    if (role != null) {
      params['role'] = role!;
    }
    if (type != null) {
      params['type'] = type!;
    }
    if (distance != null) {
      params['distance'] = distance!.toString();
    }

    return params;
  }
}

// Event Status Enum
enum EventStatus { pending, confirmed, ongoing, completed, cancelled }

extension EventStatusExtension on EventStatus {
  String get value {
    switch (this) {
      case EventStatus.pending:
        return 'pending';
      case EventStatus.confirmed:
        return 'confirmed';
      case EventStatus.ongoing:
        return 'ongoing';
      case EventStatus.completed:
        return 'completed';
      case EventStatus.cancelled:
        return 'cancelled';
    }
  }

  static EventStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return EventStatus.confirmed;
      case 'ongoing':
        return EventStatus.ongoing;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.pending;
    }
  }
}

// Recipient Status Enum
enum RecipientStatus { pending, accepted, declined }

extension RecipientStatusExtension on RecipientStatus {
  String get value {
    switch (this) {
      case RecipientStatus.pending:
        return 'pending';
      case RecipientStatus.accepted:
        return 'accepted';
      case RecipientStatus.declined:
        return 'declined';
    }
  }

  static RecipientStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'accepted':
        return RecipientStatus.accepted;
      case 'declined':
        return RecipientStatus.declined;
      default:
        return RecipientStatus.pending;
    }
  }
}
