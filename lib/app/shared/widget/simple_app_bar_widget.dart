import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';
import 'package:photo_bug/app/shared/widget/my_button_widget.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

AppBar simpleAppBar({
  required String title,
  Color? bgColor = kPrimaryColor,
  bool? haveLeading = true,
  List<Widget>? actions,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: bgColor,
    titleSpacing: 0,
    leading:
        haveLeading!
            ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: MyRippleEffect(
                    onTap: () {
                      Get.back();
                    },
                    radius: 100,
                    splashColor: kSecondaryColor.withOpacity(0.1),
                    child: Center(
                      child: Image.asset(Assets.imagesBack, height: 12),
                    ),
                  ),
                ),
              ],
            )
            : null,
    title: MyText(
      text: title,
      size: 16,
      color: kTertiaryColor,
      weight: FontWeight.w600,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    actions: actions,
  );
}

AppBar authAppBar({required String title, bool? haveLeading = true}) {
  return AppBar(
    automaticallyImplyLeading: false,
    centerTitle: true,
    shape: Border(bottom: BorderSide(color: kInputBorderColor)),
    leading:
        haveLeading!
            ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: MyRippleEffect(
                    onTap: () {
                      Get.back();
                    },
                    radius: 100,
                    splashColor: kSecondaryColor.withOpacity(0.1),
                    child: Center(
                      child: Image.asset(Assets.imagesBack, height: 12),
                    ),
                  ),
                ),
              ],
            )
            : null,
    title: MyText(
      text: title,
      size: 16,
      color: kTertiaryColor,
      weight: FontWeight.w500,
    ),
  );
}
