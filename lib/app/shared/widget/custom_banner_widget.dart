import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/shared/constants/app_colors.dart';
import 'package:photo_bug/app/shared/widget/common_image_view_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomBanner extends StatefulWidget {
  final List<String> images;

  const CustomBanner({super.key, required this.images});

  @override
  State<CustomBanner> createState() => _CustomBannerState();
}

class _CustomBannerState extends State<CustomBanner> {
  int currentIndex = 0;

  final PageController pageController = PageController();
  Timer? timer;

  void _bannerHandler() {
    timer = Timer.periodic(3.seconds, (timer) {
      if (currentIndex < widget.images.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      pageController.animateToPage(
        currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _bannerHandler();
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            onPageChanged: (v) {
              setState(() {
                currentIndex = v;
              });
            },
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CommonImageView(
                  // url: ,
                  imagePath: widget.images[index],
                  height: Get.height,
                  width: Get.width,
                  radius: 12,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12),
        Center(
          child: SmoothPageIndicator(
            controller: pageController,
            axisDirection: Axis.horizontal,
            count: widget.images.length,
            effect: ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              spacing: 6,
              expansionFactor: 2,
              radius: 8,
              activeDotColor: kTertiaryColor,
              dotColor: kTertiaryColor.withOpacity(0.2),
            ),
            onDotClicked: (index) {},
          ),
        ),
      ],
    );
  }
}
