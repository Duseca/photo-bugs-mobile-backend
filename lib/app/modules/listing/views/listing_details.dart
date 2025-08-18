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
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.listing.value == null) {
          return const Center(child: Text('Failed to load listing details'));
        }

        return _buildBody();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return simpleAppBar(
      title: 'My Listings',
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: controller.shareListing,
              child: Image.asset(Assets.imagesShare, height: 20),
            ),
          ],
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildBody() {
    final listing = controller.listing.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: AppSizes.DEFAULT,
            children: [
              _buildImage(listing),
              const SizedBox(height: 8),
              _buildDateAndStatus(listing),
              _buildTitle(listing),
              _buildLocation(listing),
              _buildRecipients(),
              _buildDivider(),
              _buildFolders(listing),
            ],
          ),
        ),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildImage(ListingItem listing) {
    return CommonImageView(
      imagePath: Assets.imagesEventImage,
      // url: listing.imageUrl,
      height: 200,
      radius: 8,
    );
  }

  Widget _buildDateAndStatus(ListingItem listing) {
    return Row(
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
        // Uncomment if you want to show status
        // MyText(
        //   text: listing.status,
        //   size: 12,
        //   color: kSecondaryColor,
        //   weight: FontWeight.w500,
        // ),
      ],
    );
  }

  Widget _buildTitle(ListingItem listing) {
    return MyText(
      text: listing.title,
      weight: FontWeight.w500,
      paddingTop: 8,
      paddingBottom: 8,
    );
  }

  Widget _buildLocation(ListingItem listing) {
    return Row(
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
    );
  }

  Widget _buildRecipients() {
    return Obx(
      () => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FlutterImageStack(
            imageList: controller.recipientsImages,
            showTotalCount: false,
            totalCount: controller.recipientsCount,
            itemRadius: 20,
            itemCount: controller.recipientsImages.length,
            itemBorderWidth: 2,
            itemBorderColor: kInputBorderColor,
          ),
          MyText(
            text: '${controller.recipientsCount} Recipients',
            size: 12,
            color: kSecondaryColor,
            weight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: kSecondaryColor,
            paddingLeft: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: kInputBorderColor,
      margin: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildFolders(ListingItem listing) {
    return Column(
      children:
          listing.folders.map((folder) => _buildFolderItem(folder)).toList(),
    );
  }

  Widget _buildFolderItem(ListingFolder folder) {
    return GestureDetector(
      onTap: () => controller.openUserImageFolderDetails(folder),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Image.asset(Assets.imagesFolder, height: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    text: folder.name,
                    weight: FontWeight.w500,
                    paddingBottom: 4,
                  ),
                  MyText(
                    text: '${folder.date}  |  ${folder.itemCount} items',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ],
              ),
            ),
            Image.asset(Assets.imagesArrowRightIos, height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: MyButton(
        buttonText: 'Download in Bulk',
        onTap: controller.downloadInBulk,
      ),
    );
  }
}
