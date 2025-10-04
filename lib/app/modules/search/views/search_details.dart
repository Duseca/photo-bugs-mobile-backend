import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
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
      body: RefreshIndicator(
        onRefresh: controller.refreshEventDetails,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.eventDetails.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    MyText(
                      text: 'Failed to load event details',
                      size: 16,
                      weight: FontWeight.w500,
                    ),
                    const SizedBox(height: 16),
                    MyButton(
                      buttonText: 'Retry',
                      onTap: controller.loadEventDetails,
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildContent();
        }),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: AppSizes.DEFAULT,
            children: [
              _buildEventImage(),
              const SizedBox(height: 12),
              _buildEventInfo(),
              const SizedBox(height: 12),
              _buildRecipients(),
              _buildDivider(),
              _buildEventTimings(),
              if (controller.eventDetails.value?.role != null ||
                  controller.eventDetails.value?.matureContent == true)
                _buildDivider(),
              _buildAdditionalInfo(),
            ],
          ),
        ),
        if (controller.canSendQuote) _buildSendQuoteButton(),
      ],
    );
  }

  Widget _buildEventImage() {
    return Obx(
      () => CommonImageView(
        imagePath: controller.eventImage ?? Assets.imagesEventImage,
        height: 220,
        radius: 8,
      ),
    );
  }

  Widget _buildEventInfo() {
    return Obx(() {
      final event = controller.eventDetails.value!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date
          if (controller.formattedDate.isNotEmpty)
            MyText(
              text: controller.formattedDate,
              size: 11,
              color: kQuaternaryColor,
              weight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              paddingBottom: 8,
            ),

          // Event Name
          MyText(
            text: controller.eventName,
            size: 18,
            weight: FontWeight.w600,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            paddingBottom: 8,
          ),

          // Location
          if (controller.locationText.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Image.asset(Assets.imagesLocation, height: 16),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: MyText(
                    text: controller.locationText,
                    size: 12,
                    color: kQuaternaryColor,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          // Badges
          if (event.type != null || event.role != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (event.type != null && event.type!.isNotEmpty)
                    _buildInfoBadge('Type', event.type!, kSecondaryColor),
                  if (event.role != null && event.role!.isNotEmpty)
                    _buildInfoBadge('Role', event.role!, kPrimaryColor),
                  if (event.status != EventStatus.pending)
                    _buildInfoBadge(
                      'Status',
                      event.status.value.toUpperCase(),
                      _getStatusColor(event.status),
                    ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildInfoBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText(
            text: '$label: ',
            size: 11,
            color: color.withOpacity(0.7),
            weight: FontWeight.w500,
          ),
          MyText(text: value, size: 11, color: color, weight: FontWeight.w600),
        ],
      ),
    );
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.confirmed:
        return Colors.green;
      case EventStatus.ongoing:
        return Colors.orange;
      case EventStatus.completed:
        return Colors.blue;
      case EventStatus.cancelled:
        return Colors.red;
      default:
        return kQuaternaryColor;
    }
  }

  Widget _buildRecipients() {
    return Obx(() {
      if (controller.recipientCount == 0) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: 'Recipients',
            size: 14,
            weight: FontWeight.w600,
            paddingBottom: 8,
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (controller.recipientImages.isNotEmpty)
                FlutterImageStack(
                  imageList: controller.recipientImages,
                  showTotalCount: false,
                  totalCount: controller.recipientCount,
                  itemRadius: 20,
                  itemCount: controller.recipientImages.length.clamp(0, 5),
                  itemBorderWidth: 2,
                  itemBorderColor: kInputBorderColor,
                ),
              MyText(
                text:
                    '${controller.recipientCount} ${controller.recipientCount == 1 ? 'Recipient' : 'Recipients'}',
                size: 12,
                color: kSecondaryColor,
                weight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: kSecondaryColor,
                paddingLeft: 4,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildEventTimings() {
    return Obx(() {
      final hasStartTime = controller.formattedStartTime.isNotEmpty;
      final hasEndTime = controller.formattedEndTime.isNotEmpty;

      if (!hasStartTime && !hasEndTime) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Event Timings',
            size: 14,
            weight: FontWeight.w600,
            paddingBottom: 12,
          ),

          // Start Time
          if (hasStartTime)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Image.asset(Assets.imagesClock, height: 16),
                  const SizedBox(width: 8),
                  MyText(text: 'Start Time', size: 12, color: kQuaternaryColor),
                  const Spacer(),
                  MyText(
                    text: controller.formattedStartTime,
                    size: 13,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),

          // End Time
          if (hasEndTime)
            Row(
              children: [
                Image.asset(Assets.imagesClock, height: 16),
                const SizedBox(width: 8),
                MyText(text: 'End Time', size: 12, color: kQuaternaryColor),
                const Spacer(),
                MyText(
                  text: controller.formattedEndTime,
                  size: 13,
                  weight: FontWeight.w500,
                ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildAdditionalInfo() {
    return Obx(() {
      final event = controller.eventDetails.value;
      if (event == null) return const SizedBox.shrink();

      final hasMatureContent = event.matureContent;

      if (!hasMatureContent) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMatureContent)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyText(
                      text: 'This event may contain mature content',
                      size: 12,
                      color: Colors.orange.shade700,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
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
