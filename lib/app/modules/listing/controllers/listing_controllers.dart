// controllers/listing_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/photo_service/listing_service.dart';

class ListingController extends GetxController {
  late final ListingService _listingService;

  final RxList<Photo> listings = <Photo>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalPhotosCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    loadListings();
  }

  void _initializeService() {
    try {
      _listingService = ListingService.instance;
    } catch (e) {
      print('❌ Error initializing ListingService: $e');
      errorMessage.value = 'Failed to initialize service';
    }
  }

  Future<void> loadListings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔄 Controller: Loading listings...');

      final response = await _listingService.getUserListings();

      if (response.success && response.data != null) {
        // Get data from service directly
        final serviceListings = _listingService.userListings;
        listings.value = List<Photo>.from(serviceListings);
        totalPhotosCount.value = _listingService.totalPhotos;

        print(
          '✅ Controller: Loaded ${listings.length} listings (Total: ${totalPhotosCount.value})',
        );
        print('✅ Service has: ${_listingService.userListings.length} listings');

        if (listings.isEmpty) {
          errorMessage.value = '';
          print('⚠️ Controller: No listings found');
        }
      } else {
        errorMessage.value = response.error ?? 'Failed to load photos';
        print('❌ Controller: Error - ${errorMessage.value}');
        if (errorMessage.value.isNotEmpty) {
          _showError(errorMessage.value);
        }
      }
    } catch (e) {
      print('❌ Controller: Error loading listings: $e');
      errorMessage.value = 'Failed to load photos';
      _showError('Failed to load photos. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshListings() async {
    try {
      isRefreshing.value = true;
      errorMessage.value = '';

      print('🔄 Controller: Refreshing listings...');

      final response = await _listingService.getUserListings();

      if (response.success && response.data != null) {
        final serviceListings = _listingService.userListings;
        listings.value = List<Photo>.from(serviceListings);
        totalPhotosCount.value = _listingService.totalPhotos;
        print('✅ Controller: Refreshed ${listings.length} listings');
      } else {
        _showError(response.error ?? 'Failed to refresh photos');
      }
    } catch (e) {
      print('❌ Controller: Error refreshing listings: $e');
      _showError('Failed to refresh photos');
    } finally {
      isRefreshing.value = false;
    }
  }

  void openListingDetails(Photo photo) {
    if (photo.id == null || photo.id!.isEmpty) {
      _showError('Invalid photo');
      return;
    }

    print('🔄 Controller: Opening details for photo: ${photo.id}');

    Get.toNamed(
      Routes.LISTING_DETAILS,
      arguments: {'photoId': photo.id, 'photo': photo},
    )?.then((_) {
      refreshListings();
    });
  }

  void addNewListing() {
    print('🔄 Controller: Opening add new listing');
    Get.toNamed(Routes.PHOTO_UPLOAD)?.then((_) {
      refreshListings();
    });
  }

  Future<void> deleteListing(String photoId) async {
    try {
      isLoading.value = true;

      print('🔄 Controller: Deleting photo: $photoId');

      final response = await _listingService.deleteListing(photoId);

      if (response.success) {
        listings.removeWhere((photo) => photo.id == photoId);
        totalPhotosCount.value--;
        print('✅ Controller: Photo deleted successfully');
        _showSuccess('Photo deleted successfully');
      } else {
        print('❌ Controller: Delete failed - ${response.error}');
        _showError(response.error ?? 'Failed to delete photo');
      }
    } catch (e) {
      print('❌ Controller: Error deleting photo: $e');
      _showError('Failed to delete photo');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePhotoPrice(String photoId, double newPrice) async {
    try {
      isLoading.value = true;

      final request = UpdatePhotoRequest(price: newPrice);
      final response = await _listingService.updateListing(photoId, request);

      if (response.success && response.data != null) {
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

  List<Photo> getPhotosByEvent(String eventId) {
    return listings.where((p) => p.eventId == eventId).toList();
  }

  List<Photo> getPhotosByFolder(String folderId) {
    return listings.where((p) => p.folderId == folderId).toList();
  }

  double get totalPhotosValue {
    return listings.fold(0.0, (sum, photo) => sum + (photo.price ?? 0.0));
  }

  int get totalViews {
    return listings.fold(0, (sum, photo) => sum + (photo.views ?? 0));
  }

  bool get hasListings => listings.isNotEmpty;
  int get listingsCount => listings.length;

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}

// ==================== LISTING DETAILS CONTROLLER ====================

class ListingDetailsController extends GetxController {
  late final ListingService _listingService;

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

  void _initializeService() {
    try {
      _listingService = ListingService.instance;
    } catch (e) {
      print('❌ Error initializing ListingService: $e');
      errorMessage.value = 'Failed to initialize service';
    }
  }

  void _loadArguments() {
    final arguments = Get.arguments;

    if (arguments != null && arguments is Map) {
      photoId.value = arguments['photoId'] ?? '';
      photo.value = arguments['photo'];

      print('🔄 Details Controller: Loaded arguments');
      print('📸 Photo ID: ${photoId.value}');
      print('📸 Photo available: ${photo.value != null}');
    }

    if (photo.value == null && photoId.value.isNotEmpty) {
      loadPhotoDetails();
    } else if (photo.value == null) {
      errorMessage.value = 'No photo data available';
    }
  }

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
      _showError('Failed to load photo details. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void sharePhoto() {
    if (photo.value == null) {
      _showError('No photo to share');
      return;
    }

    _showSuccess('Sharing functionality coming soon!');
  }

  void downloadPhoto() {
    if (photo.value == null) {
      _showError('No photo available');
      return;
    }

    _showSuccess('Download feature coming soon!');
  }

  void editPhoto() {
    if (photo.value == null) {
      _showError('No photo available');
      return;
    }

    _showInfo('Edit feature coming soon!');
  }

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
          Get.back(result: true);
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

  String? get displayUrl {
    if (photo.value == null) return null;
    return photo.value!.displayUrl;
  }

  String get priceDisplay {
    if (photo.value?.price == null || photo.value!.price == 0) {
      return 'Free';
    }
    return '\$${photo.value!.price!.toStringAsFixed(2)}';
  }

  String get viewsDisplay {
    final views = photo.value?.views ?? 0;
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return '$views';
  }

  String get creatorName {
    return photo.value?.creator?.name ?? 'Unknown';
  }

  bool get hasPhoto => photo.value != null;

  String get photoTitle {
    if (photo.value?.metadata?.fileName != null) {
      return photo.value!.metadata!.fileName!;
    }
    if (photo.value?.id != null) {
      return 'Photo ${photo.value!.id!.substring(0, 8)}';
    }
    return 'Photo Details';
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void _showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
