import 'package:get/get.dart';
import 'package:photo_bug/app/modules/launch/controller/onboarding_controller.dart';
import 'package:photo_bug/app/modules/launch/controller/splash_controller.dart';
import 'package:photo_bug/app/modules/launch/controller/welcome_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

// bindings/welcome_binding.dart
class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeController>(() => WelcomeController());
  }
}

// bindings/onboarding_binding.dart
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}

// bindings/launch_binding.dart (combined binding for the entire launch flow)
class LaunchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
    Get.lazyPut<WelcomeController>(() => WelcomeController());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}