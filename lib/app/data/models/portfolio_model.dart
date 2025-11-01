class Portfolio {
  final String id;
  final String creatorId;
  final List<PortfolioMedia> media;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Portfolio({
    required this.id,
    required this.creatorId,
    required this.media,
    this.createdAt,
    this.updatedAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['_id'] ?? json['id'] ?? '',
      creatorId: json['creator_id'] ?? json['creatorId'] ?? '',
      media:
          (json['media'] as List?)
              ?.map((e) => PortfolioMedia.fromJson(e))
              .toList() ??
          [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'creator_id': creatorId,
      'media': media.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PortfolioMedia {
  final List<String> urls; // Changed from single url to array of urls
  final String type;

  PortfolioMedia({required this.urls, required this.type});

  // Convenience getter for single URL (backwards compatibility)
  String get url => urls.isNotEmpty ? urls.first : '';

  factory PortfolioMedia.fromJson(Map<String, dynamic> json) {
    // Handle both array and single string for backwards compatibility
    List<String> urlList;

    if (json['url'] is List) {
      urlList = List<String>.from(json['url']);
    } else if (json['url'] is String) {
      urlList = [json['url']];
    } else {
      urlList = [];
    }

    return PortfolioMedia(urls: urlList, type: json['type'] ?? 'image');
  }

  Map<String, dynamic> toJson() {
    return {
      'url': urls, // Send as array
      'type': type,
    };
  }
}

class CreatePortfolioRequest {
  final List<PortfolioMedia> media;

  CreatePortfolioRequest({required this.media});

  Map<String, dynamic> toJson() {
    return {'media': media.map((e) => e.toJson()).toList()};
  }
}
