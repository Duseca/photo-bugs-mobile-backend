
// models/trending_item.dart
class TrendingItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String size;
  final int viewCount;
  final bool isFavorite;
  final String authorName;
  final String authorImage;

  TrendingItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.viewCount,
    required this.isFavorite,
    required this.authorName,
    required this.authorImage,
  });

  factory TrendingItem.fromJson(Map<String, dynamic> json) {
    return TrendingItem(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      size: json['size'],
      viewCount: json['viewCount'],
      isFavorite: json['isFavorite'],
      authorName: json['authorName'],
      authorImage: json['authorImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'size': size,
      'viewCount': viewCount,
      'isFavorite': isFavorite,
      'authorName': authorName,
      'authorImage': authorImage,
    };
  }

  TrendingItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? price,
    String? size,
    int? viewCount,
    bool? isFavorite,
    String? authorName,
    String? authorImage,
  }) {
    return TrendingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      size: size ?? this.size,
      viewCount: viewCount ?? this.viewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
    );
  }
}

// models/home_quick_action.dart
class HomeQuickAction {
  final String id;
  final String label;
  final String icon;
  final String route;
  final bool isEnabled;

  HomeQuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.isEnabled = true,
  });

  factory HomeQuickAction.fromJson(Map<String, dynamic> json) {
    return HomeQuickAction(
      id: json['id'],
      label: json['label'],
      icon: json['icon'],
      route: json['route'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon,
      'route': route,
      'isEnabled': isEnabled,
    };
  }
}

// models/banner_item.dart
class BannerItem {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;
  final String? actionUrl;

  BannerItem({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    this.actionUrl,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
      actionUrl: json['actionUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'actionUrl': actionUrl,
    };
  }
}

// models/report_reason.dart
class ReportReason {
  final String id;
  final String title;
  final String description;

  ReportReason({
    required this.id,
    required this.title,
    required this.description,
  });

  static List<ReportReason> get defaultReasons => [
    ReportReason(
      id: 'bullying',
      title: 'Bullying or unwanted contact',
      description: 'Harassment, threats, or unwanted advances',
    ),
    ReportReason(
      id: 'self_harm',
      title: 'Suicide, self-injury or eating disorders',
      description: 'Content promoting harmful behaviors',
    ),
    ReportReason(
      id: 'inappropriate',
      title: 'Inappropriate content',
      description: 'Spam, violence, or adult content',
    ),
  ];
}
