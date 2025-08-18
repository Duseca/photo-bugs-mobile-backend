import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:photo_bug/app/modules/authentication/screens/login_screen.dart';
import 'package:photo_bug/app/core/common_widget/custom_check_box_widget.dart';
import 'package:photo_bug/app/core/common_widget/heading_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: authAppBar(
        haveLeading: false,
        title: 'Signup',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Form(
              key: authController.signUpFormKey,
              child: ListView(
                padding: AppSizes.DEFAULT,
                children: [
                  const AuthHeading(
                    title: 'Signup',
                    subTitle:
                        'Create your account to discover and buy the best photographs effortlessly.',
                  ),
                  
                  // First Name
                  MyTextField(
                    label: 'First Name',
                    controller: authController.firstNameController,
                    validator: (value) => authController.validateRequired(value, 'First Name'),
                  ),
                  
                  // Last Name
                  MyTextField(
                    label: 'Last Name',
                    controller: authController.lastNameController,
                    validator: (value) => authController.validateRequired(value, 'Last Name'),
                  ),
                  
                  // Email
                  MyTextField(
                    label: 'Email Address',
                    controller: authController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: authController.validateEmail,
                  ),
                  
                  // Create Password
                  Obx(() => MyTextField(
                    label: 'Create Password',
                    controller: authController.passwordController,
                    isObSecure: !authController.isPasswordVisible.value,
                    marginBottom: 16,
                    validator: authController.validatePassword,
                    suffix: GestureDetector(
                      onTap: authController.togglePasswordVisibility,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            authController.isPasswordVisible.value
                                ? Assets.imagesAdd
                                : Assets.imagesEye,
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  )),
                  
                  // Repeat Password
                  Obx(() => MyTextField(
                    label: 'Repeat Password',
                    controller: authController.confirmPasswordController,
                    isObSecure: !authController.isConfirmPasswordVisible.value,
                    marginBottom: 16,
                    validator: authController.validateConfirmPassword,
                    suffix: GestureDetector(
                      onTap: authController.toggleConfirmPasswordVisibility,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            authController.isConfirmPasswordVisible.value
                                ? Assets.imagesEdit
                                : Assets.imagesEye,
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  )),
                  
                  // Terms and Conditions Checkbox
                  Obx(() => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCheckBox(
                        isActive: authController.agreeToTerms.value,
                        onTap: authController.toggleAgreeToTerms,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: authController.toggleAgreeToTerms,
                          child: MyText(
                            text: 'I agree to the Terms and Conditions.',
                            size: 12,
                            color: kTertiaryColor,
                            paddingLeft: 8,
                          ),
                        ),
                      ),
                    ],
                  )),
                  
                  const SizedBox(height: 16),
                  
                  // Signup Button
                  Obx(() => MyButton(
                    buttonText: 'Signup',
                    isLoading: authController.isLoading.value,
                    onTap: authController.signUp,
                  )),
                  
                  const SizedBox(height: 16),
                  
                  // Divider
                  _buildDivider(),
                  
                  const SizedBox(height: 16),
                  
                  // Social Login
                  Obx(() => SocialLogin(
                    isLoading: authController.isLoading.value,
                    onGoogle: authController.loginWithGoogle,
                    onApple: authController.loginWithApple,
                    onFacebook: authController.loginWithFacebook,
                  )),
                ],
              ),
            ),
          ),
          
          // Login Link
          Padding(
            padding: AppSizes.DEFAULT,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                MyText(
                  text: 'Already have an account? ',
                  size: 13,
                  color: kQuaternaryColor,
                ),
                MyText(
                  text: 'Login',
                  size: 13,
                  color: kSecondaryColor,
                  weight: FontWeight.w600,
                  onTap: authController.goToLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: kInputBorderColor,
          ),
        ),
        MyText(
          text: 'or continue with',
          size: 12,
          color: kQuaternaryColor,
          weight: FontWeight.w300,
          paddingLeft: 8,
          paddingRight: 8,
        ),
        Expanded(
          child: Container(
            height: 1,
            color: kInputBorderColor,
          ),
        ),
      ],
    );
  }
}