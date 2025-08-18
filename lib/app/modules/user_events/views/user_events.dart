// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/user_events/controllers/user_events_controller.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class UserEvents extends GetView<UserEventsController> {
  const UserEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: simpleAppBar(title: 'My Events'),
        floatingActionButton: _buildFloatingActionButton(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTabsAndFilters(),
            const SizedBox(height: 10),
            Expanded(child: _buildTabBarView()),
          ],
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
          label: 'New Event',
          onTap: controller.navigateToAddEvent,
        ),
      ],
    );
  }

  Widget _buildTabsAndFilters() {
    return Padding(
      padding: AppSizes.HORIZONTAL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: controller.tabController,
            labelPadding: const EdgeInsets.symmetric(vertical: 12),
            dividerColor: kInputBorderColor,
            dividerHeight: 1,
            labelColor: kSecondaryColor,
            unselectedLabelColor: kQuaternaryColor,
            indicatorColor: kSecondaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            overlayColor: WidgetStatePropertyAll(
              kSecondaryColor.withOpacity(0.1),
            ),
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
            tabs: const [Text('My Events'), Text('Shared Events')],
          ),
          const SizedBox(height: 10),
          _buildFilterRow(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => CustomDropDown(
              hint: 'Type',
              selectedValue:
                  controller.selectedType.value == 'All'
                      ? null
                      : controller.selectedType.value,
              items: controller.typeOptions,
              onChanged: (value) => controller.filterByType(value ?? 'All'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Obx(
            () => CustomDropDown(
              hint: 'Sort by',
              selectedValue:
                  controller.selectedSort.value == 'None'
                      ? null
                      : controller.selectedSort.value,
              items: controller.sortOptions,
              onChanged: (value) => controller.sortEvents(value ?? 'None'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Obx(
            () => CustomDropDown(
              hint: 'Location',
              selectedValue:
                  controller.selectedLocation.value.isEmpty
                      ? null
                      : controller.selectedLocation.value,
              items: controller.locationOptions,
              onChanged: (value) => controller.filterByLocation(value ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: controller.tabController,
      children: [_MyEventsTab(), _SharedEventsTab()],
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

// views/my_events_tab.dart
class _MyEventsTab extends GetView<UserEventsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final events = controller.filteredMyEvents;

      if (events.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              MyText(
                text: 'No events found',
                size: 18,
                weight: FontWeight.w600,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              MyText(
                text: 'Create your first event using the + button',
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshEvents,
        child: ListView.builder(
          padding: AppSizes.DEFAULT,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              title: event['title'],
              image: event['image'],
              date: event['date'],
              location: event['location'],
              eventType: event['eventType'],
              onTap:
                  () =>
                      controller.navigateToEventDetails(event, isMyEvent: true),
            );
          },
        ),
      );
    });
  }
}

// views/shared_events_tab.dart
class _SharedEventsTab extends GetView<UserEventsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final events = controller.filteredSharedEvents;

      if (events.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              MyText(
                text: 'No shared events',
                size: 18,
                weight: FontWeight.w600,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              MyText(
                text: 'Events shared with you will appear here',
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshEvents,
        child: ListView.builder(
          padding: AppSizes.DEFAULT,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              title: event['title'],
              image: event['image'],
              date: event['date'],
              location: event['location'],
              eventType: event['eventType'],
              onTap:
                  () => controller.navigateToEventDetails(
                    event,
                    isMyEvent: false,
                  ),
            );
          },
        ),
      );
    });
  }
}

// ==================== WIDGETS ====================

// widgets/event_card.dart
class EventCard extends StatelessWidget {
  final String image, title, date, location, eventType;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.image,
    required this.title,
    required this.date,
    required this.location,
    required this.eventType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: onTap,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(eventType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getEventTypeColor(eventType),
                            width: 1,
                          ),
                        ),
                        child: MyText(
                          text: eventType,
                          size: 10,
                          color: _getEventTypeColor(eventType),
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  MyText(
                    text: title,
                    weight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    paddingTop: 8,
                    paddingBottom: 8,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'scheduled':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return kSecondaryColor;
    }
  }
}
