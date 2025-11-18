// modules/listing/views/listing.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/modules/listing/controllers/listing_controllers.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:intl/intl.dart';

class Listing extends GetView<ListingController> {
  const Listing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'My Listings'),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: kSecondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      onPressed: controller.addNewListing,
      child: const Icon(Icons.add, color: kTertiaryColor),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value && controller.listings.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // Error state with retry
      if (controller.errorMessage.isNotEmpty && controller.listings.isEmpty) {
        return _buildErrorState();
      }

      // Empty state
      if (controller.listings.isEmpty) {
        return _buildEmptyState();
      }

      // Success state with listings
      return RefreshIndicator(
        onRefresh: controller.refreshListings,
        child: Column(
          children: [
            _buildListingsSummary(),
            Expanded(
              child: ListView.builder(
                padding: AppSizes.DEFAULT,
                itemCount: controller.listings.length,
                itemBuilder: (context, index) {
                  final photo = controller.listings[index];
                  return _buildListingItem(photo, index);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildListingsSummary() {
    return Obx(() {
      if (controller.listings.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kSecondaryColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kSecondaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.photo_library,
                label: 'Photos',
                value: '${controller.listingsCount}',
              ),
            ),
            Container(width: 1, height: 40, color: kInputBorderColor),
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.visibility,
                label: 'Views',
                value: _formatNumber(controller.totalViews),
              ),
            ),
            Container(width: 1, height: 40, color: kInputBorderColor),
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.attach_money,
                label: 'Value',
                value: '\$${controller.totalPhotosValue.toStringAsFixed(0)}',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: kSecondaryColor, size: 24),
        const SizedBox(height: 4),
        MyText(
          text: value,
          size: 16,
          weight: FontWeight.w700,
          color: kSecondaryColor,
        ),
        MyText(text: label, size: 11, color: kQuaternaryColor),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.imagesFolder, height: 64, color: Colors.grey),
          const SizedBox(height: 16),
          MyText(
            text: 'No Photos Found',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MyText(
              text: 'Upload your first photo to get started',
              size: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.loadListings,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.imagesFolder, height: 64, color: Colors.grey),
          const SizedBox(height: 16),
          MyText(
            text: 'No photos yet',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MyText(
              text: 'Upload your first photo by tapping the + button',
              size: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingItem(Photo photo, int index) {
    return Dismissible(
      key: Key(photo.id ?? 'photo_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Photo'),
            content: const Text('Are you sure you want to delete this photo?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (photo.id != null) {
          controller.deleteListing(photo.id!);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () => controller.openListingDetails(photo),
          child: _buildListingCard(photo),
        ),
      ),
    );
  }

  Widget _buildListingCard(Photo photo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildListingImage(photo),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildListingInfo(photo),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildListingImage(Photo photo) {
    final imageUrl = photo.thumbnailUrl ?? photo.watermarkedUrl ?? photo.url;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
      child:
          imageUrl != null && imageUrl.isNotEmpty
              ? CommonImageView(
                url: imageUrl,
                height: 100,
                width: 80,
                fit: BoxFit.cover,
              )
              : Container(
                height: 100,
                width: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
    );
  }

  Widget _buildListingInfo(Photo photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: MyText(
                text: _formatDate(photo.createdAt),
                size: 11,
                color: kQuaternaryColor,
                weight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(photo.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: MyText(
                text: _getStatusText(photo.status),
                size: 10,
                color: Colors.white,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
        MyText(
          text: _getPhotoTitle(photo),
          weight: FontWeight.w600,
          size: 15,
          paddingTop: 6,
          paddingBottom: 6,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (photo.metadata?.category != null) ...[
          Row(
            children: [
              const Icon(Icons.category, size: 14, color: kSecondaryColor),
              Expanded(
                child: MyText(
                  text: photo.metadata!.category!,
                  size: 11,
                  color: kQuaternaryColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  paddingLeft: 4,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            if (photo.price != null && photo.price! > 0) ...[
              const Icon(Icons.attach_money, size: 14, color: Colors.green),
              MyText(
                text: '\$${photo.price!.toStringAsFixed(2)}',
                size: 11,
                color: Colors.green,
                weight: FontWeight.w600,
              ),
              const SizedBox(width: 12),
            ],
            if (photo.views != null && photo.views! > 0) ...[
              const Icon(Icons.visibility, size: 14, color: kSecondaryColor),
              const SizedBox(width: 4),
              MyText(
                text: '${photo.views} views',
                size: 11,
                color: kSecondaryColor,
                weight: FontWeight.w500,
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _getPhotoTitle(Photo photo) {
    // Try to get title from metadata filename
    if (photo.metadata?.fileName != null) {
      return photo.metadata!.fileName!;
    }
    // Fallback to ID or "Untitled"
    return photo.id != null
        ? 'Photo ${photo.id!.substring(0, 8)}'
        : 'Untitled Photo';
  }

  String _getStatusText(PhotoStatus status) {
    switch (status) {
      case PhotoStatus.active:
        return 'Active';
      case PhotoStatus.processing:
        return 'Processing';
      case PhotoStatus.archived:
        return 'Archived';
      case PhotoStatus.deleted:
        return 'Deleted';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(PhotoStatus status) {
    switch (status) {
      case PhotoStatus.active:
        return Colors.green;
      case PhotoStatus.processing:
        return Colors.orange;
      case PhotoStatus.archived:
        return Colors.blue;
      case PhotoStatus.deleted:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
