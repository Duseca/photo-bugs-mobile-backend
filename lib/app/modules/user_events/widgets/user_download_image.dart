import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/view/bottom_nav.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_check_box_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';
class UserDownloadImage extends StatelessWidget {
  const UserDownloadImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Download Images'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GridView.builder(
              padding: AppSizes.DEFAULT,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                mainAxisExtent: 200,
              ),
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CommonImageView(
                        url: dummyImg,
                        radius: 8,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: CustomCheckBox(
                            isActive: index == 0,
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Select 1/6 images to download',
              onTap: () {
                Get.to(() => _Feedback());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  _Feedback();

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
                MyText(
                  text: 'How was it working with Hassan?',
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
                MyText(
                  text: 'Write a public review',
                  size: 12,
                  weight: FontWeight.w600,
                  paddingTop: 24,
                  paddingBottom: 8,
                ),
                MyTextField(
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
                Get.offAll(() => BottomNavBar());
              },
            ),
          ),
        ],
      ),
    );
  }
}
