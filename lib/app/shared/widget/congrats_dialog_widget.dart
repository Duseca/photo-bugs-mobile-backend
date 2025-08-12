import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';
import 'package:photo_bug/app/shared/widget/my_button_widget.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';
import 'package:flutter/material.dart';

class CongratsDialog extends StatelessWidget {
  final String title, congratsText, btnText;
  final String? icon;
  final VoidCallback onTap;
  const CongratsDialog({
    super.key,
    this.icon = Assets.imagesCongrats,
    required this.title,
    required this.congratsText,
    required this.btnText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset(icon!, height: 120)),
              MyText(
                text: title,
                size: 22,
                weight: FontWeight.w700,
                textAlign: TextAlign.center,
                paddingTop: 16,
                paddingBottom: 8,
              ),
              MyText(
                text: congratsText,
                size: 13,
                color: kQuaternaryColor,
                textAlign: TextAlign.center,
                lineHeight: 1.6,
                paddingBottom: 16,
              ),
              MyButton(buttonText: btnText, onTap: onTap),
            ],
          ),
        ),
      ],
    );
  }
}
