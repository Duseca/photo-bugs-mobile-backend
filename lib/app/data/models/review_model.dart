class Review {
  final String? id;
  final String reviewForId;
  final String? reviewerId;
  final int ratings; // 1-5 or 1-10 scale
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    required this.reviewForId,
    this.reviewerId,
    required this.ratings,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'],
      reviewForId: json['review_for'] ?? json['reviewFor'] ?? '',
      reviewerId: json['reviewer'] ?? json['reviewerId'],
      ratings: json['ratings'] ?? json['rating'] ?? 0,
      description: json['description'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'review_for': reviewForId,
      if (reviewerId != null) 'reviewer': reviewerId,
      'ratings': ratings,
      'description': description,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? reviewForId,
    String? reviewerId,
    int? ratings,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      reviewForId: reviewForId ?? this.reviewForId,
      reviewerId: reviewerId ?? this.reviewerId,
      ratings: ratings ?? this.ratings,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Review{id: $id, reviewForId: $reviewForId, ratings: $ratings}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Create Review Request Model
class CreateReviewRequest {
  final String reviewForId;
  final int ratings;
  final String description;

  CreateReviewRequest({
    required this.reviewForId,
    required this.ratings,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'review_for': reviewForId,
      'ratings': ratings,
      'description': description,
    };
  }
}

// Update Review Request Model
class UpdateReviewRequest {
  final int? ratings;
  final String? description;

  UpdateReviewRequest({this.ratings, this.description});

  Map<String, dynamic> toJson() {
    return {
      if (ratings != null) 'ratings': ratings,
      if (description != null) 'description': description,
    };
  }
}

// Average Rating Model
class AverageRating {
  final double averageRating;
  final int totalReviews;
  final Map<int, int>? ratingDistribution; // rating -> count

  AverageRating({
    required this.averageRating,
    required this.totalReviews,
    this.ratingDistribution,
  });

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      averageRating:
          (json['averageRating'] ?? json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? json['total_reviews'] ?? 0,
      ratingDistribution:
          json['ratingDistribution'] != null
              ? Map<int, int>.from(json['ratingDistribution'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      if (ratingDistribution != null) 'ratingDistribution': ratingDistribution,
    };
  }

  @override
  String toString() {
    return 'AverageRating{averageRating: $averageRating, totalReviews: $totalReviews}';
  }
}
