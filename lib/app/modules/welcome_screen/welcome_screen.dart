import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/privacy_policy/privacy_policy.dart';
import 'package:photo_bug/app/modules/privacy_policy/terms.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_fonts.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';

import 'package:photo_bug/app/shared/widget/custom_check_box_widget.dart';
import 'package:photo_bug/app/shared/widget/my_button_widget.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(Assets.imagesChoseRoleBg, fit: BoxFit.fill),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyText(
                  text: 'Welcome to PhotoBugs',
                  size: 30,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: kQuaternaryColor,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFonts.inter,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'By selecting one or the other, you agreeing to the ',
                            ),
                            TextSpan(
                              text: 'Terms of Services',
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => Terms());
                                    },
                              style: const TextStyle(
                                color: kSecondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => PrivacyPolicy());
                                    },
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: kSecondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Client Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSecondaryColor, // Orange color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Navigate to client flow
                      Get.toNamed(Routes.ONBOARDING);
                    },
                    child: const Text(
                      "I'm a Client",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Creator Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kSecondaryColor, width: 1.5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Navigate to creator flow
                      Get.toNamed(
                        Routes.ONBOARDING,
                      ); // Or different route for creators
                    },
                    child: const Text(
                      "I'm a Creator",
                      style: TextStyle(
                        color: kSecondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // MyButton(
                //   buttonText: 'Continue',
                //   onTap: () {
                //     if (isTermsAccepted) {
                //       // Navigate to onboarding using GetX route
                //       Get.toNamed(Routes.ONBOARDING);
                //     } else {
                //       // Show message or do nothing if terms not accepted
                //       Get.snackbar(
                //         'Terms Required',
                //         'Please accept the terms and privacy policy to continue',
                //         snackPosition: SnackPosition.BOTTOM,
                //       );
                //     }
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
