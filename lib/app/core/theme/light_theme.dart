import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';

import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: kPrimaryColor,
  fontFamily: AppFonts.inter,
  appBarTheme: AppBarTheme(
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    backgroundColor: kPrimaryColor,
    elevation: 0,
  ),
  splashColor: kSecondaryColor.withOpacity(0.10),
  highlightColor: kSecondaryColor.withOpacity(0.10),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: kSecondaryColor.withOpacity(0.1),
  ),
  textSelectionTheme: TextSelectionThemeData(cursorColor: kTertiaryColor),
);
