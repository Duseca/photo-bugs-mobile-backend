import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/authentication/screens/complete_profile_screen.dart';
import 'package:photo_bug/app/modules/authentication/screens/forget_password.dart';
import 'package:photo_bug/app/modules/authentication/screens/interest_selection_screen.dart';
import 'package:photo_bug/app/modules/authentication/screens/otp_verification.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/data/models/auth_models.dart' as auth_models;

class AuthController extends GetxController {
  // Get AuthService instance
  final AuthService _authService = AuthService.instance;
  final isSocialLoading = false.obs;

  // Observable variables
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final agreeToTerms = false.obs;
  final selectedGender = Rxn<String>();
  final selectedDateOfBirth = Rxn<DateTime>();
  final selectedInterests = <String>[].obs;

  // Email verification state
  final verificationEmail = ''.obs;
  final isEmailVerified = false.obs;

  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();
  final otpController = TextEditingController();
  final forgotPasswordEmailController = TextEditingController();

  // Password visibility
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Social auth state
  final isFromSocialAuth = false.obs; // Track if user came from social auth
  final socialUserInfo = Rxn<auth_models.SocialUserInfo>();

  // OTP Timer
  final otpTimer = 58.obs;
  final canResendOTP = false.obs;

  // Form validation
  final loginFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();
  final emailVerificationFormKey = GlobalKey<FormState>();
  final completeProfileFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();

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

  @override
  void onInit() {
    super.onInit();
    startOTPTimer();
    _listenToAuthState();
  }

  @override
  void onClose() {
    // Don't dispose controllers here since we want them to persist
    super.onClose();
  }

  /// Listen to AuthService state changes
  void _listenToAuthState() {
    _authService.authStateStream.listen((bool authenticated) {
      if (authenticated) {
        // User successfully authenticated, navigate to home
        Get.offAllNamed(Routes.BOTTOM_NAV_BAR);
      }
    });
  }

  // Toggle functions
  void toggleRememberMe() => rememberMe.toggle();
  void toggleAgreeToTerms() => agreeToTerms.toggle();
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

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

  // Interest management
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  bool isInterestSelected(String interest) {
    return selectedInterests.contains(interest);
  }

  // ==================== SOCIAL AUTHENTICATION ====================

  /// Google Sign In

  /// Google Sign In (Updated for v7.x)
  Future<void> signInWithGoogle() async {
    try {
      isSocialLoading.value = true;

      final response = await _authService.signInWithGoogle();

      if (response.success) {
        _showSuccessSnackbar('Google sign-in successful!');
        // Navigation handled by auth state listener in _listenToAuthState()
      } else {
        _showErrorSnackbar(response.error ?? 'Google sign-in failed');
      }
    } catch (e) {
      _showErrorSnackbar('Google sign-in failed: $e');
      print('Google sign-in error in controller: $e');
    } finally {
      isSocialLoading.value = false;
    }
  }

  /// Facebook Sign In (Updated for v7.x)
  Future<void> signInWithFacebook() async {
    try {
      isSocialLoading.value = true;

      final response = await _authService.signInWithFacebook();

      if (response.success) {
        _showSuccessSnackbar('Facebook sign-in successful!');
        // Navigation handled by auth state listener in _listenToAuthState()
      } else {
        _showErrorSnackbar(response.error ?? 'Facebook sign-in failed');
      }
    } catch (e) {
      _showErrorSnackbar('Facebook sign-in failed: $e');
      print('Facebook sign-in error in controller: $e');
    } finally {
      isSocialLoading.value = false;
    }
  }

  /// Check if current user is from social auth and needs profile completion
  bool get needsProfileCompletion => _authService.needsProfileCompletion;

