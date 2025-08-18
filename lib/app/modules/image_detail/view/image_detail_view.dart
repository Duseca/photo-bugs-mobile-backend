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
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.imageDetail.value == null) {
          return const Center(child: Text('Failed to load image details'));
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
                        child: MyText(text: 'Share Profile', size: 12),
                      ),
                      PopupMenuItem(
                        height: 36,
                        onTap: controller.reportUser,
                        child: MyText(text: 'Report User', size: 12),
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CommonImageView(url: imageDetail.imageUrl, height: 240),
              Padding(
                padding: AppSizes.DEFAULT,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAuthorSection(imageDetail),
                    _buildTitle(imageDetail),
                    _buildPhotoInfo(imageDetail),
                    _buildKeywords(),
                  ],
                ),
              ),
            ],
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            paddingLeft: 8,
            onTap: controller.openAuthorProfile,
          ),
        ),
        MyText(
          text: imageDetail.viewCount.toString(),
          size: 12,
          paddingRight: 4,
        ),
        Image.asset(Assets.imagesEyeOutline, height: 20),
      ],
    );
  }

  Widget _buildTitle(ImageDetail imageDetail) {
    return MyText(
      text: imageDetail.title,
      size: 12,
      weight: FontWeight.w500,
      paddingTop: 8,
      paddingBottom: 24,
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
          paddingRight: 4,
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Keywords',
            size: 16,
            weight: FontWeight.w600,
            paddingTop: 16,
            paddingBottom: 16,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...visibleKeywords.map((keyword) => _buildKeywordChip(keyword)),
              if (additionalCount > 0)
                MyText(
                  text: '+$additionalCount',
                  size: 13,
                  color: kTertiaryColor,
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
    return Padding(
      padding: AppSizes.DEFAULT,
      child: MyButton(
        buttonText: 'Purchase for \$${imageDetail.price.toStringAsFixed(0)}',
        onTap: controller.purchaseImage,
      ),
    );
  }
}

// widgets/details_tile.dart
class DetailsTile extends StatelessWidget {
  final String title, subText;

  const DetailsTile({super.key, required this.title, required this.subText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: title,
              size: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(text: subText, size: 12),
        ],
      ),
    );
  }
}
