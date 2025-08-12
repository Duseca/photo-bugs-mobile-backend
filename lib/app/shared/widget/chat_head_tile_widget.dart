import 'package:flutter/material.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';
import 'package:photo_bug/app/shared/widget/common_image_view_widget.dart';
import 'package:photo_bug/app/shared/widget/my_button_widget.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';

class ChatHeadTile extends StatelessWidget {
  final String image, name, lastMsg, time;
  final bool? isOnline, isNewMessage;
  final VoidCallback onTap;

  const ChatHeadTile({
    required this.image,
    required this.name,
    required this.lastMsg,
    required this.time,
    required this.onTap,
    this.isNewMessage = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: MyRippleEffect(
        onTap: onTap,
        splashColor: kSecondaryColor.withOpacity(0.1),
        radius: 8,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CommonImageView(
                    url: image,
                    height: 40,
                    width: 40,
                    radius: 100,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(
                      isOnline!
                          ? Assets.imagesOnlineIndicator
                          : Assets.imagesOfflineIndicator,
                      height: 10,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MyText(
                            text: name,
                            size: 14,
                            weight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        MyText(
                          text: isNewMessage! ? 'Now' : time,
                          size: 12,
                          color:
                              isNewMessage!
                                  ? kSecondaryColor
                                  : kQuaternaryColor,
                        ),
                      ],
                    ),
                    MyText(
                      text: lastMsg,
                      size: 12,
                      color: isNewMessage! ? kTertiaryColor : kQuaternaryColor,
                      weight: isNewMessage! ? FontWeight.w500 : FontWeight.w400,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      paddingTop: 4,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
