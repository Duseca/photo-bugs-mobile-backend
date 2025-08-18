import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/settings/profile/change_password.dart';
import 'package:photo_bug/app/modules/settings/profile/edit_profile.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/payment_method_tile_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class Security extends StatelessWidget {
  const Security({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Security'),
      body: Padding(
        padding: AppSizes.DEFAULT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyText(
                        text: 'Face ID',
                        weight: FontWeight.w600,
                        paddingBottom: 2,
                      ),
                      MyText(
                        text: 'Turn on/off your Face Id security',
                        size: 12,
                        color: kQuaternaryColor,
                      ),
                    ],
                  ),
                ),
                FlutterSwitch(
                  height: 22,
                  width: 40,
                  toggleSize: 20,
                  padding: 1.5,
                  activeColor: kSecondaryColor,
                  inactiveColor: Colors.grey.shade400,
                  toggleColor: kWhiteColor,
                  value: true,
                  onToggle: (v) {},
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyText(
                        text: 'Biometric ID',
                        weight: FontWeight.w600,
                        paddingBottom: 2,
                      ),
                      MyText(
                        text: 'Turn on/off your Biometric ID security',
                        size: 12,
                        color: kQuaternaryColor,
                      ),
                    ],
                  ),
                ),
                FlutterSwitch(
                  height: 22,
                  width: 40,
                  toggleSize: 20,
                  padding: 1.5,
                  activeColor: kSecondaryColor,
                  inactiveColor: Colors.grey.shade400,
                  toggleColor: kWhiteColor,
                  value: false,
                  onToggle: (v) {},
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => ChangePassword());
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          text: 'Change Password',
                          weight: FontWeight.w600,
                          paddingBottom: 2,
                        ),
                        MyText(
                          text:
                              'Change your account password to secure account',
                          size: 12,
                          color: kQuaternaryColor,
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    Assets.imagesArrowRightIos,
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
