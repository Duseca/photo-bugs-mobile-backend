import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/settings/profile/edit_profile.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class UserId extends StatelessWidget {
  const UserId({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'User Id'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                MyText(
                  text:
                      'Please enter your ID details carefully. Ensure the information matches your official ID. If OCR is enabled, you can scan your ID to fill in the details automatically.',
                  color: kQuaternaryColor,
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Open camera for OCR scanning
                  },
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kInputBorderColor,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: kQuaternaryColor,
                          ),
                          SizedBox(height: 8),
                          MyText(
                            text: 'Tap to scan ID',
                            color: kQuaternaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                MyTextField(
                  label: 'First Name',
                ),
                MyTextField(
                  label: 'Last Name',
                ),
                MyTextField(
                  label: 'Country',
                ),
                MyTextField(
                  label: 'State',
                ),
                MyTextField(
                  label: 'Town',
                ),
                MyTextField(
                  label: 'ID Number',
                ),
                MyTextField(
                  label: 'ID Type',
                ),
                MyTextField(
                  label: 'Expiration Date',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Submit',
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
