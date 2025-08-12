import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
  MyTextField({
    Key? key,
    this.controller,
    this.label,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 16.0,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.readOnly = false,
    this.onTap,
    this.radius = 8,
    this.initialValue,
    this.hint,
    this.heading,
  }) : super(key: key);

  final String? label, hint, heading;
  TextEditingController? controller;
  ValueChanged<String>? onChanged;
  bool? isObSecure;
  double? marginBottom;
  int? maxLines;
  Widget? prefix, suffix;
  TextInputType? keyboardType;
  TextInputAction textInputAction;
  final bool? readOnly;
  final VoidCallback? onTap;
  final double? radius;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading != null
              ? MyText(
                text: heading!,
                size: 12,
                weight: FontWeight.w600,
                paddingBottom: 8,
              )
              : SizedBox(),
          TextFormField(
            onTap: onTap,
            readOnly: readOnly!,
            keyboardType: keyboardType,
            textAlignVertical:
                prefix != null || prefix != null
                    ? TextAlignVertical.center
                    : null,
            maxLines: maxLines,
            controller: controller,
            onChanged: onChanged,
            textInputAction: textInputAction,
            obscureText: isObSecure!,
            // obscuringCharacter: '*',
            initialValue: initialValue,

            // onTapOutside: (_) {
            //   FocusScope.of(context).unfocus();
            // },
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: kTertiaryColor,
              fontFamily: AppFonts.inter,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: prefix,
              suffixIcon: suffix,
              alignLabelWithHint: true,
              labelStyle: TextStyle(
                fontSize: 12,
                color: kHintColor,
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.inter,
              ),
              hintStyle: TextStyle(
                fontSize: 12,
                color: kHintColor,
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.inter,
              ),
              floatingLabelStyle: TextStyle(
                fontSize: 10,
                color: kSecondaryColor,
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.inter,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: maxLines! > 1 ? 15 : 0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius!),
                borderSide: BorderSide(color: kInputBorderColor, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius!),
                borderSide: BorderSide(color: kSecondaryColor, width: 1.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius!),
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius!),
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
