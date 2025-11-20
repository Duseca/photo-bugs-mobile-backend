// modules/search/controllers/search_controller.dart - UPDATED COMPLETE VERSION

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/location_model.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/send_event_quote.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/event_service.dart/event_service.dart';

class SearchController extends GetxController {
  // Services
  late final EventService _eventService;

  // Observable variables
  final RxList<Event> searchResults = <Event>[].obs;
  final RxList<Event> allEvents = <Event>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt resultsCount = 0.obs;

  // Search filters
  final RxString locationFilter = ''.obs;
  final RxString typeFilter = ''.obs;
  final RxString roleFilter = ''.obs;
  final Rx<RangeValues> radiusRange = const RangeValues(0, 50).obs;
  final RxInt selectedRating = 0.obs;
  final RxString statusFilter = ''.obs; // New: Status filter
  final Rx<DateTime?> startDateFilter = Rx<DateTime?>(
    null,
  ); // New: Start date filter
  final Rx<DateTime?> endDateFilter = Rx<DateTime?>(
    null,
  ); // New: End date filter
  final RxBool matureContentFilter = false.obs; // New: Mature content filter

  // Text controllers
  final TextEditingController searchTextController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Filter options - will be populated from API or predefined
  final List<String> typeOptions = [
    'Photography Workshop',
    'Wedding',
    'Birthday',
    'Corporate Event',
    'Party',
  ];

  final List<String> roleOptions = [
    'Wildlife Photographer',
    'Photographer',
    'Videographer',
    'Event Photographer',
  ];

  final List<String> statusOptions = [
    'pending',
    'confirmed',
    'ongoing',
    'completed',
    'cancelled',
  ];

  // Current user location (can be set from GPS)
  Location? currentLocation;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    loadInitialResults();

