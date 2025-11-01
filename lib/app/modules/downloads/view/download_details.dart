// views/download_details_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/models/download_model/download_model.dart';
import 'package:photo_bug/app/modules/downloads/controller/download_controller.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class DownloadDetails extends GetView<DownloadDetailsController> {
  const DownloadDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildHeader(), Expanded(child: _buildItemsList())],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(
        () => MyText(
          text: controller.monthName.value,
          size: 18,
          color: kTertiaryColor,
          weight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: MyText(
              text: 'Category',
              size: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: 'Downloads',
              size: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: 'Earned',
              size: 12,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.downloadItems.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.downloadItems.isEmpty) {
        return _buildEmptyView();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshItems,
        child: ListView.builder(
          padding: AppSizes.DEFAULT,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.downloadItems.length,
          itemBuilder: (context, index) {
            final item = controller.downloadItems[index];
            return _buildDownloadItem(item);
          },
        ),
      );
    });
  }

  Widget _buildDownloadItem(DownloadItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => controller.openImageView(item),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: MyText(
                  text: item.name,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Image.asset(
                      Assets.imagesDownload,
                      height: 14,
                      color: kTertiaryColor,
                    ),
                    MyText(
                      text: item.downloadCount.toString(),
                      size: 12,
                      weight: FontWeight.w500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: MyText(
                  text: '\$${item.earnings.toStringAsFixed(0)}',
                  size: 12,
                  weight: FontWeight.w500,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            size: 64,
            color: kTertiaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Obx(
            () => MyText(
              text: 'No items for ${controller.monthName.value}',
              size: 16,
              color: kTertiaryColor.withOpacity(0.6),
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          MyText(
            text: 'Upload photos to see them here',
            size: 14,
            color: kTertiaryColor.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
