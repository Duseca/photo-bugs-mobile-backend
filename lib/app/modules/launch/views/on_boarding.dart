import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/modules/launch/controller/onboarding_controller.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class OnBoarding extends GetView<OnboardingController> {
  const OnBoarding({super.key});

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
            duration: const Duration(milliseconds: 280),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      key: ValueKey(controller.currentIndex.value),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [Expanded(child: _buildImage()), _buildBottomSection()],
    );
  }

  Widget _buildImage() {
    return Obx(
      () => Image.asset(controller.currentItem.image, fit: BoxFit.fill),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          Assets.imagesAppLogo,
          height: 48,
          alignment: Alignment.centerLeft,
        ),
        _buildTitle(),
        _buildSubtitle(),
        _buildProgressIndicator(),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildTitle() {
    return Obx(
      () => MyText(
        text: controller.currentItem.title,
        size: 28,
        weight: FontWeight.w800,
        paddingTop: 12,
        paddingBottom: 8,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Obx(
      () => MyText(
        text: controller.currentItem.subTitle,
        size: 12,
        color: kQuaternaryColor,
        paddingBottom: 12,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => LinearProgressIndicator(
          value: controller.progress,
          backgroundColor: kInputBorderColor,
          valueColor: const AlwaysStoppedAnimation<Color>(kSecondaryColor),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Obx(
      () => MyButton(
        buttonText: controller.buttonText,
        onTap: controller.continueOnboarding,
        isLoading: controller.isLoading.value,
      ),
    );
  }
}
