// modules/listing/controllers/listing_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/models/listings_model/listings_model.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/photo_service/listing_service.dart';

class ListingController extends GetxController {
  // Services
  late final ListingService _listingService;

  // Observable variables
  final RxList<ListingItem> listings = <ListingItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    loadListings();
  }

  /// Initialize the listing service
  void _initializeService() {
    try {
      _listingService = ListingService.instance;

      // Listen to service updates
      _listingService.listingsStream.listen((updatedListings) {
        listings.value = updatedListings;
      });

      _listingService.loadingStream.listen((loading) {
        isLoading.value = loading;
      });
    } catch (e) {
      print('❌ Error initializing ListingService: $e');
      errorMessage.value = 'Failed to initialize service';
    }
  }

  /// Load listings from API
  Future<void> loadListings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _listingService.getUserListings();

      if (response.success && response.data != null) {
        listings.assignAll(response.data!);
        print('✅ Loaded ${response.data!.length} listings');

        if (listings.isEmpty) {
          errorMessage.value = 'No listings found';
        }
      } else {
        errorMessage.value = response.error ?? 'Failed to load listings';
        _showError(errorMessage.value);
      }
    } catch (e) {
      print('❌ Error loading listings: $e');
      errorMessage.value = 'Failed to load listings';
      _showError('Failed to load listings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh listings with pull-to-refresh
  Future<void> refreshListings() async {
    try {
      isRefreshing.value = true;
      errorMessage.value = '';

      final response = await _listingService.getUserListings();

      if (response.success && response.data != null) {
        listings.assignAll(response.data!);
        _showSuccess('Listings refreshed successfully');
      } else {
        _showError(response.error ?? 'Failed to refresh listings');
      }
    } catch (e) {
      print('❌ Error refreshing listings: $e');
      _showError('Failed to refresh listings');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Navigate to listing details
  void openListingDetails(ListingItem listing) {
    if (listing.id.isEmpty) {
      _showError('Invalid listing');
      return;
    }

    Get.toNamed(
      Routes.LISTING_DETAILS,
      arguments: {'listingId': listing.id, 'listing': listing},
    );
  }

  /// Navigate to add new listing
  void addNewListing() {
    Get.toNamed(Routes.ADD_NEW_LISTING);
  }

  /// Delete listing with confirmation
  Future<void> deleteListing(String listingId) async {
    try {
      // Show confirmation dialog
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Listing'),
          content: const Text(
            'Are you sure you want to delete this listing? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (result == true) {
        isLoading.value = true;

        final response = await _listingService.deleteListing(listingId);

        if (response.success) {
          listings.removeWhere((listing) => listing.id == listingId);
          _showSuccess('Listing deleted successfully');
        } else {
          _showError(response.error ?? 'Failed to delete listing');
        }
      }
    } catch (e) {
      print('❌ Error deleting listing: $e');
      _showError('Failed to delete listing');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if there are any listings
  bool get hasListings => listings.isNotEmpty;

  /// Get listings count
  int get listingsCount => listings.length;

  /// Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}

// ==================== LISTING DETAILS CONTROLLER ====================

class ListingDetailsController extends GetxController {
  // Services
  late final ListingService _listingService;

  // Observable variables
  final Rx<ListingItem?> listing = Rx<ListingItem?>(null);
  final RxBool isLoading = false.obs;
  final RxString listingId = ''.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    _loadArguments();
  }

  /// Initialize the listing service
  void _initializeService() {
    try {
      _listingService = ListingService.instance;
    } catch (e) {
      print('❌ Error initializing ListingService: $e');
      errorMessage.value = 'Failed to initialize service';
    }
  }

  /// Load arguments passed from previous screen
  void _loadArguments() {
    final arguments = Get.arguments;

    if (arguments != null) {
      listingId.value = arguments['listingId'] ?? '';
      listing.value = arguments['listing'];
    }

    // If listing not passed, fetch it from API
    if (listing.value == null && listingId.value.isNotEmpty) {
      loadListingDetails();
    } else if (listing.value == null) {
      errorMessage.value = 'No listing data available';
    }
  }

  /// Load listing details from API
  Future<void> loadListingDetails() async {
    if (listingId.value.isEmpty) {
      errorMessage.value = 'Invalid listing ID';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔄 Loading listing details for ID: ${listingId.value}');

      final response = await _listingService.getListingById(listingId.value);

      if (response.success && response.data != null) {
        listing.value = response.data;
        print('✅ Listing details loaded: ${response.data!.title}');
      } else {
        errorMessage.value = response.error ?? 'Failed to load listing details';
        _showError(errorMessage.value);
      }
    } catch (e) {
      print('❌ Error loading listing details: $e');
      errorMessage.value = 'Failed to load listing details';
      _showError('Failed to load listing details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Share listing
  void shareListing() {
    if (listing.value == null) {
      _showError('No listing to share');
      return;
    }

    // TODO: Implement actual sharing functionality
    // For now, just show a success message
    _showSuccess('Sharing functionality coming soon!');
  }

  /// Navigate to user image folder details
  void openUserImageFolderDetails(ListingFolder folder) {
    if (folder.id.isEmpty) {
      _showError('Invalid folder');
      return;
    }

    // TODO: Implement navigation to folder details
    Get.snackbar(
      'Folder',
      'Opening ${folder.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Navigate to bulk download
  void downloadInBulk() {
    if (listing.value == null) {
      _showError('No listing available');
      return;
    }

    // TODO: Implement navigation to bulk download
    _showSuccess('Bulk download feature coming soon!');
  }

  /// Get recipients count
  int get recipientsCount => listing.value?.recipients.length ?? 0;

  /// Get recipients images (limited to display)
  List<String> get recipientsImages {
    if (listing.value == null) return [];

    final images = listing.value!.recipients;
    return images.length > 5 ? images.take(5).toList() : images;
  }

  /// Check if listing has data
  bool get hasListing => listing.value != null;

  /// Get listing title
  String get listingTitle => listing.value?.title ?? 'Listing Details';

  /// Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}
