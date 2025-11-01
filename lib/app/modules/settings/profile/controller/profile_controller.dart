import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/review_service/review_service.dart';
import 'package:photo_bug/app/services/review_service/portfolio_service.dart';
import 'package:photo_bug/app/data/models/user_model.dart' as models;
import 'package:photo_bug/app/data/models/review_model.dart';
import 'package:photo_bug/app/data/models/portfolio_model.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  // Get service instances
  final AuthService _authService = AuthService.instance;
  late final ReviewService _reviewService;
  late final PortfolioService _portfolioService;

  // Stream subscriptions
  StreamSubscription<models.User?>? _userStreamSubscription;
  StreamSubscription<List<Review>>? _reviewsStreamSubscription;
  StreamSubscription<Portfolio?>? _portfolioStreamSubscription;

  // Observable variables for profile data
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final selectedGender = Rxn<String>();
  final selectedDateOfBirth = Rxn<DateTime>();
  final selectedInterests = <String>[].obs;

  // Reactive user
  final Rx<models.User?> _localCurrentUser = Rx<models.User?>(null);

  // Reactive reviews data (bridge from ReviewService)
  final RxList<Review> _receivedReviews = <Review>[].obs;
  final RxDouble _averageRating = 0.0.obs;

  // Reactive portfolio data (bridge from PortfolioService)
  final Rx<Portfolio?> _portfolio = Rx<Portfolio?>(null);
  final RxList<PortfolioMedia> _portfolioImages = <PortfolioMedia>[].obs;

  // Text editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();

  // Form validation
  final completeProfileFormKey = GlobalKey<FormState>();

  // Track disposal
  bool _isDisposed = false;

  // Interest options
  final List<String> interestOptions = [
    'Nature',
    'Technology',
    'Food',
    'Travel',
    'People',
    'Outdoor',
    'Science',
    'Background',
    'Abstract',
    'Sports',
    'Flower',
    'Digital',
    'Real Estate',
  ];

  // Getters
  models.User? get currentUser => _localCurrentUser.value;
  Rx<models.User?> get currentUserRx => _localCurrentUser;

  // Review getters (bridge)
  List<Review> get receivedReviews => _receivedReviews;
  double get averageRating => _averageRating.value;
  int get reviewCount => _receivedReviews.length;

  // Portfolio getters (bridge)
  Portfolio? get portfolio => _portfolio.value;
  List<PortfolioMedia> get portfolioImages => _portfolioImages;
  bool get hasPortfolio =>
      _portfolio.value != null && _portfolioImages.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _initializeProfileData();
    _setupListeners();
  }

  /// Initialize services
  void _initializeServices() {
    try {
      _reviewService = Get.find<ReviewService>();
      _portfolioService = Get.find<PortfolioService>();
    } catch (e) {
      if (kDebugMode) {
        print('ProfileController: Error initializing services: $e');
      }
    }
  }

  /// Setup all listeners
  void _setupListeners() {
    _listenToAuthServiceChanges();
    _listenToReviewServiceChanges();
    _listenToPortfolioServiceChanges();
  }

  /// Listen to auth service changes
  void _listenToAuthServiceChanges() {
    try {
      _userStreamSubscription?.cancel();

      _userStreamSubscription = _authService.userStream.listen(
        (models.User? user) {
          if (_isDisposed) return;

          _localCurrentUser.value = user;

          if (user != null) {
            _populateFormFields(user);
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('ProfileController: Error in user stream: $error');
          }
        },
      );

      // Initialize with current user
      _localCurrentUser.value = _authService.currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up user stream listener: $e');
      }
    }
  }

  /// Listen to review service changes (bridge)
  void _listenToReviewServiceChanges() {
    try {
      _reviewsStreamSubscription?.cancel();

      _reviewsStreamSubscription = _reviewService.receivedReviewsStream.listen(
        (List<Review> reviews) {
          if (_isDisposed) return;

          _receivedReviews.value = reviews;
          _calculateAverageRating();
        },
        onError: (error) {
          if (kDebugMode) {
            print('ProfileController: Error in reviews stream: $error');
          }
        },
      );

      // Initialize with current data
      _receivedReviews.value = _reviewService.receivedReviews;
      _calculateAverageRating();
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up reviews stream listener: $e');
      }
    }
  }

  /// Listen to portfolio service changes (bridge)
  void _listenToPortfolioServiceChanges() {
    try {
      _portfolioStreamSubscription?.cancel();

      _portfolioStreamSubscription = _portfolioService.portfolioStream.listen(
        (Portfolio? portfolio) {
          if (_isDisposed) return;

          // Only update if the data actually changed
          if (_portfolio.value?.id != portfolio?.id ||
              _portfolio.value?.media.length != portfolio?.media.length) {
            _portfolio.value = portfolio;
            _portfolioImages.value = portfolio?.media ?? [];

            if (kDebugMode) {
              print(
                '🔄 ProfileController: Portfolio updated with ${portfolio?.media.length ?? 0} images',
              );
            }
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('ProfileController: Error in portfolio stream: $error');
          }
        },
      );

      // Initialize with current data
      _portfolio.value = _portfolioService.userPortfolio;
      _portfolioImages.value = _portfolioService.portfolioImages;

      if (kDebugMode) {
        print(
          '🔄 ProfileController: Initial portfolio loaded with ${_portfolioImages.length} images',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up portfolio stream listener: $e');
      }
    }
  }

  /// Calculate average rating locally
  void _calculateAverageRating() {
    if (_receivedReviews.isEmpty) {
      _averageRating.value = 0.0;
      return;
    }

    final sum = _receivedReviews.fold<int>(
      0,
      (sum, review) => sum + review.ratings,
    );

    _averageRating.value = sum / _receivedReviews.length;
  }

  @override
  void onReady() {
    super.onReady();
    if (_localCurrentUser.value != null && !_isDisposed) {
      _populateFormFields(_localCurrentUser.value!);
    }

    // Load initial data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAllProfileData();
    });
  }

  @override
  void onClose() {
    _isDisposed = true;

    // Cancel all subscriptions
    _userStreamSubscription?.cancel();
    _reviewsStreamSubscription?.cancel();
    _portfolioStreamSubscription?.cancel();

    _disposeControllers();

    super.onClose();
  }

  /// Safely dispose all text controllers
  void _disposeControllers() {
    try {
      firstNameController.dispose();
      lastNameController.dispose();
      usernameController.dispose();
      phoneController.dispose();
      cityController.dispose();
      stateController.dispose();
      countryController.dispose();
      addressController.dispose();
      bioController.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing controllers: $e');
      }
    }
  }

  // ==================== DATA LOADING METHODS ====================

  /// Load all profile data (reviews + portfolio)
  Future<void> loadAllProfileData() async {
    if (_isDisposed) return;

    try {
      await Future.wait([loadReviews(), loadPortfolio()]);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile data: $e');
      }
    }
  }

  /// Load reviews data
  Future<void> loadReviews() async {
    if (_isDisposed) return;

    try {
      await _reviewService.getUserReceivedReviews();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading reviews: $e');
      }
    }
  }

  /// Load portfolio data
  Future<void> loadPortfolio() async {
    if (_isDisposed) return;

    try {
      await _portfolioService.loadUserPortfolio();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading portfolio: $e');
      }
    }
  }

  /// Refresh all profile data
  Future<void> refreshAllProfileData() async {
    if (_isDisposed) return;

    try {
      isRefreshing.value = true;

      await Future.wait([
        refreshProfile(),
        refreshReviews(),
        refreshPortfolio(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing profile data: $e');
      }
    } finally {
      if (!_isDisposed) {
        isRefreshing.value = false;
      }
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    if (_isDisposed) return;

    try {
      final response = await _authService.getCurrentUser();

      if (_isDisposed) return;

      if (response.success && response.data != null) {
        _populateFormFields(response.data!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing profile: $e');
      }
    }
  }

  /// Refresh reviews
  Future<void> refreshReviews() async {
    if (_isDisposed) return;

    try {
      await _reviewService.getUserReceivedReviews();
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing reviews: $e');
      }
    }
  }

  /// Refresh portfolio
  Future<void> refreshPortfolio() async {
    if (_isDisposed) return;

    try {
      await _portfolioService.refreshPortfolio();
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing portfolio: $e');
      }
    }
  }

  // ==================== PORTFOLIO METHODS (BRIDGE) ====================

  /// Add image to portfolio - service handles stream updates
  Future<bool> addImageToPortfolio(String imageUrl) async {
    if (_isDisposed) return false;

    try {
      // Make API call - service will update stream automatically
      final response = await _portfolioService.addImageToPortfolio(imageUrl);

      if (response.success) {
        if (kDebugMode) {
          print('✅ Image added successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Failed to add image');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding image to portfolio: $e');
      }
      return false;
    }
  }

  /// Delete image from portfolio - service handles stream updates
  Future<bool> deleteImageFromPortfolio(String imageUrl) async {
    if (_isDisposed) return false;

    try {
      // Make API call - service will update stream automatically
      final response = await _portfolioService.deleteImageFromPortfolio(
        imageUrl,
      );

      if (response.success) {
        if (kDebugMode) {
          print('✅ Image deleted successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Failed to delete image');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image from portfolio: $e');
      }
      return false;
    }
  }

  /// Check if portfolio is loading
  bool get isPortfolioLoading => _portfolioService.isLoading;

  /// Check if portfolio is uploading
  bool get isPortfolioUploading => _portfolioService.isUploading;

  // ==================== REVIEW METHODS (BRIDGE) ====================

  /// Get time ago string for review
  String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Recently';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if reviews are loading
  bool get isReviewsLoading => _reviewService.isLoading;

  // ==================== PROFILE FORM METHODS ====================

  /// Initialize profile data from current user
  void _initializeProfileData() {
    final user = currentUser;
    if (user != null && !_isDisposed) {
      _populateFormFields(user);
    }
  }

  /// Populate form fields with user data
  void _populateFormFields(models.User user) {
    if (_isDisposed) return;

    try {
      final nameParts = (user.name ?? '').split(' ');
      if (nameParts.isNotEmpty) {
        firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          lastNameController.text = nameParts.sublist(1).join(' ');
        }
      }

      usernameController.text = user.userName;
      phoneController.text = user.phone ?? '';
      bioController.text = user.bio ?? '';

      if (user.address != null) {
        countryController.text = user.address?.country ?? '';
        cityController.text = user.address?.town ?? '';
        addressController.text = user.address?.address ?? '';
      }

      selectedGender.value = _normalizeGender(user.gender);
      selectedDateOfBirth.value = user.dateOfBirth;

      if (user.interests != null) {
        selectedInterests.assignAll(user.interests!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error populating form fields: $e');
      }
    }
  }

  /// Normalize gender value
  String? _normalizeGender(String? gender) {
    if (gender == null || gender.isEmpty) return null;

    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'prefer not to say':
      case 'other':
        return 'Prefer not to say';
      default:
        return null;
    }
  }

  // ==================== VALIDATION METHODS ====================

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // ==================== PROFILE UPDATE METHODS ====================

  /// Complete profile information
  Future<void> completeProfile() async {
    if (_isDisposed || !completeProfileFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final userData = {
        'name':
            '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        'user_name': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': selectedGender.value?.toLowerCase(),
        'dob': selectedDateOfBirth.value?.toIso8601String(),
        'address': {
          'country': countryController.text.trim(),
          'town': cityController.text.trim(),
          'address': addressController.text.trim(),
        },
        'bio': bioController.text.trim(),
      };

      final response = await _authService.updateUser(userData);

      if (_isDisposed) return;

      if (response.success) {
        _showSuccessSnackbar('Profile updated successfully!');
      } else {
        _showErrorSnackbar(response.error ?? 'Profile update failed');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar('Profile completion failed. Please try again.');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  /// Update profile information
  Future<void> updateProfile() async {
    if (_isDisposed || !completeProfileFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final userData = {
        'name':
            '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        'user_name': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': _convertGenderForApi(selectedGender.value),
        'dob': selectedDateOfBirth.value?.toIso8601String(),
        'address': {
          'country': countryController.text.trim(),
          'town': cityController.text.trim(),
          'address': addressController.text.trim(),
        },
        'bio': bioController.text.trim(),
        'interests': selectedInterests.toList(),
      };

      final response = await _authService.updateUser(userData);

      if (_isDisposed) return;

      if (response.success) {
        await Future.delayed(Duration(milliseconds: 100));

        if (!_isDisposed) {
          _showSuccessSnackbar('Profile updated successfully!');
          await refreshProfile();
        }
      } else {
        _showErrorSnackbar(response.error ?? 'Profile update failed');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar('Profile update failed. Please try again.');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  /// Convert gender for API
  String? _convertGenderForApi(String? gender) {
    if (gender == null || gender.isEmpty) return null;

    switch (gender) {
      case 'Male':
        return 'male';
      case 'Female':
        return 'female';
      case 'Prefer not to say':
        return 'other';
      default:
        return gender.toLowerCase();
    }
  }

  /// Update interests
  Future<void> updateInterests() async {
    if (_isDisposed) return;

    try {
      isLoading.value = true;

      final interestData = {'interests': selectedInterests.toList()};

      final response = await _authService.updateUser(interestData);

      if (_isDisposed) return;

      if (response.success) {
        _showSuccessSnackbar('Interests updated successfully!');
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to save interests');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar('Failed to update interests. Please try again.');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // ==================== INTEREST MANAGEMENT ====================

  void toggleInterest(String interest) {
    if (_isDisposed) return;

    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  bool isInterestSelected(String interest) {
    return selectedInterests.contains(interest);
  }

  // ==================== DATE AND GENDER SELECTION ====================

  void selectDateOfBirth(DateTime date) {
    if (_isDisposed) return;
    selectedDateOfBirth.value = date;
  }

  void selectGender(String gender) {
    if (_isDisposed) return;
    selectedGender.value = gender;
  }

  // ==================== LOGOUT FUNCTIONALITY ====================

  void showLogoutDialog() {
    if (_isDisposed) return;

    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    if (_isDisposed) return;

    try {
      isLoading.value = true;

      await _authService.logout();

      if (_isDisposed) return;

      _clearProfileData();
      _showSuccessSnackbar('Logged out successfully');
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar('Logout failed. Please try again.');
        print('Logout error: $e');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // ==================== HELPER METHODS ====================

  void _clearProfileData() {
    if (_isDisposed) return;

    try {
      firstNameController.clear();
      lastNameController.clear();
      usernameController.clear();
      phoneController.clear();
      cityController.clear();
      stateController.clear();
      countryController.clear();
      addressController.clear();
      bioController.clear();

      selectedGender.value = null;
      selectedDateOfBirth.value = null;
      selectedInterests.clear();

      _receivedReviews.clear();
      _averageRating.value = 0.0;
      _portfolio.value = null;
      _portfolioImages.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing profile data: $e');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    if (_isDisposed) return;

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showErrorSnackbar(String message) {
    if (_isDisposed) return;

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ==================== NAVIGATION METHODS ====================

  void goToPersonalInformation() {
    if (_isDisposed) return;
    Get.toNamed('/personal-information');
  }

  void goToSecurity() {
    if (_isDisposed) return;
    Get.toNamed('/security');
  }

  void goToPaymentMethod() {
    if (_isDisposed) return;
    Get.toNamed('/payment-method');
  }

  void goToNotificationSettings() {
    if (_isDisposed) return;
    Get.toNamed('/notification-settings');
  }

  void goBack() {
    if (_isDisposed) return;
    Get.back();
  }
}
