import 'package:photo_bug/app/core/constants/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:pinput/pinput.dart';

class AppStyling {
  static final cardDecoration = BoxDecoration(
    color: kWhiteColor,
    borderRadius: BorderRadius.circular(12),
  );
  static final cardDecoration2 = BoxDecoration(
    color: kWhiteColor,
    borderRadius: BorderRadius.circular(8),
  );

  static final defaultPinTheme = PinTheme(
    height: 56,
    width: 48,
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    textStyle: TextStyle(
      fontSize: 24,
      color: kTertiaryColor,
      fontWeight: FontWeight.w500,
      fontFamily: AppFonts.inter,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        width: 1.0,
        color: kInputBorderColor,
      ),
    ),
  );
  static final focusPinTheme = PinTheme(
    height: 56,
    width: 48,
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    textStyle: TextStyle(
      fontSize: 24,
      color: kSecondaryColor,
      fontWeight: FontWeight.w500,
      fontFamily: AppFonts.inter,
    ),
    decoration: BoxDecoration(
      color: kSecondaryColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        width: 1.0,
        color: kSecondaryColor,
      ),
    ),
  );
}
