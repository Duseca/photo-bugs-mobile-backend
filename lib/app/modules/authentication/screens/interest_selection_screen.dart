import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class SelectInterest extends StatelessWidget {
  SelectInterest({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Expanded(
              child: MyText(
                text: 'Please Select Interests',
                size: 18,
                color: kTertiaryColor,
                fontFamily: AppFonts.inter,
                weight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: authController.skipStep,
              child: MyText(
                text: 'Skip',
                size: 12,
                color: kSecondaryColor,
                weight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: AppSizes.DEFAULT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            MyText(
              text:
                  'Select your areas of interest to get personalized recommendations',
              size: 14,
              color: kQuaternaryColor,
              paddingBottom: 24,
              textAlign: TextAlign.center,
            ),

            // Selected count
            Obx(
              () => MyText(
                text: 'Selected: ${authController.selectedInterests.length}',
                size: 12,
                color: kSecondaryColor,
                weight: FontWeight.w600,
                paddingBottom: 16,
              ),
            ),

            // Interest options
            Expanded(
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    authController.interestOptions.length,
                    (index) {
                      final interest = authController.interestOptions[index];
                      return IntrinsicWidth(
                        child: _CustomToggleButton(
                          text: interest,
                          isSelected: authController.isInterestSelected(
                            interest,
                          ),
                          onTap: () => authController.toggleInterest(interest),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Finish Button
            Obx(
              () => MyButton(
                buttonText:
                    authController.selectedInterests.isEmpty
                        ? 'Skip for now'
                        : 'Finish (${authController.selectedInterests.length})',
                isLoading: authController.isLoading.value,
                onTap: () {
                  Get.dialog(
                    CongratsDialog(
                      title: 'Profile Completed',
                      congratsText:
                          authController.selectedInterests.isEmpty
                              ? 'You can always update your interests later in settings.'
                              : 'Your profile has been successfully completed with ${authController.selectedInterests.length} interests.',
                      btnText: 'Go to Home',
                      onTap: () {
                        Get.back(); // Close dialog
                        authController.finishRegistration();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomToggleButton({
    // ignore: unused_element_parameter
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 34,
      duration: 220.milliseconds,
      decoration: BoxDecoration(
        color: isSelected ? kSecondaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        border:
            isSelected
                ? null
                : Border.all(width: 1.0, color: kInputBorderColor),
      ),
      child: MyRippleEffect(
        onTap: onTap,
        radius: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                text: text,
                size: 13,
                color: isSelected ? kTertiaryColor : kDarkGreyColor,
                paddingRight: 4,
              ),
              Image.asset(
                isSelected ? Assets.imagesClose : Assets.imagesAdd,
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom ripple effect widget (if MyRippleEffect doesn't exist)
class MyRippleEffect extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double radius;

  const MyRippleEffect({
    super.key,
    required this.child,
    required this.onTap,
    this.radius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
