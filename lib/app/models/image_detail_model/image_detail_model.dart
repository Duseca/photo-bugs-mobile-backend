// ==================== MODELS ====================

// models/image_detail.dart
class ImageDetail {
  final String id;
  final String imageUrl;
  final String authorName;
  final String authorImage;
  final String title;
  final int viewCount;
  final double price;
  final bool isFavorite;
  final ImageMetadata metadata;
  final List<String> keywords;

  ImageDetail({
    required this.id,
    required this.imageUrl,
    required this.authorName,
    required this.authorImage,
    required this.title,
    required this.viewCount,
    required this.price,
    required this.isFavorite,
    required this.metadata,
    required this.keywords,
  });

  factory ImageDetail.fromJson(Map<String, dynamic> json) {
    return ImageDetail(
      id: json['id'],
      imageUrl: json['imageUrl'],
      authorName: json['authorName'],
      authorImage: json['authorImage'],
      title: json['title'],
      viewCount: json['viewCount'],
      price: json['price'].toDouble(),
      isFavorite: json['isFavorite'],
      metadata: ImageMetadata.fromJson(json['metadata']),
      keywords: List<String>.from(json['keywords']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'authorName': authorName,
      'authorImage': authorImage,
      'title': title,
      'viewCount': viewCount,
      'price': price,
      'isFavorite': isFavorite,
      'metadata': metadata.toJson(),
      'keywords': keywords,
    };
  }

  ImageDetail copyWith({
    String? id,
    String? imageUrl,
    String? authorName,
    String? authorImage,
    String? title,
    int? viewCount,
    double? price,
    bool? isFavorite,
    ImageMetadata? metadata,
    List<String>? keywords,
  }) {
    return ImageDetail(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      title: title ?? this.title,
      viewCount: viewCount ?? this.viewCount,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
      metadata: metadata ?? this.metadata,
      keywords: keywords ?? this.keywords,
    );
  }
}

// models/image_metadata.dart
class ImageMetadata {
  final String resolution;
  final String size;
  final String orientation;
  final String camera;
  final String cameraModel;
  final String isoSpeed;
  final String exposureBias;
  final String focalLength;

  ImageMetadata({
    required this.resolution,
    required this.size,
    required this.orientation,
    required this.camera,
    required this.cameraModel,
    required this.isoSpeed,
    required this.exposureBias,
    required this.focalLength,
  });

  factory ImageMetadata.fromJson(Map<String, dynamic> json) {
    return ImageMetadata(
      resolution: json['resolution'],
      size: json['size'],
      orientation: json['orientation'],
      camera: json['camera'],
      cameraModel: json['cameraModel'],
      isoSpeed: json['isoSpeed'],
      exposureBias: json['exposureBias'],
      focalLength: json['focalLength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution,
      'size': size,
      'orientation': orientation,
      'camera': camera,
      'cameraModel': cameraModel,
      'isoSpeed': isoSpeed,
      'exposureBias': exposureBias,
      'focalLength': focalLength,
    };
  }

  List<DetailTileData> get detailsList => [
        DetailTileData(title: 'Resolution', subText: resolution),
        DetailTileData(title: 'Size', subText: size),
        DetailTileData(title: 'Orientation', subText: orientation),
        DetailTileData(title: 'Camera', subText: camera),
        DetailTileData(title: 'Camera Model', subText: cameraModel),
        DetailTileData(title: 'ISO speed', subText: isoSpeed),
        DetailTileData(title: 'Exposure bias', subText: exposureBias),
        DetailTileData(title: 'Focal length', subText: focalLength),
      ];
}

// models/detail_tile_data.dart
class DetailTileData {
  final String title;
  final String subText;

  DetailTileData({
    required this.title,
    required this.subText,
  });
}
