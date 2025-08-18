import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/models/add_listings_model/add_listing_model.dart';
import 'package:photo_bug/app/modules/add_new_listing/controller/add_listing_controller.dart';
import 'package:photo_bug/app/modules/add_new_listing/view/add_creator_listing.dart';
import 'package:photo_bug/app/modules/add_new_listing/view/add_host_event.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class AddNewListing extends GetView<AddListingController> {
  const AddNewListing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Add New Listing'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
          _buildPublishButton(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: kInputBorderColor),
      ),
      child: Row(
        children: controller.tabs.map((tab) => _buildTabButton(tab)).toList(),
      ),
    );
  }

  Widget _buildTabButton(ListingType tab) {
    return Expanded(
      child: Obx(() => GestureDetector(
        onTap: () => controller.switchTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          decoration: BoxDecoration(
            color: controller.currentTab.value == tab
                ? kSecondaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: MyText(
              text: tab.displayName,
              size: 12,
              color: controller.currentTab.value == tab
                  ? kTertiaryColor
                  : kQuaternaryColor,
              weight: FontWeight.w500,
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildTabContent() {
    return Obx(() => IndexedStack(
      index: controller.currentTab.value.index,
      children: const [
        AddCreatorListing(),
        AddHostEvent(),
      ],
    ));
  }

  Widget _buildPublishButton() {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: Obx(() => MyButton(
        buttonText: 'Publish Listing',
        onTap: controller.publishListing,
        isLoading: controller.isLoading.value,
        // isEnabled: controller.canPublish.value,
      )),
    );
  }
}