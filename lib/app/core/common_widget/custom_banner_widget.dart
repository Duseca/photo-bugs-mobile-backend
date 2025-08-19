import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();
  Timer? timer;

  void initBanner(int imageCount) {
    _startBannerTimer(imageCount);
  }

  void _startBannerTimer(int imageCount) {
    timer = Timer.periodic(3.seconds, (timer) {
      if (currentIndex.value < imageCount - 1) {
        currentIndex.value++;
      } else {
        currentIndex.value = 0;
      }
      pageController.animateToPage(
        currentIndex.value,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}

class CustomBanner extends StatefulWidget {
  final List<String> images;

  const CustomBanner({super.key, required this.images});

  @override
  State<CustomBanner> createState() => _CustomBannerState();
}

class _CustomBannerState extends State<CustomBanner> {
  late PageController pageController;
  late Timer timer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (currentIndex < widget.images.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      if (pageController.hasClients) {
        pageController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void dispose() {
    timer.cancel();
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
            onPageChanged: onPageChanged,
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CommonImageView(
                  imagePath: widget.images[index],
                  height: 170,
                  width: double.infinity,
                  radius: 12,
                  fit: BoxFit.cover,
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
            onDotClicked: (index) {
              setState(() {
                currentIndex = index;
              });
              pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
          ),
        ),
      ],
    );
  }
}

// You can remove the BannerController class since we're not using GetX for this widget anymore
