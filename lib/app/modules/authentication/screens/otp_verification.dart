import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/constants/app_styling.dart';
import 'package:photo_bug/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/heading_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

import 'package:pinput/pinput.dart';


class OtpVerification extends StatelessWidget {
  const OtpVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: authAppBar(
        title: 'Account Verification',
      ),
      body: ListView(
        padding: AppSizes.DEFAULT,
        children: [
          const AuthHeading(
            title: 'OTP Verification',
            subTitle:
                'Enter the One-Time Password (OTP) sent to your email to verify your account.',
          ),
          
          // OTP Input
          Pinput(
            controller: authController.otpController,
            showCursor: true,
            autofocus: true,
            length: 6,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            mainAxisAlignment: MainAxisAlignment.center,
            defaultPinTheme: AppStyling.defaultPinTheme,
            focusedPinTheme: AppStyling.focusPinTheme,
            onCompleted: (pin) {
              // Auto verify when OTP is complete
              if (pin.length == 6) {
                authController.verifyOTP();
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // Timer and Resend
          Obx(() => Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!authController.canResendOTP.value) ...[
                MyText(
                  text: '00:${authController.otpTimer.value.toString().padLeft(2, '0')} ',
                  size: 12,
                  color: kQuaternaryColor,
                ),
              ],
              GestureDetector(
                onTap: authController.canResendOTP.value 
                    ? authController.resendOTP 
                    : null,
                child: MyText(
                  text: 'Resend',
                  size: 12,
                  color: authController.canResendOTP.value 
                      ? kSecondaryColor 
                      : kQuaternaryColor,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          )),
          
          const SizedBox(height: 24),
          
          // Confirm Button
          Obx(() => MyButton(
            buttonText: 'Confirm',
            isLoading: authController.isLoading.value,
            onTap: () {
              authController.verifyOTP();
              
              // Show success dialog
              Get.dialog(
                CongratsDialog(
                  title: 'Verification Complete!',
                  congratsText: 'Your account has been successfully verified.',
                  btnText: 'Continue',
                  onTap: () {
                    Get.back(); // Close dialog
                    authController.completeProfile();
                  },
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}