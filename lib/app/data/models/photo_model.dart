// models/photo_model.dart

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
  final String? accessImage;
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
    this.accessImage,
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
      creatorId: _parseCreatorId(json),
      creator: _parseCreator(json),
      eventId: json['eventId'] ?? json['event_id'],
      folderId: json['folderId'] ?? json['folder_id'],
      url: json['url'] ?? json['file'],
      link: json['link'],
      watermarkedUrl: json['watermarked_link'] ?? json['watermarkedLink'],
      watermarkedLink: json['watermarked_link'] ?? json['watermarkedLink'],
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail_url'],
      accessImage: json['access_image'] ?? json['accessImage'],
      price: _parsePrice(json['price']),
      metadata: _parseMetadata(json),
      ownership:
          json['ownership'] != null
              ? List<String>.from(json['ownership'])
              : null,
      views: _parseViews(json['views']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      status: PhotoStatusExtension.fromString(json['status'] ?? 'active'),
    );
  }

  static String? _parseCreatorId(Map<String, dynamic> json) {
    if (json['creatorId'] != null) return json['creatorId'] as String?;
    if (json['creator_id'] != null) return json['creator_id'] as String?;
    if (json['created_by'] is Map) {
      return json['created_by']['_id'] ?? json['created_by']['id'];
    }
    if (json['created_by'] is String) return json['created_by'] as String?;
    return null;
  }

  static CreatorInfo? _parseCreator(Map<String, dynamic> json) {
    if (json['created_by'] != null && json['created_by'] is Map) {
      return CreatorInfo.fromJson(json['created_by'] as Map<String, dynamic>);
    }
    if (json['creator'] != null && json['creator'] is Map) {
      return CreatorInfo.fromJson(json['creator'] as Map<String, dynamic>);
    }
    return null;
  }

  static double? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price);
    return null;
  }

  static int? _parseViews(dynamic views) {
    if (views == null) return 0;
    if (views is int) return views;
    if (views is double) return views.toInt();
    if (views is String) return int.tryParse(views) ?? 0;
    return 0;
  }

  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) return DateTime.tryParse(dateTime);
    return null;
  }

  static PhotoMetadata? _parseMetadata(Map<String, dynamic> json) {
    PhotoMetadata? metadata;

    if (json['metadata'] != null) {
      if (json['metadata'] is String) {
        try {
          final metadataJson = jsonDecode(json['metadata'] as String);
          if (metadataJson is Map<String, dynamic>) {
            metadata = PhotoMetadata.fromJson(metadataJson);
          }
        } catch (e) {
          print('⚠️ Error parsing metadata string: $e');
        }
      } else if (json['metadata'] is Map) {
        metadata = PhotoMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>,
        );
      }
    }

    if (json['views'] != null && metadata != null) {
      metadata = metadata.copyWith(views: _parseViews(json['views']));
    }

    return metadata;
  }

  String get displayUrl {
    return accessImage ??
        watermarkedUrl ??
        watermarkedLink ??
        thumbnailUrl ??
        link ??
        url ??
        '';
  }

  String get downloadUrl {
    return link ?? url ?? '';
  }

  String get previewUrl {
    return thumbnailUrl ?? accessImage ?? watermarkedUrl ?? url ?? '';
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
      if (watermarkedUrl != null) 'watermarked_link': watermarkedUrl,
      if (watermarkedLink != null) 'watermarked_link': watermarkedLink,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (accessImage != null) 'access_image': accessImage,
      if (price != null) 'price': price,
      if (metadata != null) 'metadata': jsonEncode(metadata!.toJson()),
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
    String? accessImage,
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
      accessImage: accessImage ?? this.accessImage,
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
    return 'Photo{id: $id, creator: ${creator?.name}, price: \$$price, views: $views}';
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
  final String? userName;
  final String? profilePicture;
  final String? email;
  final String? phone;
  final String? role;

  CreatorInfo({
    this.id,
    this.name,
    this.userName,
    this.profilePicture,
    this.email,
    this.phone,
    this.role,
  });

  factory CreatorInfo.fromJson(Map<String, dynamic> json) {
    return CreatorInfo(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      userName: json['user_name'] ?? json['userName'] ?? json['username'],
      profilePicture:
          json['profile_picture'] ?? json['profilePicture'] ?? json['avatar'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
      if (userName != null) 'user_name': userName,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
    };
  }

  @override
  String toString() => 'CreatorInfo{id: $id, name: $name, role: $role}';
}

class PhotoMetadata {
  final String? fileName;
  final int? fileSize;
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
      fileName: json['fileName'] ?? json['file_name'] ?? json['filename'],
      fileSize: _parseInt(json['fileSize'] ?? json['file_size']),
      mimeType: json['mimeType'] ?? json['mime_type'] ?? json['type'],
      width: _parseInt(json['width']),
      height: _parseInt(json['height']),
      dateTaken: _parseDateTime(json['dateTaken'] ?? json['date_taken']),
      cameraModel:
          json['cameraModel'] ?? json['camera_model'] ?? json['camera'],
      location: json['location'],
      category: json['category'],
      tags: _parseTags(json['tags']),
      views: _parseInt(json['views']),
      exifData: json['exifData'] ?? json['exif_data'],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String>? _parseTags(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        return [value];
      }
    }
    return null;
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
    return 'PhotoMetadata{fileName: $fileName, size: ${_formatFileSize(fileSize)}, dimensions: ${width}x$height}';
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class UploadPhotoRequest {
  final double? price;
  final String? file;
  final String? link;
  final PhotoMetadata? metadata;
  final String? eventId;
  final String? folderId;

  UploadPhotoRequest({
    this.price,
    this.file,
    this.link,
    this.metadata,
    this.eventId,
    this.folderId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (price != null) json['price'] = price;
    if (file != null) json['file'] = file;
    if (link != null) json['link'] = link;
    if (eventId != null) json['eventId'] = eventId;
    if (folderId != null) json['folderId'] = folderId;

    if (metadata != null) {
      json['metadata'] = jsonEncode(metadata!.toJson());
    }

    return json;
  }
}

class UpdatePhotoRequest {
  final double? price;
  final PhotoMetadata? metadata;
  final PhotoStatus? status;

  UpdatePhotoRequest({this.price, this.metadata, this.status});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (price != null) json['price'] = price;
    if (status != null) json['status'] = status!.value;

    if (metadata != null) {
      json['metadata'] = jsonEncode(metadata!.toJson());
    }

    return json;
  }
}

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
      case 'active':
      default:
        return PhotoStatus.active;
    }
  }
}
