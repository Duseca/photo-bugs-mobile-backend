import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/creator_events/widgets/send_event_quote.dart';
import 'package:photo_bug/app/modules/search/views/search_details.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/main.dart';

class SearchController extends GetxController {
  // Observable variables
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt resultsCount = 0.obs;

  // Search filters
  final RxString usernameFilter = ''.obs;
  final RxString locationFilter = ''.obs;
  final RxString searchTypeFilter = ''.obs;
  final RxString roleFilter = ''.obs;
  final Rx<RangeValues> radiusRange = const RangeValues(0, 15).obs;
  final RxInt selectedRating = 0.obs; // 0 means "All"

  // Text controllers
  final TextEditingController searchTextController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Filter options
  final List<String> searchTypeOptions = ['Creator', 'Event'];
  final List<String> roleOptions = [
    'Photographer',
    'Videographer',
    'DJ',
    'Host',
  ];

  @override
  void onInit() {
    super.onInit();
    loadInitialResults();

    // Listen to search text changes
    searchTextController.addListener(() {
      searchQuery.value = searchTextController.text;
      if (searchQuery.value.isNotEmpty) {
        _debounceSearch();
      }
    });
  }

  @override
  void onClose() {
    searchTextController.dispose();
    usernameController.dispose();
    locationController.dispose();
    super.onClose();
  }

  // Load initial search results
  void loadInitialResults() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample search results
      final sampleResults = List.generate(10, (index) {
        return {
          'id': 'event_$index',
          'title': 'Den & Tina wedding event',
          'image': 'Assets.imagesEventImage',
          'date': '27 Sep, 2024',
          'location': '385 Main Street, Suite 52, USA',
          'type': index % 2 == 0 ? 'Event' : 'Creator',
          'rating': 4.0 + (index % 5),
          'distance': (index + 1) * 2.5,
          'recipients': [dummyImg, dummyImg2, dummyImg, dummyImg2, dummyImg],
          'startTime': '02:30 PM',
          'endTime': '04:30 PM',
          'category': 'Wedding',
        };
      });

      searchResults.assignAll(sampleResults);
      resultsCount.value = sampleResults.length;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load search results');
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

  // Perform search
  void performSearch() async {
    if (searchQuery.value.isEmpty) {
      loadInitialResults();
      return;
    }

    isSearching.value = true;
    try {
      // Simulate API call with search query
      await Future.delayed(const Duration(milliseconds: 300));

      // Filter results based on search query
      final filteredResults =
          searchResults.where((result) {
            return result['title'].toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                result['location'].toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                result['category'].toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                );
          }).toList();

      searchResults.assignAll(filteredResults);
      resultsCount.value = filteredResults.length;
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isSearching.value = false;
    }
  }

  // Apply filters
  void applyFilters() async {
    isLoading.value = true;
    try {
      // Simulate API call with filters
      await Future.delayed(const Duration(milliseconds: 500));

      // Apply filters to search results
      List<Map<String, dynamic>> filteredResults = List.from(searchResults);

      // Filter by search type
      if (searchTypeFilter.value.isNotEmpty) {
        filteredResults =
            filteredResults
                .where((result) => result['type'] == searchTypeFilter.value)
                .toList();
      }

      // Filter by rating
      if (selectedRating.value > 0) {
        filteredResults =
            filteredResults
                .where((result) => result['rating'] >= selectedRating.value)
                .toList();
      }

      // Filter by distance (radius)
      filteredResults =
          filteredResults
              .where(
                (result) =>
                    result['distance'] >= radiusRange.value.start &&
                    result['distance'] <= radiusRange.value.end,
              )
              .toList();

      searchResults.assignAll(filteredResults);
      resultsCount.value = filteredResults.length;

      Get.back(); // Close filter bottom sheet
      Get.snackbar('Success', 'Filters applied successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply filters');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear all filters
  void clearFilters() {
    usernameFilter.value = '';
    locationFilter.value = '';
    searchTypeFilter.value = '';
    roleFilter.value = '';
    radiusRange.value = const RangeValues(0, 15);
    selectedRating.value = 0;

    usernameController.clear();
    locationController.clear();

    loadInitialResults();
  }

  // Set search type filter
  void setSearchTypeFilter(String? type) {
    searchTypeFilter.value = type ?? '';
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
  void navigateToSearchDetails(Map<String, dynamic> result) {
    Get.toNamed(
      Routes.SEARCH_DETAILS,
      arguments: {'resultId': result['id'], 'result': result},
    );
  }

  // Show map view
  void showMapView() {
    Get.snackbar('Map View', 'Map view feature coming soon!');
  }

  // Get formatted results text
  String get resultsText => '${resultsCount.value} results found';
}

// controllers/search_details_controller.dart
class SearchDetailsController extends GetxController {
  // Observable variables
  final Rx<Map<String, dynamic>?> eventDetails = Rx<Map<String, dynamic>?>(
    null,
  );
  final RxBool isLoading = false.obs;
  final RxString eventId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get event data from arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      eventId.value = arguments['resultId'] ?? '';
      eventDetails.value = arguments['result'];
    }

    if (eventDetails.value == null && eventId.value.isNotEmpty) {
      loadEventDetails();
    }
  }

  // Load event details if not passed as argument
  void loadEventDetails() async {
    isLoading.value = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample event details
      final sampleEvent = {
        'id': eventId.value,
        'title': 'Den & Tina wedding event',
        'image': 'Assets.imagesEventImage',
        'date': '27 Sep, 2024',
        'location': '385 Main Street, Suite 52, USA',
        'recipients': [dummyImg2, dummyImg, dummyImg2, dummyImg, dummyImg2],
        'startTime': '02:30 PM',
        'endTime': '04:30 PM',
        'recipientCount': 5,
        'hostName': 'John & Jane',
        'eventType': 'Wedding',
        'budget': '\$500 - \$1000',
        'description':
            'Beautiful wedding ceremony seeking professional photographer.',
      };

      eventDetails.value = sampleEvent;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load event details');
    } finally {
      isLoading.value = false;
    }
  }

  // Share event
  void shareEvent() {
    Get.snackbar('Share', 'Event shared successfully');
  }

  // Navigate to send quote
  void navigateToSendQuote() {
    if (eventDetails.value != null) {
      Get.to(
        () => const SendEventQuote(),
        arguments: {
          'eventId': eventDetails.value!['id'],
          'eventDetails': eventDetails.value,
        },
      );
    }
  }

  // Get recipient images (limited to display)
  List<String> get recipientImages {
    if (eventDetails.value == null) return [];
    final recipients = eventDetails.value!['recipients'] as List<String>?;
    return recipients ?? [];
  }

  // Get recipient count
  int get recipientCount {
    return eventDetails.value?['recipientCount'] ?? 0;
  }
}
