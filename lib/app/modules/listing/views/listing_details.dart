// modules/listing/views/listing_details.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/models/listings_model/listings_model.dart';
import 'package:photo_bug/app/modules/listing/controllers/listing_controllers.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';

class ListingDetails extends GetView<ListingDetailsController> {
  const ListingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: Obx(() => _buildBody()));
  }

  PreferredSizeWidget _buildAppBar() {
    return simpleAppBar(
      title: 'Listing Details',
      actions: [
        Obx(() {
          if (controller.hasListing) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: controller.shareListing,
                  child: Image.asset(Assets.imagesShare, height: 20),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildBody() {
    // Loading state
    if (controller.isLoading.value && !controller.hasListing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (controller.errorMessage.isNotEmpty && !controller.hasListing) {
      return _buildErrorState();
    }

    // No listing state
    if (!controller.hasListing) {
      return _buildNoListingState();
    }

    // Success state with listing details
    final listing = controller.listing.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: AppSizes.DEFAULT,
            children: [
              _buildImage(listing),
              const SizedBox(height: 12),
              _buildDateAndStatus(listing),
              _buildTitle(listing),
              _buildLocation(listing),
              const SizedBox(height: 12),
              _buildRecipients(),
              const SizedBox(height: 8),
              _buildPhotoCount(listing),
              _buildDivider(),
              _buildFolders(listing),
            ],
          ),
        ),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          MyText(
            text: 'Failed to Load Details',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MyText(
              text: controller.errorMessage.value,
              size: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.loadListingDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoListingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.imagesFolder, height: 64, color: Colors.grey),
          const SizedBox(height: 16),
          MyText(
            text: 'No listing data available',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ListingItem listing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          listing.imageUrl.isNotEmpty
              ? CommonImageView(
                url: listing.imageUrl,
                height: 220,
                fit: BoxFit.cover,
              )
              : Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey, size: 60),
                ),
              ),
    );
  }

  Widget _buildDateAndStatus(ListingItem listing) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: kQuaternaryColor),
              const SizedBox(width: 4),
              MyText(
                text: listing.date,
                size: 12,
                color: kQuaternaryColor,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(listing.status),
            borderRadius: BorderRadius.circular(6),
          ),
          child: MyText(
            text: listing.status,
            size: 12,
            color: Colors.white,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ListingItem listing) {
    return MyText(
      text: listing.title,
      weight: FontWeight.w700,
      size: 20,
      paddingTop: 12,
      paddingBottom: 8,
    );
  }

  Widget _buildLocation(ListingItem listing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(Assets.imagesLocation, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: MyText(
              text: listing.location,
              size: 13,
              color: kQuaternaryColor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipients() {
    return Obx(() {
      if (controller.recipientsCount == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kInputBorderColor),
        ),
        child: Row(
          children: [
            MyText(
              text: 'Recipients:',
              size: 13,
              weight: FontWeight.w600,
              paddingRight: 8,
            ),
            if (controller.recipientsImages.isNotEmpty)
              FlutterImageStack(
                imageList: controller.recipientsImages,
                showTotalCount: false,
                totalCount: controller.recipientsCount,
                itemRadius: 18,
                itemCount:
                    controller.recipientsImages.length > 5
                        ? 5
                        : controller.recipientsImages.length,
                itemBorderWidth: 2,
                itemBorderColor: kInputBorderColor,
              ),
            const SizedBox(width: 8),
            MyText(
              text: '${controller.recipientsCount} people',
              size: 12,
              color: kSecondaryColor,
              weight: FontWeight.w600,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPhotoCount(ListingItem listing) {
    if (listing.totalPhotos == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_library, size: 20, color: kSecondaryColor),
          const SizedBox(width: 8),
          MyText(
            text: '${listing.totalPhotos} photos in this listing',
            size: 14,
            color: kSecondaryColor,
            weight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: kInputBorderColor,
      margin: const EdgeInsets.symmetric(vertical: 20),
    );
  }

  Widget _buildFolders(ListingItem listing) {
    if (listing.folders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: MyText(
            text: 'No folders available',
            size: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: 'Folders',
          size: 16,
          weight: FontWeight.w700,
          paddingBottom: 12,
        ),
        ...listing.folders.map((folder) => _buildFolderItem(folder)).toList(),
      ],
    );
  }

  Widget _buildFolderItem(ListingFolder folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kInputBorderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.openUserImageFolderDetails(folder),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    Assets.imagesFolder,
                    height: 32,
                    width: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: folder.name,
                        weight: FontWeight.w600,
                        size: 15,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          MyText(
                            text: folder.date,
                            size: 11,
                            color: kQuaternaryColor,
                          ),
                          MyText(
                            text: ' • ',
                            size: 11,
                            color: kQuaternaryColor,
                          ),
                          MyText(
                            text: '${folder.itemCount} items',
                            size: 11,
                            color: kSecondaryColor,
                            weight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Image.asset(Assets.imagesArrowRightIos, height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Obx(() {
      if (!controller.hasListing) return const SizedBox.shrink();

      return Container(
        padding: AppSizes.DEFAULT,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: MyButton(
          buttonText: 'Download in Bulk',
          onTap: controller.downloadInBulk,
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'scheduled':
        return Colors.green;
      case 'upcoming':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
