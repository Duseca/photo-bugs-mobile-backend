// models/download_model/download_model.dart

import 'package:intl/intl.dart';

/// Download Statistics Model
class DownloadStats {
  final int totalDownloads;
  final List<MonthlyStats> monthlyStats;

  DownloadStats({required this.totalDownloads, required this.monthlyStats});

  factory DownloadStats.fromJson(Map<String, dynamic> json) {
    return DownloadStats(
      totalDownloads: json['totalDownloads'] as int? ?? 0,
      monthlyStats:
          (json['monthlyStats'] as List<dynamic>?)
              ?.map((e) => MonthlyStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDownloads': totalDownloads,
      'monthlyStats': monthlyStats.map((e) => e.toJson()).toList(),
    };
  }
}

/// Monthly Statistics Model
class MonthlyStats {
  final int year;
  final int month;
  final int downloads;

  MonthlyStats({
    required this.year,
    required this.month,
    required this.downloads,
  });

  /// Get month name from month number
  String get monthName {
    try {
      final date = DateTime(year, month);
      return DateFormat('MMMM').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'year': year, 'month': month, 'downloads': downloads};
  }
}

/// Download Month Model (for UI display)
class DownloadMonth {
  final String id;
  final String month;
  final int year;
  final int monthNumber;
  final int downloadCount;
  final double earnings;
  final DateTime date;

  DownloadMonth({
    required this.id,
    required this.month,
    required this.year,
    required this.monthNumber,
    required this.downloadCount,
    required this.earnings,
    required this.date,
  });

  String get displayDate => DateFormat('MMM yyyy').format(date);

  factory DownloadMonth.fromJson(Map<String, dynamic> json) {
    return DownloadMonth(
      id: json['id'] as String? ?? '',
      month: json['month'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      monthNumber: json['monthNumber'] as int? ?? 0,
      downloadCount: json['downloadCount'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      date:
          json['date'] != null
              ? DateTime.parse(json['date'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'monthNumber': monthNumber,
      'downloadCount': downloadCount,
      'earnings': earnings,
      'date': date.toIso8601String(),
    };
  }
}

/// Download Item Model (for category display)
class DownloadItem {
  final String id;
  final String name;
  final int downloadCount;
  final double earnings;
  final String? imageUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  DownloadItem({
    required this.id,
    required this.name,
    required this.downloadCount,
    required this.earnings,
    this.imageUrl,
    this.thumbnailUrl,
    this.createdAt,
    this.metadata,
  });

  String get displayImage => thumbnailUrl ?? imageUrl ?? '';

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      downloadCount: json['downloadCount'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'downloadCount': downloadCount,
      'earnings': earnings,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}
