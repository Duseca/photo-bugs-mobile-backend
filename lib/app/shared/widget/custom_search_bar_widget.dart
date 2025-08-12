import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    this.hint,
    this.readOnly = false,
    this.onTap,
    this.controller,
    this.onChanged,
    this.validator,
  });

  final String? hint;
  final bool? readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        readOnly: readOnly!,
        onTap: onTap,
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        cursorColor: kTertiaryColor,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        // onTapOutside: (_) {
        //   FocusScope.of(context).unfocus();
        // },
        style: TextStyle(
          fontSize: 12,
          color: kTertiaryColor,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.inter,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12,
            color: kHintColor,
            fontWeight: FontWeight.w400,
            fontFamily: AppFonts.inter,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          prefixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(Assets.imagesSearch, height: 18)],
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: kInputBorderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: kSecondaryColor, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
        ),
      ),
    );
  }
}
