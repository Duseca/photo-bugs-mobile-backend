import 'package:get/get.dart';
import 'package:photo_bug/app/models/favourites_model/favourite_model.dart';
import 'package:photo_bug/app/modules/image_detail/view/image_detail_view.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/main.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/photo_service/photo_service.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';

class FavouriteController extends GetxController {
  // Services
  final AuthService _authService = AuthService.instance;
  final PhotoService _photoService = PhotoService.instance;

  // Observable variables
  final RxList<FavoriteItem> favoriteItems = <FavoriteItem>[].obs;
  final RxList<FavoriteItem> filteredItems = <FavoriteItem>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<SortType?> selectedSort = Rx<SortType?>(null);

  // Sort options
  final List<SortOption> sortOptions = SortOption.defaultOptions;

  @override
  void onInit() {
    super.onInit();
    loadFavoriteItems();
  }

  /// Load favorite items from API
  Future<void> loadFavoriteItems() async {
    isLoading.value = true;
    try {
      // Check if user is logged in
      if (!_authService.isAuthenticated) {
        print('User not authenticated - cannot load favorites');
        favoriteItems.clear();
        filteredItems.clear();
        isLoading.value = false;
        return;
      }

      final currentUser = _authService.currentUser;
      if (currentUser == null ||
          currentUser.favorites == null ||
          currentUser.favorites!.isEmpty) {
        print('No favorites found for user');
        favoriteItems.clear();
        filteredItems.clear();
        isLoading.value = false;
        return;
      }

      print('Loading favorites for ${currentUser.favorites!.length} creators');

      // Get all trending photos (or you can fetch specific photos by creator IDs)
      await _photoService.loadTrendingPhotosWithIsolate();
      final allPhotos = _photoService.trendingPhotos;

      // Filter photos from favorite creators
      final favoritePhotosList =
          allPhotos.where((photo) {
            final creatorId = photo.creator?.id;
            return creatorId != null &&
                currentUser.favorites!.contains(creatorId);
          }).toList();

      print('Found ${favoritePhotosList.length} photos from favorite creators');

      // Convert photos to FavoriteItem
      final items =
          favoritePhotosList.map((photo) {
            return FavoriteItem(
              id: photo.id ?? '',
              imageUrl:
                  photo.watermarkedLink ?? photo.link ?? photo.url ?? dummyImg2,
              authorName: photo.creator?.name ?? 'Unknown',
              authorImage: photo.creator?.profilePicture ?? dummyImg,
              size: _formatFileSize(150),
              price: photo.price ?? 0.0,
              isFavorite: true,
            );
          }).toList();

      favoriteItems.assignAll(items);
      filteredItems.assignAll(items);

      print('Loaded ${items.length} favorite items');
    } catch (e) {
      print('Error loading favorite items: $e');
      Get.snackbar('Error', 'Failed to load favorite items');
    } finally {
      isLoading.value = false;
    }
  }

  /// Format file size from bytes to readable format
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 MB';

    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }

  /// Sort items based on selected option
  void sortItems(SortType sortType) {
    selectedSort.value = sortType;

    List<FavoriteItem> sortedItems = List.from(favoriteItems);

    switch (sortType) {
      case SortType.priceHighToLow:
        sortedItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.priceLowToHigh:
        sortedItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.sizeHighToLow:
        sortedItems.sort(
          (a, b) =>
              _extractSizeValue(b.size).compareTo(_extractSizeValue(a.size)),
        );
        break;
      case SortType.sizeLowToHigh:
        sortedItems.sort(
          (a, b) =>
              _extractSizeValue(a.size).compareTo(_extractSizeValue(b.size)),
        );
        break;
    }

    filteredItems.assignAll(sortedItems);
  }

  /// Extract numeric value from size string (e.g., "40.5 MB" -> 40.5)
  double _extractSizeValue(String size) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(size.toLowerCase());
    if (match != null) {
      final value = double.tryParse(match.group(1) ?? '0') ?? 0;

      // Convert to MB for consistent comparison
      if (size.toLowerCase().contains('gb')) {
        return value * 1024;
      } else if (size.toLowerCase().contains('kb')) {
        return value / 1024;
      } else if (size.toLowerCase().contains('b') &&
          !size.toLowerCase().contains('mb')) {
        return value / (1024 * 1024);
      }

      return value; // Already in MB
    }
    return 0;
  }

  /// Toggle favorite status - Remove from favorites
  Future<void> toggleFavorite(String itemId) async {
    try {
      // Find the item
      final item = favoriteItems.firstWhereOrNull((i) => i.id == itemId);

      if (item == null) {
        print('Item not found: $itemId');
        return;
      }

      // Get the photo to find creator ID
      final photo = _photoService.trendingPhotos.firstWhereOrNull(
        (p) => p.id == itemId,
      );

      if (photo == null || photo.creator?.id == null) {
        print('Photo or creator not found for item: $itemId');
        Get.snackbar('Error', 'Unable to remove favorite');
        return;
      }

      final creatorId = photo.creator!.id!;

      // Optimistically remove from UI
      favoriteItems.removeWhere((i) => i.id == itemId);
      _updateFilteredItems();

      // Call API to remove favorite
      final response = await _authService.removeFavorite(creatorId);

      if (response.success) {
        // Refresh user data to update favorites list
        await _authService.refreshUserData();

        Get.snackbar(
          'Success',
          'Removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        print('Favorite removed successfully - Creator: $creatorId');
      } else {
        // Revert on failure - reload favorites
        await loadFavoriteItems();

        Get.snackbar(
          'Error',
          response.error ?? 'Failed to remove favorite',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        print('Failed to remove favorite: ${response.error}');
      }
    } catch (e) {
      // Revert on error - reload favorites
      await loadFavoriteItems();

      print('Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Update filtered items based on current sort
  void _updateFilteredItems() {
    if (selectedSort.value != null) {
      sortItems(selectedSort.value!);
    } else {
      filteredItems.assignAll(favoriteItems);
    }
  }

  /// Navigate to image details
  void openImageDetails(FavoriteItem item) {
    // Find the actual photo object
    final photo = _photoService.trendingPhotos.firstWhereOrNull(
      (p) => p.id == item.id,
    );

    Get.toNamed(
      Routes.IMAGE_DETAILS,
      arguments: {
        'photo': photo,
        'imageUrl': item.imageUrl,
        'imageTitle': photo?.metadata?.fileName ?? 'Image',
        'price': item.price,
        'photoId': item.id,
        'creator': item.authorName,
        'views': photo?.views ?? photo?.metadata?.views ?? 0,
        // Legacy fields for backward compatibility
        'itemId': item.id,
        'authorName': item.authorName,
        'authorImage': item.authorImage,
        'size': item.size,
      },
    );
  }

  /// Refresh favorite items
  Future<void> refreshFavoriteItems() async {
    // First refresh user data to get latest favorites list
    await _authService.refreshUserData();

    // Then reload favorites
    await loadFavoriteItems();
  }
}
