import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';

import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class CreatorAddEmails extends StatelessWidget {
  const CreatorAddEmails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Add Recipients Emails'),
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
                  textColor: kSecondaryColor,
                  splashColor: kSecondaryColor.withValues(alpha: 0.1),
                  buttonText: 'Add New',
                  onTap: () {},
                ),
                SizedBox(height: 12),
                ...List.generate(3, (index) {
                  return MyTextField(label: 'Email Address');
                }),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Send Invites',
              onTap: () {
                Get.dialog(
                  CongratsDialog(
                    title: 'Invitation Sent to All!',
                    congratsText: 'Wohoo! Event invitation sent on all emails.',
                    btnText: 'Continue',
                    onTap: () {
                      Get.back();
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
