import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/widget/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onToggle;

  const SwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: title,
              size: 14,
              weight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          FlutterSwitch(
            height: 22,
            width: 40,
            toggleSize: 20,
            padding: 1.5,
            activeColor: kSecondaryColor,
            inactiveColor: kGreyColor2,
            toggleColor: kWhiteColor,
            value: value,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }
}
