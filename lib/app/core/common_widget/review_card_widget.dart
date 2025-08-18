import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';

import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class ReviewCard extends StatelessWidget {
  final String profileImage, name, reviewText, time;
  final double rating;
  const ReviewCard({
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
