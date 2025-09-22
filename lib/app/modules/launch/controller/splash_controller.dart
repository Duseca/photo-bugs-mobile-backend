import 'dart:async';
import 'package:get/get.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

class SplashController extends GetxController {
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxDouble logoOpacity = 0.0.obs;

  // Timer for splash duration
  Timer? _splashTimer;

  @override
  void onInit() {
    super.onInit();
    _startSplashSequence();
  }

  @override
  void onClose() {
    _splashTimer?.cancel();
    super.onClose();
  }

  // Start splash sequence with animation
  void _startSplashSequence() async {
    // Animate logo appearance
    await Future.delayed(const Duration(milliseconds: 300));
    logoOpacity.value = 1.0;

    // Wait for splash duration
    _splashTimer = Timer(
      const Duration(seconds: 3),
      () => _navigateToWelcome(),
    );
  }

  // Navigate to welcome screen
  void _navigateToWelcome() {
    isLoading.value = false;
    Get.toNamed(Routes.BOTTOM_NAV_BAR);
  }

  void skipSplash() {
    _splashTimer?.cancel();
    _navigateToWelcome();
  }
}
