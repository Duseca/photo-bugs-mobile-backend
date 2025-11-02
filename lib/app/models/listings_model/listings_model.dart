// models/listings_model/listing_item.dart

class ListingItem {
  final String id;
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String status;
  final List<String> recipients;
  final List<ListingFolder> folders;
  final String? eventId;
  final String? creatorId;
  final int totalPhotos;

  ListingItem({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.recipients,
    required this.folders,
    this.eventId,
    this.creatorId,
    this.totalPhotos = 0,
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    return ListingItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['name'] ?? json['title'] ?? 'Untitled',
      date: _formatDate(json['createdAt'] ?? json['date']),
      location: _extractLocation(json),
      imageUrl: _extractImageUrl(json),
      status: _determineStatus(json),
      recipients: _extractRecipients(json),
      folders: _extractFolders(json),
      eventId: json['event_id'] ?? json['eventId'],
      creatorId: json['created_by'] ?? json['createdBy'] ?? json['creator_id'],
      totalPhotos: _countPhotos(json),
    );
  }

  // Helper method to format date
  static String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'N/A';
      }

      // Format: "27 Sep, 2024"
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Helper method to extract location
  static String _extractLocation(Map<String, dynamic> json) {
    // Try different location fields
    if (json['location'] is Map) {
      final loc = json['location'];
      if (loc['address'] != null) return loc['address'];
      if (loc['town'] != null && loc['country'] != null) {
        return '${loc['town']}, ${loc['country']}';
      }
    }

    if (json['address'] is Map) {
      final addr = json['address'];
      final parts = <String>[];
      if (addr['address'] != null) parts.add(addr['address']);
      if (addr['town'] != null) parts.add(addr['town']);
      if (addr['country'] != null) parts.add(addr['country']);
      if (parts.isNotEmpty) return parts.join(', ');
    }

    return 'Location not specified';
  }

  // Helper method to extract image URL
  static String _extractImageUrl(Map<String, dynamic> json) {
    // Try different image fields
    if (json['cover_photo_id'] is Map &&
        json['cover_photo_id']['url'] != null) {
      return json['cover_photo_id']['url'];
    }

    if (json['image'] != null) return json['image'];
    if (json['imageUrl'] != null) return json['imageUrl'];
    if (json['cover_image'] != null) return json['cover_image'];

    // Try to get first photo from photos array
    if (json['photo_id'] is List && (json['photo_id'] as List).isNotEmpty) {
      final firstPhoto = json['photo_id'][0];
      if (firstPhoto is Map && firstPhoto['url'] != null) {
        return firstPhoto['url'];
      }
    }

    return '';
  }

  // Helper method to determine status
  static String _determineStatus(Map<String, dynamic> json) {
    // Check if there's an explicit status field
    if (json['status'] != null) return json['status'];

    // Determine status based on dates
    try {
      if (json['date'] != null) {
        final eventDate = DateTime.parse(json['date']);
        final now = DateTime.now();

        if (eventDate.isBefore(now)) {
          return 'Completed';
        } else if (eventDate.difference(now).inDays <= 7) {
          return 'Upcoming';
        } else {
          return 'Scheduled';
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return 'Active';
  }

  // Helper method to extract recipients
  static List<String> _extractRecipients(Map<String, dynamic> json) {
    final recipients = <String>[];

    // Check recipients array
    if (json['recipients'] is List) {
      for (var recipient in json['recipients']) {
        if (recipient is Map) {
          if (recipient['profile_picture'] != null) {
            recipients.add(recipient['profile_picture']);
          } else if (recipient['user_id'] is Map &&
              recipient['user_id']['profile_picture'] != null) {
            recipients.add(recipient['user_id']['profile_picture']);
          }
        } else if (recipient is String) {
          recipients.add(recipient);
        }
      }
    }

    return recipients;
  }

  // Helper method to extract folders
  static List<ListingFolder> _extractFolders(Map<String, dynamic> json) {
    // This would typically come from a separate API call
    // For now, create a default folder from the bundle data
    return [
      ListingFolder(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? 'Photos',
        date: _formatDate(json['createdAt'] ?? json['date']),
        itemCount: _countPhotos(json),
        ownerName: _extractOwnerName(json),
      ),
    ];
  }

  // Helper method to count photos
  static int _countPhotos(Map<String, dynamic> json) {
    int count = 0;

    if (json['photo_id'] is List) {
      count += (json['photo_id'] as List).length;
    }

    if (json['bonus_photo_id'] is List) {
      count += (json['bonus_photo_id'] as List).length;
    }

    return count;
  }

  // Helper method to extract owner name
  static String _extractOwnerName(Map<String, dynamic> json) {
    if (json['created_by'] is Map) {
      return json['created_by']['name'] ??
          json['created_by']['user_name'] ??
          'Unknown';
    }
    return 'Me';
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
      'eventId': eventId,
      'creatorId': creatorId,
      'totalPhotos': totalPhotos,
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
    String? eventId,
    String? creatorId,
    int? totalPhotos,
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
      eventId: eventId ?? this.eventId,
      creatorId: creatorId ?? this.creatorId,
      totalPhotos: totalPhotos ?? this.totalPhotos,
    );
  }
}

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
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Folder',
      date: json['date'] ?? json['createdAt'] ?? 'N/A',
      itemCount: json['itemCount'] ?? json['item_count'] ?? 0,
      ownerName: json['ownerName'] ?? json['owner_name'] ?? 'Unknown',
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
