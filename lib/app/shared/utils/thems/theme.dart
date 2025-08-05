// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'my_colors.dart';

ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: MyColors.appColor1,
    scaffoldBackgroundColor: MyColors.white,
    appBarTheme: const AppBarTheme(
        centerTitle: false, elevation: 0, color: MyColors.appColor1),
    iconTheme: const IconThemeData(color: MyColors.black),
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: MyColors.textColor),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateColor.resolveWith(
          (states) => MyColors.lightContainerColor),
      overlayColor:
          WidgetStateColor.resolveWith((states) => MyColors.themeOrangeColor),
    ),
    colorScheme: const ColorScheme.light(
        primary: MyColors.textColor,
        onPrimary: MyColors.themeOrangeColor,
        secondary: MyColors.textLightColor,
        primaryContainer: MyColors.lightContainerColor,
        secondaryContainer: MyColors.black,
        error: MyColors.red),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 1,
      backgroundColor: MyColors.lightContainerColor,
      selectedItemColor: MyColors.textColor,
      unselectedItemColor: MyColors.textLightColor,
      selectedIconTheme: IconThemeData(color: MyColors.textLightColor),
      showUnselectedLabels: true,
    ),
  );
}
//
// ThemeData darkThemeData(BuildContext context) {
//   return ThemeData.dark().copyWith(
//     primaryColor: MyColors.darkThemeColor,
//     scaffoldBackgroundColor: MyColors.darkThemeColor,
//     appBarTheme:const AppBarTheme(centerTitle: false, elevation: 0, color: MyColors.darkThemeColor),
//     iconTheme: const IconThemeData(color: MyColors.darkLightTextColor),
//     textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
//         .apply(bodyColor: MyColors.darkTextColor),
//     colorScheme: const ColorScheme.dark().copyWith(
//       primary: MyColors.darkTextColor ,
//       onPrimary: MyColors.darkButtonTextColor,
//       secondary: MyColors.darkLightTextColor,
//       primaryContainer: MyColors.darkContainerColor,
//       secondaryContainer:MyColors.white,
//       error:MyColors.red,
//     ),
//     bottomNavigationBarTheme: BottomNavigationBarThemeData(
//       elevation: 1.h,
//       backgroundColor: MyColors.darkContainerColor,
//       selectedItemColor: MyColors.darkTitleColor,
//       unselectedItemColor: MyColors.darkLightTextColor,
//       selectedIconTheme: const IconThemeData(color: MyColors.darkTitleColor),
//       showUnselectedLabels: true,
//     ),
//   );
// }

