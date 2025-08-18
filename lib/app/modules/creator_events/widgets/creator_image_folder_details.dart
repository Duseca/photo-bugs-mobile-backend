import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/creator_add_emails.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/creator_upload_folder_image.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/share_event.dart';

import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
class CreatorImageFolderDetails extends StatelessWidget {
  CreatorImageFolderDetails({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        title: 'Table 15',
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.imagesEdit2,
                height: 20,
                color: kTertiaryColor,
              ),
            ],
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: ListView(
        padding: AppSizes.DEFAULT,
        children: [
          MyButton(
            buttonText: 'Enter Email addresses',
            onTap: () {
              Get.to(() => CreatorAddEmails());
            },
          ),
          SizedBox(
            height: 12,
          ),
          MyButton(
            buttonText: 'Upload Images',
            onTap: () {
              Get.to(() => CreatorUploadFolderImage());
            },
          ),
          SizedBox(
            height: 12,
          ),
          MyButton(
            buttonText: 'Upload Thumbnail',
            onTap: () {},
          ),
          SizedBox(
            height: 12,
          ),
          MyButton(
            buttonText: 'Share Folder',
            onTap: () {
              Get.to(() => ShareEvent());
            },
          ),
          SizedBox(
            height: 24,
          ),
          MyTextField(
            heading: 'Single Photo Price',
            hint: 'Enter price per photo',
            keyboardType: TextInputType.number,
            suffix: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: '\$',
                  size: 14,
                  color: kQuaternaryColor,
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
          MyTextField(
            heading: 'Group of Photos',
            hint: 'Ex. Every 5 photos for \$4',
            keyboardType: TextInputType.number,
            suffix: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: '\$',
                  size: 14,
                  color: kQuaternaryColor,
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
          MyTextField(
            heading: 'Price for Folder',
            hint: 'Enter total price for folder',
            keyboardType: TextInputType.number,
            suffix: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: '\$',
                  size: 14,
                  color: kQuaternaryColor,
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
          MyText(
            text: '+ Pricing Options',
            color: kSecondaryColor,
            weight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
