import 'package:flutter/material.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/heading_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

import 'package:get/get.dart';


class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: authAppBar(
        title: 'Forgot Password',
      ),
      body: Form(
        key: authController.forgotPasswordFormKey,
        child: ListView(
          padding: AppSizes.DEFAULT,
          children: [
            const AuthHeading(
              title: 'Reset Your Password',
              subTitle:
                  'Forgot your password? No worries! Enter your email below to receive a reset link.',
            ),
            
            // Email Field
            MyTextField(
              label: 'Email Address',
              controller: authController.forgotPasswordEmailController,
              keyboardType: TextInputType.emailAddress,
              marginBottom: 24,
              validator: authController.validateEmail,
              suffix: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [],
              ),
            ),
            
            // Send Reset Link Button
            Obx(() => MyButton(
              buttonText: 'Send Password Reset Link',
              isLoading: authController.isLoading.value,
              onTap: () {
                if (authController.forgotPasswordFormKey.currentState!.validate()) {
                  Get.dialog(
                    CongratsDialog(
                      icon: Assets.imagesMailSent,
                      title: 'Check Your Email',
                      congratsText:
                          'Password reset link has been sent to ${authController.forgotPasswordEmailController.text}',
                      btnText: 'Back to Login',
                      onTap: () {
                        Get.back(); // Close dialog
                        authController.forgotPassword();
                      },
                    ),
                  );
                }
              },
            )),
            
            const SizedBox(height: 24),
            
            // Back to Login Link
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MyText(
                  text: 'Remember your password? ',
                  size: 13,
                  color: kQuaternaryColor,
                ),
                MyText(
                  text: 'Login',
                  size: 13,
                  color: kSecondaryColor,
                  weight: FontWeight.w600,
                  onTap: authController.goBack,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Additional Help Section
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kInputBorderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kInputBorderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: 'Need help?',
            size: 14,
            color: kTertiaryColor,
            weight: FontWeight.w600,
            paddingBottom: 8,
          ),
          MyText(
            text: '• Check your spam/junk folder\n• Make sure you entered the correct email\n• Contact support if you don\'t receive the email',
            size: 12,
            color: kQuaternaryColor,
       
          ),
        ],
      ),
    );
  }
}