import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/creator_edit_event.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/creator_image_folder_details.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/share_event.dart';

import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';


import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';
class CreatorEventDetails extends StatelessWidget {
  const CreatorEventDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        title: 'Events Details',
        actions: [
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => ShareEvent());
                },
                child: Image.asset(
                  Assets.imagesShare,
                  height: 24,
                ),
              ),
              PopupMenuButton(
                surfaceTintColor: Colors.transparent,
                color: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  Assets.imagesMenuVertical,
                  height: 20,
                ),
                itemBuilder: (ctx) {
                  return [
                    PopupMenuItem(
                      height: 36,
                      onTap: () {
                        Get.to(() => CreatorEditEvent());
                      },
                      child: MyText(
                        text: 'Edit Event',
                        size: 12,
                      ),
                    ),
                    PopupMenuItem(
                      height: 36,
                      onTap: () {
                        Get.dialog(
                          CustomDialog(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  MyText(
                                    text: 'Are you sure you want to delete?',
                                    size: 18,
                                    weight: FontWeight.w700,
                                    textAlign: TextAlign.center,
                                    paddingBottom: 16,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MyButton(
                                          radius: 5,
                                          borderWidth: 1,
                                          bgColor: Colors.transparent,
                                          textColor: kSecondaryColor,
                                          borderColor: kInputBorderColor,
                                          splashColor:
                                              kSecondaryColor.withOpacity(0.1),
                                          buttonText: 'No',
                                          onTap: () {
                                            Get.back();
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        child: MyButton(
                                          radius: 5,
                                          borderWidth: 1,
                                          bgColor: kRedColor,
                                          textColor: kPrimaryColor,
                                          buttonText: 'Yes, Delete',
                                          onTap: () {
                                            Get.back();
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: MyText(
                        text: 'Delete Event',
                        size: 12,
                      ),
                    ),
                    PopupMenuItem(
                      height: 36,
                      onTap: () {
                        Get.dialog(CustomDialog(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MyText(
                                  text: 'Close this Event?',
                                  size: 18,
                                  weight: FontWeight.w700,
                                  textAlign: TextAlign.center,
                                  paddingBottom: 16,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyButton(
                                        radius: 5,
                                        borderWidth: 1,
                                        bgColor: Colors.transparent,
                                        textColor: kSecondaryColor,
                                        borderColor: kInputBorderColor,
                                        splashColor:
                                            kSecondaryColor.withOpacity(0.1),
                                        buttonText: 'No',
                                        onTap: () {
                                          Get.back();
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24,
                                    ),
                                    Expanded(
                                      child: MyButton(
                                        radius: 5,
                                        borderWidth: 1,
                                        bgColor: kRedColor,
                                        textColor: kPrimaryColor,
                                        buttonText: 'Yes',
                                        onTap: () {
                                          Get.back();
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ));
                      },
                      child: MyText(
                        text: 'Close Event',
                        size: 12,
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                CommonImageView(
                  url: dummyImg,
                  height: 200,
                  radius: 8,
                ),
                SizedBox(
                  height: 8,
                ),
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
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Den & Tina wedding event',
                        weight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(
                      text: '\$250',
                      size: 16,
                      color: kSecondaryColor,
                      weight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Image.asset(
                      Assets.imagesLocation,
                      height: 16,
                    ),
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
                SizedBox(
                  height: 8,
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
                MyText(
                  text: 'Event Timings',
                  weight: FontWeight.w500,
                  paddingBottom: 8,
                ),
                Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Image.asset(
                      Assets.imagesClock,
                      height: 16,
                    ),
                    MyText(
                      text: 'Start Time',
                      size: 12,
                      color: kQuaternaryColor,
                    ),
                    MyText(
                      text: '02:30 PM',
                      size: 12,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Image.asset(
                      Assets.imagesClock,
                      height: 16,
                    ),
                    MyText(
                      text: 'End Time',
                      size: 12,
                      color: kQuaternaryColor,
                    ),
                    MyText(
                      text: '04:30 PM',
                      size: 12,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: kInputBorderColor,
                  margin: EdgeInsets.symmetric(vertical: 16),
                ),
                ...List.generate(2, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => CreatorImageFolderDetails());
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            Assets.imagesFolder,
                            height: 40,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MyText(
                                  text: index == 0 ? 'Table 15' : 'Table 16',
                                  weight: FontWeight.w500,
                                  paddingBottom: 4,
                                ),
                                MyText(
                                  text: '12/09/2024  |  4 items',
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
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              borderWidth: 1,
              bgColor: Colors.transparent,
              textColor: kSecondaryColor,
              splashColor: kSecondaryColor.withValues(alpha: 0.1),
              buttonText: 'Create New Folder',
              onTap: () {
                // Get.to(() => CreatorAddNewFolder());
              },
            ),
          ),
        ],
      ),
    );
  }
}
