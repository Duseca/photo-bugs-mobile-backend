import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';
import 'package:photo_bug/app/shared/widget/my_button_widget.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 40,
          bottom: 16,
        ),
        child: Obx(
          () => AnimatedSwitcher(
            duration: 280.milliseconds,
            child: Column(
              key: ValueKey(controller.currentIndex.value),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(controller.currentImage, fit: BoxFit.fill),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      Assets.imagesAppLogo,
                      height: 48,
                      alignment: Alignment.centerLeft,
                    ),
                    MyText(
                      text: controller.currentTitle,
                      size: 28,
                      weight: FontWeight.w800,
                      paddingTop: 12,
                      paddingBottom: 8,
                    ),
                    MyText(
                      text: controller.currentSubTitle,
                      size: 12,
                      color: kQuaternaryColor,
                      paddingBottom: 12,
                    ),

                    // Optional: Add page indicators
                    _buildPageIndicators(),

                    const SizedBox(height: 16),

                    // Continue button
                    MyButton(
                      buttonText:
                          controller.isLastPage ? 'Let\'s Get Started' : 'Next',
                      onTap: controller.onContinue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Optional: Page indicators
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.items.length,
        (index) => Obx(
          () => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: controller.currentIndex.value == index ? 24 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color:
                  controller.currentIndex.value == index
                      ? kSecondaryColor
                      : kQuaternaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
