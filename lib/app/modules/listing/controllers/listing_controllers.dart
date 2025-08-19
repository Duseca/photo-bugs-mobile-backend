import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/models/listings_model/listings_model.dart';
import 'package:photo_bug/app/modules/add_new_listing/view/add_new_listing.dart';
import 'package:photo_bug/app/modules/listing/views/listing_details.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_image_folder_details.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_select_download.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/main.dart';

class ListingController extends GetxController {
  // Observable variables
  final RxList<ListingItem> listings = <ListingItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadListings();
  }

  // Load listings from API
  void loadListings() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data - replace with actual API data
      final sampleListings = [
        ListingItem(
          id: '1',
          title: 'Den & Tina wedding event',
          date: '27 Sep, 2024',
          location: '385 Main Street, Suite 52, USA',
          imageUrl: dummyImg, // Replace with actual image URL
          status: 'Scheduled',
          recipients: [dummyImg, dummyImg2, dummyImg, dummyImg2],
          folders: [
            ListingFolder(
              id: 'folder_1',
              name: 'Samuel Images',
              date: '12/09/2024',
              itemCount: 0,
              ownerName: 'Samuel',
            ),
          ],
        ),
        ListingItem(
          id: '2',
          title: 'Corporate Event 2024',
          date: '15 Oct, 2024',
          location: '123 Business Ave, Downtown, USA',
          imageUrl: dummyImg2, // Replace with actual image URL
          status: 'Upcoming',
          recipients: [dummyImg, dummyImg2, dummyImg, dummyImg2],
          folders: [
            ListingFolder(
              id: 'folder_2',
              name: 'Event Photos',
              date: '15/10/2024',
              itemCount: 25,
              ownerName: 'Admin',
            ),
          ],
        ),
      ];

      listings.assignAll(sampleListings);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load listings');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh listings
  Future<void> refreshListings() async {
    isRefreshing.value = true;
    loadListings();
    isRefreshing.value = false;
  }

  // Navigate to listing details
  void openListingDetails(ListingItem listing) {
    Get.toNamed(
      Routes.LISTING_DETAILS,
      arguments: {'listingId': listing.id, 'listing': listing},
    );
  }

  // Navigate to add new listing
  void addNewListing() {
    Get.toNamed(Routes.ADD_NEW_LISTING);
  }

  // Delete listing
  void deleteListing(String listingId) async {
    try {
      // Show confirmation dialog
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Listing'),
          content: const Text('Are you sure you want to delete this listing?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (result == true) {
        // Remove from list
        listings.removeWhere((listing) => listing.id == listingId);

        // Here you would make actual API call
        // await listingService.deleteListing(listingId);

        Get.snackbar('Success', 'Listing deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete listing');
    }
  }
}

// controllers/listing_details_controller.dart
class ListingDetailsController extends GetxController {
  // Observable variables
  final Rx<ListingItem?> listing = Rx<ListingItem?>(null);
  final RxBool isLoading = false.obs;
  final RxString listingId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get listing data from arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      listingId.value = arguments['listingId'] ?? '';
      listing.value = arguments['listing'];
    }

    if (listing.value == null && listingId.value.isNotEmpty) {
      loadListingDetails();
    }
  }

  // Load listing details if not passed as argument
  void loadListingDetails() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Here you would fetch listing details from API
      // final response = await listingService.getListingDetails(listingId.value);
      // listing.value = ListingItem.fromJson(response);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load listing details');
    } finally {
      isLoading.value = false;
    }
  }

  // Share listing
  void shareListing() {
    if (listing.value != null) {
      // Implement share functionality
      Get.snackbar('Share', 'Listing shared successfully');
    }
  }

  // Navigate to user image folder details
  void openUserImageFolderDetails(ListingFolder folder) {
    Get.to(
      () => const UserImageFolderDetails(),
      arguments: {
        'folderId': folder.id,
        'folder': folder,
        'listingId': listingId.value,
      },
    );
  }

  // Navigate to bulk download
  void downloadInBulk() {
    if (listing.value != null) {
      Get.to(
        () => UserSelectDownload(),
        arguments: {'listingId': listing.value!.id, 'listing': listing.value},
      );
    }
  }

  // Get recipients count
  int get recipientsCount => listing.value?.recipients.length ?? 0;

  // Get recipients images (limited to display)
  List<String> get recipientsImages {
    if (listing.value == null) return [];
    final images = listing.value!.recipients;
    return images.length > 5 ? images.take(5).toList() : images;
  }
}
