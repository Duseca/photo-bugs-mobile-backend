class Photo {
  final String? id;
  final String? creatorId;
  final String? eventId;
  final String? folderId;
  final String? url;
  final String? thumbnailUrl;
  final double? price;
  final PhotoMetadata? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PhotoStatus status;

  Photo({
    this.id,
    this.creatorId,
    this.eventId,
    this.folderId,
    this.url,
    this.thumbnailUrl,
    this.price,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.status = PhotoStatus.active,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['_id'] ?? json['id'],
      creatorId: json['creatorId'] ?? json['creator_id'],
      eventId: json['eventId'] ?? json['event_id'],
      folderId: json['folderId'] ?? json['folder_id'],
      url: json['url'] ?? json['file'],
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail_url'],
      price: json['price']?.toDouble(),
      metadata:
          json['metadata'] != null
              ? PhotoMetadata.fromJson(json['metadata'])
              : null,
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

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (creatorId != null) 'creatorId': creatorId,
      if (eventId != null) 'eventId': eventId,
      if (folderId != null) 'folderId': folderId,
      if (url != null) 'url': url,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (price != null) 'price': price,
      if (metadata != null) 'metadata': metadata!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'status': status.value,
    };
  }

  Photo copyWith({
    String? id,
    String? creatorId,
    String? eventId,
    String? folderId,
    String? url,
    String? thumbnailUrl,
    double? price,
    PhotoMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    PhotoStatus? status,
  }) {
    return Photo(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      eventId: eventId ?? this.eventId,
      folderId: folderId ?? this.folderId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      price: price ?? this.price,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Photo{id: $id, url: $url, price: $price}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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
    this.exifData,
  });

  factory PhotoMetadata.fromJson(Map<String, dynamic> json) {
    return PhotoMetadata(
      fileName: json['fileName'] ?? json['file_name'],
      fileSize: json['fileSize'] ?? json['file_size'],
      mimeType: json['mimeType'] ?? json['mime_type'],
      width: json['width'],
      height: json['height'],
      dateTaken:
          json['dateTaken'] != null
              ? DateTime.tryParse(json['dateTaken'])
              : null,
      cameraModel: json['cameraModel'] ?? json['camera_model'],
      location: json['location'],
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
      exifData: exifData ?? this.exifData,
    );
  }

  @override
  String toString() {
    return 'PhotoMetadata{fileName: $fileName, fileSize: $fileSize, width: $width, height: $height}';
  }
}

// Upload Photo Request Model
class UploadPhotoRequest {
  final double? price;
  final String? file; // This would be file path or file data
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
