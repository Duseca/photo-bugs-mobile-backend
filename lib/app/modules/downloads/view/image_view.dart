import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/authentication/screens/interest_selection_screen.dart';
import 'package:photo_bug/app/modules/downloads/controller/download_controller.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/main.dart';

class ImageView extends GetView<ImageViewController> {
  const ImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlackColor,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: _buildImageView()), _buildStatsSection()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBlackColor,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: MyRippleEffect(
              onTap: () => Get.back(),
              radius: 100,
              child: Center(
                child: Image.asset(
                  Assets.imagesBack,
                  height: 12,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      title: MyText(
        text: 'View',
        size: 16,
        color: kPrimaryColor,
        weight: FontWeight.w600,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImageView() {
    return Center(
      child: Obx(
        () => CommonImageView(
          url:
              controller.imageUrl.value.isNotEmpty
                  ? controller.imageUrl.value
                  : dummyImg,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: 'Lifetime total',
              color: kPrimaryColor,
              weight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(
            () => Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image.asset(
                  Assets.imagesDownload,
                  height: 16,
                  color: kPrimaryColor,
                ),
                MyText(
                  text: controller.lifetimeDownloads.value.toString(),
                  color: kPrimaryColor,
                  weight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => MyText(
                text:
                    '\$${controller.lifetimeEarnings.value.toStringAsFixed(0)}',
                color: kPrimaryColor,
                weight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
