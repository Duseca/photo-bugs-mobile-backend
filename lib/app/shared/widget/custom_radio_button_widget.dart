import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  const CustomRadioButton({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? kSecondaryColor : kPrimaryColor,
          ),
        ),
        child:
            isSelected
                ? Center(
                  child: AnimatedContainer(
                    width: 10,
                    height: 10,
                    duration: Duration(microseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kSecondaryColor,
                    ),
                  ),
                )
                : SizedBox(),
      ),
    );
  }
}
