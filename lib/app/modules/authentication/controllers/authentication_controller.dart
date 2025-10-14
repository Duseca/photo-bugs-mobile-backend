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
  final isFromSocialAuth = false.obs;
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
    super.onClose();
  }

  /// Listen to AuthService state changes
  void _listenToAuthState() {
    _authService.authStateStream.listen((bool authenticated) {
      if (authenticated) {
        // ✅ CHANGE: Check profile completion first
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_authService.needsProfileCompletion) {
            print('📝 Profile incomplete - navigating to complete profile');

            Get.offAndToNamed(Routes.COMPLETE_PROFILE);
          } else {
            print('✅ Profile complete - checking Google Drive');
            checkAndPromptGoogleDrive();
            Get.offAllNamed(Routes.BOTTOM_NAV_BAR);
          }
        });
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

  // ==================== SOCIAL AUTHENTICATION ====================

  /// Google Sign In (v7.2.0)
  Future<void> signInWithGoogle() async {
    try {
      isSocialLoading.value = true;

      final response = await _authService.signInWithGoogle();

      if (response.success) {
        _showSuccessSnackbar('✅ Google sign-in successful!');
      } else {
        print('Google sign-in error: ${response.error}');
        // ✅ ADD: Check if user cancelled
        if (response.error?.contains('cancel') == true) {
          _showInfoSnackbar('Sign-in cancelled'); // Friendly message
        } else {
          _showErrorSnackbar(response.error ?? 'Google sign-in failed');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Google sign-in failed: $e');
      print('Google sign-in error in controller: $e');
    } finally {
      isSocialLoading.value = false;
    }
  }

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// Facebook Sign In
  Future<void> signInWithFacebook() async {
    try {
      isSocialLoading.value = true;

      final response = await _authService.signInWithFacebook();

      if (response.success) {
        _showSuccessSnackbar('✅ Facebook sign-in successful!');
        // Navigation handled by auth state listener
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

  // ==================== GOOGLE DRIVE AUTHORIZATION ====================

  /// Check if Google Drive authorization is needed and prompt
  Future<void> checkAndPromptGoogleDrive() async {
    // Only prompt for email/password users who don't have tokens
    if (_authService.needsGoogleDriveAuth) {
      await Future.delayed(const Duration(microseconds: 500));
      showGoogleDriveAuthDialog();
    }
  }

  /// Show Google Drive authorization dialog
  void showGoogleDriveAuthDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.cloud, color: Colors.blue),
            SizedBox(width: 8),
            Text('Connect Google Drive'),
          ],
        ),
        content: const Text(
          'Connect your Google Drive to backup and sync your photos securely. '
          'Would you like to authorize Google Drive access now?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authorizeGoogleDrive();
            },

            child: const Text('Connect Now'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Authorize Google Drive for email/password users
  Future<void> authorizeGoogleDrive() async {
    try {
      isSocialLoading.value = true;

      final response = await _authService.authorizeGoogleDrive();

      if (response.success) {
        _showSuccessSnackbar('✅ Google Drive connected successfully!');
      } else {
        _showErrorSnackbar(
          response.error ?? 'Google Drive authorization failed',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Google Drive authorization failed: $e');
      print('Google Drive auth error: $e');
    } finally {
      isSocialLoading.value = false;
    }
  }

  /// Disconnect Google Drive
  Future<void> disconnectGoogleDrive() async {
    try {
      isLoading.value = true;
      await _authService.disconnectGoogleDrive();
      _showSuccessSnackbar('Google Drive disconnected');
    } catch (e) {
      _showErrorSnackbar('Failed to disconnect Google Drive');
    } finally {
      isLoading.value = false;
    }
  }

  /// Build Google Drive settings widget
  Widget buildGoogleDriveSettings() {
    return Obx(() {
      final isConnected = _authService.isGoogleDriveConnected;
      final hasTokens = _authService.currentUser?.googleTokens != null;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(
            Icons.cloud_circle,
            color: isConnected ? Colors.green : Colors.grey,
            size: 40,
          ),
          title: const Text(
            'Google Drive',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isConnected
                ? '✅ Connected and syncing'
                : hasTokens
                ? '⏰ Tokens expired - Tap to reconnect'
                : '❌ Not connected',
            style: TextStyle(
              color:
                  isConnected
                      ? Colors.green
                      : hasTokens
                      ? Colors.orange
                      : Colors.grey,
            ),
          ),
          trailing:
              isConnected
                  ? IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () => _showDisconnectConfirmation(),
                  )
                  : ElevatedButton(
                    onPressed: authorizeGoogleDrive,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Connect'),
                  ),
        ),
      );
    });
  }

  void _showDisconnectConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Disconnect Google Drive?'),
        content: const Text(
          'Your photos will no longer sync with Google Drive. '
          'You can reconnect anytime.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              disconnectGoogleDrive();
            },
            child: const Text(
              'Disconnect',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AUTHENTICATION FLOW ====================

  /// Step 1: Initiate signup
  Future<void> initiateSignup() async {
    if (!signUpFormKey.currentState!.validate()) return;
    if (!agreeToTerms.value) {
      _showErrorSnackbar('Please agree to the Terms and Conditions');
      return;
    }

    try {
      isLoading.value = true;

      verificationEmail.value = emailController.text.trim();

      final response = await _authService.sendVerificationEmail(
        emailController.text.trim(),
      );

      if (response.success) {
        _showSuccessSnackbar('📧 Verification code sent to your email!');
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

  /// Step 2: Verify email code
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
        _showSuccessSnackbar('✅ Email verified successfully!');
      } else {
        _showErrorSnackbar(response.error ?? 'Email verification failed');
      }
    } catch (e) {
      _showErrorSnackbar('Verification failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 3: Complete registration
  Future<void> completeRegistration() async {
    try {
      isLoading.value = true;

      final request = auth_models.RegisterRequest(
        name:
            '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        userName: _generateUsername(),
        email: verificationEmail.value,
        password: passwordController.text,
        phone: '12344432',
        profilePicture: 'https://via.placeholder.com/150',
        deviceToken: '',
        stripeAccountId: '',
        role: 'creator',
        gender: 'male',
        dob: DateTime.now().subtract(const Duration(days: 365 * 18)),
        address: {'country': '', 'town': '', 'address': ''},
        location: {
          'coordinates': [0.0, 0.0],
        },
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
        _showSuccessSnackbar('✅ Registration successful!');
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
        _showSuccessSnackbar('✅ Login successful!');
        // Check Google Drive after a moment
        Future.delayed(const Duration(milliseconds: 800), () {
          checkAndPromptGoogleDrive();
        });
      } else {
        print('Login error: ${response.error}');
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
        _showSuccessSnackbar('📧 New verification code sent!');
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

  bool get needsProfileCompletion => _authService.needsProfileCompletion;

  void prefillSocialData() {
    if (_authService.currentUser != null) {
      final user = _authService.currentUser!;

      final nameParts = user.name.split(' ');
      if (nameParts.isNotEmpty) {
        firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          lastNameController.text = nameParts.skip(1).join(' ');
        }
      }

      usernameController.text = user.userName;
      emailController.text = user.email;

      if (user.phone != null && user.phone != '+1234567890') {
        phoneController.text = user.phone!;
      }

      if (user.bio != null && user.bio!.isNotEmpty) {
        bioController.text = user.bio!;
      }

      print('Social data pre-filled for user: ${user.name}');
    }
  }

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
        _showSuccessSnackbar('✅ Profile updated successfully!');
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
        _showSuccessSnackbar('✅ Registration completed successfully!');
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

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    try {
      isLoading.value = true;

      await _authService.logout();

      _clearAllData();

      _showSuccessSnackbar('✅ Logged out successfully');

      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      _showErrorSnackbar('Logout failed. Please try again.');
      print('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearAllData() {
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

    rememberMe.value = false;
    agreeToTerms.value = false;
    selectedGender.value = null;
    selectedDateOfBirth.value = null;
    selectedInterests.clear();
    verificationEmail.value = '';
    isEmailVerified.value = false;
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;

    isFromSocialAuth.value = false;
    socialUserInfo.value = null;

    otpTimer.value = 58;
    canResendOTP.value = false;
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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

      final response = await _authService.sendVerificationEmail(
        forgotPasswordEmailController.text.trim(),
      );

      if (response.success) {
        _showSuccessSnackbar('📧 Password reset code sent to your email');
        Get.back();
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
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  // Navigation methods
  void goToSignUp() => Get.toNamed(Routes.SIGN_UP);
  void goToLogin() => Get.toNamed(Routes.LOGIN);
  void goToEmailVerification() => Get.to(() => const OtpVerification());
  void goToForgotPassword() => Get.to(() => const ForgetPassword());
  void goBack() => Get.back();
  void skipStep() => Get.toNamed(Routes.BOTTOM_NAV_BAR);

  // Individual clear methods
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

  void resetAuthState() {
    clearLoginForm();
    clearSignUpForm();
    clearCompleteProfileForm();
    clearEmailVerification();
    selectedInterests.clear();
  }
}
