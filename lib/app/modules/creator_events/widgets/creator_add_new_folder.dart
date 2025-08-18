import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';


import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';


class CreatorAddNewFolder extends StatelessWidget {
  const CreatorAddNewFolder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Create Folder'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                MyTextField(
                  label: 'Folder Name',
                ),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Folder Pricing',
                        size: 13,
                        weight: FontWeight.w500,
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
                      value: true,
                      onToggle: (v) {},
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                MyTextField(
                  label: 'Price',
                ),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Price Per Image',
                        size: 13,
                        weight: FontWeight.w500,
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
                      value: true,
                      onToggle: (v) {},
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                MyTextField(
                  label: 'Price Per Image',
                ),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Packages',
                        size: 13,
                        weight: FontWeight.w500,
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
                      value: true,
                      onToggle: (v) {},
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                MyTextField(
                  label: 'Package Name',
                ),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        label: 'No of Images',
                        marginBottom: 0,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: MyTextField(
                        label: 'Pricing',
                        marginBottom: 0,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                MyTextField(
                  label: 'No of free Images',
                  marginBottom: 24,
                ),
                GestureDetector(
                  onTap: () {},
                  child: Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Image.asset(
                        Assets.imagesAdd,
                        height: 20,
                        color: kSecondaryColor,
                      ),
                      MyText(
                        text: 'Add New Package',
                        size: 13,
                        weight: FontWeight.w500,
                        color: kSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Save',
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
