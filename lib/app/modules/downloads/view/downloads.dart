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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildHeader(), Expanded(child: _buildDownloadsList())],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.downloadMonths.isEmpty) {
        return const Center(child: Text('No downloads data available'));
      }

      return ListView.builder(
        padding: AppSizes.DEFAULT,
        itemCount: controller.downloadMonths.length,
        itemBuilder: (context, index) {
          final month = controller.downloadMonths[index];
          return _buildDownloadItem(month);
        },
      );
    });
  }

  Widget _buildDownloadItem(DownloadMonth month) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => controller.openDownloadDetails(month),
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
    );
  }
}
