import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/authentication/screens/complete_profile_screen.dart';
import 'package:photo_bug/app/modules/authentication/screens/forget_password.dart';
import 'package:photo_bug/app/modules/authentication/screens/interest_selection_screen.dart';
import 'package:photo_bug/app/modules/authentication/screens/login_screen.dart';
import 'package:photo_bug/app/modules/authentication/screens/otp_verification.dart';

import 'package:photo_bug/app/routes/app_pages.dart';

class AuthController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final agreeToTerms = false.obs;
  final selectedGender = Rxn<String>();
  final selectedDateOfBirth = Rxn<DateTime>();
  final selectedInterests = <String>[].obs;

  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
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

  // OTP Timer
  final otpTimer = 58.obs;
  final canResendOTP = false.obs;

  // Form validation
  final loginFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();
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
  }

  @override
  void onClose() {
    // Dispose controllers
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    addressController.dispose();
    bioController.dispose();
    otpController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
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

  void resendOTP() {
    if (canResendOTP.value) {
      startOTPTimer();
      Get.snackbar(
        'OTP Sent',
        'A new OTP has been sent to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Auth methods
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to home
      Get.toNamed(Routes.BOTTOM_NAV_BAR);

      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the Terms and Conditions',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to OTP verification
      Get.to(() => const OtpVerification());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to complete profile
      Get.offAll(() => const CompleteProfile());
    } catch (e) {
      Get.snackbar(
        'Error',
        'OTP verification failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeProfile() async {
    if (!completeProfileFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to select interests
      Get.to(() => SelectInterest());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Profile completion failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> finishRegistration() async {
    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to home
      Get.toNamed(Routes.BOTTOM_NAV_BAR);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration completion failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success dialog and navigate back to login
      Get.back(); // Close dialog
      Get.off(() => const Login());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reset link. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Social login methods
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Simulate Google login
      await Future.delayed(const Duration(seconds: 2));

      Get.toNamed(Routes.BOTTOM_NAV_BAR);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google login failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;

      // Simulate Apple login
      await Future.delayed(const Duration(seconds: 2));

      Get.toNamed(Routes.BOTTOM_NAV_BAR);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Apple login failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      isLoading.value = true;

      // Simulate Facebook login
      await Future.delayed(const Duration(seconds: 2));

      Get.toNamed(Routes.BOTTOM_NAV_BAR);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Facebook login failed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigation methods
  void goToSignUp() => Get.toNamed(Routes.SIGN_UP);
  void goToLogin() => Get.toNamed(Routes.LOGIN);
  void goToForgotPassword() => Get.to(() => const ForgetPassword());
  void goBack() => Get.back();
  void skipStep() => Get.toNamed(Routes.BOTTOM_NAV_BAR);

  // Clear form data
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
    agreeToTerms.value = false;
  }

  void clearCompleteProfileForm() {
    usernameController.clear();
    selectedGender.value = null;
    selectedDateOfBirth.value = null;
    cityController.clear();
    stateController.clear();
    countryController.clear();
    addressController.clear();
    bioController.clear();
  }
}
