import 'package:photo_bug/app/data/models/location_model.dart';

class Event {
  final String? id;
  final String name;
  final String? creatorId;
  final String? photographerId;
  final String? image;
  final Location? location;
  final DateTime? date;
  final int? timeStart;
  final int? timeEnd;
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
    // Safely extract creator ID
    String? creatorId;
    try {
      if (json['created_by'] != null) {
        if (json['created_by'] is Map) {
          creatorId = json['created_by']['_id'] ?? json['created_by']['id'];
        } else if (json['created_by'] is String) {
          creatorId = json['created_by'];
        }
      }
      creatorId ??= json['creatorId'] ?? json['creator_id'];
    } catch (e) {
      print('Error parsing creatorId: $e');
    }

    // Safely extract photographer ID
    String? photographerId;
    try {
      if (json['photographer'] != null) {
        if (json['photographer'] is Map) {
          photographerId =
              json['photographer']['_id'] ?? json['photographer']['id'];
        } else if (json['photographer'] is String) {
          photographerId = json['photographer'];
        }
      }
      photographerId ??= json['photographerId'];
    } catch (e) {
      print('Error parsing photographerId: $e');
    }

    // Safely parse location
    Location? location;
    try {
      if (json['location'] != null && json['location'] is Map) {
        location = Location.fromJson(json['location'] as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error parsing location: $e');
      location = null;
    }

    // Safely parse date
    DateTime? date;
    try {
      if (json['date'] != null) {
        date = DateTime.tryParse(json['date'].toString());
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    // Safely parse recipients
    List<EventRecipient>? recipients;
    try {
      if (json['recipients'] != null && json['recipients'] is List) {
        recipients =
            (json['recipients'] as List)
                .map((r) {
                  try {
                    return EventRecipient.fromJson(r as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing recipient: $e');
                    return null;
                  }
                })
                .where((r) => r != null)
                .cast<EventRecipient>()
                .toList();
      }
    } catch (e) {
      print('Error parsing recipients: $e');
      recipients = [];
    }

    // Parse createdAt
    DateTime? createdAt;
    try {
      if (json['createdAt'] != null) {
        createdAt = DateTime.tryParse(json['createdAt'].toString());
      }
    } catch (e) {
      print('Error parsing createdAt: $e');
    }

    // Parse updatedAt
    DateTime? updatedAt;
    try {
      if (json['updatedAt'] != null) {
        updatedAt = DateTime.tryParse(json['updatedAt'].toString());
      }
    } catch (e) {
      print('Error parsing updatedAt: $e');
    }

    return Event(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString() ?? 'Untitled Event',
      creatorId: creatorId,
      photographerId: photographerId,
      image: json['image']?.toString(),
      location: location,
      date: date,
      timeStart: json['time_start'] ?? json['timeStart'],
      timeEnd: json['time_end'] ?? json['timeEnd'],
      type: json['type']?.toString(),
      role: json['role']?.toString(),
      matureContent: json['mature_content'] ?? json['matureContent'] ?? false,
      recipients: recipients,
      status: _determineEventStatus(json, date),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static EventStatus _determineEventStatus(
    Map<String, dynamic> json,
    DateTime? date,
  ) {
    // If status is explicitly provided
    if (json['status'] != null) {
      try {
        return EventStatusExtension.fromString(json['status'].toString());
      } catch (e) {
        print('Error parsing status: $e');
      }
    }

    // Determine status based on date
    if (date != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDay = DateTime(date.year, date.month, date.day);

      if (eventDay.isAfter(today)) {
        return EventStatus.confirmed; // Future event
      } else if (eventDay.isBefore(today)) {
        return EventStatus.completed; // Past event
      } else {
        return EventStatus.ongoing; // Today's event
      }
    }

    return EventStatus.pending;
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
      id: json['id']?.toString() ?? json['user_id']?.toString(),
      email: json['email']?.toString(),
      status: RecipientStatusExtension.fromString(
        json['status']?.toString() ?? 'pending',
      ),
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
      if (location != null) 'location': location!.toJson(),
      if (date != null) 'date': date!.toIso8601String(),
      if (timeStart != null) 'time_start': timeStart,
      if (timeEnd != null) 'time_end': timeEnd,
      if (type != null) 'type': type,
      if (role != null) 'role': role,
      'mature_content': matureContent,
    };
  }
}

class AddRecipientsRequest {
  final List<EventRecipient> recipients;

  AddRecipientsRequest({required this.recipients});

  Map<String, dynamic> toJson() {
    return {'recipients': recipients.map((r) => r.toJson()).toList()};
  }
}

/// Event Search Parameters - COMPLETE VERSION
class EventSearchParams {
  final Location? location;
  final String? role;
  final String? type;
  final double? distance;
  final String? name; // Add name/query parameter
  final String? status; // Optional: search by status
  final DateTime? startDate; // Optional: search by date range
  final DateTime? endDate; // Optional: search by date range
  final bool? matureContent; // Optional: filter mature content

  const EventSearchParams({
    this.location,
    this.role,
    this.type,
    this.distance,
    this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.matureContent,
  });

  /// Convert to query parameters for API request
  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    // Location parameters
    if (location != null) {
      params['location'] = '${location!.longitude},${location!.latitude}';
    }

    // Role filter
    if (role != null && role!.isNotEmpty) {
      params['role'] = role!;
    }

    // Type filter
    if (type != null && type!.isNotEmpty) {
      params['type'] = type!;
    }

    // Distance/radius filter
    if (distance != null && distance! > 0) {
      params['distance'] = distance!.toString();
    }

    // Name/query search
    if (name != null && name!.isNotEmpty) {
      params['name'] = name!;
    }

    // Status filter
    if (status != null && status!.isNotEmpty) {
      params['status'] = status!;
    }

    // Date range filters
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String();
    }

    // Mature content filter
    if (matureContent != null) {
      params['matureContent'] = matureContent!.toString();
    }

    return params;
  }

  /// Create a copy with updated parameters
  EventSearchParams copyWith({
    Location? location,
    String? role,
    String? type,
    double? distance,
    String? name,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? matureContent,
  }) {
    return EventSearchParams(
      location: location ?? this.location,
      role: role ?? this.role,
      type: type ?? this.type,
      distance: distance ?? this.distance,
      name: name ?? this.name,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      matureContent: matureContent ?? this.matureContent,
    );
  }

  /// Check if any search parameters are set
  bool get hasFilters {
    return location != null ||
        (role != null && role!.isNotEmpty) ||
        (type != null && type!.isNotEmpty) ||
        (distance != null && distance! > 0) ||
        (name != null && name!.isNotEmpty) ||
        (status != null && status!.isNotEmpty) ||
        startDate != null ||
        endDate != null ||
        matureContent != null;
  }

  @override
  String toString() {
    return 'EventSearchParams(location: $location, role: $role, type: $type, '
        'distance: $distance, name: $name, status: $status, '
        'startDate: $startDate, endDate: $endDate, matureContent: $matureContent)';
  }
}

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
