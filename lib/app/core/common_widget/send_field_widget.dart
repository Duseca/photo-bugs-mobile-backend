import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:flutter/material.dart';


class SendField extends StatelessWidget {
  SendField({
    Key? key,
    this.controller,
    this.onChanged,
    this.onAttach,
    this.onMic,
    this.onFieldSubmitted,
  }) : super(key: key);

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  final VoidCallback? onAttach, onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSizes.DEFAULT,
      color: kInputBorderColor,
      child: Row(
        children: [
          GestureDetector(
            onTap: onAttach,
            child: Image.asset(Assets.imagesAttach, height: 40),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 12,
                color: kTertiaryColor,
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.inter,
              ),
              decoration: InputDecoration(
                hintText: 'Message',
                fillColor: kPrimaryColor,
                filled: true,
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: kHintColor,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.inter,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
                constraints: BoxConstraints(maxHeight: 40),
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onMic,
                      child: Image.asset(Assets.imagesMic, height: 20),
                    ),
                  ],
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
          // SizedBox(
          //   width: 8,
          // ),
          // GestureDetector(
          //   onTap: onSend,
          //   child: CircleAvatar(
          //     radius: 20,
          //     backgroundColor: kSecondaryColor,
          //     child: Center(
          //       child: Icon(
          //         Icons.send,
          //         color: kPrimaryColor,
          //         size: 18,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
