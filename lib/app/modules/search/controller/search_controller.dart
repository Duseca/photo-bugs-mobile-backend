import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/event_model.dart';

import 'package:photo_bug/app/modules/creator_events/widgets/send_event_quote.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/event_service.dart/event_service.dart';

class SearchController extends GetxController {
  // Services
  late final EventService _eventService;

  // Observable variables
  final RxList<Event> searchResults = <Event>[].obs;
  final RxList<Event> allEvents = <Event>[].obs; // Cache all events
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt resultsCount = 0.obs;

  // Search filters
  final RxString locationFilter = ''.obs;
  final RxString typeFilter = ''.obs; // Event type (Wedding, Birthday, etc.)
  final RxString roleFilter = ''.obs; // Photographer, Videographer, etc.
  final Rx<RangeValues> radiusRange = const RangeValues(0, 15).obs;
  final RxInt selectedRating = 0.obs; // 0 means "All"

  // Text controllers
  final TextEditingController searchTextController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Filter options
  final List<String> typeOptions = [
    'Wedding',
    'Birthday',
    'Corporate',
    'Party',
  ];
  final List<String> roleOptions = [
    'Photographer',
    'Videographer',
    'DJ',
    'Host',
  ];

  @override
  void onInit() {
    super.onInit();
    _eventService = EventService.instance;
    loadInitialResults();

    // Listen to search text changes
    searchTextController.addListener(() {
      searchQuery.value = searchTextController.text;
      if (searchQuery.value.isNotEmpty) {
        _debounceSearch();
      } else {
        _applyLocalFilters();
      }
    });
  }

  @override
  void onClose() {
    searchTextController.dispose();
    locationController.dispose();
    super.onClose();
  }

