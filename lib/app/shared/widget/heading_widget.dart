import 'package:flutter/widgets.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';
import 'package:flutter/material.dart';

class AuthHeading extends StatelessWidget {
  final String title, subTitle;
  const AuthHeading({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            Assets.imagesLogo,
            height: 48,
            alignment: Alignment.centerLeft,
          ),
          MyText(
            text: title,
            size: 28,
            weight: FontWeight.w800,
            paddingTop: 8,
            paddingBottom: 8,
          ),
          MyText(
            text: subTitle,
            size: 13,
            color: kQuaternaryColor,
            lineHeight: 1.6,
          ),
        ],
      ),
    );
  }
}
