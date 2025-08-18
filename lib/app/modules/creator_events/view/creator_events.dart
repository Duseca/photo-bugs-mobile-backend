import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/creator_events/controller/creator_events_controller.dart';

import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class CreatorEvents extends GetView<CreatorEventsController> {
  const CreatorEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabs.length,
      child: Scaffold(
        appBar: simpleAppBar(title: 'My Events'),
        floatingActionButton: _buildFloatingActionButton(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildTabBar(), Expanded(child: _buildTabBarView())],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return SpeedDial(
      backgroundColor: kSecondaryColor,
      spaceBetweenChildren: 12,
      overlayColor: kBlackColor.withOpacity(0.1),
      foregroundColor: Colors.transparent,
      overlayOpacity: 0.2,
      elevation: 1.0,
      animationCurve: Curves.elasticInOut,
      isOpenOnStart: false,
      childMargin: EdgeInsets.zero,
      childPadding: const EdgeInsets.all(12),
      icon: Icons.add,
      activeIcon: Icons.close,
      iconTheme: const IconThemeData(color: kTertiaryColor),
      children: [
        _customSpeedDial(
          label: 'Book Event',
          onTap: controller.navigateToBookEvent,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: controller.tabController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      labelPadding: const EdgeInsets.symmetric(vertical: 12),
      dividerColor: kInputBorderColor,
      dividerHeight: 1,
      labelColor: kSecondaryColor,
      unselectedLabelColor: kQuaternaryColor,
      indicatorColor: kSecondaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      overlayColor: WidgetStatePropertyAll(kSecondaryColor.withOpacity(0.1)),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: kSecondaryColor,
        fontWeight: FontWeight.w500,
        fontFamily: AppFonts.inter,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        color: kQuaternaryColor,
        fontWeight: FontWeight.w500,
        fontFamily: AppFonts.inter,
      ),
      tabs: controller.tabs.map((e) => Text(e)).toList(),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: controller.tabController,
      children: [_BookedEventsTab(), _ClosedEventsTab()],
    );
  }

  SpeedDialChild _customSpeedDial({
    required String label,
    required VoidCallback onTap,
  }) {
    return SpeedDialChild(
      label: label,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelBackgroundColor: kSecondaryColor,
      foregroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      elevation: 0,
      labelShadow: const [],
      labelStyle: const TextStyle(
        fontSize: 15,
        color: kTertiaryColor,
        fontWeight: FontWeight.w600,
        fontFamily: AppFonts.inter,
      ),
    );
  }
}

// views/booked_events_tab.dart
class _BookedEventsTab extends GetView<CreatorEventsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.bookedEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              MyText(
                text: 'No booked events',
                size: 18,
                weight: FontWeight.w600,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              MyText(
                text: 'Book your first event using the + button',
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshEvents,
        child: Column(
          children: [
            _buildBookedEventsStats(),
            Expanded(
              child: ListView.builder(
                padding: AppSizes.DEFAULT,
                itemCount: controller.bookedEvents.length,
                itemBuilder: (context, index) {
                  final event = controller.bookedEvents[index];
                  return EventTile(
                    image: event['image'],
                    title: event['title'],
                    date: event['date'],
                    location: event['location'],
                    isClosed: false,
                    eventType: event['status'],
                    earnings: event['earnings'],
                    onTap: () => controller.navigateToEventDetails(event),
                    onLongPress: () => _showEventOptions(event),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBookedEventsStats() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSecondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kSecondaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  MyText(
                    text: controller.bookedEvents.length.toString(),
                    size: 24,
                    weight: FontWeight.w700,
                    color: kSecondaryColor,
                  ),
                  MyText(
                    text: 'Booked Events',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: kInputBorderColor),
            Expanded(
              child: Column(
                children: [
                  MyText(
                    text:
                        '\$${controller.totalBookedEarnings.toStringAsFixed(0)}',
                    size: 24,
                    weight: FontWeight.w700,
                    color: kSecondaryColor,
                  ),
                  MyText(
                    text: 'Total Earnings',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventOptions(Map<String, dynamic> event) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            MyText(text: event['title'], size: 18, weight: FontWeight.w600),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Mark as Completed'),
              onTap: () {
                Get.back();
                _showRatingDialog(event['id']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel Event'),
              onTap: () {
                Get.back();
                controller.cancelEvent(event['id']);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(String eventId) {
    double rating = 5.0;
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rate your experience with this event:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => rating = (index + 1).toDouble(),
                  icon: Icon(
                    Icons.star,
                    color: index < rating ? Colors.orange : Colors.grey,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.completeEvent(eventId, rating);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

// views/closed_events_tab.dart
class _ClosedEventsTab extends GetView<CreatorEventsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.closedEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              MyText(
                text: 'No closed events',
                size: 18,
                weight: FontWeight.w600,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              MyText(
                text: 'Completed events will appear here',
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshEvents,
        child: Column(
          children: [
            _buildClosedEventsStats(),
            Expanded(
              child: ListView.builder(
                padding: AppSizes.DEFAULT,
                itemCount: controller.closedEvents.length,
                itemBuilder: (context, index) {
                  final event = controller.closedEvents[index];
                  return EventTile(
                    image: event['image'],
                    title: event['title'],
                    date: event['date'],
                    location: event['location'],
                    isClosed: true,
                    eventType: event['status'],
                    earnings: event['earnings'],
                    rating: event['rating'],
                    onTap: () => controller.navigateToEventDetails(event),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildClosedEventsStats() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  MyText(
                    text: controller.closedEvents.length.toString(),
                    size: 24,
                    weight: FontWeight.w700,
                    color: Colors.grey[700]!,
                  ),
                  MyText(text: 'Completed', size: 12, color: kQuaternaryColor),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: kInputBorderColor),
            Expanded(
              child: Column(
                children: [
                  MyText(
                    text:
                        '\$${controller.totalClosedEarnings.toStringAsFixed(0)}',
                    size: 24,
                    weight: FontWeight.w700,
                    color: Colors.grey[700]!,
                  ),
                  MyText(
                    text: 'Total Earned',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: kInputBorderColor),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        text: controller.averageRating.toStringAsFixed(1),
                        size: 24,
                        weight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                    ],
                  ),
                  MyText(text: 'Avg Rating', size: 12, color: kQuaternaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== WIDGETS ====================

// widgets/event_tile.dart
class EventTile extends StatelessWidget {
  final String image, title, date, location, eventType;
  final bool isClosed;
  final double? earnings;
  final double? rating;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const EventTile({
    super.key,
    required this.image,
    required this.title,
    required this.date,
    required this.location,
    required this.isClosed,
    required this.eventType,
    this.earnings,
    this.rating,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isClosed
                      ? Colors.grey.withOpacity(0.3)
                      : kSecondaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CommonImageView(url: image, height: 80, width: 64, radius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MyText(
                              text: date,
                              size: 11,
                              color: kQuaternaryColor,
                              weight: FontWeight.w500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(),
                        ],
                      ),
                      MyText(
                        text: title,
                        weight: FontWeight.w500,
                        paddingTop: 8,
                        paddingBottom: 8,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Image.asset(Assets.imagesLocation, height: 16),
                          Expanded(
                            child: MyText(
                              text: location,
                              size: 11,
                              color: kQuaternaryColor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              paddingLeft: 4,
                            ),
                          ),
                        ],
                      ),
                      if (earnings != null || rating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (earnings != null) ...[
                              const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.green,
                              ),
                              MyText(
                                text: '\$${earnings!.toStringAsFixed(0)}',
                                size: 12,
                                color: Colors.green,
                                weight: FontWeight.w500,
                              ),
                            ],
                            if (earnings != null && rating != null)
                              const SizedBox(width: 16),
                            if (rating != null) ...[
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 2),
                              MyText(
                                text: rating!.toStringAsFixed(1),
                                size: 12,
                                color: Colors.orange,
                                weight: FontWeight.w500,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    switch (eventType.toLowerCase()) {
      case 'scheduled':
        statusColor = kSecondaryColor;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'closed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = kSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: MyText(
        text: isClosed ? 'Closed' : 'Scheduled',
        size: 10,
        color: statusColor,
        weight: FontWeight.w500,
      ),
    );
  }
}

SpeedDialChild customSpeedDial({
  required String label,
  required VoidCallback onTap,
}) {
  return SpeedDialChild(
    label: label,
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    labelBackgroundColor: kSecondaryColor,
    foregroundColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    elevation: 0,
    labelShadow: [],
    labelStyle: TextStyle(
      fontSize: 15,
      color: kTertiaryColor,
      fontWeight: FontWeight.w600,
      fontFamily: AppFonts.inter,
    ),
  );
}
