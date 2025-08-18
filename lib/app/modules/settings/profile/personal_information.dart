import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/settings/profile/edit_profile.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class PersonalInformation extends StatelessWidget {
  const PersonalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        title: 'Personal Information',
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => EditProfile());
                },
                child: Image.asset(
                  Assets.imagesEdit,
                  height: 20,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: ListView(
        padding: AppSizes.VERTICAL,
        children: [
          Center(
            child: Stack(
              children: [
                CommonImageView(
                  url: dummyImg,
                  height: 84,
                  width: 84,
                  radius: 100,
                  borderColor: kInputBorderColor,
                  borderWidth: 2,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    Assets.imagesEditBg,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Container(
            padding: AppSizes.HORIZONTAL,
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.1),
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: kInputBorderColor,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DetailRow(
                  title: 'Username',
                  subText: 'Samuel',
                ),
                _DetailRow(
                  title: 'First Name',
                  subText: 'Samuel',
                ),
                _DetailRow(
                  title: 'Last Name',
                  subText: 'No',
                ),
                _DetailRow(
                  title: 'Occupation',
                  subText: 'Photographer',
                ),
                _DetailRow(
                  title: 'Bio',
                  subText: 'Nah, I am a computer student',
                ),
                _DetailRow(
                  title: 'Email',
                  subText: 'Samuel',
                ),
                _DetailRow(
                  title: 'Phone Number',
                  subText: '+92123456789',
                ),
                _DetailRow(
                  title: 'Gender',
                  subText: 'Male',
                ),
                _DetailRow(
                  title: 'Date of Birth',
                  subText: '00/00/0000',
                ),
                _DetailRow(
                  title: 'Country',
                  subText: 'United States',
                ),
                _DetailRow(
                  title: 'Town',
                  subText: 'Town Name',
                ),
                _DetailRow(
                  title: 'Address',
                  subText: '1234 Elm Street, Apt 56B',
                  haveDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title, subText;
  final bool? haveDivider;
  const _DetailRow({
    super.key,
    required this.title,
    required this.subText,
    this.haveDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: kInputBorderColor,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: MyText(
              text: title,
              size: 12,
              color: kQuaternaryColor,
              weight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(
            text: subText,
            size: 12,
          ),
        ],
      ),
    );
  }
}
