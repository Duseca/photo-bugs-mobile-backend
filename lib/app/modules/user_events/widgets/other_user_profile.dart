import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/chat/views/chat_screen.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class OtherUserProfile extends StatelessWidget {
  const OtherUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Details'),
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
                      CommonImageView(
                        url: dummyImg,
                        height: 86,
                        width: 86,
                        radius: 100,
                        borderWidth: 4,
                        borderColor: kInputBorderColor,
                      ),
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
                MyText(
                  text: 'Mark',
                  size: 16,
                  weight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  paddingTop: 16,
                  paddingBottom: 8,
                ),
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
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    Image.asset(
                      Assets.imagesLocation,
                      height: 14,
                      color: kSecondaryColor,
                    ),
                    MyText(text: 'Pakistan, Islamabad', size: 12),
                  ],
                ),
                SizedBox(height: 16),
                MyButton(
                  buttonText: 'Message',
                  onTap: () {
                    Get.to(() => ChatScreen());
                  },
                ),
                MyText(
                  text: 'About',
                  weight: FontWeight.w600,
                  paddingTop: 16,
                  paddingBottom: 12,
                ),
                MyText(
                  text:
                      'I\'m a full-time photographer based in NYC. I shoot portraits, weddings, lifestyle, and events throughout the USA and all over the world. I strive to capture sincere emotions and bring timeless approach to my work.',
                  size: 12,
                  color: kQuaternaryColor,
                  paddingBottom: 16,
                ),
                MyText(
                  text: 'Portfolio',
                  weight: FontWeight.w600,
                  paddingBottom: 12,
                ),
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
                _ReviewCard(
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

class _ReviewCard extends StatelessWidget {
  final String profileImage, name, reviewText, time;
  final double rating;
  const _ReviewCard({
    super.key,
    required this.profileImage,
    required this.name,
    required this.reviewText,
    required this.time,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kInputBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RatingBar(
                initialRating: rating,
                itemSize: 16,
                itemCount: 5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                ignoreGestures: true,
                updateOnDrag: false,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                ratingWidget: RatingWidget(
                  full: Image.asset(Assets.imagesStar, color: kSecondaryColor),
                  half: Image.asset(Assets.imagesStar),
                  empty: Image.asset(
                    Assets.imagesStar,
                    color: Colors.grey.shade300,
                  ),
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                },
              ),
              Expanded(
                child: MyText(
                  text: time,
                  size: 12,
                  color: kQuaternaryColor,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          MyText(
            text: reviewText,
            size: 13,
            color: kQuaternaryColor,
            paddingTop: 8,
            paddingBottom: 8,
          ),
          Row(
            children: [
              CommonImageView(
                url: profileImage,
                height: 32,
                width: 32,
                radius: 100,
              ),
              Expanded(
                child: MyText(
                  text: name,
                  size: 12,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  paddingLeft: 8,
                ),
              ),
            ],
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
          return _ReviewCard(
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
