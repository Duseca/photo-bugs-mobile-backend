import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/creator_event_details.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_add_event.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_event_details.dart';

class UserEventsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable variables
  final RxList<Map<String, dynamic>> myEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sharedEvents =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedType = 'All'.obs;
  final RxString selectedSort = 'None'.obs;
  final RxString selectedLocation = ''.obs;

  // Tab controller
  late TabController tabController;

  // Filter options
  final List<String> typeOptions = ['All', 'Scheduled', 'Pending'];
  final List<String> sortOptions = ['None', 'Old to new', 'New to Old'];
  final List<String> locationOptions = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Miami',
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
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

      // Sample my events data
      final sampleMyEvents = [
        {
          'id': '1',
          'title': 'Den & Tina wedding event',
          'image': 'dummyImg',
          'date': '27 Sep, 2024',
          'location': '385 Main Street, Suite 52, USA',
          'eventType': 'Scheduled',
          'category': 'Wedding',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '2',
          'title': 'Corporate Annual Meeting',
          'image': 'dummyImg',
          'date': '30 Sep, 2024',
          'location': '123 Business Ave, Downtown, USA',
          'eventType': 'Pending',
          'category': 'Corporate',
          'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        },
      ];

      // Sample shared events data
      final sampleSharedEvents = [
        {
          'id': '3',
          'title': 'Birthday Celebration',
          'image': 'dummyImg',
          'date': '28 Sep, 2024',
          'location': '456 Party Lane, City, USA',
          'eventType': 'Scheduled',
          'category': 'Birthday',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '4',
          'title': 'Art Exhibition Opening',
          'image': 'dummyImg',
          'date': '01 Oct, 2024',
          'location': '789 Gallery St, Arts District, USA',
          'eventType': 'Pending',
          'category': 'Art',
          'createdAt': DateTime.now().subtract(const Duration(days: 4)),
        },
      ];

      myEvents.assignAll(sampleMyEvents);
      sharedEvents.assignAll(sampleSharedEvents);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter events by type
  void filterByType(String type) {
    selectedType.value = type;
    _applyFilters();
  }

  // Sort events
  void sortEvents(String sortBy) {
    selectedSort.value = sortBy;
    _applyFilters();
  }

  // Filter by location
  void filterByLocation(String location) {
    selectedLocation.value = location;
    _applyFilters();
  }

  // Apply all filters and sorting
  void _applyFilters() {
    // This would filter and sort the events based on selected criteria
    // For now, just reload the data
    loadEvents();
  }

  // Get filtered my events
  List<Map<String, dynamic>> get filteredMyEvents {
    List<Map<String, dynamic>> events = List.from(myEvents);

    // Filter by type
    if (selectedType.value != 'All') {
      events =
          events
              .where((event) => event['eventType'] == selectedType.value)
              .toList();
    }

    // Sort events
    if (selectedSort.value == 'Old to new') {
      events.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
    } else if (selectedSort.value == 'New to Old') {
      events.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    }

    return events;
  }

  // Get filtered shared events
  List<Map<String, dynamic>> get filteredSharedEvents {
    List<Map<String, dynamic>> events = List.from(sharedEvents);

    // Filter by type
    if (selectedType.value != 'All') {
      events =
          events
              .where((event) => event['eventType'] == selectedType.value)
              .toList();
    }

    // Sort events
    if (selectedSort.value == 'Old to new') {
      events.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
    } else if (selectedSort.value == 'New to Old') {
      events.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    }

    return events;
  }

  // Navigate to add new event
  void navigateToAddEvent() {
    Get.to(() => const UserAddEvent());
  }

  // Navigate to event details
  void navigateToEventDetails(
    Map<String, dynamic> event, {
    bool isMyEvent = true,
  }) {
    if (isMyEvent) {
      Get.to(
        () => const CreatorEventDetails(),
        arguments: {'eventId': event['id'], 'event': event, 'isMyEvent': true},
      );
    } else {
      Get.to(
        () => const UserEventDetails(),
        arguments: {'eventId': event['id'], 'event': event, 'isMyEvent': false},
      );
    }
  }

  // Refresh events
  Future<void> refreshEvents() async {
    loadEvents();
  }

  // Get current tab index
  int get currentTabIndex => tabController.index;

  // Switch to specific tab
  void switchToTab(int index) {
    tabController.animateTo(index);
  }
}
