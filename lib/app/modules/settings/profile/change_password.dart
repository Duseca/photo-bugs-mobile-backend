import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';


class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Change Password'),
      body: ListView(
        padding: AppSizes.DEFAULT,
        children: [
          MyTextField(
            label: 'Current Password',
            isObSecure: true,
            suffix: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.imagesEye,
                  height: 18,
                ),
              ],
            ),
          ),
          MyTextField(
            label: 'New Password',
            isObSecure: true,
            suffix: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.imagesEye,
                  height: 18,
                ),
              ],
            ),
          ),
          MyTextField(
            label: 'Confirm New Password',
            isObSecure: true,
            marginBottom: 24,
            suffix: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.imagesEye,
                  height: 18,
                ),
              ],
            ),
          ),
          MyButton(
            buttonText: 'Save Changes',
            onTap: () {
              Get.dialog(
                CongratsDialog(
                  title: 'Password Changed',
                  congratsText: 'You password has been successfully changed.',
                  btnText: 'Continue',
                  onTap: () {
                    Get.back();
                    Get.back();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
