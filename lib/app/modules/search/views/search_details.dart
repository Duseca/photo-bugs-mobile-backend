import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/search/controller/search_controller.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class SearchDetails extends GetView<SearchDetailsController> {
  const SearchDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.eventDetails.value == null) {
          return const Center(child: Text('Failed to load event details'));
        }

        return _buildContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return simpleAppBar(
      title: 'Event Details',
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: controller.shareEvent,
              child: Image.asset(Assets.imagesShare, height: 20),
            ),
          ],
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildContent() {
    final event = controller.eventDetails.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: AppSizes.DEFAULT,
            children: [
              _buildEventImage(),
              const SizedBox(height: 8),
              _buildEventInfo(event),
              _buildRecipients(),
              _buildDivider(),
              _buildEventTimings(event),
              _buildDivider(),
            ],
          ),
        ),
        _buildSendQuoteButton(),
      ],
    );
  }

  Widget _buildEventImage() {
    return CommonImageView(
      imagePath: Assets.imagesEventImage,
      height: 200,
      radius: 8,
    );
  }

  Widget _buildEventInfo(Map<String, dynamic> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(
          text: event['date'],
          size: 11,
          color: kQuaternaryColor,
          weight: FontWeight.w500,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          paddingBottom: 8,
        ),
        MyText(
          text: event['title'],
          weight: FontWeight.w500,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          paddingBottom: 8,
        ),
        Row(
          children: [
            Image.asset(Assets.imagesLocation, height: 16),
            Expanded(
              child: MyText(
                text: event['location'],
                size: 11,
                color: kQuaternaryColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                paddingLeft: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRecipients() {
    return Obx(
      () => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FlutterImageStack(
            imageList: controller.recipientImages,
            showTotalCount: false,
            totalCount: controller.recipientCount,
            itemRadius: 20,
            itemCount: controller.recipientImages.length,
            itemBorderWidth: 2,
            itemBorderColor: kInputBorderColor,
          ),
          MyText(
            text: '${controller.recipientCount} Recipients',
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

  Widget _buildEventTimings(Map<String, dynamic> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(
          text: 'Event Timings',
          weight: FontWeight.w500,
          paddingBottom: 8,
        ),
        Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Image.asset(Assets.imagesClock, height: 16),
            MyText(text: 'Start Time', size: 12, color: kQuaternaryColor),
            MyText(text: event['startTime'], size: 12, weight: FontWeight.w500),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Image.asset(Assets.imagesClock, height: 16),
            MyText(text: 'End Time', size: 12, color: kQuaternaryColor),
            MyText(text: event['endTime'], size: 12, weight: FontWeight.w500),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: kInputBorderColor,
      margin: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildSendQuoteButton() {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: MyButton(
        buttonText: 'Send Quote',
        onTap: controller.navigateToSendQuote,
      ),
    );
  }
}
