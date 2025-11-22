import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';

import 'package:photo_bug/app/modules/creator_events/widgets/creator_event_details.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_add_event.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_event_details.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/event_service.dart/event_service.dart';

class UserEventsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Services
  final EventService _eventService = EventService.instance;

  // Observable variables
  final RxList<Event> myEvents = <Event>[].obs;
  final RxList<Event> sharedEvents = <Event>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedType = 'All'.obs;
  final RxString selectedSort = 'None'.obs;
  final RxString selectedLocation = ''.obs;

  // Tab controller
  late TabController tabController;

  // Stream subscriptions
  StreamSubscription? _createdEventsSubscription;
  StreamSubscription? _photographerEventsSubscription;

  // Filter options
  final List<String> typeOptions = ['All', 'Pending', 'Confirmed', 'Completed'];
  final List<String> sortOptions = ['None', 'Old to new', 'New to Old'];
  final List<String> locationOptions = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Miami',
  ];

  // Get current user ID from AuthService
  String? getCurrentUserId() {
    try {
      final authService = Get.find<AuthService>();
      return authService.currentUser?.id;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _setupEventStreams();
    loadEvents();
  }

  @override
  void onClose() {
    tabController.dispose();
    _createdEventsSubscription?.cancel();
    _photographerEventsSubscription?.cancel();
    super.onClose();
  }

  // Setup real-time event streams
  void _setupEventStreams() {
    // Listen to created events stream
    _createdEventsSubscription = _eventService.createdEventsStream.listen(
      (events) {
        myEvents.value = events;
      },
      onError: (error) {
        Get.snackbar(
          'Error',
          'Failed to load events: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    // Listen to photographer events stream (shared events)
    _photographerEventsSubscription = _eventService.photographerEventsStream
        .listen(
          (events) {
            sharedEvents.value = events;
          },
          onError: (error) {
            Get.snackbar(
              'Error',
              'Failed to load shared events: $error',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
  }

  // Load events data from API
  Future<void> loadEvents() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      // Load both created and photographer events
      await Future.wait([
        _eventService.getUserCreatedEvents(),
        _eventService.getUserPhotographerEvents(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load events',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create new event
  Future<ApiResponse<Event>> createEvent(CreateEventRequest request) async {
    isLoading.value = true;
    try {
      final response = await _eventService.createEvent(request);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Event created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      return response;
    } finally {
      isLoading.value = false;
    }
  }

  // Get event by ID from local lists or service
  Event? getEventById(String? eventId) {
    if (eventId == null) return null;

    // Try to find in my events
    try {
      return myEvents.firstWhere((e) => e.id == eventId);
    } catch (e) {
      // Try to find in shared events
      try {
        return sharedEvents.firstWhere((e) => e.id == eventId);
      } catch (e) {
        // Return from service if available
        return _eventService.selectedEvent;
      }
    }
  }

  // Filter events by type
  void filterByType(String type) {
    selectedType.value = type;
  }

  // Sort events
  void sortEvents(String sortBy) {
    selectedSort.value = sortBy;
  }

  // Filter by location
  void filterByLocation(String location) {
    selectedLocation.value = location;
  }

  // Get filtered my events
  List<Event> get filteredMyEvents {
    List<Event> events = List.from(myEvents);

    // Filter by type/status
    if (selectedType.value != 'All') {
      final statusFilter = _getEventStatusFromType(selectedType.value);
      events = events.where((event) => event.status == statusFilter).toList();
    }

    // Sort events
    events = _applySorting(events);

    return events;
  }

  // Get filtered shared events
  List<Event> get filteredSharedEvents {
    List<Event> events = List.from(sharedEvents);

    // Filter by type/status
    if (selectedType.value != 'All') {
      final statusFilter = _getEventStatusFromType(selectedType.value);
      events = events.where((event) => event.status == statusFilter).toList();
    }

    // Sort events
    events = _applySorting(events);

    return events;
  }

  // Apply sorting to events list
  List<Event> _applySorting(List<Event> events) {
    if (selectedSort.value == 'Old to new') {
      events.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.now();
        final dateB = b.createdAt ?? DateTime.now();
        return dateA.compareTo(dateB);
      });
    } else if (selectedSort.value == 'New to Old') {
      events.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.now();
        final dateB = b.createdAt ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
    }
    return events;
  }

  // Convert filter type to EventStatus
  EventStatus _getEventStatusFromType(String type) {
    switch (type) {
      case 'Pending':
        return EventStatus.pending;
      case 'Confirmed':
        return EventStatus.confirmed;
      case 'Completed':
        return EventStatus.completed;
      default:
        return EventStatus.pending;
    }
  }

  // Navigate to add new event
  void navigateToAddEvent() {
    Get.to(() => const UserAddEvent());
  }

  // Navigate to event details
  void navigateToEventDetails(Event event, {bool isMyEvent = true}) {
    // Set selected event in service
    _eventService.setSelectedEvent(event);

    if (!isMyEvent) {
      Get.to(
        () => const CreatorEventDetails(),
        arguments: {
          'eventId': event.id,
          'event': _convertEventToMap(event),
          'isMyEvent': true,
        },
      );
    } else {
      Get.to(
        () => const UserEventDetails(),
        arguments: {'eventId': event.id, 'event': event, 'isMyEvent': false},
      );
    }
  }

  // Convert Event model to Map for compatibility
  Map<String, dynamic> _convertEventToMap(Event event) {
    return {
      'id': event.id,
      'title': event.name,
      'image': event.image ?? '',
      'date': event.date?.toString() ?? '',
      'location':
          event.location != null
              ? '${event.location!.latitude}, ${event.location!.longitude}'
              : '',
      'eventType': event.status.value,
      'category': event.type ?? '',
      'createdAt': event.createdAt,
    };
  }

  // Refresh events
  Future<void> refreshEvents() async {
    await loadEvents();
  }

  // Get current tab index
  int get currentTabIndex => tabController.index;

  // Switch to specific tab
  void switchToTab(int index) {
    tabController.animateTo(index);
  }

  // Accept event invitation
  Future<void> acceptEventInvitation(String eventId) async {
    try {
      isLoading.value = true;
      final response = await _eventService.acceptEventInvitation(eventId);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Event invitation accepted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh events to update lists
        await loadEvents();
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to accept invitation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Decline event invitation
  Future<void> declineEventInvitation(String eventId) async {
    try {
      isLoading.value = true;
      final response = await _eventService.declineEventInvitation(eventId);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Event invitation declined',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        // Refresh events to update lists
        await loadEvents();
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to decline invitation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      isLoading.value = true;
      final response = await _eventService.deleteEvent(eventId);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Event deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back(); // Go back if on event details page
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to delete event',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
