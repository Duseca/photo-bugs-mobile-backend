import 'package:get/get.dart';
import 'package:photo_bug/app/models/favourites_model/favourite_model.dart';
import 'package:photo_bug/app/modules/image_detail/view/image_detail_view.dart';

class FavouriteController extends GetxController {
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

  // Load favorite items
  void loadFavoriteItems() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data - replace with actual API data
      final sampleData = List.generate(12, (index) {
        return FavoriteItem(
          id: 'fav_$index',
          imageUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=764&q=80', // Replace with actual image URL
          authorName: 'Adrian',
          authorImage: 'dummyImg', // Replace with actual author image URL
          size: '40mb',
          price: 100.0 + (index * 10),
          isFavorite: true,
        );
      });

      favoriteItems.assignAll(sampleData);
      filteredItems.assignAll(sampleData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load favorite items');
    } finally {
      isLoading.value = false;
    }
  }

  // Sort items based on selected option
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

  // Extract numeric value from size string (e.g., "40mb" -> 40)
  double _extractSizeValue(String size) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(size.toLowerCase());
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  // Toggle favorite status
  void toggleFavorite(String itemId) {
    final index = favoriteItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = favoriteItems[index];
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);

      if (updatedItem.isFavorite) {
        favoriteItems[index] = updatedItem;
      } else {
        // Remove from favorites
        favoriteItems.removeAt(index);
      }

      // Update filtered items
      _updateFilteredItems();
    }
  }

  // Update filtered items based on current sort
  void _updateFilteredItems() {
    if (selectedSort.value != null) {
      sortItems(selectedSort.value!);
    } else {
      filteredItems.assignAll(favoriteItems);
    }
  }

  // Navigate to image details
  void openImageDetails(FavoriteItem item) {
    Get.to(
      () => const ImageDetails(),
      arguments: {
        'itemId': item.id,
        'imageUrl': item.imageUrl,
        'authorName': item.authorName,
        'authorImage': item.authorImage,
        'size': item.size,
        'price': item.price,
      },
    );
  }

  // Refresh favorite items
  Future<void> refreshFavoriteItems() async {}
}
