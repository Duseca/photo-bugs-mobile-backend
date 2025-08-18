
import 'package:flutter/material.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/modules/launch/controller/splash_controller.dart';
import 'package:get/get.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Double tap to skip splash for testing
        onDoubleTap: controller.skipSplash,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Obx(() => AnimatedOpacity(
              opacity: controller.logoOpacity.value,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Image.asset(
                Assets.imagesAppLogo,
                height: 98,
              ),
            )),
          ),
        ),
      ),
    );
  }
}