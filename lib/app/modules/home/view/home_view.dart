import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_banner_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_bottom_sheet_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/modules/home/controller/home_controller.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset(Assets.imagesAppLogo, height: 42)],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSizes.VERTICAL,
          child: Column(
            children: [
              CustomBanner(
                images: [
                  Assets.imagesBannerImage,
                  Assets.imagesBannerImage,
                  Assets.imagesBannerImage,
                ],
              ),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildTrendingSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            controller.quickActions.map((action) {
              return _CustomCard(
                icon: action['icon'],
                label: action['label'],
                onTap: action['onTap'],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Padding(
      padding: AppSizes.HORIZONTAL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: MyText(
                  text: 'Trending',
                  size: 16,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(
                () => GestureDetector(
                  onTap: controller.toggleViewType,
                  child: Image.asset(
                    controller.isListView.value
                        ? Assets.imagesGridIcon
                        : Assets.imagesListIcon,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: controller.showSortOptions,
                child: Image.asset(Assets.imagesSortIcon, height: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () =>
                controller.isListView.value
                    ? _buildListView()
                    : _buildGridView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: controller.navigateToImageDetails,
            child: Row(
              children: [
                CommonImageView(
                  url: controller.dummyImg,
                  height: 48,
                  width: 48,
                  radius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyText(
                        text: 'Image1234567890',
                        size: 13,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        paddingBottom: 4,
                      ),
                      MyText(
                        text: 'Size: 60mb',
                        size: 12,
                        color: kQuaternaryColor,
                      ),
                    ],
                  ),
                ),
                MyText(text: '\$10', size: 16, weight: FontWeight.w500),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return StaggeredGridView.countBuilder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      crossAxisCount: 2,
      itemCount: 12,
      staggeredTileBuilder: (int index) {
        return StaggeredTile.count(1, index.isEven ? 1.4 : 1);
      },
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: controller.navigateToImageDetails,
          child: Stack(
            children: [
              CommonImageView(
                url: controller.dummyImg,
                height: Get.height,
                width: Get.width,
                radius: 12,
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap:
                                () =>
                                    controller.toggleFavorite(index.toString()),
                            child: Obx(
                              () => Icon(
                                controller.isFavorite(index.toString())
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: kSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: kWhiteColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(Assets.imagesEye2, height: 18),
                                MyText(
                                  text: '200',
                                  size: 12,
                                  weight: FontWeight.w500,
                                  paddingLeft: 4,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showReportBottomSheet,
                            child: Image.asset(
                              Assets.imagesWarning,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportBottomSheet() {
    final reportController = Get.put(ReportController());

    Get.bottomSheet(
      CustomBottomSheet(
        height: Get.height * 0.42,
        child: Padding(
          padding: AppSizes.HORIZONTAL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyText(
                text: 'Report',
                size: 18,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
                paddingBottom: 16,
              ),
              MyText(
                text: 'Why are you reporting this post?',
                size: 16,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
                paddingBottom: 8,
              ),
              MyText(
                text: 'Your report is anonymous.',
                textAlign: TextAlign.center,
                paddingBottom: 24,
              ),
              ...List.generate(
                reportController.reportReasons.length,
                (index) => MyText(
                  text: reportController.reportReasons[index],
                  size: 13,
                  weight: FontWeight.w500,
                  paddingBottom: 24,
                  onTap: () => reportController.selectReason(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;

  const _CustomCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: kSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Image.asset(icon, height: 26)),
              ),
              MyText(
                text: label,
                textAlign: TextAlign.center,
                size: 10,
                weight: FontWeight.w500,
                paddingTop: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
