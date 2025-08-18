import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/creator_event_details.dart';
import 'package:photo_bug/app/modules/search/views/search_screen.dart';

class CreatorEventsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable variables
  final RxList<Map<String, dynamic>> bookedEvents =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> closedEvents =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Tab controller
  late TabController tabController;

  // Tabs
  final List<String> tabs = ['Booked Events', 'Closed Events'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    loadEvents();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Load events data
  void loadEvents() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample booked events data
      final sampleBookedEvents = [
        {
          'id': '1',
          'title': 'Den & Tina wedding event',
          'image': 'dummyImg',
          'date': '29 Sep, 2024',
          'location': '385 Main Street, Suite 52, USA',
          'status': 'Scheduled',
          'eventType': 'Wedding',
          'clientName': 'Den & Tina',
          'earnings': 500.0,
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '2',
          'title': 'Corporate Photography Session',
          'image': 'dummyImg',
          'date': '02 Oct, 2024',
          'location': '123 Business Tower, Downtown, USA',
          'status': 'Scheduled',
          'eventType': 'Corporate',
          'clientName': 'ABC Corp',
          'earnings': 300.0,
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
      ];

      // Sample closed events data
      final sampleClosedEvents = [
        {
          'id': '3',
          'title': 'Birthday Photo Shoot',
          'image': 'dummyImg',
          'date': '15 Sep, 2024',
          'location': '456 Family Home, Suburb, USA',
          'status': 'Closed',
          'eventType': 'Birthday',
          'clientName': 'Johnson Family',
          'earnings': 200.0,
          'completedAt': DateTime.now().subtract(const Duration(days: 10)),
          'rating': 4.8,
        },
        {
          'id': '4',
          'title': 'Graduation Ceremony',
          'image': 'dummyImg',
          'date': '10 Sep, 2024',
          'location': '789 University Hall, City, USA',
          'status': 'Closed',
          'eventType': 'Graduation',
          'clientName': 'City University',
          'earnings': 400.0,
          'completedAt': DateTime.now().subtract(const Duration(days: 15)),
          'rating': 5.0,
        },
      ];

      bookedEvents.assignAll(sampleBookedEvents);
      closedEvents.assignAll(sampleClosedEvents);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh events
  Future<void> refreshEvents() async {
    isRefreshing.value = true;
    loadEvents();
    isRefreshing.value = false;
  }

  // Navigate to book new event (search)
  void navigateToBookEvent() {
    Get.to(() => const SearchScreen());
  }

  // Navigate to event details
  void navigateToEventDetails(Map<String, dynamic> event) {
    Get.to(
      () => const CreatorEventDetails(),
      arguments: {
        'eventId': event['id'],
        'event': event,
        'isBooked':
            !event['status'].toString().toLowerCase().contains('closed'),
      },
    );
  }

  // Get current tab index
  int get currentTabIndex => tabController.index;

  // Switch to specific tab
  void switchToTab(int index) {
    tabController.animateTo(index);
  }

  // Get total earnings for booked events
  double get totalBookedEarnings {
    return bookedEvents.fold(
      0.0,
      (sum, event) => sum + (event['earnings'] ?? 0.0),
    );
  }

  // Get total earnings for closed events
  double get totalClosedEarnings {
    return closedEvents.fold(
      0.0,
      (sum, event) => sum + (event['earnings'] ?? 0.0),
    );
  }

  // Get average rating for closed events
  double get averageRating {
    final ratings =
        closedEvents
            .where((event) => event['rating'] != null)
            .map((event) => event['rating'] as double)
            .toList();

    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  // Cancel booked event
  void cancelEvent(String eventId) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Cancel Event'),
          content: const Text('Are you sure you want to cancel this event?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );

      if (result == true) {
        // Move event from booked to closed with cancelled status
        final eventIndex = bookedEvents.indexWhere(
          (event) => event['id'] == eventId,
        );
        if (eventIndex != -1) {
          final event = Map<String, dynamic>.from(bookedEvents[eventIndex]);
          event['status'] = 'Cancelled';
          event['completedAt'] = DateTime.now();

          bookedEvents.removeAt(eventIndex);
          closedEvents.insert(0, event);

          Get.snackbar('Success', 'Event cancelled successfully');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel event');
    }
  }

  // Complete booked event
  void completeEvent(String eventId, double rating) async {
    try {
      final eventIndex = bookedEvents.indexWhere(
        (event) => event['id'] == eventId,
      );
      if (eventIndex != -1) {
        final event = Map<String, dynamic>.from(bookedEvents[eventIndex]);
        event['status'] = 'Completed';
        event['completedAt'] = DateTime.now();
        event['rating'] = rating;

        bookedEvents.removeAt(eventIndex);
        closedEvents.insert(0, event);

        Get.snackbar('Success', 'Event marked as completed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete event');
    }
  }
}