    // Listen to search text changes with debounce
    searchTextController.addListener(_onSearchTextChanged);
  }

  @override
  void onClose() {
    searchTextController.dispose();
    locationController.dispose();
    _searchDebounceTimer?.cancel();
    super.onClose();
  }

  void _initializeService() {
    try {
      _eventService = EventService.instance;
    } catch (e) {
      print('❌ Error initializing EventService: $e');
    }
  }

  /// Load initial search results (all events)
  Future<void> loadInitialResults() async {
    try {
      isLoading.value = true;

      final response = await _eventService.getAllEvents();

      if (response.success && response.data != null) {
        allEvents.assignAll(response.data!);
        searchResults.assignAll(response.data!);
        resultsCount.value = response.data!.length;
        print('✅ Loaded ${response.data!.length} events');
      } else {
        _showError(response.error ?? 'Failed to load events');
        allEvents.clear();
        searchResults.clear();
        resultsCount.value = 0;
      }
    } catch (e) {
      print('❌ Error loading initial results: $e');
      _showError('Failed to load search results');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle search text changes with debounce
  void _onSearchTextChanged() {
    searchQuery.value = searchTextController.text;

    // Cancel previous search
    if (_searchDebounceTimer?.isActive ?? false) {
      _searchDebounceTimer!.cancel();
    }

    // Start new search after 500ms
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      performSearch();
    });
  }

  Timer? _searchDebounceTimer;

  /// Perform search with current query and filters
  Future<void> performSearch() async {
    // If no search query and no active filters, show all events
    if (searchQuery.value.isEmpty && !_hasActiveFilters()) {
      searchResults.assignAll(allEvents);
      resultsCount.value = allEvents.length;
      return;
    }

    try {
      isSearching.value = true;

      // ALWAYS use API search when any filter is active or search query exists
      // This ensures we send the complete query to the backend
      if (_shouldUseApiSearch()) {
        await _performApiSearch();
      } else {
        // Use local filtering only when no filters and just browsing
        _applyLocalFilters();
      }
    } catch (e) {
      print('❌ Search error: $e');
      _showError('Search failed');
    } finally {
      isSearching.value = false;
    }
  }

  /// Determine if we should use API search
  bool _shouldUseApiSearch() {
    return locationFilter.value.isNotEmpty ||
        roleFilter.value.isNotEmpty ||
        typeFilter.value.isNotEmpty ||
        statusFilter.value.isNotEmpty ||
        startDateFilter.value != null ||
        endDateFilter.value != null ||
        searchQuery
            .value
            .isNotEmpty || // IMPORTANT: Also use API for text search
        radiusRange.value.end < 50; // If radius is adjusted
  }

  /// Perform API search with filters - COMPLETE IMPLEMENTATION
  Future<void> _performApiSearch() async {
    // Parse location coordinates from locationController
    Location? searchLocation;
    if (locationFilter.value.isNotEmpty) {
      searchLocation = _parseLocationFromText(locationFilter.value);
    }

    // Build complete search parameters
    final searchParams = EventSearchParams(
      // Location-based search
      location: searchLocation,
      distance: radiusRange.value.end > 0 ? radiusRange.value.end : null,

      // Filter parameters
      role: roleFilter.value.isNotEmpty ? roleFilter.value : null,
      type: typeFilter.value.isNotEmpty ? typeFilter.value : null,
      status: statusFilter.value.isNotEmpty ? statusFilter.value : null,

      // Text search parameter - THIS IS CRITICAL
      name: searchQuery.value.isNotEmpty ? searchQuery.value : null,

      // Date range filters
      startDate: startDateFilter.value,
      endDate: endDateFilter.value,

      // Content filter
      matureContent: matureContentFilter.value ? true : null,
    );

    print('🔍 Searching with complete params: ${searchParams.toQueryParams()}');
    print('🔍 Query String will be: ${_buildQueryString(searchParams)}');

    final response = await _eventService.searchEvents(searchParams);

    if (response.success && response.data != null) {
      List<Event> results = response.data!;

      // Results are already filtered by backend, no need for local filtering
      searchResults.assignAll(results);
      resultsCount.value = results.length;

      print('✅ Search completed: ${results.length} results');
    } else {
      _showError(response.error ?? 'Search failed');
      searchResults.clear();
      resultsCount.value = 0;
    }
  }

  /// Build query string for debugging (helper method)
  String _buildQueryString(EventSearchParams params) {
    final queryParams = params.toQueryParams();
    return queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Apply filters locally on cached events (only for browsing without filters)
  void _applyLocalFilters() {
    List<Event> filtered = List.from(allEvents);

    // Filter by search query
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

    // Filter by status
    if (statusFilter.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (event) =>
                    event.status.value.toLowerCase() ==
                    statusFilter.value.toLowerCase(),
              )
              .toList();
    }

    searchResults.assignAll(filtered);
    resultsCount.value = filtered.length;
  }

  /// Filter events by search query
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

  /// Parse location from text (expects format: "lng,lat" or "lat,lng")
  Location? _parseLocationFromText(String text) {
    try {
      final parts = text.split(',');
      if (parts.length == 2) {
        final first = double.parse(parts[0].trim());
        final second = double.parse(parts[1].trim());

        // Assuming user enters as "lng,lat" format based on your example
        // If your backend expects "lat,lng", swap these
        return Location.fromCoordinates(first, second);
      }
    } catch (e) {
      print('❌ Failed to parse location: $e');
    }
    return null;
  }

  /// Apply filters and close bottom sheet
  Future<void> applyFilters() async {
    try {
      await performSearch();
      Get.back(); // Close filter bottom sheet
      _showSuccess('Filters applied - ${resultsCount.value} results found');
    } catch (e) {
      _showError('Failed to apply filters');
    }
  }

  /// Clear all filters
  void clearFilters() {
    locationFilter.value = '';
    typeFilter.value = '';
    roleFilter.value = '';
    statusFilter.value = '';
    radiusRange.value = const RangeValues(0, 50);
    selectedRating.value = 0;
    startDateFilter.value = null;
    endDateFilter.value = null;
    matureContentFilter.value = false;

    locationController.clear();
    searchTextController.clear();

    searchResults.assignAll(allEvents);
    resultsCount.value = allEvents.length;
  }

  /// Check if there are active filters
  bool _hasActiveFilters() {
    return locationFilter.value.isNotEmpty ||
        typeFilter.value.isNotEmpty ||
        roleFilter.value.isNotEmpty ||
        statusFilter.value.isNotEmpty ||
        radiusRange.value.start != 0 ||
        radiusRange.value.end != 50 ||
        startDateFilter.value != null ||
        endDateFilter.value != null ||
        matureContentFilter.value;
  }

  /// Set type filter
  void setTypeFilter(String? type) {
    typeFilter.value = type ?? '';
  }

  /// Set role filter
  void setRoleFilter(String? role) {
    roleFilter.value = role ?? '';
  }

  /// Set status filter
  void setStatusFilter(String? status) {
    statusFilter.value = status ?? '';
  }

  /// Set radius range
  void setRadiusRange(RangeValues range) {
    radiusRange.value = range;
  }

  /// Set selected rating
  void setSelectedRating(int rating) {
    selectedRating.value = rating;
  }

  /// Set start date filter
  void setStartDateFilter(DateTime? date) {
    startDateFilter.value = date;
  }

  /// Set end date filter
  void setEndDateFilter(DateTime? date) {
    endDateFilter.value = date;
  }

  /// Toggle mature content filter
  void toggleMatureContentFilter(bool value) {
    matureContentFilter.value = value;
  }

  /// Navigate to search details
  void navigateToSearchDetails(Event event) {
    Get.toNamed(
      Routes.SEARCH_DETAILS,
      arguments: {'eventId': event.id, 'event': event},
    );
  }

  /// Show map view
  void showMapView() {
    _showInfo('Map view feature coming soon!');
  }

  /// Refresh search results
  Future<void> refreshResults() async {
    await loadInitialResults();
    if (searchQuery.value.isNotEmpty || _hasActiveFilters()) {
      performSearch();
    }
  }

  /// Get formatted results text
  String get resultsText => '${resultsCount.value} results found';

  /// Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (locationFilter.value.isNotEmpty) count++;
    if (typeFilter.value.isNotEmpty) count++;
    if (roleFilter.value.isNotEmpty) count++;
    if (statusFilter.value.isNotEmpty) count++;
    if (radiusRange.value.end < 50) count++;
    if (startDateFilter.value != null) count++;
    if (endDateFilter.value != null) count++;
    if (matureContentFilter.value) count++;
    return count;
  }

  /// Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show info message
  void _showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

