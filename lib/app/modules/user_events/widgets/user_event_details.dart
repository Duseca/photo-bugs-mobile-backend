import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/modules/user_events/widgets/user_image_folder_details.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_select_download.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class UserEventDetails extends StatelessWidget {
  const UserEventDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        title: 'My Events',
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(Assets.imagesShare, height: 20)],
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                CommonImageView(url: dummyImg, height: 200, radius: 8),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: '27 Sep, 2024',
                        size: 11,
                        color: kQuaternaryColor,
                        weight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(
                      text: 'Scheduled',
                      size: 12,
                      color: kSecondaryColor,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
                MyText(
                  text: 'Den & Tina wedding event',
                  weight: FontWeight.w500,
                  paddingTop: 8,
                  paddingBottom: 8,
                ),
                Row(
                  children: [
                    Image.asset(Assets.imagesLocation, height: 16),
                    Expanded(
                      child: MyText(
                        text: '385 Main Street, Suite 52, USA',
                        size: 11,
                        color: kQuaternaryColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        paddingLeft: 4,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FlutterImageStack(
                      imageList: [
                        dummyImg,
                        dummyImg,
                        dummyImg,
                        dummyImg,
                        dummyImg,
                      ],
                      showTotalCount: false,
                      totalCount: 5,
                      itemRadius: 20,
                      itemCount: 5,
                      itemBorderWidth: 2,
                      itemBorderColor: kInputBorderColor,
                    ),
                    MyText(
                      text: '5 Recipients',
                      size: 12,
                      color: kSecondaryColor,
                      weight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: kSecondaryColor,
                      paddingLeft: 4,
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: kInputBorderColor,
                  margin: EdgeInsets.symmetric(vertical: 16),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => UserImageFolderDetails());
                  },
                  child: Row(
                    children: [
                      Image.asset(Assets.imagesFolder, height: 40),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            MyText(
                              text: 'Samuel Images',
                              weight: FontWeight.w500,
                              paddingBottom: 4,
                            ),
                            MyText(
                              text: '12/09/2024  |  0 items',
                              size: 12,
                              color: kQuaternaryColor,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(Assets.imagesArrowRightIos, height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Download in Bulk',
              onTap: () {
                Get.to(() => UserSelectDownload());
              },
            ),
          ),
        ],
      ),
    );
  }
}
