// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/custom_bottom_sheet_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/folder_model.dart';
import 'package:photo_bug/app/modules/home/screens/app_feedback.dart';
import 'package:photo_bug/app/modules/home/widgets/upload_image.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/event_service.dart/event_service.dart';
import 'package:photo_bug/app/services/folder_service/folder_service.dart';
import 'package:photo_bug/app/services/photo_service/photo_service.dart';

// HomeController
class HomeController extends GetxController {
  // Services
  final PhotoService _photoService = PhotoService.instance;
  final AuthService _authService = AuthService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  final RxBool isListView = false.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedSortOption = 'Most Popular'.obs;
  final RxMap<String, bool> favoriteStates = <String, bool>{}.obs;
  final RxList<Photo> trendingPhotos = <Photo>[].obs;
  final RxBool isFetchingTrending = false.obs;

  final EventService _eventService = EventService.instance;
  final FolderService _folderService = FolderService.instance;

  // NEW: Event and Folder selection for upload
  final RxString selectedEventId = ''.obs;
  final RxString selectedFolderId = ''.obs;
  final RxList<Event> userEvents = <Event>[].obs;
  final RxList<Folder> eventFolders = <Folder>[].obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingFolders = false.obs;

  // NEW: Toggle for showing only user's photos
  final RxBool showOnlyMyPhotos = false.obs;
  final RxList<Photo> _allPhotos = <Photo>[].obs; // Store all photos

  // Photo upload related variables
  final Rx<XFile?> selectedImageFile = Rx<XFile?>(null);
  final RxBool isUploadingPhoto = false.obs;

  // Text controllers for upload form
  final TextEditingController imageTitleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController keywordsController = TextEditingController();

  // Dropdown and toggle values
  final RxString selectedCategory = ''.obs;
  final RxString selectedSubCategory = ''.obs;
  final RxBool isMatureContent = false.obs;
  final RxBool isRedescription = false.obs;

  // Categories and sub-categories
  final List<String> categories = [
    'Nature',
    'Architecture',
    'People',
    'Animals',
    'Food',
    'Technology',
    'Travel',
    'Sports',
    'Art',
    'Other',
  ];

  final List<String> subCategories = [
    'Landscape',
    'Portrait',
    'Street',
    'Abstract',
    'Macro',
    'Black & White',
    'Wildlife',
    'Fashion',
    'Documentary',
    'Fine Art',
  ];

  // Dummy image URL
  final String dummyImg =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=764&q=80';

