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
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.navigateToUploadScreen(),
        backgroundColor: kSecondaryColor,
        child: const Icon(Icons.add, color: kWhiteColor, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshTrendingPhotos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
          Obx(() {
            // Show loading state
            if (controller.isFetchingTrending.value &&
                controller.trendingPhotos.isEmpty) {
              return _buildLoadingState();
            }

            // Show empty state
            if (controller.trendingPhotos.isEmpty) {
              return _buildEmptyState();
            }

            // Show list or grid view
            return controller.isListView.value
                ? _buildListView()
                : _buildGridView();
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading trending photos...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            MyText(
              text: 'No trending photos available',
              size: 16,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            MyText(
              text: 'Pull down to refresh',
              size: 14,
              color: Colors.grey[500],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.trendingPhotos.length,
        itemBuilder: (BuildContext context, int index) {
          final photo = controller.trendingPhotos[index];
          final fileSize = photo.metadata?.fileSize;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GestureDetector(
              onTap: () => controller.navigateToImageDetails(photo: photo),
              child: Row(
                children: [
                  CommonImageView(
                    url:
                        photo.watermarkedLink ??
                        photo.link ??
                        photo.url ??
                        controller.dummyImg,
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
                          text:
                              photo.metadata?.fileName ??
                              photo.creator?.name ??
                              'Image ${index + 1}',
                          size: 13,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          paddingBottom: 4,
                        ),
                        MyText(
                          text:
                              fileSize != null
                                  ? 'Size: ${_formatFileSize(fileSize)}'
                                  : 'Size: Unknown',
                          size: 12,
                          color: kQuaternaryColor,
                        ),
                      ],
                    ),
                  ),
                  MyText(
                    text:
                        photo.price != null && photo.price! > 0
                            ? '\$${photo.price!.toStringAsFixed(2)}'
                            : 'Free',
                    size: 16,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView() {
    return Obx(
      () => StaggeredGridView.countBuilder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        crossAxisCount: 2,
        itemCount: controller.trendingPhotos.length,
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(1, index.isEven ? 1.4 : 1);
        },
        itemBuilder: (context, index) {
          final photo = controller.trendingPhotos[index];
          final photoId = photo.id ?? index.toString();
          final views = photo.views ?? photo.metadata?.views ?? 0;

          return GestureDetector(
            onTap: () => controller.navigateToImageDetails(photo: photo),
            child: Stack(
              children: [
                CommonImageView(
                  url:
                      photo.watermarkedLink ??
                      photo.link ??
                      photo.url ??
                      controller.dummyImg,
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
                              onTap: () => controller.toggleFavorite(photoId),
                              child: Obx(
                                () => Icon(
                                  controller.isFavorite(photoId)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: kSecondaryColor,
                                  size: 24,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: kWhiteColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(Assets.imagesEye2, height: 18),
                                  MyText(
                                    text: '$views',
                                    size: 12,
                                    weight: FontWeight.w500,
                                    paddingLeft: 4,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showReportBottomSheet(photoId),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: kWhiteColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.asset(
                                  Assets.imagesWarning,
                                  height: 20,
                                ),
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
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  void _showReportBottomSheet(String photoId) {
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
                (index) => GestureDetector(
                  onTap: () => reportController.selectReason(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
                    ),
                    child: MyText(
                      text: reportController.reportReasons[index],
                      size: 13,
                      weight: FontWeight.w500,
                    ),
                  ),
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