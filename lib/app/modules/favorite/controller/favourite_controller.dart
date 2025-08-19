import 'package:get/get.dart';
import 'package:photo_bug/app/models/favourites_model/favourite_model.dart';
import 'package:photo_bug/app/modules/image_detail/view/image_detail_view.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/main.dart';

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
        // Array of different image URLs
        final imageUrls = [
          dummyImg2,
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1433086966358-54859d0ed716?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1506197603052-3cc9c3a201bd?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1518837695005-2083093ee35b?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1511593358241-7eea1f3c84e5?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=764&q=80',
        ];

        final authorNames = [
          'Adrian',
          'Sarah',
          'Michael',
          'Emma',
          'James',
          'Sofia',
          'David',
          'Luna',
          'Alex',
          'Maya',
          'Chris',
          'Zara',
        ];

        final sizes = [
          '40mb',
          '35mb',
          '50mb',
          '28mb',
          '42mb',
          '38mb',
          '45mb',
          '32mb',
          '48mb',
          '36mb',
          '44mb',
          '39mb',
        ];

        return FavoriteItem(
          id: 'fav_$index',
          imageUrl: imageUrls[index], // Different URL for each image
          authorName: authorNames[index], // Different author name
          authorImage: dummyImg, // You can also make this different if needed
          size: sizes[index], // Different file size
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
    Get.toNamed(
      Routes.IMAGE_DETAILS,
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
