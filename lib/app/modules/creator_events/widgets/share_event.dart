import 'package:flutter/material.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';


import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class ShareEvent extends StatelessWidget {
  const ShareEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Event Qr Code'),
      body: Padding(
        padding: AppSizes.DEFAULT,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(
              text: "Scan this QR Code to join the event",
              size: 16,
              weight: FontWeight.w500,
              paddingBottom: 20,
            ),
            Image.asset(
              Assets.imagesQrCode,
              height: 200,
              color: kTertiaryColor,
            ),
            MyText(
              text: 'https://event.photobugs.com/Table15',
              textAlign: TextAlign.center,
              paddingTop: 20,
              paddingBottom: 8,
            ),
            Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.copy,
                  size: 16,
                  color: kSecondaryColor,
                ),
                MyText(
                  text: 'Copy Link',
                  size: 12,
                  color: kSecondaryColor,
                  weight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            MyButton(
              buttonText: 'Download QR Code',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
