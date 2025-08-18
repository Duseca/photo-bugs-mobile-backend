import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/share_event.dart';

import 'package:photo_bug/app/core/common_widget/custom_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class UserAddEvent extends StatelessWidget {
  const UserAddEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Add New Event'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                Row(
                  children: [
                    Image.asset(Assets.imagesUploadImage, height: 80),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MyText(
                            text: 'Browse File',
                            size: 12,
                            color: kSecondaryColor,
                            weight: FontWeight.w500,
                            paddingBottom: 8,
                          ),
                          MyText(
                            text: 'Select photos to upload',
                            size: 12,
                            color: kQuaternaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                MyTextField(label: 'Name'),
                MyTextField(
                  label: 'Location',
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesLocation, height: 18)],
                  ),
                ),
                MyTextField(
                  label: 'Date',
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesCalendar, height: 18)],
                  ),
                ),
                MyTextField(
                  label: 'Time Start',
                  readOnly: true,
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesClock, height: 18)],
                  ),
                ),
                MyTextField(
                  label: 'Time End',
                  readOnly: true,
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesClock, height: 18)],
                  ),
                ),
                CustomDropDown(
                  hint: 'Type of Event',
                  selectedValue: null,
                  items: [],
                  onChanged: (v) {},
                ),
                CustomDropDown(
                  hint: 'Role',
                  selectedValue: null,
                  items: [],
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Add Event',
              onTap: () {
                Get.back();
                Get.dialog(
                  CustomDialog(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Image.asset(
                              Assets.imagesCongrats,
                              height: 120,
                            ),
                          ),
                          MyText(
                            text: 'Event Added Successfully',
                            size: 22,
                            weight: FontWeight.w700,
                            textAlign: TextAlign.center,
                            paddingTop: 16,
                            paddingBottom: 8,
                          ),
                          MyText(
                            text:
                                'Your event has been created. You can now share it with others or continue.',
                            size: 13,
                            color: kQuaternaryColor,
                            textAlign: TextAlign.center,
                            lineHeight: 1.6,
                            paddingBottom: 16,
                          ),
                          MyButton(
                            bgColor: Colors.transparent,
                            splashColor: kSecondaryColor.withValues(alpha: 0.1),
                            textColor: kSecondaryColor,
                            borderWidth: 1,
                            buttonText: 'Share',
                            onTap: () {
                              Get.back();
                              Get.to(() => ShareEvent());
                            },
                          ),
                          SizedBox(height: 12),
                          MyButton(
                            buttonText: 'Continue',
                            onTap: () {
                              Get.back();
                              Get.back();
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
