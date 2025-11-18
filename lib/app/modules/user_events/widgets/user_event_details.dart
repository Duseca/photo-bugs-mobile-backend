// modules/user_events/widgets/user_event_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/folder_model.dart';

import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:intl/intl.dart';
import 'package:photo_bug/app/modules/user_events/controllers/user_events_controller.dart';
import 'package:photo_bug/app/modules/user_events/controllers/user_events_detail_controller.dart';

class UserEventDetails extends StatelessWidget {
  const UserEventDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserEventDetailsController());

    return Scaffold(
      appBar: _buildAppBar(controller),
      body: Obx(() => _buildBody(controller)),
    );
  }

  PreferredSizeWidget _buildAppBar(UserEventDetailsController controller) {
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

  Widget _buildBody(UserEventDetailsController controller) {
    if (controller.isLoading.value && controller.event.value == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.event.value == null) {
      return _buildErrorState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshEventDetails,
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                _buildEventImage(controller),
                const SizedBox(height: 12),
                _buildEventInfo(controller),
                const SizedBox(height: 12),
                _buildRecipients(controller),
                if (controller.recipientCount > 0) _buildDivider(),
                _buildEventTimings(controller),
                if (controller.hasTimings) _buildDivider(),
                _buildFoldersSection(controller),
              ],
            ),
          ),
        ),
        _buildBottomActions(controller),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            MyText(text: 'Event not found', size: 16, weight: FontWeight.w600),
            const SizedBox(height: 16),
            MyButton(buttonText: 'Go Back', onTap: () => Get.back()),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(UserEventDetailsController controller) {
    return Obx(() {
      final imageUrl = controller.event.value?.image;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            imageUrl != null && imageUrl.isNotEmpty
                ? CommonImageView(url: imageUrl, height: 200, fit: BoxFit.cover)
                : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.event, size: 80, color: Colors.grey),
                  ),
                ),
      );
    });
  }

  Widget _buildEventInfo(UserEventDetailsController controller) {
    return Obx(() {
      final event = controller.event.value!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date and Status Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: kQuaternaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: MyText(
                        text: _formatDate(event.date),
                        size: 12,
                        color: kQuaternaryColor,
                        weight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(event.status),
            ],
          ),
          const SizedBox(height: 12),

          // Event Name
          MyText(
            text: event.name,
            size: 20,
            weight: FontWeight.w700,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Location
          if (event.location != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Image.asset(Assets.imagesLocation, height: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyText(
                      text: _formatLocation(event.location!),
                      size: 12,
                      color: kQuaternaryColor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Type, Role, Mature Content Badges
          if (event.type != null || event.role != null || event.matureContent)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (event.type != null && event.type!.isNotEmpty)
                    _buildInfoChip('Type: ${event.type}', kSecondaryColor),
                  if (event.role != null && event.role!.isNotEmpty)
                    _buildInfoChip('Role: ${event.role}', kPrimaryColor),
                  if (event.matureContent) _buildInfoChip('18+', Colors.red),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildStatusBadge(EventStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status), width: 1.5),
      ),
      child: MyText(
        text: _getStatusText(status),
        size: 11,
        color: _getStatusColor(status),
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: MyText(
        text: text,
        size: 11,
        color: color,
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRecipients(UserEventDetailsController controller) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kInputBorderColor),
            ),
            child: Row(
              children: [
                if (controller.recipientImages.isNotEmpty)
                  FlutterImageStack(
                    imageList: controller.recipientImages,
                    showTotalCount: false,
                    totalCount: controller.recipientCount,
                    itemRadius: 18,
                    itemCount: controller.recipientImages.length.clamp(0, 5),
                    itemBorderWidth: 2,
                    itemBorderColor: kInputBorderColor,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: MyText(
                    text:
                        '${controller.recipientCount} ${controller.recipientCount == 1 ? 'Recipient' : 'Recipients'}',
                    size: 12,
                    color: kSecondaryColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEventTimings(UserEventDetailsController controller) {
    return Obx(() {
      if (!controller.hasTimings) return const SizedBox.shrink();

      final event = controller.event.value!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Event Timings',
            size: 14,
            weight: FontWeight.w600,
            paddingBottom: 12,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kInputBorderColor),
            ),
            child: Column(
              children: [
                if (event.formattedStartTime != null)
                  _buildTimingRow('Start Time', event.formattedStartTime!),
                if (event.formattedStartTime != null &&
                    event.formattedEndTime != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                if (event.formattedEndTime != null)
                  _buildTimingRow('End Time', event.formattedEndTime!),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTimingRow(String label, String time) {
    return Row(
      children: [
        Image.asset(Assets.imagesClock, height: 16),
        const SizedBox(width: 8),
        MyText(text: label, size: 12, color: kQuaternaryColor),
        const Spacer(),
        MyText(text: time, size: 13, weight: FontWeight.w600),
      ],
    );
  }

  Widget _buildFoldersSection(UserEventDetailsController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: MyText(
                  text: 'Folders',
                  size: 14,
                  weight: FontWeight.w600,
                ),
              ),
              if (controller.isMyEvent.value)
                GestureDetector(
                  onTap: controller.showCreateFolderDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: kTertiaryColor),
                        const SizedBox(width: 4),
                        MyText(
                          text: 'Create Folder',
                          size: 11,
                          color: kTertiaryColor,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Loading state
          if (controller.isFoldersLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          // Empty state
          else if (controller.folders.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kInputBorderColor),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    MyText(
                      text: 'No folders yet',
                      size: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            )
          // Folders list
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.folders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final folder = controller.folders[index];
                return _buildFolderItem(folder, controller);
              },
            ),
        ],
      );
    });
  }

  Widget _buildFolderItem(
    Folder folder,
    UserEventDetailsController controller,
  ) {
    final photoCount = folder.photoIds?.length ?? 0;
    final bundleCount = folder.bundleIds?.length ?? 0;
    final totalItems = photoCount + bundleCount;

    return GestureDetector(
      onTap: () => controller.navigateToFolderDetails(folder),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kInputBorderColor),
        ),
        child: Row(
          children: [
            Image.asset(Assets.imagesFolder, height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: folder.name,
                    weight: FontWeight.w600,
                    size: 14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    text:
                        '${_formatDate(folder.createdAt)}  |  $totalItems items',
                    size: 11,
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: kInputBorderColor,
      margin: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildBottomActions(UserEventDetailsController controller) {
    return Obx(() {
      final event = controller.event.value;
      if (event == null) return const SizedBox.shrink();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pending invitation actions
            if (!controller.isMyEvent.value &&
                event.status == EventStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      buttonText: 'Decline',
                      bgColor: Colors.transparent,
                      textColor: Colors.red,
                      borderWidth: 1,
                      borderColor: Colors.red,
                      onTap: () => _showDeclineDialog(controller),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      buttonText: 'Accept',
                      onTap: controller.acceptEventInvitation,
                    ),
                  ),
                ],
              )
            // Delete event button (for my events)
            else if (controller.isMyEvent.value)
              MyButton(
                buttonText: 'Delete Event',
                bgColor: Colors.red,
                onTap: () => _showDeleteDialog(controller),
              ),
          ],
        ),
      );
    });
  }

  void _showDeclineDialog(UserEventDetailsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Decline Invitation'),
        content: const Text(
          'Are you sure you want to decline this event invitation?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.declineEventInvitation();
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(UserEventDetailsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteEvent();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date not set';
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatLocation(location) {
    if (location.latitude != null && location.longitude != null) {
      return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
    }
    return 'Location not set';
  }

  String _getStatusText(EventStatus status) {
    switch (status) {
      case EventStatus.pending:
        return 'PENDING';
      case EventStatus.confirmed:
        return 'CONFIRMED';
      case EventStatus.ongoing:
        return 'ONGOING';
      case EventStatus.completed:
        return 'COMPLETED';
      case EventStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.pending:
        return Colors.orange;
      case EventStatus.confirmed:
        return Colors.blue;
      case EventStatus.ongoing:
        return Colors.green;
      case EventStatus.completed:
        return Colors.grey;
      case EventStatus.cancelled:
        return Colors.red;
    }
  }
}

// ==================== CREATE FOLDER DIALOG ====================

void showCreateFolderDialog(
  BuildContext context,
  String eventId,
  Function(String) onCreateFolder,
) {
  final folderNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Icon(Icons.create_new_folder, color: kSecondaryColor, size: 24),
          const SizedBox(width: 8),
          const Text('Create New Folder'),
        ],
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyTextField(
              controller: folderNameController,
              hint: 'Enter folder name',
              label: 'Folder Name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a folder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            MyText(
              text: 'This folder will be created for this event',
              size: 11,
              color: kQuaternaryColor,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            folderNameController.dispose();
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final folderName = folderNameController.text.trim();
              folderNameController.dispose();
              Get.back();
              onCreateFolder(folderName);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kSecondaryColor,
            foregroundColor: kTertiaryColor,
          ),
          child: const Text('Create'),
        ),
      ],
    ),
  );
}
