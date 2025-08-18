
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomChatBubbles extends StatelessWidget {
  CustomChatBubbles({
    Key? key,
    required this.isMe,
    required this.profileImage,
    required this.name,
    required this.msg,
  }) : super(key: key);
  final String name;
  final String msg;
  final bool isMe;
  final String profileImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        // mainAxisAlignment:
        //     isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CommonImageView(
                url: profileImage,
                height: 32,
                width: 32,
                radius: 100,
                borderWidth: 1,
                borderColor: kInputBorderColor,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Image.asset(Assets.imagesOnlineIndicator, height: 6),
              ),
            ],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyText(
                  text: name,
                  size: 12,
                  weight: FontWeight.w600,
                  paddingBottom: 4,
                ),
                MyText(text: '$msg', size: 12, color: kTertiaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
