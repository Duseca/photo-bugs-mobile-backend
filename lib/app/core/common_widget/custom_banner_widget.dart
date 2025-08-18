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

class CustomBanner extends StatelessWidget {
  final List<String> images;

  const CustomBanner({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    // Create controller and initialize banner
    final controller = Get.put(BannerController(), tag: images.hashCode.toString());
    controller.initBanner(images.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: controller.pageController,
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CommonImageView(
                  imagePath: images[index],
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
          child: Obx(() => SmoothPageIndicator(
            controller: controller.pageController,
            axisDirection: Axis.horizontal,
            count: images.length,
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
          )),
        ),
      ],
    );
  }
}