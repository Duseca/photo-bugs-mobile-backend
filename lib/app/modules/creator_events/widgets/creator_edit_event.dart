import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class CreatorEditEvent extends StatelessWidget {
  const CreatorEditEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Edit Event'),
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
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Share permission access to client',
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
              buttonText: 'Save Changes',
              onTap: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
