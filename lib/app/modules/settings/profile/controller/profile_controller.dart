import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/data/models/user_model.dart' as models;
import 'package:photo_bug/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  // Get AuthService instance
  final AuthService _authService = AuthService.instance;

  // Stream subscription for proper disposal
  StreamSubscription<models.User?>? _userStreamSubscription;

  // Observable variables for profile data
  final isLoading = false.obs;
  final selectedGender = Rxn<String>();
  final selectedDateOfBirth = Rxn<DateTime>();
  final selectedInterests = <String>[].obs;

  // Create a local reactive user to ensure UI updates
  final Rx<models.User?> _localCurrentUser = Rx<models.User?>(null);

  // Text editing controllers for profile
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

  // Track if controller is disposed
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

  // Get current user data - now reactive
  models.User? get currentUser => _localCurrentUser.value;
  Rx<models.User?> get currentUserRx => _localCurrentUser;

  @override
  void onInit() {
    super.onInit();
    _initializeProfileData();
    _listenToAuthServiceChanges();
  }

  /// Modified _listenToAuthServiceChanges with proper stream management
  void _listenToAuthServiceChanges() {
    try {
      // Cancel any existing subscription
      _userStreamSubscription?.cancel();

      // Subscribe to auth service user changes
      _userStreamSubscription = _authService.userStream.listen(
        (models.User? user) {
          // Check if controller is disposed before updating
          if (_isDisposed) return;

          // Update local user and trigger UI refresh
          _localCurrentUser.value = user;

          if (user != null) {
            _populateFormFields(user);
          }

          // Force UI update
          update();
        },
        onError: (error) {
          if (kDebugMode) {
            print('ProfileController: Error in user stream: $error');
          }
        },
      );

      // Initialize with current user
      final currentUser = _authService.currentUser;
      _localCurrentUser.value = currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up user stream listener: $e');
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Only populate if we have a user and controller isn't disposed
    if (_localCurrentUser.value != null && !_isDisposed) {
      _populateFormFields(_localCurrentUser.value!);
    }
  }

  @override
  void onClose() {
    // Mark as disposed first
    _isDisposed = true;

    // Cancel stream subscription
    _userStreamSubscription?.cancel();
    _userStreamSubscription = null;

    // Dispose controllers safely
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

  /// Initialize profile data from current user
  void _initializeProfileData() {
    final user = currentUser;
    if (user != null && !_isDisposed) {
      _populateFormFields(user);
    }
  }

  /// Populate form fields with user data (with disposal check)
  void _populateFormFields(models.User user) {
    // Check if controller is disposed before using text controllers
    if (_isDisposed) return;

    try {
      // Split name into first and last name
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

      // Handle address
      if (user.address != null) {
        countryController.text = user.address?.country ?? '';
        cityController.text = user.address?.town ?? '';
        addressController.text = user.address?.address ?? '';
      }

      // Set gender with proper capitalization to match dropdown items
      selectedGender.value = _normalizeGender(user.gender);
      selectedDateOfBirth.value = user.dateOfBirth;

      // Set interests
      if (user.interests != null) {
        selectedInterests.assignAll(user.interests!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error populating form fields: $e');
      }
    }
  }

  /// Normalize gender value to match dropdown options
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

  /// Refresh profile data from API
  Future<void> refreshProfile() async {
    if (_isDisposed) return; // Early return if disposed

    try {
      isLoading.value = true;

      final response = await _authService.getCurrentUser();

      // Check if still not disposed after async call
      if (_isDisposed) return;

      if (response.success && response.data != null) {
        // Force trigger UI update by updating a reactive variable
        update();

        // Re-populate form fields with fresh data
        _populateFormFields(response.data!);
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to refresh profile');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar('Failed to refresh profile');
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
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

  // ==================== PROFILE MANAGEMENT ====================

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

      // Check if still not disposed after async call
      if (_isDisposed) return;

      if (response.success) {
        _showSuccessSnackbar('Profile updated successfully!');
        return;
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

      // Check if still not disposed after async call
      if (_isDisposed) return;

      if (response.success) {
        // Wait a bit for the stream to update
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

  /// Convert gender from dropdown format to API format
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

      // Check if still not disposed after async call
      if (_isDisposed) return;

      if (response.success) {
        _showSuccessSnackbar('Interests updated successfully!');
        return;
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

  /// Toggle interest selection
  void toggleInterest(String interest) {
    if (_isDisposed) return;

    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  /// Check if interest is selected
  bool isInterestSelected(String interest) {
    return selectedInterests.contains(interest);
  }

  // ==================== DATE AND GENDER SELECTION ====================

  /// Select date of birth
  void selectDateOfBirth(DateTime date) {
    if (_isDisposed) return;
    selectedDateOfBirth.value = date;
  }

  /// Select gender
  void selectGender(String gender) {
    if (_isDisposed) return;
    selectedGender.value = gender;
  }

  // ==================== LOGOUT FUNCTIONALITY ====================

  /// Show logout confirmation dialog
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
              Get.back(); // Close dialog
              logout(); // Perform logout
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Logout user
  Future<void> logout() async {
    if (_isDisposed) return;

    try {
      isLoading.value = true;

      // Call the AuthService logout method
      await _authService.logout();

      // Check if still not disposed after async call
      if (_isDisposed) return;

      // Clear profile data
      _clearProfileData();

      // Show success message
      _showSuccessSnackbar('Logged out successfully');

      // Navigate to login screen
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

  /// Check current user state for debugging
  void checkCurrentUserState() {
    if (_isDisposed) return;

    final user = currentUser;
    final authServiceUser = _authService.currentUser;
    print('ProfileController: Current user state:');
    print('  - ProfileController user: ${user?.name}');
    print('  - AuthService user: ${authServiceUser?.name}');
    print('  - Users match: ${user?.name == authServiceUser?.name}');
    if (user != null) {
      print('  - User exists: ${user != null}');
      print('  - Name: ${user.name}');
      print('  - Email: ${user.email}');
      print('  - Username: ${user.userName}');
      print('  - Phone: ${user.phone}');
      print('  - Gender: ${user.gender}');
      print('  - Bio: ${user.bio}');
    }
  }

  /// Clear all profile data
  void _clearProfileData() {
    if (_isDisposed) return;

    try {
      // Clear all text controllers
      firstNameController.clear();
      lastNameController.clear();
      usernameController.clear();
      phoneController.clear();
      cityController.clear();
      stateController.clear();
      countryController.clear();
      addressController.clear();
      bioController.clear();

      // Reset observable variables
      selectedGender.value = null;
      selectedDateOfBirth.value = null;
      selectedInterests.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing profile data: $e');
      }
    }
  }

  /// Show success snackbar
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

  /// Show error snackbar
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
