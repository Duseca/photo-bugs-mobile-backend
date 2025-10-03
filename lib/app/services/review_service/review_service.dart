// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/review_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

class ReviewService extends GetxService {
  static ReviewService get instance => Get.find<ReviewService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Review> _userReviews = <Review>[].obs;
  final RxList<Review> _receivedReviews = <Review>[].obs;
  final RxMap<String, AverageRating> _cachedAverageRatings =
      <String, AverageRating>{}.obs;
  final Rx<Review?> _selectedReview = Rx<Review?>(null);
  final RxBool _isLoading = false.obs;

  // Getters
  List<Review> get userReviews => _userReviews;
  List<Review> get receivedReviews => _receivedReviews;
  Review? get selectedReview => _selectedReview.value;
  bool get isLoading => _isLoading.value;

  // Streams for reactive UI
  Stream<List<Review>> get userReviewsStream => _userReviews.stream;
  Stream<List<Review>> get receivedReviewsStream => _receivedReviews.stream;
  Stream<Review?> get selectedReviewStream => _selectedReview.stream;

  Future<ReviewService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      // Load user reviews if authenticated
      if (_authService.isAuthenticated) {
        await _loadUserReviews();
      }

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('ReviewService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        _loadUserReviews();
      } else {
        _clearAllReviews();
      }
    });
  }

  // ==================== REVIEW CRUD OPERATIONS ====================

  /// Get all reviews
  Future<ApiResponse<List<Review>>> getAllReviews() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Review>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.allReviews,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Review.fromJson(e)).toList();
          }
          return <Review>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Review>>(
        success: false,
        error: 'Failed to get all reviews: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get review by ID
  Future<ApiResponse<Review>> getReviewById(String reviewId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Review>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.reviewById(reviewId),
        fromJson: (json) => Review.fromJson(json),
      );

      if (response.success && response.data != null) {
        _selectedReview.value = response.data;
      }

      return response;
    } catch (e) {
      return ApiResponse<Review>(
        success: false,
        error: 'Failed to get review: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create a new review
  Future<ApiResponse<Review>> createReview(CreateReviewRequest request) async {
    try {
      _isLoading.value = true;

      // Validate ratings range (assuming 1-10 scale based on API)
      if (request.ratings < 1 || request.ratings > 10) {
        return ApiResponse<Review>(
          success: false,
          error: 'Ratings must be between 1 and 10',
        );
      }

      final response = await _makeApiRequest<Review>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createReview,
        data: request.toJson(),
        fromJson: (json) => Review.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Add to user reviews list
        _userReviews.insert(0, response.data!);

        // Clear cached average rating for the reviewed user
        _cachedAverageRatings.remove(request.reviewForId);

        print('Review created successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Review>(
        success: false,
        error: 'Failed to create review: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update an existing review
  Future<ApiResponse<Review>> updateReview(
    String reviewId,
    UpdateReviewRequest request,
  ) async {
    try {
      _isLoading.value = true;

      // Validate ratings if provided
      if (request.ratings != null &&
          (request.ratings! < 1 || request.ratings! > 10)) {
        return ApiResponse<Review>(
          success: false,
          error: 'Ratings must be between 1 and 10',
        );
      }

      final response = await _makeApiRequest<Review>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updateReview(reviewId),
        data: request.toJson(),
        fromJson: (json) => Review.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Update in lists
        _updateReviewInLists(response.data!);

        // Clear cached average rating
        _cachedAverageRatings.remove(response.data!.reviewForId);

        print('Review updated successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Review>(
        success: false,
        error: 'Failed to update review: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete a review
  Future<ApiResponse<dynamic>> deleteReview(String reviewId) async {
    try {
      _isLoading.value = true;

      // Get the review to know which user's average to clear
      final review = _userReviews.firstWhereOrNull((r) => r.id == reviewId);

      final response = await _makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.deleteReview(reviewId),
      );

      if (response.success) {
        // Remove from lists
        _removeReviewFromLists(reviewId);

        // Clear cached average rating
        if (review != null) {
          _cachedAverageRatings.remove(review.reviewForId);
        }

        if (_selectedReview.value?.id == reviewId) {
          _selectedReview.value = null;
        }

        print('Review deleted successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to delete review: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== AVERAGE RATINGS ====================

  /// Get average rating for a user
  Future<ApiResponse<AverageRating>> getAverageRating(String userId) async {
    try {
      // Check cache first
      if (_cachedAverageRatings.containsKey(userId)) {
        return ApiResponse<AverageRating>(
          success: true,
          data: _cachedAverageRatings[userId],
        );
      }

      _isLoading.value = true;

      final response = await _makeApiRequest<AverageRating>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.reviewAverage(userId),
        fromJson: (json) => AverageRating.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Cache the result
        _cachedAverageRatings[userId] = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<AverageRating>(
        success: false,
        error: 'Failed to get average rating: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Clear cached average rating for a user
  void clearCachedRating(String userId) {
    _cachedAverageRatings.remove(userId);
  }

  /// Clear all cached ratings
  void clearAllCachedRatings() {
    _cachedAverageRatings.clear();
  }

  // ==================== USER REVIEWS ====================

  /// Get reviews written by current user
  Future<ApiResponse<List<Review>>> getUserGivenReviews() async {
    try {
      _isLoading.value = true;

      if (_authService.currentUser == null) {
        return ApiResponse<List<Review>>(
          success: false,
          error: 'User not authenticated',
        );
      }

      final response = await getAllReviews();

      if (response.success && response.data != null) {
        // Filter reviews written by current user
        final givenReviews =
            response.data!
                .where(
                  (review) => review.reviewerId == _authService.currentUser!.id,
                )
                .toList();

        _userReviews.value = givenReviews;

        return ApiResponse<List<Review>>(success: true, data: givenReviews);
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Review>>(
        success: false,
        error: 'Failed to get user reviews: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get reviews received by current user
  Future<ApiResponse<List<Review>>> getUserReceivedReviews() async {
    try {
      _isLoading.value = true;

      if (_authService.currentUser == null) {
        return ApiResponse<List<Review>>(
          success: false,
          error: 'User not authenticated',
        );
      }

      final response = await getAllReviews();

      if (response.success && response.data != null) {
        // Filter reviews for current user
        final receivedReviews =
            response.data!
                .where(
                  (review) =>
                      review.reviewForId == _authService.currentUser!.id,
                )
                .toList();

        _receivedReviews.value = receivedReviews;

        return ApiResponse<List<Review>>(success: true, data: receivedReviews);
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Review>>(
        success: false,
        error: 'Failed to get received reviews: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get reviews for a specific user
  Future<ApiResponse<List<Review>>> getReviewsForUser(String userId) async {
    try {
      _isLoading.value = true;

      final response = await getAllReviews();

      if (response.success && response.data != null) {
        final userReviews =
            response.data!
                .where((review) => review.reviewForId == userId)
                .toList();

        return ApiResponse<List<Review>>(success: true, data: userReviews);
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Review>>(
        success: false,
        error: 'Failed to get reviews for user: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load all user reviews
  Future<void> _loadUserReviews() async {
    await Future.wait([getUserGivenReviews(), getUserReceivedReviews()]);
  }

  // ==================== HELPER METHODS ====================

  /// Update review in all lists
  void _updateReviewInLists(Review updatedReview) {
    // Update in user reviews (given)
    final userIndex = _userReviews.indexWhere((r) => r.id == updatedReview.id);
    if (userIndex != -1) {
      _userReviews[userIndex] = updatedReview;
    }

    // Update in received reviews
    final receivedIndex = _receivedReviews.indexWhere(
      (r) => r.id == updatedReview.id,
    );
    if (receivedIndex != -1) {
      _receivedReviews[receivedIndex] = updatedReview;
    }

    // Update selected review
    if (_selectedReview.value?.id == updatedReview.id) {
      _selectedReview.value = updatedReview;
    }
  }

  /// Remove review from all lists
  void _removeReviewFromLists(String reviewId) {
    _userReviews.removeWhere((r) => r.id == reviewId);
    _receivedReviews.removeWhere((r) => r.id == reviewId);
  }

  /// Clear all reviews
  void _clearAllReviews() {
    _userReviews.clear();
    _receivedReviews.clear();
    _cachedAverageRatings.clear();
    _selectedReview.value = null;
  }

  /// Refresh all reviews
  Future<void> refreshAllReviews() async {
    if (_authService.isAuthenticated) {
      await _loadUserReviews();
    }
  }

  /// Set selected review
  void setSelectedReview(Review? review) {
    _selectedReview.value = review;
  }

  /// Check if current user has reviewed a specific user
  bool hasReviewedUser(String userId) {
    return _userReviews.any((review) => review.reviewForId == userId);
  }

  /// Get user's review for a specific user
  Review? getUserReviewFor(String userId) {
    return _userReviews.firstWhereOrNull(
      (review) => review.reviewForId == userId,
    );
  }

  /// Calculate local average from received reviews
  double get localAverageRating {
    if (_receivedReviews.isEmpty) return 0.0;

    final sum = _receivedReviews.fold<int>(
      0,
      (sum, review) => sum + review.ratings,
    );

    return sum / _receivedReviews.length;
  }

  /// Get rating distribution from received reviews
  Map<int, int> get localRatingDistribution {
    final distribution = <int, int>{};

    for (final review in _receivedReviews) {
      distribution[review.ratings] = (distribution[review.ratings] ?? 0) + 1;
    }

    return distribution;
  }

  /// Sort reviews by rating (highest first)
  List<Review> sortReviewsByRating(
    List<Review> reviews, {
    bool descending = true,
  }) {
    final sorted = List<Review>.from(reviews);
    sorted.sort((a, b) {
      return descending
          ? b.ratings.compareTo(a.ratings)
          : a.ratings.compareTo(b.ratings);
    });
    return sorted;
  }

  /// Sort reviews by date (most recent first)
  List<Review> sortReviewsByDate(
    List<Review> reviews, {
    bool descending = true,
  }) {
    final sorted = List<Review>.from(reviews);
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return descending
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });
    return sorted;
  }

  /// Filter reviews by minimum rating
  List<Review> filterReviewsByMinRating(List<Review> reviews, int minRating) {
    return reviews.where((review) => review.ratings >= minRating).toList();
  }

  // ==================== API REQUEST METHOD ====================

  /// Generic API request method
  Future<ApiResponse<T>> _makeApiRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      // Check authentication
      if (_authService.authToken == null) {
        return ApiResponse<T>(
          success: false,
          error: 'Authentication required',
          statusCode: 401,
        );
      }

      final url = '${ApiConfig.fullApiUrl}$endpoint';
      final headers = ApiConfig.authHeaders(_authService.authToken!);

      final getConnect = GetConnect(timeout: ApiConfig.connectTimeout);

      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await getConnect.get(url, headers: headers);
          break;
        case 'POST':
          response = await getConnect.post(url, data, headers: headers);
          break;
        case 'PUT':
          response = await getConnect.put(url, data, headers: headers);
          break;
        case 'DELETE':
          response = await getConnect.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final responseData = response.body;

        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: responseData['message'],
          data:
              fromJson != null && responseData['data'] != null
                  ? fromJson(responseData['data'])
                  : responseData['data'],
          metadata: responseData['metadata'],
        );
      }

      final errorData = response.body ?? {};
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        error: errorData['message'] ?? errorData['error'] ?? 'Unknown error',
        message: errorData['message'],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle request errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    String errorMessage;

    if (error.toString().contains('SocketException')) {
      errorMessage = 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'Request timeout';
    } else {
      errorMessage = 'Network error: $error';
    }

    return ApiResponse<T>(success: false, error: errorMessage);
  }

  @override
  void onClose() {
    _clearAllReviews();
    super.onClose();
  }
}
