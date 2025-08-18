enum ListingType {
  creator,
  hostedEvent,
}

extension ListingTypeExtension on ListingType {
  String get displayName {
    switch (this) {
      case ListingType.creator:
        return 'Creator';
      case ListingType.hostedEvent:
        return 'Hosted Event';
    }
  }
}

// models/creator_listing.dart
class CreatorListing {
  final String? id;
  final String? profilePicture;
  final String name;
  final String location;
  final String description;
  final DateTime? date;
  final String? timeStart;
  final String? timeEnd;
  final List<String> keywords;
  final String email;
  final String phoneNumber;
  final List<String> servicesOffered;
  final String prices;
  final List<String> languagesSpoken;
  final String experienceQualifications;
  final List<String> socialMediaLinks;
  final List<String> portfolioImages;

  CreatorListing({
    this.id,
    this.profilePicture,
    required this.name,
    required this.location,
    required this.description,
    this.date,
    this.timeStart,
    this.timeEnd,
    required this.keywords,
    required this.email,
    required this.phoneNumber,
    required this.servicesOffered,
    required this.prices,
    required this.languagesSpoken,
    required this.experienceQualifications,
    required this.socialMediaLinks,
    required this.portfolioImages,
  });

  factory CreatorListing.fromJson(Map<String, dynamic> json) {
    return CreatorListing(
      id: json['id'],
      profilePicture: json['profilePicture'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      timeStart: json['timeStart'],
      timeEnd: json['timeEnd'],
      keywords: List<String>.from(json['keywords'] ?? []),
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      servicesOffered: List<String>.from(json['servicesOffered'] ?? []),
      prices: json['prices'] ?? '',
      languagesSpoken: List<String>.from(json['languagesSpoken'] ?? []),
      experienceQualifications: json['experienceQualifications'] ?? '',
      socialMediaLinks: List<String>.from(json['socialMediaLinks'] ?? []),
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profilePicture': profilePicture,
      'name': name,
      'location': location,
      'description': description,
      'date': date?.toIso8601String(),
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'keywords': keywords,
      'email': email,
      'phoneNumber': phoneNumber,
      'servicesOffered': servicesOffered,
      'prices': prices,
      'languagesSpoken': languagesSpoken,
      'experienceQualifications': experienceQualifications,
      'socialMediaLinks': socialMediaLinks,
      'portfolioImages': portfolioImages,
    };
  }
}

// models/host_event.dart
class HostEvent {
  final String? id;
  final String eventName;
  final List<String> eventTypes;
  final String location;
  final String description;
  final String hostOrganizerName;
  final DateTime? date;
  final String? timeStart;
  final String? timeEnd;
  final List<String> keywords;
  final String email;
  final String phoneNumber;
  final int expectedAttendees;
  final List<String> servicesNeeded;
  final String budgetCompensation;
  final String specialRequirements;
  final String eventTheme;
  final DateTime? applicationDeadline;
  final List<String> socialMediaLinks;

  HostEvent({
    this.id,
    required this.eventName,
    required this.eventTypes,
    required this.location,
    required this.description,
    required this.hostOrganizerName,
    this.date,
    this.timeStart,
    this.timeEnd,
    required this.keywords,
    required this.email,
    required this.phoneNumber,
    required this.expectedAttendees,
    required this.servicesNeeded,
    required this.budgetCompensation,
    required this.specialRequirements,
    required this.eventTheme,
    this.applicationDeadline,
    required this.socialMediaLinks,
  });

  factory HostEvent.fromJson(Map<String, dynamic> json) {
    return HostEvent(
      id: json['id'],
      eventName: json['eventName'] ?? '',
      eventTypes: List<String>.from(json['eventTypes'] ?? []),
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      hostOrganizerName: json['hostOrganizerName'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      timeStart: json['timeStart'],
      timeEnd: json['timeEnd'],
      keywords: List<String>.from(json['keywords'] ?? []),
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      expectedAttendees: json['expectedAttendees'] ?? 0,
      servicesNeeded: List<String>.from(json['servicesNeeded'] ?? []),
      budgetCompensation: json['budgetCompensation'] ?? '',
      specialRequirements: json['specialRequirements'] ?? '',
      eventTheme: json['eventTheme'] ?? '',
      applicationDeadline: json['applicationDeadline'] != null 
          ? DateTime.parse(json['applicationDeadline']) : null,
      socialMediaLinks: List<String>.from(json['socialMediaLinks'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'eventTypes': eventTypes,
      'location': location,
      'description': description,
      'hostOrganizerName': hostOrganizerName,
      'date': date?.toIso8601String(),
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'keywords': keywords,
      'email': email,
      'phoneNumber': phoneNumber,
      'expectedAttendees': expectedAttendees,
      'servicesNeeded': servicesNeeded,
      'budgetCompensation': budgetCompensation,
      'specialRequirements': specialRequirements,
      'eventTheme': eventTheme,
      'applicationDeadline': applicationDeadline?.toIso8601String(),
      'socialMediaLinks': socialMediaLinks,
    };
  }
}

// models/service_category.dart
class ServiceCategory {
  final String title;
  final List<String> items;

  ServiceCategory({
    required this.title,
    required this.items,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      title: json['title'],
      items: List<String>.from(json['items']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items,
    };
  }
}