// ==================== SEARCH DETAILS CONTROLLER ====================

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
    _initializeService();
    _loadArguments();
  }

  void _initializeService() {
    try {
      _eventService = EventService.instance;
    } catch (e) {
      print('❌ Error initializing EventService: $e');
    }
  }

  void _loadArguments() {
    final arguments = Get.arguments;
    if (arguments != null) {
      eventId.value = arguments['eventId'] ?? '';

      // If event object is passed, use it
      if (arguments['event'] != null) {
        eventDetails.value = arguments['event'] as Event;
      }
    }

    // If no event details, load from API
    if (eventDetails.value == null && eventId.value.isNotEmpty) {
      loadEventDetails();
    }
  }

  /// Load event details from API
  Future<void> loadEventDetails() async {
    if (eventId.value.isEmpty) {
      _showError('Invalid event ID');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _eventService.getEventById(eventId.value);

      if (response.success && response.data != null) {
        eventDetails.value = response.data;
        print('✅ Event details loaded: ${response.data!.name}');
      } else {
        _showError(response.error ?? 'Failed to load event details');
      }
    } catch (e) {
      print('❌ Error loading event details: $e');
      _showError('Failed to load event details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Share event
  void shareEvent() {
    if (eventDetails.value != null) {
      _showInfo('Sharing: ${eventDetails.value!.name}');
      // TODO: Implement actual sharing
    }
  }

  /// Navigate to send quote
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

  /// Refresh event details
  Future<void> refreshEventDetails() async {
    await loadEventDetails();
  }

  // ==================== GETTERS ====================

  /// Get recipient count
  int get recipientCount => eventDetails.value?.recipients?.length ?? 0;

  /// Format date for display
  String get formattedDate {
    if (eventDetails.value?.date == null) return '';
    final date = eventDetails.value!.date!;
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
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  /// Format start time
  String get formattedStartTime {
    return eventDetails.value?.formattedStartTime ?? '';
  }

  /// Format end time
  String get formattedEndTime {
    return eventDetails.value?.formattedEndTime ?? '';
  }

  /// Get location text
  String get locationText {
    final location = eventDetails.value?.location;
    if (location == null) return '';

    // Return formatted coordinates
    return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
  }

  /// Get event name
  String get eventName => eventDetails.value?.name ?? 'Event Details';

  /// Get event image
  String? get eventImage => eventDetails.value?.image;

  /// Check if user can send quote
  bool get canSendQuote => eventDetails.value != null;

  /// Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Show info message
  void _showInfo(String message) {
    Get.snackbar('Info', message, snackPosition: SnackPosition.BOTTOM);
  }
}