  // Load initial search results (all events)
  Future<void> loadInitialResults() async {
    isLoading.value = true;
    try {
      final response = await _eventService.getAllEvents();

      if (response.success && response.data != null) {
        allEvents.assignAll(response.data!);
        searchResults.assignAll(response.data!);
        resultsCount.value = response.data!.length;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to load events',
          snackPosition: SnackPosition.BOTTOM,
        );
        allEvents.clear();
        searchResults.clear();
        resultsCount.value = 0;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load search results: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      allEvents.clear();
      searchResults.clear();
      resultsCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  // Perform search with debouncing
  void _debounceSearch() {
    isSearching.value = true;

    // Debounce search by 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery.value == searchTextController.text) {
        performSearch();
      }
    });
  }

  // Perform search with current query and filters
  Future<void> performSearch() async {
    if (searchQuery.value.isEmpty && !_hasActiveFilters()) {
      searchResults.assignAll(allEvents);
      resultsCount.value = allEvents.length;
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    try {
      // If we have location/role/type/distance filters, use API search
      if (_shouldUseApiSearch()) {
        await _performApiSearch();
      } else {
        // Otherwise, use local filtering
        _applyLocalFilters();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Search failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSearching.value = false;
    }
  }

  // Determine if we should use API search
  bool _shouldUseApiSearch() {
    return roleFilter.value.isNotEmpty ||
        (locationFilter.value.isNotEmpty && radiusRange.value.end > 0);
  }

  // Perform API search with EventSearchParams
  Future<void> _performApiSearch() async {
    final searchParams = EventSearchParams(
      role: roleFilter.value.isNotEmpty ? roleFilter.value : null,
      type: typeFilter.value.isNotEmpty ? typeFilter.value : null,
      distance: radiusRange.value.end > 0 ? radiusRange.value.end : null,
      // Note: Location would need coordinates from locationController
      // You might need to geocode the location string first
    );

    final response = await _eventService.searchEvents(searchParams);

    if (response.success && response.data != null) {
      // Apply local filters on top of API results
      List<Event> results = response.data!;

      // Apply text search locally
      if (searchQuery.value.isNotEmpty) {
        results = _filterByQuery(results);
      }

      searchResults.assignAll(results);
      resultsCount.value = results.length;
    } else {
      Get.snackbar(
        'Error',
        response.error ?? 'Search failed',
        snackPosition: SnackPosition.BOTTOM,
      );
      searchResults.clear();
      resultsCount.value = 0;
    }
  }

  // Apply filters locally on cached events
  void _applyLocalFilters() {
    List<Event> filtered = List.from(allEvents);

    // Filter by search query (name, type)
    if (searchQuery.value.isNotEmpty) {
      filtered = _filterByQuery(filtered);
    }

    // Filter by type
    if (typeFilter.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (event) =>
                    event.type?.toLowerCase() == typeFilter.value.toLowerCase(),
              )
              .toList();
    }

    // Filter by role
    if (roleFilter.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (event) =>
                    event.role?.toLowerCase() == roleFilter.value.toLowerCase(),
              )
              .toList();
    }

    // Note: Location filtering by coordinates would require distance calculation
    // This is better handled by API search with EventSearchParams

    searchResults.assignAll(filtered);
    resultsCount.value = filtered.length;
  }

  // Filter events by search query
  List<Event> _filterByQuery(List<Event> events) {
    final query = searchQuery.value.toLowerCase();
    return events.where((event) {
      final name = event.name.toLowerCase();
      final type = event.type?.toLowerCase() ?? '';
      final role = event.role?.toLowerCase() ?? '';

      return name.contains(query) ||
          type.contains(query) ||
          role.contains(query);
    }).toList();
  }

  // Apply filters
  void applyFilters() async {
    isLoading.value = true;
    try {
      await performSearch();

      Get.back(); // Close filter bottom sheet
      Get.snackbar(
        'Success',
        'Filters applied - ${resultsCount.value} results found',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to apply filters: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear all filters
  void clearFilters() {
    locationFilter.value = '';
    typeFilter.value = '';
    roleFilter.value = '';
    radiusRange.value = const RangeValues(0, 15);
    selectedRating.value = 0;

    locationController.clear();
    searchTextController.clear();

    _eventService.clearSearchResults();
    searchResults.assignAll(allEvents);
    resultsCount.value = allEvents.length;
  }

  // Check if there are active filters
  bool _hasActiveFilters() {
    return locationFilter.value.isNotEmpty ||
        typeFilter.value.isNotEmpty ||
        roleFilter.value.isNotEmpty ||
        selectedRating.value > 0 ||
        radiusRange.value.start != 0 ||
        radiusRange.value.end != 15;
  }

  // Set type filter
  void setTypeFilter(String? type) {
    typeFilter.value = type ?? '';
  }

  // Set role filter
  void setRoleFilter(String? role) {
    roleFilter.value = role ?? '';
  }

  // Set radius range
  void setRadiusRange(RangeValues range) {
    radiusRange.value = range;
  }

  // Set selected rating
  void setSelectedRating(int rating) {
    selectedRating.value = rating;
  }

  // Navigate to search details
  void navigateToSearchDetails(Event event) {
    Get.toNamed(
      Routes.SEARCH_DETAILS,
      arguments: {'eventId': event.id, 'event': event},
    );
  }

  // Show map view
  void showMapView() {
    Get.snackbar(
      'Map View',
      'Map view feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Refresh search results
  Future<void> refreshResults() async {
    await loadInitialResults();
    if (searchQuery.value.isNotEmpty || _hasActiveFilters()) {
      performSearch();
    }
  }

  // Get formatted results text
  String get resultsText => '${resultsCount.value} results found';
}

// controllers/search_details_controller.dart
class SearchDetailsController extends GetxController {
  // Services
  late final EventService _eventService;

  // Observable variables
  final Rx<Event?> eventDetails = Rx<Event?>(null);
  final RxBool isLoading = false.obs;
  final RxString eventId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _eventService = EventService.instance;

    // Get event data from arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      eventId.value = arguments['eventId'] ?? '';

      // If event object is passed directly, use it
      if (arguments['event'] != null) {
        eventDetails.value = arguments['event'] as Event;
      }
    }

    // If no event details passed, load from API
    if (eventDetails.value == null && eventId.value.isNotEmpty) {
      loadEventDetails();
    }
  }

  // Load event details from API
  Future<void> loadEventDetails() async {
    if (eventId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid event ID',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _eventService.getEventById(eventId.value);

      if (response.success && response.data != null) {
        eventDetails.value = response.data;
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to load event details',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load event details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Share event
  void shareEvent() {
    if (eventDetails.value != null) {
      // Implement actual sharing functionality
      Get.snackbar(
        'Share',
        'Sharing: ${eventDetails.value!.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to send quote
  void navigateToSendQuote() {
    if (eventDetails.value != null) {
      Get.to(
        () => const SendEventQuote(),
        arguments: {
          'eventId': eventDetails.value!.id,
          'eventDetails': eventDetails.value,
        },
      );
    }
  }

  // Refresh event details
  Future<void> refreshEventDetails() async {
    await loadEventDetails();
  }

  // Get recipient images (limited to display)
  List<String> get recipientImages {
    if (eventDetails.value == null || eventDetails.value!.recipients == null) {
      return [];
    }
    // Map recipient IDs to images if needed
    // This might require additional API calls to get user details
    return eventDetails.value!.recipients!.take(5).map((recipient) {
      // Return placeholder or fetch user images
      return 'placeholder_image_url';
    }).toList();
  }

  // Get recipient count
  int get recipientCount {
    return eventDetails.value?.recipients?.length ?? 0;
  }

  // Format date for display
  String get formattedDate {
    if (eventDetails.value?.date == null) return '';
    final date = eventDetails.value!.date!;
    return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
  }

  // Format time for display (using Event's computed properties)
  String get formattedStartTime {
    return eventDetails.value?.formattedStartTime ?? '';
  }

  String get formattedEndTime {
    return eventDetails.value?.formattedEndTime ?? '';
  }

  // Helper to get month name
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

  // Get event type display text
  String get eventTypeText {
    return eventDetails.value?.type ?? 'Event';
  }

  // Get location text
  String get locationText {
    final location = eventDetails.value?.location;
    if (location == null) return 'Location not specified';

    // Format coordinates as "Lat: X.XX, Lng: Y.YY"
    return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
  }

  // Get event name
  String get eventName {
    return eventDetails.value?.name ?? 'Untitled Event';
  }

  // Get event image
  String? get eventImage {
    return eventDetails.value?.image;
  }

  // Check if user can send quote (is photographer)
  bool get canSendQuote {
    // Add logic to check if current user is a photographer/creator
    // and can send quotes for this event
    return eventDetails.value != null;
  }

  // Get event status text
  String get statusText {
    return eventDetails.value?.status.value ?? 'pending';
  }

  // Get role text
  String get roleText {
    return eventDetails.value?.role ?? '';
  }
}
