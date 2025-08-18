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
      appBar: simpleAppBar(title: 'My Listing'),
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
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.listings.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshListings,
        child: ListView.builder(
          padding: AppSizes.DEFAULT,
          itemCount: controller.listings.length,
          itemBuilder: (context, index) {
            final listing = controller.listings[index];
            return _buildListingItem(listing);
          },
        ),
      );
    });
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
          MyText(
            text: 'Create your first listing by tapping the + button',
            size: 14,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListingItem(ListingItem listing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: () => controller.openListingDetails(listing),
        child: Row(
          children: [
            CommonImageView(
              url: listing.imageUrl,
              height: 80,
              width: 64,
              radius: 8,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    text: listing.date,
                    size: 11,
                    color: kQuaternaryColor,
                    weight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  MyText(
                    text: listing.title,
                    weight: FontWeight.w500,
                    paddingTop: 8,
                    paddingBottom: 8,
                  ),
                  Row(
                    children: [
                      Image.asset(Assets.imagesLocation, height: 16),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
