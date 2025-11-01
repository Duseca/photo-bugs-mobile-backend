// views/downloads_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/models/download_model/download_model.dart';
import 'package:photo_bug/app/modules/downloads/controller/download_controller.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class Downloads extends GetView<DownloadsController> {
  const Downloads({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: MyText(
          text: 'Downloads',
          size: 18,
          color: kTertiaryColor,
          weight: FontWeight.w600,
        ),
        actions: [
          // Total downloads indicator
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: MyText(
                  text: 'Total: ${controller.totalDownloads.value}',
                  size: 14,
                  color: kTertiaryColor.withOpacity(0.7),
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildHeader(), Expanded(child: _buildDownloadsList())],
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
              text: 'Month',
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

  Widget _buildDownloadsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.downloadMonths.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.downloadMonths.isEmpty) {
        return _buildErrorView();
      }

      if (controller.downloadMonths.isEmpty) {
        return _buildEmptyView();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshDownloads,
        child: ListView.builder(
          padding: AppSizes.DEFAULT,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.downloadMonths.length,
          itemBuilder: (context, index) {
            final month = controller.downloadMonths[index];
            return _buildDownloadItem(month);
          },
        ),
      );
    });
  }

  Widget _buildDownloadItem(DownloadMonth month) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => controller.openDownloadDetails(month),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: MyText(
                  text: month.month,
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
                      text: month.downloadCount.toString(),
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
                  text: '\$${month.earnings.toStringAsFixed(0)}',
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
            Icons.download_outlined,
            size: 64,
            color: kTertiaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          MyText(
            text: 'No downloads yet',
            size: 16,
            color: kTertiaryColor.withOpacity(0.6),
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          MyText(
            text: 'Upload some photos to get started!',
            size: 14,
            color: kTertiaryColor.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Obx(
            () => MyText(
              text: controller.errorMessage.value,
              size: 14,
              color: kTertiaryColor.withOpacity(0.6),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshDownloads,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
