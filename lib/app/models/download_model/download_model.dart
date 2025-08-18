// ==================== MODELS ====================

// models/download_month.dart
class DownloadMonth {
  final String id;
  final String month;
  final int downloadCount;
  final double earnings;

  DownloadMonth({
    required this.id,
    required this.month,
    required this.downloadCount,
    required this.earnings,
  });

  factory DownloadMonth.fromJson(Map<String, dynamic> json) {
    return DownloadMonth(
      id: json['id'],
      month: json['month'],
      downloadCount: json['downloadCount'],
      earnings: json['earnings'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'downloadCount': downloadCount,
      'earnings': earnings,
    };
  }
}

// models/download_item.dart
class DownloadItem {
  final String id;
  final String name;
  final int downloadCount;
  final double earnings;
  final String imageUrl;

  DownloadItem({
    required this.id,
    required this.name,
    required this.downloadCount,
    required this.earnings,
    required this.imageUrl,
  });

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'],
      name: json['name'],
      downloadCount: json['downloadCount'],
      earnings: json['earnings'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'downloadCount': downloadCount,
      'earnings': earnings,
      'imageUrl': imageUrl,
    };
  }
}

// models/image_stats.dart
class ImageStats {
  final String imageUrl;
  final int lifetimeDownloads;
  final double lifetimeEarnings;

  ImageStats({
    required this.imageUrl,
    required this.lifetimeDownloads,
    required this.lifetimeEarnings,
  });

  factory ImageStats.fromJson(Map<String, dynamic> json) {
    return ImageStats(
      imageUrl: json['imageUrl'],
      lifetimeDownloads: json['lifetimeDownloads'],
      lifetimeEarnings: json['lifetimeEarnings'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'lifetimeDownloads': lifetimeDownloads,
      'lifetimeEarnings': lifetimeEarnings,
    };
  }
}