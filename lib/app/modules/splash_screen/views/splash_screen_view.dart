import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          color: controller.currentColorScheme.backgroundColor,
          child: Center(
            child: AnimatedBuilder(
              animation: controller.animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: controller.fadeAnimation,
                  child: ScaleTransition(
                    scale: controller.scaleAnimation,
                    child: Image.asset(
                      Assets.imagesAppLogo,
                      height: 120,
                      width: 120,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
