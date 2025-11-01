import 'dart:convert';

class Photo {
  final String? id;
  final String? creatorId;
  final CreatorInfo? creator;
  final String? eventId;
  final String? folderId;
  final String? url;
  final String? link;
  final String? watermarkedUrl;
  final String? watermarkedLink;
  final String? thumbnailUrl;
  final double? price;
  final PhotoMetadata? metadata;
  final List<String>? ownership;
  final int? views;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PhotoStatus status;

  Photo({
    this.id,
    this.creatorId,
    this.creator,
    this.eventId,
    this.folderId,
    this.url,
    this.link,
    this.watermarkedUrl,
    this.watermarkedLink,
    this.thumbnailUrl,
    this.price,
    this.metadata,
    this.ownership,
    this.views,
    this.createdAt,
    this.updatedAt,
    this.status = PhotoStatus.active,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['_id'] ?? json['id'],
      creatorId:
          json['creatorId'] ??
          json['creator_id'] ??
          (json['created_by'] is Map ? json['created_by']['_id'] : null),
      creator:
          json['created_by'] != null && json['created_by'] is Map
              ? CreatorInfo.fromJson(json['created_by'])
              : null,
      eventId: json['eventId'] ?? json['event_id'],
      folderId: json['folderId'] ?? json['folder_id'],
      url: json['url'] ?? json['file'],
      link: json['link'],
      watermarkedUrl: json['thumbnailUrl'] ?? json['thumbnail_url'],
      watermarkedLink: json['watermarked_link'] ?? json['watermarkedLink'],
      price: json['price']?.toDouble(),
      metadata: _parseMetadata(json),
      ownership:
          json['ownership'] != null
              ? List<String>.from(json['ownership'])
              : null,
      views: json['views']?.toInt(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      status: PhotoStatusExtension.fromString(json['status'] ?? 'active'),
    );
  }

  static PhotoMetadata? _parseMetadata(Map<String, dynamic> json) {
    PhotoMetadata? metadata;

    // Try to parse metadata field
    if (json['metadata'] != null) {
      if (json['metadata'] is String) {
        // If metadata is a JSON string, parse it
        try {
          final metadataJson = jsonDecode(json['metadata'] as String);
          if (metadataJson is Map<String, dynamic>) {
            metadata = PhotoMetadata.fromJson(metadataJson);
          }
        } catch (e) {
          print('Error parsing metadata string: $e');
        }
      } else if (json['metadata'] is Map) {
        metadata = PhotoMetadata.fromJson(json['metadata']);
      }
    }

    // Add views if it exists at root level
    if (json['views'] != null) {
      if (metadata != null) {
        metadata = metadata.copyWith(views: json['views']?.toInt());
      } else {
        metadata = PhotoMetadata(views: json['views']?.toInt());
      }
    }

    return metadata;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (creatorId != null) 'creatorId': creatorId,
      if (creator != null) 'created_by': creator!.toJson(),
      if (eventId != null) 'eventId': eventId,
      if (folderId != null) 'folderId': folderId,
      if (url != null) 'url': url,
      if (link != null) 'link': link,
      if (watermarkedUrl != null) 'thumbnailUrl': watermarkedUrl,
      if (watermarkedLink != null) 'watermarked_link': watermarkedLink,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (price != null) 'price': price,
      if (metadata != null) 'metadata': metadata!.toJson(),
      if (ownership != null) 'ownership': ownership,
      if (views != null) 'views': views,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'status': status.value,
    };
  }

