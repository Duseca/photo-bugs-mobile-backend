import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';

import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class PaymentMethodTile extends StatelessWidget {
  final String icon, title;
  final bool isSelected;
  final VoidCallback onTap;
  const PaymentMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 48,
      duration: 220.milliseconds,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kInputBorderColor),
      ),
      child: MyRippleEffect(
        onTap: onTap,
        radius: 8,
        splashColor: kSecondaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Image.asset(icon, height: 24),
              Expanded(
                child: MyText(
                  text: title,
                  weight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  paddingLeft: 12,
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? kSecondaryColor : kInputBorderColor,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: AnimatedContainer(
                            width: 10,
                            height: 10,
                            duration: 220.milliseconds,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kSecondaryColor,
                            ),
                          ),
                        )
                        : SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
