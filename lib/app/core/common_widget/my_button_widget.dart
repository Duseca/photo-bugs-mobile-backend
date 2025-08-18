import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  MyButton({
    required this.buttonText,
    required this.onTap,
    this.bgColor = kSecondaryColor,
    this.textColor = kTertiaryColor,
    this.borderColor = kSecondaryColor,
    this.weight = FontWeight.w600,
    this.height = 48,
    this.textSize = 16,
    this.radius = 8,
    this.borderWidth = 0.0,
    this.splashColor,
    this.child,
    this.horizontalPadding = 0,
    this.width,
    this.isLoading = false, // 👈 added
    this.loaderColor = Colors.white, // 👈 added
  });

  final String buttonText;
  final VoidCallback onTap;
  final double? height, width, textSize, radius, borderWidth, horizontalPadding;
  final Color? bgColor, textColor, borderColor, splashColor, loaderColor;
  final FontWeight? weight;
  final Widget? child;
  final bool isLoading; // 👈 added

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius!),
        border:
            borderWidth == 0
                ? null
                : Border.all(width: borderWidth!, color: borderColor!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap, // 👈 disable tap when loading
          splashColor: splashColor ?? kBlackColor.withOpacity(0.1),
          highlightColor: splashColor ?? kBlackColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(radius!),
          child: Center(
            child:
                isLoading
                    ? SizedBox(
                      height: textSize! + 4,
                      width: textSize! + 4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(loaderColor!),
                      ),
                    )
                    : (child ??
                        MyText(
                          text: buttonText,
                          size: textSize,
                          weight: weight,
                          color: textColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          paddingLeft: horizontalPadding,
                          paddingRight: horizontalPadding,
                        )),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyRippleEffect extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  Color? splashColor;
  double? radius;
  MyRippleEffect({
    super.key,
    required this.child,
    required this.onTap,
    this.splashColor,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor ?? kBlackColor.withOpacity(0.1),
        highlightColor: splashColor ?? kBlackColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radius!),
        child: child,
      ),
    );
  }
}
