import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/view/bottom_nav.dart';
import 'package:photo_bug/app/core/common_widget/custom_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';


class AppFeedback extends StatelessWidget {
  AppFeedback({super.key});

  final List<Map<String, dynamic>> items = [
    {
      'icon': Assets.imagesEmoji1,
      'text': 'Very Bad',
    },
    {
      'icon': Assets.imagesEmoji2,
      'text': 'Bad',
    },
    {
      'icon': Assets.imagesEmoji3,
      'text': 'Neutral',
    },
    {
      'icon': Assets.imagesEmoji4,
      'text': 'Good',
    },
    {
      'icon': Assets.imagesEmoji5,
      'text': 'Very Good',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Give Feedback'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                MyTextField(
                  heading: 'Email address (optional)',
                  hint: 'Enter your email address',
                ),
                MyText(
                  text: 'Rate your experience',
                  size: 12,
                  weight: FontWeight.w600,
                  paddingBottom: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            items[index]['icon'],
                            height: 40,
                          ),
                          MyText(
                            text: items[index]['text'],
                            size: 10,
                            weight: FontWeight.w500,
                            paddingTop: 4,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                MyTextField(
                  heading: 'What are we missing?',
                  hint: 'Say, something here...',
                  maxLines: 5,
                ),
                MyTextField(
                  heading: 'What is not working?',
                  hint: 'Say, something here...',
                  maxLines: 5,
                ),
                MyTextField(
                  heading: 'What is working the best?',
                  hint: 'Say, something here...',
                  maxLines: 5,
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Send Feedback',
              onTap: () {
                Get.dialog(
                  CustomDialog(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Image.asset(
                              Assets.imagesThankYou,
                              height: 200,
                            ),
                          ),
                          MyText(
                            text: 'Thank you!',
                            size: 22,
                            weight: FontWeight.w700,
                            textAlign: TextAlign.center,
                            paddingTop: 16,
                            paddingBottom: 8,
                          ),
                          MyText(
                            text:
                                'By making your voice heard, you help us improve :)',
                            size: 13,
                            color: kQuaternaryColor,
                            textAlign: TextAlign.center,
                            lineHeight: 1.6,
                            paddingBottom: 16,
                          ),
                          MyButton(
                            bgColor: Colors.transparent,
                            textColor: kSecondaryColor,
                            splashColor: kSecondaryColor.withOpacity(0.1),
                            borderWidth: 1,
                            buttonText: 'Back to home',
                            onTap: () {
                              Get.offAll(() => BottomNavBar());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