  // Quick actions data
  final List<Map<String, dynamic>> quickActions = [
    {
      'icon': Assets.imagesCalendar,
      'label': 'My listing',
      'onTap': () => Get.toNamed(Routes.LISTING),
    },
    {
      'icon': Assets.imagesCalendar,
      'label': 'My Event',
      'onTap': () => Get.toNamed(Routes.USER_EVENTS),
    },
    {
      'icon': Assets.imagesFeedback,
      'label': 'Feedback',
      'onTap': () => Get.to(() => AppFeedback()),
    },
    {
      'icon': Assets.imagesSearchCreator,
      'label': 'Search',
      'onTap': () => Get.toNamed(Routes.SEARCH_SCREEN),
    },
    {
      'icon': Assets.imagesStorage,
      'label': 'My Storage',
      'onTap': () => Get.toNamed(Routes.STORAGE),
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeData();

    // NEW: Listen to toggle changes
    ever(showOnlyMyPhotos, (_) => _filterPhotos());
  }

  /// Initialize data on controller creation
  Future<void> _initializeData() async {
    await loadTrendingPhotos();
    _loadFavorites(); // Load favorites after photos are loaded
  }

  /// Load favorites from current user
  /// Note: Favorites are stored as creator/user IDs in the backend
  void _loadFavorites() {
    final currentUser = _authService.currentUser;
    if (currentUser != null && currentUser.favorites != null) {
      // The favorites list contains creator/user IDs
      // We need to mark photos from these creators as favorites
      for (final photo in trendingPhotos) {
        final creatorId = photo.creator?.id;
        if (creatorId != null && currentUser.favorites!.contains(creatorId)) {
          if (photo.id != null) {
            favoriteStates[photo.id!] = true;
          }
        }
      }
      print('Loaded favorites for ${currentUser.favorites!.length} creators');
    }
  }

  /// Load trending photos using isolate for background processing
  Future<void> loadTrendingPhotos() async {
    try {
      isFetchingTrending.value = true;

      // Use isolate for background processing to prevent UI blocking
      await _photoService.loadTrendingPhotosWithIsolate();

      // Store all photos
      _allPhotos.value = _photoService.trendingPhotos;

      // Apply filter
      _filterPhotos();

      print('Trending photos loaded in controller: ${_allPhotos.length}');
    } catch (e) {
      print('Error loading trending photos: $e');
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to load trending photos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isFetchingTrending.value = false;
    }
  }

  /// NEW: Filter photos based on toggle
  void _filterPhotos() {
    if (showOnlyMyPhotos.value) {
      final currentUser = _authService.currentUser;
      if (currentUser != null && currentUser.id != null) {
        // Filter photos created by current user
        trendingPhotos.value =
            _allPhotos.where((photo) {
              return photo.creator?.id == currentUser.id;
            }).toList();

        print(
          'Filtered to ${trendingPhotos.length} photos by user ${currentUser.id}',
        );
      } else {
        // User not logged in
        trendingPhotos.value = [];
        print('User not logged in, showing empty list');
      }
    } else {
      // Show all photos
      trendingPhotos.value = List<Photo>.from(_allPhotos);
      print('Showing all ${trendingPhotos.length} photos');
    }

    // Re-apply sorting after filtering
    sortTrendingPhotos();
  }

  /// NEW: Toggle user photos filter
  void toggleUserPhotosFilter() {
    if (!_authService.isAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to view your photos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    showOnlyMyPhotos.value = !showOnlyMyPhotos.value;

    // Show feedback
    Get.snackbar(
      showOnlyMyPhotos.value ? 'My Photos' : 'All Photos',
      showOnlyMyPhotos.value
          ? 'Showing only your uploaded photos'
          : 'Showing all trending photos',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimaryColor.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Refresh trending photos
  Future<void> refreshTrendingPhotos() async {
    await loadTrendingPhotos();
  }

  /// Sort trending photos based on selected option
  void sortTrendingPhotos() {
    final photos = List<Photo>.from(trendingPhotos);

    switch (selectedSortOption.value) {
      case 'Most Popular':
        // Already sorted by popularity from backend
        break;

      case 'Newest':
        photos.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;

      case 'Price: Low to High':
        photos.sort((a, b) {
          final priceA = a.price ?? 0;
          final priceB = b.price ?? 0;
          return priceA.compareTo(priceB);
        });
        break;

      case 'Price: High to Low':
        photos.sort((a, b) {
          final priceA = a.price ?? 0;
          final priceB = b.price ?? 0;
          return priceB.compareTo(priceA);
        });
        break;

      case 'Most Viewed':
        photos.sort((a, b) {
          final viewsA = a.views ?? a.metadata?.views ?? 0;
          final viewsB = b.views ?? b.metadata?.views ?? 0;
          return viewsB.compareTo(viewsA);
        });
        break;
    }

    trendingPhotos.value = photos;
  }

  /// Toggle favorite for a photo - UPDATED WITH API CALL
  /// Note: The API expects creator/user ID, not photo ID
  Future<void> toggleFavorite(String photoId) async {
    try {
      print('');
      print('🔄 Toggling favorite for photo: $photoId');

      // Check if user is logged in
      if (!_authService.isAuthenticated) {
        print('❌ User not authenticated');
        Get.snackbar(
          'Authentication Required',
          'Please login to add favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Find the photo to get the creator ID
      final photo = trendingPhotos.firstWhereOrNull((p) => p.id == photoId);

      if (photo == null) {
        print('❌ Photo not found in trending list: $photoId');
        Get.snackbar(
          'Error',
          'Photo not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Get creator ID from photo
      final creatorId = photo.creator?.id;

      if (creatorId == null || creatorId.isEmpty) {
        print('❌ Creator ID not found for photo: $photoId');
        Get.snackbar(
          'Error',
          'Creator information not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      print('✅ Found creator: ${photo.creator?.name} (ID: $creatorId)');

      // Get current state
      final currentState = favoriteStates[photoId] ?? false;
      print('📊 Current favorite state: $currentState');

      // Optimistically update UI
      favoriteStates[photoId] = !currentState;
      print('🔄 Optimistically updated to: ${!currentState}');

      // Call API with creator ID
      final response =
          currentState
              ? await _authService.removeFavorite(creatorId)
              : await _authService.addFavorite(creatorId);

      if (response.success) {
        print('✅ API call successful');

        // Refresh user data to update favorites list
        await _authService.refreshUserData();
        print('✅ User data refreshed');

        // Reload favorites to sync all photos from this creator
        _loadFavorites();

        // Show success message
        Get.snackbar(
          'Success',
          currentState ? 'Removed from favorites' : 'Added to favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kPrimaryColor.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        print(
          '✅ Favorite toggled successfully - Creator: ${photo.creator?.name}',
        );
      } else {
        print('❌ API call failed: ${response.error}');

        // Revert on failure
        favoriteStates[photoId] = currentState;

        Get.snackbar(
          'Error',
          response.error ?? 'Failed to update favorite',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Exception in toggleFavorite: $e');

      // Revert on error
      final currentState = favoriteStates[photoId] ?? false;
      favoriteStates[photoId] = !currentState;

      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Check if photo is favorite
  bool isFavorite(String itemId) {
    return favoriteStates[itemId] ?? false;
  }

  /// Toggle view type
  void toggleViewType() {
    isListView.value = !isListView.value;
  }

  /// Navigate to image details
  void navigateToImageDetails({Photo? photo}) {
    Get.toNamed(
      Routes.IMAGE_DETAILS,
      arguments: {
        'photo': photo,
        'imageUrl':
            photo?.watermarkedLink ?? photo?.link ?? photo?.url ?? dummyImg,
        'imageTitle': photo?.metadata?.fileName ?? 'Image',
        'price': photo?.price ?? 0,
        'photoId': photo?.id,
        'creator': photo?.creator?.name,
        'views': photo?.views ?? photo?.metadata?.views ?? 0,
      },
    );
  }

  /// Show sort options
  void showSortOptions() {
    final sortOptions = [
      'Most Popular',
      'Newest',
      'Price: Low to High',
      'Price: High to Low',
      'Most Viewed',
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            MyText(text: 'Sort By', size: 18, weight: FontWeight.w600),
            const SizedBox(height: 20),
            ...sortOptions.map(
              (option) => ListTile(
                title: Text(option),
                trailing:
                    selectedSortOption.value == option
                        ? const Icon(Icons.check, color: kPrimaryColor)
                        : null,
                onTap: () {
                  selectedSortOption.value = option;
                  sortTrendingPhotos();
                  Get.back();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> loadUserEvents() async {
    try {
      isLoadingEvents.value = true;

      final response = await _eventService.getUserCreatedEvents();

      if (response.success && response.data != null) {
        userEvents.value = response.data!;
        print('✅ Loaded ${userEvents.length} user events');
      } else {
        print('⚠️ Failed to load events: ${response.error}');
        userEvents.clear();
      }
    } catch (e) {
      print('❌ Error loading user events: $e');
      userEvents.clear();
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> loadEventFolders(String eventId) async {
    try {
      isLoadingFolders.value = true;
      selectedFolderId.value = ''; // Clear previous selection

      final response = await _folderService.getFoldersByEvent(eventId);

      if (response.success && response.data != null) {
        eventFolders.value = response.data!;
        print('✅ Loaded ${eventFolders.length} folders for event');
      } else {
        print('⚠️ Failed to load folders: ${response.error}');
        eventFolders.clear();
      }
    } catch (e) {
      print('❌ Error loading event folders: $e');
      eventFolders.clear();
    } finally {
      isLoadingFolders.value = false;
    }
  }

  /// Handle event selection
  void onEventSelected(String eventId) {
    selectedEventId.value = eventId;
    // Load folders for this event
    loadEventFolders(eventId);
  }

  /// Clear event selection
  void clearEventSelection() {
    selectedEventId.value = '';
    selectedFolderId.value = '';
    eventFolders.clear();
  }

  // ==================== PHOTO UPLOAD FUNCTIONALITY ====================

  /// Navigate to upload screen
  void navigateToUploadScreen() {
    // Check if user is authenticated
    if (!_authService.isAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to upload photos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Load user events before navigation
    loadUserEvents();
    Get.to(() => PhotoUploadScreen());
  }

  /// Pick image for upload
  Future<void> pickImageForUpload() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = image;
        print('Image selected: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Clear selected image
  void clearSelectedImage() {
    selectedImageFile.value = null;
  }

  /// Validate upload form
  bool _validateUploadForm() {
    if (selectedImageFile.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select an image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (imageTitleController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter image title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    // NEW: Validate folder selection if event is selected
    if (selectedEventId.value.isNotEmpty && selectedFolderId.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a folder for the selected event',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (keywordsController.text.trim().length < 20) {
      Get.snackbar(
        'Validation Error',
        'Keywords must be at least 20 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    return true;
  }

  /// Upload photo - UPDATED VERSION
  Future<void> uploadPhoto() async {
    try {
      // Validate form
      if (!_validateUploadForm()) {
        return;
      }

      isUploadingPhoto.value = true;

      // Parse price
      double? price;
      if (priceController.text.trim().isNotEmpty) {
        price = double.tryParse(priceController.text.trim());
        if (price == null || price < 0) {
          Get.snackbar(
            'Validation Error',
            'Please enter a valid price',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          isUploadingPhoto.value = false;
          return;
        }
      }

      // Create metadata
      final metadata = PhotoMetadata(
        fileName: imageTitleController.text.trim(),
        category:
            selectedCategory.value.isNotEmpty ? selectedCategory.value : null,
        tags:
            keywordsController.text
                .trim()
                .split(',')
                .map((e) => e.trim())
                .toList(),
      );

      // Upload photo with file - UPDATED WITH FOLDER ID
      final response = await _photoService.uploadPhotoWithFile(
        file: File(selectedImageFile.value!.path),
        price: price,
        metadata: metadata,
        folderId:
            selectedFolderId.value.isNotEmpty
                ? selectedFolderId.value
                : null, // NEW: Pass folder ID
      );

      if (response.success) {
        // Show success message
        Get.dialog(
          CongratsDialog(
            title: 'Upload Successful',
            congratsText: 'Your photo has been uploaded successfully!',
            btnText: 'Continue',
            onTap: () {
              // Clear form
              _clearUploadForm();
              // Go back to home
              Get.back(); // Close dialog
              Get.back(); // Close upload screen
              // Refresh trending photos
              refreshTrendingPhotos();
            },
          ),
        );

        print('✅ Photo uploaded successfully: ${response.data?.id}');
      } else {
        Get.snackbar(
          'Upload Failed',
          response.error ?? 'Failed to upload photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        _clearUploadForm();
        print('❌ Upload failed: ${response.error}');
      }
    } catch (e) {
      print('❌ Error uploading photo: $e');
      Get.snackbar(
        'Error',
        'An error occurred while uploading',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Clear upload form
  void _clearUploadForm() {
    selectedImageFile.value = null;
    imageTitleController.clear();
    priceController.clear();
    keywordsController.clear();
    selectedCategory.value = '';
    selectedSubCategory.value = '';
    isMatureContent.value = false;
    isRedescription.value = false;
    selectedEventId.value = '';
    selectedFolderId.value = '';
    eventFolders.clear();
  }

  @override
  void onClose() {
    // Dispose text controllers
    imageTitleController.dispose();
    priceController.dispose();
    keywordsController.dispose();
    super.onClose();
  }
}

// Report Controller
class ReportController extends GetxController {
  final RxString selectedReason = ''.obs;
  final RxString reportDescription = ''.obs;
  final RxBool isSubmitting = false.obs;
  final TextEditingController descriptionController = TextEditingController();

  final List<String> reportReasons = [
    'Bullying or unwanted contact',
    'Suicide, self-injury or eating disorders',
    'Inappropriate content',
  ];

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  void selectReason(int index) {
    selectedReason.value = reportReasons[index];
    _showReportDetailsBottomSheet();
  }

  void _showReportDetailsBottomSheet() {
    Get.bottomSheet(
      isScrollControlled: true,
      CustomBottomSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyText(
              text: 'Report',
              size: 18,
              weight: FontWeight.w600,
              textAlign: TextAlign.center,
              paddingBottom: 8,
            ),
            MyText(
              text:
                  'If you want to share more info about the report then write below in detail.',
              size: 12,
              textAlign: TextAlign.center,
              paddingLeft: 20,
              paddingRight: 20,
              paddingBottom: 20,
            ),
            Expanded(
              child: ListView(
                padding: AppSizes.HORIZONTAL,
                children: [
                  MyTextField(
                    label: 'Description',
                    maxLines: 5,
                    controller: descriptionController,
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSizes.DEFAULT,
              child: Obx(
                () => MyButton(
                  buttonText: 'Submit',
                  onTap: submitReport,
                  isLoading: isSubmitting.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitReport() async {
    isSubmitting.value = true;

    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));

    isSubmitting.value = false;

    Get.dialog(
      CongratsDialog(
        title: 'Report Submitted',
        congratsText:
            'Your report has been submitted, our team is looking into it.',
        btnText: 'Continue',
        onTap: () {
          Get.offAllNamed(Routes.BOTTOM_NAV_BAR);
        },
      ),
    );
  }
}
