// modules/listing/controllers/listing_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/photo_service/listing_service.dart';

class ListingController extends GetxController {
  // Services
  late final ListingService _listingService;

  // Observable variables
  final RxList<Photo> listings = <Photo>[].obs;
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
          errorMessage.value = 'No photos found';
        }
      } else {
        errorMessage.value = response.error ?? 'Failed to load photos';
        _showError(errorMessage.value);
      }
    } catch (e) {
      print('❌ Error loading listings: $e');
      errorMessage.value = 'Failed to load photos';
      _showError('Failed to load photos: $e');
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
        _showSuccess('Photos refreshed successfully');
      } else {
        _showError(response.error ?? 'Failed to refresh photos');
      }
    } catch (e) {
      print('❌ Error refreshing listings: $e');
      _showError('Failed to refresh photos');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Navigate to photo details
  void openListingDetails(Photo photo) {
    if (photo.id == null || photo.id!.isEmpty) {
      _showError('Invalid photo');
      return;
    }

    Get.toNamed(
      Routes.LISTING_DETAILS,
      arguments: {'photoId': photo.id, 'photo': photo},
    );
  }

  /// Navigate to add new photo
  void addNewListing() {
    // Navigate to upload photo screen
    Get.toNamed(Routes.ADD_NEW_LISTING);
  }

  /// Delete photo with confirmation
  Future<void> deleteListing(String photoId) async {
    try {
      // Show confirmation dialog
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Photo'),
          content: const Text(
            'Are you sure you want to delete this photo? This action cannot be undone.',
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

        final response = await _listingService.deleteListing(photoId);

        if (response.success) {
          listings.removeWhere((photo) => photo.id == photoId);
          _showSuccess('Photo deleted successfully');
        } else {
          _showError(response.error ?? 'Failed to delete photo');
        }
      }
    } catch (e) {
      print('❌ Error deleting photo: $e');
      _showError('Failed to delete photo');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update photo price
  Future<void> updatePhotoPrice(String photoId, double newPrice) async {
    try {
      isLoading.value = true;

      final request = UpdatePhotoRequest(price: newPrice);
      final response = await _listingService.updateListing(photoId, request);

      if (response.success && response.data != null) {
        // Update in local list
        final index = listings.indexWhere((p) => p.id == photoId);
        if (index != -1) {
          listings[index] = response.data!;
        }
        _showSuccess('Price updated successfully');
      } else {
        _showError(response.error ?? 'Failed to update price');
      }
    } catch (e) {
      print('❌ Error updating price: $e');
      _showError('Failed to update price');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update photo metadata
  Future<void> updatePhotoMetadata(
    String photoId,
    PhotoMetadata metadata,
  ) async {
    try {
      isLoading.value = true;

      final request = UpdatePhotoRequest(metadata: metadata);
      final response = await _listingService.updateListing(photoId, request);

      if (response.success && response.data != null) {
        // Update in local list
        final index = listings.indexWhere((p) => p.id == photoId);
        if (index != -1) {
          listings[index] = response.data!;
        }
        _showSuccess('Photo updated successfully');
      } else {
        _showError(response.error ?? 'Failed to update photo');
      }
    } catch (e) {
      print('❌ Error updating photo: $e');
      _showError('Failed to update photo');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get photos by event
  List<Photo> getPhotosByEvent(String eventId) {
    return listings.where((p) => p.eventId == eventId).toList();
  }

  /// Get photos by folder
  List<Photo> getPhotosByFolder(String folderId) {
    return listings.where((p) => p.folderId == folderId).toList();
  }

  /// Get total price of all photos
  double get totalPhotosValue {
    return listings.fold(0.0, (sum, photo) => sum + (photo.price ?? 0.0));
  }

  /// Get total views
  int get totalViews {
    return listings.fold(0, (sum, photo) => sum + (photo.views ?? 0));
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
  final Rx<Photo?> photo = Rx<Photo?>(null);
  final RxBool isLoading = false.obs;
  final RxString photoId = ''.obs;
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
      photoId.value = arguments['photoId'] ?? '';
      photo.value = arguments['photo'];
    }

    // If photo not passed, fetch it from API
    if (photo.value == null && photoId.value.isNotEmpty) {
      loadPhotoDetails();
    } else if (photo.value == null) {
      errorMessage.value = 'No photo data available';
    }
  }

  /// Load photo details from API
  Future<void> loadPhotoDetails() async {
    if (photoId.value.isEmpty) {
      errorMessage.value = 'Invalid photo ID';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔄 Loading photo details for ID: ${photoId.value}');

      final response = await _listingService.getListingById(photoId.value);

      if (response.success && response.data != null) {
        photo.value = response.data;
        print('✅ Photo details loaded');
      } else {
        errorMessage.value = response.error ?? 'Failed to load photo details';
        _showError(errorMessage.value);
      }
    } catch (e) {
      print('❌ Error loading photo details: $e');
      errorMessage.value = 'Failed to load photo details';
      _showError('Failed to load photo details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Share photo
  void sharePhoto() {
    if (photo.value == null) {
      _showError('No photo to share');
      return;
    }

    // TODO: Implement actual sharing functionality
    // For now, just show a success message
    _showSuccess('Sharing functionality coming soon!');
  }

  /// Download photo
  void downloadPhoto() {
    if (photo.value == null) {
      _showError('No photo available');
      return;
    }

    // TODO: Implement download functionality
    _showSuccess('Download feature coming soon!');
  }

  /// Edit photo
  void editPhoto() {
    if (photo.value == null) {
      _showError('No photo available');
      return;
    }

    // Navigate to edit screen
    //  Get.toNamed(Routes.EDIT_PHOTO, arguments: {'photo': photo.value});
  }

  /// Delete photo
  Future<void> deletePhoto() async {
    if (photo.value == null || photo.value!.id == null) {
      _showError('Invalid photo');
      return;
    }

    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Photo'),
          content: const Text(
            'Are you sure you want to delete this photo? This action cannot be undone.',
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

        final response = await _listingService.deleteListing(photo.value!.id!);

        if (response.success) {
          _showSuccess('Photo deleted successfully');
          Get.back(); // Go back to listings screen
        } else {
          _showError(response.error ?? 'Failed to delete photo');
        }
      }
    } catch (e) {
      print('❌ Error deleting photo: $e');
      _showError('Failed to delete photo');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get photo URL (watermarked or original based on ownership)
  String? get displayUrl {
    if (photo.value == null) return null;

    // Show watermarked URL if available, otherwise show original
    return photo.value!.watermarkedUrl ?? photo.value!.url;
  }

  /// Get photo price display
  String get priceDisplay {
    if (photo.value?.price == null) return 'Free';
    return '\$${photo.value!.price!.toStringAsFixed(2)}';
  }

  /// Get photo views display
  String get viewsDisplay {
    final views = photo.value?.views ?? 0;
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views';
    }
    return '$views views';
  }

  /// Get creator name
  String get creatorName {
    return photo.value?.creator?.name ?? 'Unknown';
  }

  /// Check if photo has data
  bool get hasPhoto => photo.value != null;

  /// Get photo title (filename or metadata)
  String get photoTitle {
    return photo.value?.metadata?.fileName ?? 'Photo Details';
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
