import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:photo_bug/app/core/common_widget/custom_check_box_widget.dart';
import 'package:photo_bug/app/core/common_widget/heading_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      appBar: authAppBar(
        haveLeading: false,
        title: 'Login',
      ),
      body: Form(
        key: authController.loginFormKey,
        child: ListView(
          padding: AppSizes.DEFAULT,
          children: [
            const AuthHeading(
              title: 'Login',
              subTitle:
                  'Login to your account to discover and buy the best photographs effortlessly.',
            ),
            
            // Email Field
            MyTextField(
              label: 'Email Address',
              controller: authController.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: authController.validateEmail,
            ),
            
            // Password Field
            Obx(() => MyTextField(
              label: 'Password',
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
                          ? Assets.imagesUnicon 
                          : Assets.imagesEye,
                      height: 18,
                    ),
                  ],
                ),
              ),
            )),
            
            // Forgot Password
            MyText(
              text: 'Forgot Password?',
              size: 12,
              color: kRedColor,
              weight: FontWeight.w600,
              textAlign: TextAlign.end,
              paddingBottom: 16,
              onTap: authController.goToForgotPassword,
            ),
            
            // Remember Me Checkbox
            Obx(() => Row(
              children: [
                CustomCheckBox(
                  isActive: authController.rememberMe.value,
                  onTap: authController.toggleRememberMe,
                ),
                Expanded(
                  child: MyText(
                    text: 'Remember me',
                    size: 12,
                    color: kTertiaryColor,
                    paddingLeft: 8,
                  ),
                ),
              ],
            )),
            
            const SizedBox(height: 16),
            
            // Login Button
            Obx(() => MyButton(
              buttonText: 'Login',
              isLoading: authController.isLoading.value,
              onTap: authController.login,
            )),
            
            const SizedBox(height: 16),
            
            // Sign Up Link
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                MyText(
                  text: 'Don\'t have an account? ',
                  size: 13,
                  color: kQuaternaryColor,
                ),
                MyText(
                  text: 'SignUp',
                  size: 13,
                  color: kSecondaryColor,
                  weight: FontWeight.w600,
                  onTap: authController.goToSignUp,
                ),
              ],
            ),
            
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

class SocialLogin extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogle, onApple, onFacebook;
  
  const SocialLogin({
    super.key,
    required this.isLoading,
    required this.onGoogle,
    required this.onApple,
    required this.onFacebook,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Google Login
        Expanded(
          child: MyButton(
            borderWidth: 1,
            bgColor: Colors.transparent,
            borderColor: kInputBorderColor,
            splashColor: kSecondaryColor.withOpacity(0.1),
            buttonText: '',
            isLoading: false,
            onTap:(){
              onGoogle();
            },
            child: Center(
              child: Image.asset(
                Assets.imagesGoogle,
                height: 20,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Apple Login
        Expanded(
          child: MyButton(
            borderWidth: 1,
            bgColor: Colors.transparent,
            borderColor: kInputBorderColor,
            splashColor: kSecondaryColor.withOpacity(0.1),
            buttonText: '',
            isLoading: false,
            onTap: onApple,
            child: Center(
              child: Image.asset(
                Assets.imagesApple,
                height: 20,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Facebook Login
        Expanded(
          child: MyButton(
            borderWidth: 1,
            bgColor: Colors.transparent,
            borderColor: kInputBorderColor,
            splashColor: kSecondaryColor.withOpacity(0.1),
            buttonText: '',
            isLoading: false,
            onTap: onFacebook,
            child: Center(
              child: Image.asset(
                Assets.imagesFacebook,
                height: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}