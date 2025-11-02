// modules/listing/views/listing.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/models/listings_model/listings_model.dart';
import 'package:photo_bug/app/modules/listing/controllers/listing_controllers.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

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
        child: ListView.builder(
          padding: AppSizes.DEFAULT,
          itemCount: controller.listings.length,
          itemBuilder: (context, index) {
            final listing = controller.listings[index];
            return _buildListingItem(listing, index);
          },
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.imagesFolder, height: 64, color: Colors.grey),
          const SizedBox(height: 16),
          MyText(
            text: 'No Listings Found',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MyText(
              text: 'Add your first listing to get started',
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
            text: 'No listings yet',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MyText(
              text: 'Create your first listing by tapping the + button',
              size: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingItem(ListingItem listing, int index) {
    return Dismissible(
      key: Key(listing.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Listing'),
            content: const Text(
              'Are you sure you want to delete this listing?',
            ),
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
        controller.deleteListing(listing.id);
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
          onTap: () => controller.openListingDetails(listing),
          child: _buildListingCard(listing),
        ),
      ),
    );
  }

  Widget _buildListingCard(ListingItem listing) {
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
          _buildListingImage(listing),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildListingInfo(listing),
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

  Widget _buildListingImage(ListingItem listing) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
      child:
          listing.imageUrl.isNotEmpty
              ? CommonImageView(
                url: listing.imageUrl,
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

  Widget _buildListingInfo(ListingItem listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: MyText(
                text: listing.date,
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
                color: _getStatusColor(listing.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: MyText(
                text: listing.status,
                size: 10,
                color: Colors.white,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
        MyText(
          text: listing.title,
          weight: FontWeight.w600,
          size: 15,
          paddingTop: 6,
          paddingBottom: 6,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Image.asset(Assets.imagesLocation, height: 14),
            Expanded(
              child: MyText(
                text: listing.location,
                size: 11,
                color: kQuaternaryColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                paddingLeft: 4,
              ),
            ),
          ],
        ),
        if (listing.totalPhotos > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.photo_library, size: 14, color: kSecondaryColor),
              const SizedBox(width: 4),
              MyText(
                text: '${listing.totalPhotos} photos',
                size: 11,
                color: kSecondaryColor,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ],
    );
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
