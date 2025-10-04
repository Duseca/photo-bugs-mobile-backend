import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/settings/portfolio/edit_portfolio.dart';
import 'package:photo_bug/app/modules/settings/profile/edit_profile.dart';
import 'package:photo_bug/app/modules/settings/settings/settings.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/modules/settings/profile/controller/profile_controller.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/review_card_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ProfileController instance
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Expanded(
              child: MyText(
                text: 'Profile',
                size: 18,
                color: kTertiaryColor,
                weight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => Settings());
              },
              child: Image.asset(Assets.imagesSetting, height: 24),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: AppSizes.VERTICAL,
        children: [
          Padding(
            padding: AppSizes.HORIZONTAL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      // Use user's profile picture from ProfileController
                      Obx(() {
                        final user = profileController.currentUser;
                        print(user?.toJson());
                        return CommonImageView(
                          url: user?.profilePicture ?? dummyImg,
                          height: 86,
                          width: 86,
                          radius: 100,
                          borderWidth: 4,
                          borderColor: kInputBorderColor,
                        );
                      }),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Image.asset(
                          Assets.imagesOnlineIndicator,
                          height: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Display user's name from ProfileController
                Obx(() {
                  final user = profileController.currentUser;
                  return MyText(
                    text: user?.name ?? 'Mark',
                    size: 16,
                    weight: FontWeight.w600,
                    textAlign: TextAlign.center,
                    paddingTop: 16,
                    paddingBottom: 8,
                  );
                }),
                Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    Image.asset(
                      Assets.imagesStar,
                      height: 16,
                      color: kSecondaryColor,
                    ),
                    MyText(text: '5.0 (32)', weight: FontWeight.w500),
                  ],
                ),
                MyText(
                  text: 'Bio',
                  weight: FontWeight.w600,
                  paddingTop: 16,
                  paddingBottom: 12,
                ),
                // Display user's bio from ProfileController
                Obx(() {
                  final user = profileController.currentUser;
                  return MyText(
                    text: user?.bio?.isNotEmpty == true ? user!.bio! : '',
                    size: 12,
                    color: kQuaternaryColor,
                    paddingBottom: 16,
                  );
                }),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Portfolio',
                        weight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(
                      text: 'Edit',
                      size: 12,
                      color: kSecondaryColor,
                      weight: FontWeight.w500,
                      onTap: () {
                        Get.to(() => EditPortfolio());
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          SizedBox(
            height: 240,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemExtent: 240,
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CommonImageView(url: dummyImg, radius: 8),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: AppSizes.HORIZONTAL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: MyText(
                        text: 'Reviews',
                        weight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        paddingRight: 8,
                      ),
                    ),
                    Image.asset(
                      Assets.imagesStar,
                      height: 16,
                      color: kSecondaryColor,
                    ),
                    MyText(
                      text: '5.0 (8)',
                      size: 12,
                      color: kQuaternaryColor,
                      paddingLeft: 4,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ReviewCard(
                  profileImage: dummyImg,
                  name: 'Thomas T',
                  reviewText:
                      'Amazing work in capturing the essence of Shelter Cove. Beautiful views were perfectly highlighted and the specific',
                  time: '3 minutes ago',
                  rating: 5.0,
                ),
                SizedBox(height: 16),
                MyButton(
                  borderWidth: 1,
                  bgColor: Colors.transparent,
                  textColor: kSecondaryColor,
                  splashColor: kSecondaryColor.withOpacity(0.1),
                  buttonText: 'Show All (8) Reviews',
                  onTap: () {
                    Get.to(() => _AllReviews());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllReviews extends StatelessWidget {
  const _AllReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Reviews'),
      body: ListView.builder(
        padding: AppSizes.DEFAULT,
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          return ReviewCard(
            profileImage: dummyImg,
            name: 'Thomas T',
            reviewText:
                'Amazing work in capturing the essence of Shelter Cove. Beautiful views were perfectly highlighted and the specific',
            time: '3 minutes ago',
            rating: 5.0,
          );
        },
      ),
    );
  }
}
