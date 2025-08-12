import 'package:flutter/widgets.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.radius = 24,
  });

  final Widget child;
  final double? height, radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? Get.height * 0.5,
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Image.asset(Assets.imagesLineBar, height: 4)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
