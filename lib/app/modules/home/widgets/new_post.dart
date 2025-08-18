import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/view/bottom_nav.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class NewPost extends StatelessWidget {
  const NewPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Upload'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                MyButton(
                  borderWidth: 1,
                  bgColor: Colors.transparent,
                  splashColor: kSecondaryColor.withOpacity(0.1),
                  buttonText: '',
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.imagesAdd,
                        height: 18,
                        color: kSecondaryColor,
                      ),
                      Flexible(
                        child: MyText(
                          text: 'Upload Image/Video',
                          size: 16,
                          color: kSecondaryColor,
                          weight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          paddingLeft: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stack(
                //   children: [
                //     CommonImageView(
                //       url: dummyImg,
                //       height: 180,
                //       width: Get.width,
                //       radius: 8,
                //     ),
                //     Positioned(
                //       top: 8,
                //       right: 8,
                //       child: Image.asset(
                //         Assets.imagesDeleteBg,
                //         height: 28,
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 16),
                MyTextField(label: 'Image title'),
                CustomDropDown(hint: 'Category', items: [], onChanged: (v) {}),
                CustomDropDown(
                  hint: 'Sub-Category',
                  items: [],
                  onChanged: (v) {},
                ),
                MyTextField(label: 'Price per image'),
                MyTextField(label: 'Keywords at least 20'),

                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Subscription',
                        size: 12,
                        color: kQuaternaryColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FlutterSwitch(
                      height: 20,
                      width: 36,
                      toggleSize: 16,
                      padding: 2,
                      toggleColor: kWhiteColor,
                      activeColor: kSecondaryColor,
                      inactiveColor: kQuaternaryColor,
                      value: false,
                      onToggle: (v) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Publish',
              onTap: () {
                Get.dialog(
                  CongratsDialog(
                    title: 'Published Successful',
                    congratsText:
                        'Upload more content to earn more and grow your business with us.',
                    btnText: 'Continue',
                    onTap: () {
                      Get.offAll(() => BottomNavBar());
                    },
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
