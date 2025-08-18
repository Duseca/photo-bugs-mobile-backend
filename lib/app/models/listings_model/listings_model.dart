// ==================== MODELS ====================

// models/listing_item.dart
class ListingItem {
  final String id;
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String status;
  final List<String> recipients;
  final List<ListingFolder> folders;

  ListingItem({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.recipients,
    required this.folders,
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    return ListingItem(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      location: json['location'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      recipients: List<String>.from(json['recipients'] ?? []),
      folders: (json['folders'] as List?)
          ?.map((folder) => ListingFolder.fromJson(folder))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'location': location,
      'imageUrl': imageUrl,
      'status': status,
      'recipients': recipients,
      'folders': folders.map((folder) => folder.toJson()).toList(),
    };
  }

  ListingItem copyWith({
    String? id,
    String? title,
    String? date,
    String? location,
    String? imageUrl,
    String? status,
    List<String>? recipients,
    List<ListingFolder>? folders,
  }) {
    return ListingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      recipients: recipients ?? this.recipients,
      folders: folders ?? this.folders,
    );
  }
}

// models/listing_folder.dart
class ListingFolder {
  final String id;
  final String name;
  final String date;
  final int itemCount;
  final String ownerName;

  ListingFolder({
    required this.id,
    required this.name,
    required this.date,
    required this.itemCount,
    required this.ownerName,
  });

  factory ListingFolder.fromJson(Map<String, dynamic> json) {
    return ListingFolder(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      itemCount: json['itemCount'],
      ownerName: json['ownerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'itemCount': itemCount,
      'ownerName': ownerName,
    };
  }
}