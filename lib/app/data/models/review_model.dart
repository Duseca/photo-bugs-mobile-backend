class Review {
  final String id;
  final String reviewerId;
  final String reviewForId;
  final int ratings; // 1-10 scale
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields from reviewer (populated by backend)
  final String? reviewerName;
  final String? reviewerProfilePicture;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewForId,
    required this.ratings,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.reviewerName,
    this.reviewerProfilePicture,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      reviewerId: json['reviewer_id'] ?? json['reviewerId'] ?? '',
      reviewForId: json['review_for_id'] ?? json['reviewForId'] ?? '',
      ratings: json['ratings'] ?? 0,
      comment: json['comment'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      reviewerName: json['reviewer_name'] ?? json['reviewerName'],
      reviewerProfilePicture:
          json['reviewer_profile_picture'] ?? json['reviewerProfilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reviewer_id': reviewerId,
      'review_for_id': reviewForId,
      'ratings': ratings,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'reviewer_name': reviewerName,
      'reviewer_profile_picture': reviewerProfilePicture,
    };
  }
}

class CreateReviewRequest {
  final String reviewForId;
  final int ratings; // 1-10 scale
  final String? comment;

  CreateReviewRequest({
    required this.reviewForId,
    required this.ratings,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'review_for_id': reviewForId,
      'ratings': ratings,
      if (comment != null) 'comment': comment,
    };
  }
}

class UpdateReviewRequest {
  final int? ratings;
  final String? comment;

  UpdateReviewRequest({this.ratings, this.comment});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (ratings != null) {
      data['ratings'] = ratings;
    }

    if (comment != null) {
      data['comment'] = comment;
    }

    return data;
  }
}

class AverageRating {
  final double average;
  final int totalReviews;
  final Map<int, int> distribution; // rating -> count

  AverageRating({
    required this.average,
    required this.totalReviews,
    required this.distribution,
  });

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      average: (json['average'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? json['totalReviews'] ?? 0,
      distribution: _parseDistribution(json['distribution']),
    );
  }

  static Map<int, int> _parseDistribution(dynamic distribution) {
    if (distribution == null) return {};

    if (distribution is Map) {
      return distribution.map((key, value) {
        return MapEntry(
          int.tryParse(key.toString()) ?? 0,
          value is int ? value : int.tryParse(value.toString()) ?? 0,
        );
      });
    }

    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'total_reviews': totalReviews,
      'distribution': distribution,
    };
  }
}
