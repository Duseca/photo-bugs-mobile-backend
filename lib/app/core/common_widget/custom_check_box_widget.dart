import 'package:photo_bug/app/core/constants/app_colors.dart';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCheckBox extends StatelessWidget {
  CustomCheckBox({
    Key? key,
    required this.isActive,
    required this.onTap,
    this.radius = 4,
    this.size = 18,
    this.iconSize = 12,
    this.activeColor = kSecondaryColor,
    this.iconColor = kPrimaryColor,
  }) : super(key: key);

  final bool isActive;
  final VoidCallback onTap;
  final double? radius, size, iconSize;
  final Color? activeColor, iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(radius!),
          border:
              isActive
                  ? null
                  : Border.all(width: 1.0, color: kInputBorderColor),
        ),
        child:
            !isActive
                ? SizedBox()
                : Icon(Icons.check, size: iconSize, color: iconColor),
      ),
    );
  }
}