  Photo copyWith({
    String? id,
    String? creatorId,
    CreatorInfo? creator,
    String? eventId,
    String? folderId,
    String? url,
    String? link,
    String? watermarkedUrl,
    String? watermarkedLink,
    String? thumbnailUrl,
    double? price,
    PhotoMetadata? metadata,
    List<String>? ownership,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
    PhotoStatus? status,
  }) {
    return Photo(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      eventId: eventId ?? this.eventId,
      folderId: folderId ?? this.folderId,
      url: url ?? this.url,
      link: link ?? this.link,
      watermarkedUrl: watermarkedUrl ?? this.watermarkedUrl,
      watermarkedLink: watermarkedLink ?? this.watermarkedLink,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      price: price ?? this.price,
      metadata: metadata ?? this.metadata,
      ownership: ownership ?? this.ownership,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Photo{id: $id, url: $url, price: $price, creator: ${creator?.name}, views: $views}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CreatorInfo {
  final String? id;
  final String? name;
  final String? profilePicture;

  CreatorInfo({this.id, this.name, this.profilePicture});

  factory CreatorInfo.fromJson(Map<String, dynamic> json) {
    return CreatorInfo(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
      if (profilePicture != null) 'profile_picture': profilePicture,
    };
  }

  @override
  String toString() => 'CreatorInfo{id: $id, name: $name}';
}

class PhotoMetadata {
  final String? fileName;
  final int? fileSize; // in bytes
  final String? mimeType;
  final int? width;
  final int? height;
  final DateTime? dateTaken;
  final String? cameraModel;
  final String? location;
  final String? category;
  final List<String>? tags;
  final int? views;
  final Map<String, dynamic>? exifData;

  PhotoMetadata({
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.width,
    this.height,
    this.dateTaken,
    this.cameraModel,
    this.location,
    this.category,
    this.tags,
    this.views,
    this.exifData,
  });

  factory PhotoMetadata.fromJson(Map<String, dynamic> json) {
    return PhotoMetadata(
      fileName: json['fileName'] ?? json['file_name'],
      fileSize: json['fileSize']?.toInt() ?? json['file_size']?.toInt(),
      mimeType: json['mimeType'] ?? json['mime_type'],
      width: json['width']?.toInt(),
      height: json['height']?.toInt(),
      dateTaken:
          json['dateTaken'] != null
              ? DateTime.tryParse(json['dateTaken'])
              : null,
      cameraModel: json['cameraModel'] ?? json['camera_model'],
      location: json['location'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      views: json['views']?.toInt(),
      exifData: json['exifData'] ?? json['exif_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (mimeType != null) 'mimeType': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (dateTaken != null) 'dateTaken': dateTaken!.toIso8601String(),
      if (cameraModel != null) 'cameraModel': cameraModel,
      if (location != null) 'location': location,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (views != null) 'views': views,
      if (exifData != null) 'exifData': exifData,
    };
  }

  PhotoMetadata copyWith({
    String? fileName,
    int? fileSize,
    String? mimeType,
    int? width,
    int? height,
    DateTime? dateTaken,
    String? cameraModel,
    String? location,
    String? category,
    List<String>? tags,
    int? views,
    Map<String, dynamic>? exifData,
  }) {
    return PhotoMetadata(
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      dateTaken: dateTaken ?? this.dateTaken,
      cameraModel: cameraModel ?? this.cameraModel,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      exifData: exifData ?? this.exifData,
    );
  }

  @override
  String toString() {
    return 'PhotoMetadata{fileName: $fileName, fileSize: $fileSize, width: $width, height: $height, views: $views}';
  }
}

// Upload Photo Request Model
class UploadPhotoRequest {
  final double? price;
  final String? file;
  final PhotoMetadata? metadata;

  UploadPhotoRequest({this.price, this.file, this.metadata});

  Map<String, dynamic> toJson() {
    return {
      if (price != null) 'price': price,
      if (file != null) 'file': file,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }
}

// Update Photo Request Model
class UpdatePhotoRequest {
  final double? price;
  final PhotoMetadata? metadata;

  UpdatePhotoRequest({this.price, this.metadata});

  Map<String, dynamic> toJson() {
    return {
      if (price != null) 'price': price,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }
}

// Photo Status Enum
enum PhotoStatus { active, processing, archived, deleted }

extension PhotoStatusExtension on PhotoStatus {
  String get value {
    switch (this) {
      case PhotoStatus.active:
        return 'active';
      case PhotoStatus.processing:
        return 'processing';
      case PhotoStatus.archived:
        return 'archived';
      case PhotoStatus.deleted:
        return 'deleted';
    }
  }

  static PhotoStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return PhotoStatus.processing;
      case 'archived':
        return PhotoStatus.archived;
      case 'deleted':
        return PhotoStatus.deleted;
      default:
        return PhotoStatus.active;
    }
  }
}
