import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/launch/views/on_boarding.dart';
import 'package:photo_bug/app/modules/privacy_policy/views/privacy_policy.dart';
import 'package:photo_bug/app/modules/privacy_policy/views/terms.dart';

class WelcomeController extends GetxController {
  // Observable variables
  final RxBool isTermsAccepted = false.obs;
  final RxBool isLoading = false.obs;

  // Toggle terms acceptance
  void toggleTermsAcceptance() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  // Navigate to onboarding
  void continueToOnboarding() {
    if (!isTermsAccepted.value) {
      Get.snackbar(
        'Terms Required',
        'Please accept the Terms of Service and Privacy Policy to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.to(
      () => OnBoarding(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Navigate to terms of service
  void openTermsOfService() {
    Get.to(() => const Terms(), transition: Transition.rightToLeft);
  }

  // Navigate to privacy policy
  void openPrivacyPolicy() {
    Get.to(() => const PrivacyPolicy(), transition: Transition.rightToLeft);
  }
}