  /// Pre-fill profile form with social auth data
  void prefillSocialData() {
    if (_authService.currentUser != null) {
      final user = _authService.currentUser!;

      // Pre-fill name fields
      final nameParts = user.name.split(' ');
      if (nameParts.isNotEmpty) {
        firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          lastNameController.text = nameParts.skip(1).join(' ');
        }
      }

      // Pre-fill other fields
      usernameController.text = user.userName;
      emailController.text = user.email;

      // Only set phone if it's not the default
      if (user.phone != null && user.phone != '+1234567890') {
        phoneController.text = user.phone!;
      }

      // Pre-fill bio if available
      if (user.bio != null && user.bio!.isNotEmpty) {
        bioController.text = user.bio!;
      }

      print('Social data pre-filled for user: ${user.name}');
    }
  }

  // Date picker
  void selectDateOfBirth(DateTime date) {
    selectedDateOfBirth.value = date;
  }

  // Gender selection
  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // OTP Timer
  void startOTPTimer() {
    canResendOTP.value = false;
    otpTimer.value = 58;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      otpTimer.value--;

      if (otpTimer.value <= 0) {
        canResendOTP.value = true;
        return false;
      }
      return true;
    });
  }

  // ==================== NEW AUTHENTICATION FLOW ====================

  /// Step 1: Validate signup form and send verification email
  Future<void> initiateSignup() async {
    if (!signUpFormKey.currentState!.validate()) return;
    if (!agreeToTerms.value) {
      _showErrorSnackbar('Please agree to the Terms and Conditions');
      return;
    }

    try {
      isLoading.value = true;

      // Store the email for verification
      verificationEmail.value = emailController.text.trim();

      final response = await _authService.sendVerificationEmail(
        emailController.text.trim(),
      );

      if (response.success) {
        _showSuccessSnackbar('Verification code sent to your email!');
        // Navigate to OTP verification screen
        Get.to(() => const OtpVerification());
        startOTPTimer();
      } else {
        _showErrorSnackbar(
          response.error ?? 'Failed to send verification email',
        );
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Verify email with OTP code
  Future<void> verifyEmailCode() async {
    if (otpController.text.length != 6) {
      _showErrorSnackbar('Please enter a valid 6-digit OTP');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _authService.verifyEmailCode(
        verificationEmail.value,
        otpController.text,
      );

      if (response.success) {
        isEmailVerified.value = true;
        _showSuccessSnackbar('Email verified successfully!');
        // Don't navigate here - let the calling method handle navigation
      } else {
        _showErrorSnackbar(response.error ?? 'Email verification failed');
      }
    } catch (e) {
      _showErrorSnackbar('Verification failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 3: Complete registration (called after email verification)
  Future<void> completeRegistration() async {
    try {
      isLoading.value = true;

      final request = auth_models.RegisterRequest(
        name:
            '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        userName: _generateUsername(), // Generate a temporary username
        email: verificationEmail.value, // Use verified email
        password: passwordController.text,
        phone: '12344432', // Will be filled in profile completion
        profilePicture:
            'https:/jhhdhdhdh', // Set default or allow user to upload
        deviceToken: '', // Set from device
        stripeAccountId: '', // Set later if needed
        role: 'creator', // Default role
        gender: 'male', // Default, will be updated in profile completion
        dob: DateTime.now().subtract(
          Duration(days: 365 * 18),
        ), // Default 18 years old
        address: {'country': '', 'town': '', 'address': ''},
        location: {
          'coordinates': [0.0, 0.0],
        }, // Set from location service
        bio: '',
        interests: [],
        settings: {
          'general': true,
          'sound': true,
          'vibrate': true,
          'updated': true,
        },
        favourites: [],
        storagePurchases: [],
      );

      final response = await _authService.register(request);

      if (response.success) {
        _showSuccessSnackbar('Registration successful!');
        // Navigate to complete profile screen
        Get.offAll(() => const CompleteProfile());
      } else {
        _showErrorSnackbar(response.error ?? 'Registration failed');
      }
    } catch (e) {
      _showErrorSnackbar('Registration failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to generate temporary username
  String _generateUsername() {
    String firstName = firstNameController.text.trim().toLowerCase();
    String lastName = lastNameController.text.trim().toLowerCase();
    String timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    return '${firstName}_${lastName}_$timestamp';
  }

  /// Login with email and password
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final request = auth_models.LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await _authService.login(request);

      if (response.success) {
        _showSuccessSnackbar('Login successful!');
        // Navigation will be handled by auth state listener
      } else {
        _showErrorSnackbar(response.error ?? 'Login failed');
      }
    } catch (e) {
      _showErrorSnackbar('Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    if (!canResendOTP.value) return;

    try {
      isLoading.value = true;

      final response = await _authService.sendVerificationEmail(
        verificationEmail.value,
      );

      if (response.success) {
        _showSuccessSnackbar('New verification code sent!');
        startOTPTimer();
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to resend code');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to resend code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== PROFILE COMPLETION ====================

  Future<void> completeProfile() async {
    if (!completeProfileFormKey.currentState!.validate()) return;

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

      if (response.success) {
        _showSuccessSnackbar('Profile updated successfully!');
        // Navigate to select interests
        Get.to(() => SelectInterest());
      } else {
        _showErrorSnackbar(response.error ?? 'Profile update failed');
      }
    } catch (e) {
      _showErrorSnackbar('Profile completion failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> finishRegistration() async {
    try {
      isLoading.value = true;

      final interestData = {'interests': selectedInterests.toList()};

      final response = await _authService.updateUser(interestData);

      if (response.success) {
        _showSuccessSnackbar('Registration completed successfully!');
        // Navigate to home
        Get.offAllNamed(Routes.BOTTOM_NAV_BAR);
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to save interests');
      }
    } catch (e) {
      _showErrorSnackbar('Registration completion failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== LOGOUT - FIXED VERSION ====================

  /// Logout user and clear all data
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call the AuthService logout method
      await _authService.logout();

      // Clear form data but keep controllers alive
      _clearAllData();

      // Show success message
      _showSuccessSnackbar('Logged out successfully');

      // Navigate to login screen
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      _showErrorSnackbar('Logout failed. Please try again.');
      print('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all form data and reset state (FIXED VERSION)
  void _clearAllData() {
    // Clear all text controllers
    emailController.clear();
    passwordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    confirmPasswordController.clear();
    usernameController.clear();
    phoneController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    addressController.clear();
    bioController.clear();
    otpController.clear();
    forgotPasswordEmailController.clear();

    // Reset all observable variables
    rememberMe.value = false;
    agreeToTerms.value = false;
    selectedGender.value = null;
    selectedDateOfBirth.value = null;
    selectedInterests.clear();
    verificationEmail.value = '';
    isEmailVerified.value = false;
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;

    // Reset social auth state
    isFromSocialAuth.value = false;
    socialUserInfo.value = null;

    // Reset OTP timer
    otpTimer.value = 58;
    canResendOTP.value = false;
  }

  /// Show logout confirmation dialog
  void showLogoutDialog() {
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

  // ==================== FORGOT PASSWORD ====================

  Future<void> forgotPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Send verification email for password reset
      final response = await _authService.sendVerificationEmail(
        forgotPasswordEmailController.text.trim(),
      );

      if (response.success) {
        _showSuccessSnackbar('Password reset code sent to your email');
        // You can navigate to OTP verification for password reset
        Get.back(); // Close dialog
      } else {
        _showErrorSnackbar(response.error ?? 'Failed to send reset code');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to send reset code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Navigation methods
  void goToSignUp() => Get.toNamed(Routes.SIGN_UP);
  void goToLogin() => Get.toNamed(Routes.LOGIN);
  void goToEmailVerification() => Get.to(() => const OtpVerification());
  void goToForgotPassword() => Get.to(() => const ForgetPassword());
  void goBack() => Get.back();
  void skipStep() => Get.toNamed(Routes.BOTTOM_NAV_BAR);

  // Individual clear methods (kept for specific use cases)
  void clearLoginForm() {
    emailController.clear();
    passwordController.clear();
    rememberMe.value = false;
  }

  void clearSignUpForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    usernameController.clear();
    phoneController.clear();
    agreeToTerms.value = false;
  }

  void clearCompleteProfileForm() {
    usernameController.clear();
    selectedGender.value = null;
    selectedDateOfBirth.value = null;
    cityController.clear();
    phoneController.clear();
    stateController.clear();
    countryController.clear();
    addressController.clear();
    bioController.clear();
  }

  void clearEmailVerification() {
    otpController.clear();
    verificationEmail.value = '';
    isEmailVerified.value = false;
  }

  // Reset authentication state (kept for compatibility but not used in logout)
  void resetAuthState() {
    clearLoginForm();
    clearSignUpForm();
    clearCompleteProfileForm();
    clearEmailVerification();
    selectedInterests.clear();
  }
}
