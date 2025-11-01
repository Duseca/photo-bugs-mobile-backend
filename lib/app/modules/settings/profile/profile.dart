import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/settings/portfolio/edit_portfolio.dart';
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
    // Get or create ProfileController - it will handle all services
    final ProfileController controller = Get.put(ProfileController());

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
      body: RefreshIndicator(
        onRefresh: controller.refreshAllProfileData,
        child: ListView(
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
                        // User's profile picture
                        Obx(() {
                          final user = controller.currentUser;

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
                  // User's name
                  Obx(() {
                    final user = controller.currentUser;
                    return MyText(
                      text: user?.name ?? 'Mark',
                      size: 16,
                      weight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      paddingTop: 16,
                      paddingBottom: 8,
                    );
                  }),
                  // Rating section - using controller bridge
                  Obx(() {
                    final averageRating = controller.averageRating;
                    final reviewCount = controller.reviewCount;

                    return Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Image.asset(
                          Assets.imagesStar,
                          height: 16,
                          color: kSecondaryColor,
                        ),
                        MyText(
                          text:
                              '${averageRating > 0 ? averageRating.toStringAsFixed(1) : '0.0'} ($reviewCount)',
                          weight: FontWeight.w500,
                        ),
                      ],
                    );
                  }),
                  MyText(
                    text: 'Bio',
                    weight: FontWeight.w600,
                    paddingTop: 16,
                    paddingBottom: 12,
                  ),
                  // User's bio
                  Obx(() {
                    final user = controller.currentUser;
                    return MyText(
                      text:
                          user?.bio?.isNotEmpty == true
                              ? user!.bio!
                              : 'no bio available',
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
            // Portfolio images - using controller bridge
            Obx(() {
              final images = controller.portfolioImages;
              final isLoading = controller.isPortfolioLoading;

              if (isLoading) {
                return SizedBox(
                  height: 240,
                  child: Center(
                    child: CircularProgressIndicator(color: kSecondaryColor),
                  ),
                );
              }

              if (images.isEmpty) {
                return SizedBox(
                  height: 240,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 48,
                          color: kQuaternaryColor,
                        ),
                        SizedBox(height: 8),
                        MyText(
                          text: 'No portfolio images yet',
                          color: kQuaternaryColor,
                          size: 14,
                        ),
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Get.to(() => EditPortfolio()),
                          child: MyText(
                            text: 'Add Images',
                            color: kSecondaryColor,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 240,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemExtent: 240,
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) {
                    final imageUrl = images[index].url;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CommonImageView(url: imageUrl, radius: 8),
                    );
                  },
                ),
              );
            }),
            SizedBox(height: 20),
            Padding(
              padding: AppSizes.HORIZONTAL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Reviews header - using controller bridge
                  Obx(() {
                    final averageRating = controller.averageRating;
                    final reviewCount = controller.reviewCount;

                    return Row(
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
                          text:
                              '${averageRating > 0 ? averageRating.toStringAsFixed(1) : '0.0'} ($reviewCount)',
                          size: 12,
                          color: kQuaternaryColor,
                          paddingLeft: 4,
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 24),
                  // Latest review - using controller bridge
                  Obx(() {
                    final isLoading = controller.isReviewsLoading;

                    if (isLoading) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: kSecondaryColor,
                          ),
                        ),
                      );
                    }

                    final reviews = controller.receivedReviews;

                    if (reviews.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 48,
                                color: kQuaternaryColor,
                              ),
                              SizedBox(height: 8),
                              MyText(
                                text: 'No reviews yet',
                                color: kQuaternaryColor,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Show latest review
                    final latestReview = reviews.first;
                    final timeAgo = controller.getTimeAgo(
                      latestReview.createdAt,
                    );

                    return ReviewCard(
                      profileImage:
                          latestReview.reviewerProfilePicture ?? dummyImg,
                      name: latestReview.reviewerName ?? 'Anonymous',
                      reviewText: latestReview.comment ?? 'No comment',
                      time: timeAgo,
                      rating: latestReview.ratings.toDouble(),
                    );
                  }),
                  SizedBox(height: 16),
                  // Show all reviews button
                  Obx(() {
                    final reviewCount = controller.reviewCount;

                    if (reviewCount == 0) return SizedBox.shrink();

                    return MyButton(
                      borderWidth: 1,
                      bgColor: Colors.transparent,
                      textColor: kSecondaryColor,
                      splashColor: kSecondaryColor.withOpacity(0.1),
                      buttonText: 'Show All ($reviewCount) Reviews',
                      onTap: () {
                        Get.to(() => _AllReviews());
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllReviews extends StatelessWidget {
  const _AllReviews({super.key});

  @override
  Widget build(BuildContext context) {
    // Use existing ProfileController
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: simpleAppBar(title: 'Reviews'),
      body: Obx(() {
        final isLoading = controller.isReviewsLoading;

        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(color: kSecondaryColor),
          );
        }

        final reviews = controller.receivedReviews;

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 64,
                  color: kQuaternaryColor,
                ),
                SizedBox(height: 16),
                MyText(
                  text: 'No reviews yet',
                  color: kQuaternaryColor,
                  size: 16,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshReviews,
          child: ListView.builder(
            padding: AppSizes.DEFAULT,
            itemCount: reviews.length,
            itemBuilder: (BuildContext context, int index) {
              final review = reviews[index];
              final timeAgo = controller.getTimeAgo(review.createdAt);

              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ReviewCard(
                  profileImage: review.reviewerProfilePicture ?? dummyImg,
                  name: review.reviewerName ?? 'Anonymous',
                  reviewText: review.comment ?? 'No comment',
                  time: timeAgo,
                  rating: review.ratings.toDouble(),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
