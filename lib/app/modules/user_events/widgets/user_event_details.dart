import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/modules/user_events/controllers/user_events_controller.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_image_folder_details.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_select_download.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class UserEventDetails extends GetView<UserEventsController> {
  const UserEventDetails({super.key});

  @override
  Widget build(BuildContext context) {
    // Get event from arguments or service
    final args = Get.arguments as Map<String, dynamic>?;
    final eventId = args?['eventId'] as String?;
    final isMyEvent = args?['isMyEvent'] as bool? ?? false;

    return Obx(() {
      final event = controller.getEventById(eventId);

      if (event == null) {
        return Scaffold(
          appBar: simpleAppBar(title: 'Event Details'),
          body: const Center(child: Text('Event not found')),
        );
      }

      return Scaffold(
        appBar: simpleAppBar(
          title: isMyEvent ? 'My Event' : 'Event Details',
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.snackbar('Share', 'Share functionality coming soon');
                  },
                  child: Image.asset(Assets.imagesShare, height: 20),
                ),
              ],
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: AppSizes.DEFAULT,
                children: [
                  // Event Image
                  CommonImageView(
                    url: event.image ?? '',
                    height: 200,
                    radius: 8,
                  ),
                  const SizedBox(height: 8),

                  // Date and Status
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          text: _formatDate(event.date),
                          size: 11,
                          color: kQuaternaryColor,
                          weight: FontWeight.w500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(event.status),
                            width: 1,
                          ),
                        ),
                        child: MyText(
                          text: _getStatusText(event.status),
                          size: 12,
                          color: _getStatusColor(event.status),
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Event Name
                  MyText(
                    text: event.name,
                    size: 18,
                    weight: FontWeight.w600,
                    paddingTop: 12,
                    paddingBottom: 8,
                  ),

                  // Location
                  Row(
                    children: [
                      Image.asset(Assets.imagesLocation, height: 16),
                      Expanded(
                        child: MyText(
                          text: _getLocationText(event),
                          size: 11,
                          color: kQuaternaryColor,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          paddingLeft: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Time
                  if (event.formattedStartTime != null ||
                      event.formattedEndTime != null)
                    Row(
                      children: [
                        Image.asset(Assets.imagesClock, height: 16),
                        MyText(
                          text:
                              '${event.formattedStartTime ?? 'N/A'} - ${event.formattedEndTime ?? 'N/A'}',
                          size: 11,
                          color: kQuaternaryColor,
                          paddingLeft: 4,
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),

                  // Event Type and Role
                  if (event.type != null || event.role != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (event.type != null)
                          _buildInfoChip('Type: ${event.type}'),
                        if (event.role != null)
                          _buildInfoChip('Role: ${event.role}'),
                        if (event.matureContent)
                          _buildInfoChip('18+', color: Colors.red),
                      ],
                    ),

                  // Recipients
                  if (event.recipients != null && event.recipients!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (event.recipients!.length <= 5)
                            FlutterImageStack(
                              imageList: List.generate(
                                event.recipients!.length,
                                (index) => 'https://via.placeholder.com/150',
                              ),
                              showTotalCount: false,
                              totalCount: event.recipients!.length,
                              itemRadius: 20,
                              itemCount: event.recipients!.length,
                              itemBorderWidth: 2,
                              itemBorderColor: kInputBorderColor,
                            ),
                          MyText(
                            text: '${event.recipients!.length} Recipients',
                            size: 12,
                            color: kSecondaryColor,
                            weight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: kSecondaryColor,
                            paddingLeft: 4,
                          ),
                        ],
                      ),
                    ),

                  Container(
                    height: 1,
                    color: kInputBorderColor,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                  ),

                  // Folders Section
                  GestureDetector(
                    onTap: () {
                      Get.to(() => UserImageFolderDetails());
                    },
                    child: Row(
                      children: [
                        Image.asset(Assets.imagesFolder, height: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MyText(
                                text: '${event.name} - Photos',
                                weight: FontWeight.w500,
                                paddingBottom: 4,
                              ),
                              MyText(
                                text:
                                    '${_formatDate(event.createdAt)}  |  0 items',
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
                ],
              ),
            ),

            // Bottom Actions
            Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                children: [
                  if (!isMyEvent && event.status == EventStatus.pending)
                    Row(
                      children: [
                        Expanded(
                          child: MyButton(
                            buttonText: 'Decline',
                            bgColor: Colors.transparent,
                            textColor: Colors.red,
                            borderWidth: 1,
                            borderColor: Colors.red,
                            onTap: () => _showDeclineDialog(context, event),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyButton(
                            buttonText: 'Accept',
                            onTap: () => _handleAcceptInvitation(event),
                          ),
                        ),
                      ],
                    )
                  else
                    MyButton(
                      buttonText: 'Download in Bulk',
                      onTap: () {
                        Get.to(() => UserSelectDownload());
                      },
                    ),
                  if (isMyEvent) ...[
                    const SizedBox(height: 12),
                    MyButton(
                      buttonText: 'Delete Event',
                      bgColor: Colors.red,
                      onTap: () => _showDeleteDialog(context, event),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoChip(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? kSecondaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color ?? kSecondaryColor, width: 1),
      ),
      child: MyText(
        text: text,
        size: 11,
        color: color ?? kSecondaryColor,
        weight: FontWeight.w500,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date not set';
    return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getLocationText(Event event) {
    if (event.location != null &&
        event.location!.coordinates.isNotEmpty &&
        (event.location!.latitude != 0.0 || event.location!.longitude != 0.0)) {
      return '${event.location!.latitude.toStringAsFixed(4)}, ${event.location!.longitude.toStringAsFixed(4)}';
    }
    return 'Location not set';
  }

  String _getStatusText(EventStatus status) {
    switch (status) {
      case EventStatus.pending:
        return 'Pending';
      case EventStatus.confirmed:
        return 'Confirmed';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
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

  void _handleAcceptInvitation(Event event) async {
    if (event.id != null) {
      await controller.acceptEventInvitation(event.id!);
    }
  }

  void _showDeclineDialog(BuildContext context, Event event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Decline Invitation'),
        content: const Text(
          'Are you sure you want to decline this event invitation?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              if (event.id != null) {
                await controller.declineEventInvitation(event.id!);
                Get.back(); // Go back to events list
              }
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Event event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              if (event.id != null) {
                await controller.deleteEvent(event.id!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
