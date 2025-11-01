import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/models/image_detail_model/image_detail_model.dart';
import 'package:photo_bug/app/modules/image_detail/controller/image_detail_controller.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class ImageDetails extends GetView<ImageDetailsController> {
  const ImageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading image details...'),
              ],
            ),
          );
        }

        if (controller.imageDetail.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Failed to load image details'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshImageDetails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return _buildBody();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return simpleAppBar(
      title: 'View details',
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  onTap: controller.toggleFavorite,
                  child: Obx(
                    () => Icon(
                      controller.isFavorite.value
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      size: 22,
                      color:
                          controller.isFavorite.value ? kSecondaryColor : null,
                    ),
                  ),
                ),
                PopupMenuButton(
                  surfaceTintColor: Colors.transparent,
                  color: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(Assets.imagesMenuHorizontal, height: 20),
                  itemBuilder: (ctx) {
                    return [
                      PopupMenuItem(
                        height: 36,
                        onTap: controller.shareProfile,
                        child: MyText(text: 'Share Photo', size: 12),
                      ),
                      PopupMenuItem(
                        height: 36,
                        onTap: controller.reportUser,
                        child: MyText(text: 'Report Photo', size: 12),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildBody() {
    final imageDetail = controller.imageDetail.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshImageDetails,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Main Image
                CommonImageView(
                  url: imageDetail.imageUrl,
                  height: 270,
                  width: Get.width,
                ),

                Padding(
                  padding: AppSizes.DEFAULT,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildAuthorSection(imageDetail),
                      _buildTitle(imageDetail),
                      _buildPhotoInfo(imageDetail),
                      _buildKeywords(),
                      const SizedBox(height: 80), // Space for bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildPurchaseButton(imageDetail),
      ],
    );
  }

  Widget _buildAuthorSection(ImageDetail imageDetail) {
    return Row(
      children: [
        GestureDetector(
          onTap: controller.openAuthorProfile,
          child: CommonImageView(
            url: imageDetail.authorImage,
            height: 32,
            width: 32,
            radius: 100,
          ),
        ),
        Expanded(
          child: MyText(
            text: imageDetail.authorName,
            size: 12,
            weight: FontWeight.w500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            paddingLeft: 8,
            onTap: controller.openAuthorProfile,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kSecondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.imagesEyeOutline, height: 16),
              const SizedBox(width: 4),
              MyText(
                text: imageDetail.viewCount.toString(),
                size: 12,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ImageDetail imageDetail) {
    return MyText(
      text: imageDetail.title,
      size: 14,
      weight: FontWeight.w600,
      paddingTop: 16,
      paddingBottom: 24,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPhotoInfo(ImageDetail imageDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(
          text: 'Photo Info',
          size: 16,
          weight: FontWeight.w600,
          paddingBottom: 16,
        ),
        ...imageDetail.metadata.detailsList.map(
          (detail) => DetailsTile(title: detail.title, subText: detail.subText),
        ),
      ],
    );
  }

  Widget _buildKeywords() {
    return Obx(() {
      final visibleKeywords = controller.visibleKeywords;
      final additionalCount = controller.additionalKeywordsCount;

      if (visibleKeywords.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Keywords',
            size: 16,
            weight: FontWeight.w600,
            paddingTop: 24,
            paddingBottom: 16,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...visibleKeywords.map((keyword) => _buildKeywordChip(keyword)),
              if (additionalCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: MyText(
                    text: '+$additionalCount',
                    size: 13,
                    weight: FontWeight.w500,
                    color: kSecondaryColor,
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildKeywordChip(String keyword) {
    return IntrinsicWidth(
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(width: 1.0, color: kInputBorderColor),
        ),
        child: Center(
          child: MyText(
            text: keyword,
            size: 13,
            color: kTertiaryColor,
            paddingLeft: 16,
            paddingRight: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(ImageDetail imageDetail) {
    // Check if photo is free
    final isFree = imageDetail.price == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: AppSizes.DEFAULT,
        child: SafeArea(
          child: MyButton(
            buttonText:
                isFree
                    ? 'Download for Free'
                    : 'Purchase for \$${imageDetail.price.toStringAsFixed(0)}',
            onTap: controller.purchaseImage,
          ),
        ),
      ),
    );
  }
}

/// Details Tile Widget
class DetailsTile extends StatelessWidget {
  final String title, subText;

  const DetailsTile({super.key, required this.title, required this.subText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: title,
              size: 12,
              color: kTertiaryColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          MyText(
            text: subText,
            size: 12,
            weight: FontWeight.w500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
