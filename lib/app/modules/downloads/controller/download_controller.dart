// controllers/downloads_controller.dart

import 'package:get/get.dart';
import 'package:photo_bug/app/models/download_model/download_model.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/photo_service/photo_service.dart';
import 'dart:convert';

class DownloadsController extends GetxController {
  // Dependencies
  final PhotoService _photoService = PhotoService.instance;

  // Observable variables
  final RxList<DownloadMonth> downloadMonths = <DownloadMonth>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalDownloads = 0.obs;

  // Cache for all photos
  List<Map<String, dynamic>> _allPhotos = [];

  @override
  void onInit() {
    super.onInit();
    loadDownloadMonths();
  }

  /// Load download months data from API
  Future<void> loadDownloadMonths() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔄 Loading download statistics...');

      // Step 1: Get download statistics from PhotoService
      final statsResponse = await _photoService.getDownloadStats();
      print('🔄 Download stats response received $statsResponse');

      if (!statsResponse.success || statsResponse.data == null) {
        throw Exception(
          statsResponse.error ?? 'Failed to load download statistics',
        );
      }

      final stats = statsResponse.data!;
      totalDownloads.value = stats.totalDownloads;
      print(
        '✅ Download stats loaded1: ${stats.totalDownloads} total downloads',
      );

      // Step 2: Get all photos from PhotoService
      final photosResponse = await _photoService.getAllPhotos();

      if (photosResponse.success && photosResponse.data != null) {
        _allPhotos = photosResponse.data!;
        print('✅ Photos loaded: ${_allPhotos.length} photos');
      } else {
        print('⚠️ No photos loaded: ${photosResponse.error}');
        _allPhotos = [];
      }

      // Step 3: Process and create download months
      final months = await _processDownloadMonths(stats, _allPhotos);

      downloadMonths.assignAll(months);

      print('✅ Loaded ${downloadMonths.length} months with downloads');
    } catch (e) {
      errorMessage.value = 'Failed to load downloads: $e';
      print('❌ Error loading download months: $e');

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Process download statistics with photos
  Future<List<DownloadMonth>> _processDownloadMonths(
    DownloadStats stats,
    List<Map<String, dynamic>> allPhotos,
  ) async {
    try {
      final List<DownloadMonth> months = [];

      // Filter only months with downloads > 0 or photos uploaded
      for (final monthlyStat in stats.monthlyStats) {
        // Get photos for this month
        final monthPhotos = _getPhotosForMonth(allPhotos, monthlyStat);

        // Only include months with photos
        if (monthPhotos.isNotEmpty) {
          final avgPrice = _calculateAveragePrice(monthPhotos);
          final downloads = monthlyStat.downloads;
          final earnings = downloads * avgPrice;

          final downloadMonth = DownloadMonth(
            id: '${monthlyStat.year}_${monthlyStat.month}',
            month: monthlyStat.monthName,
            year: monthlyStat.year,
            monthNumber: monthlyStat.month,
            downloadCount: downloads,
            earnings: earnings,
            date: DateTime(monthlyStat.year, monthlyStat.month, 1),
          );

          months.add(downloadMonth);
        }
      }

      // Sort by date (newest first)
      months.sort((a, b) => b.date.compareTo(a.date));

      return months;
    } catch (e) {
      print('Error processing download months: $e');
      return [];
    }
  }

  /// Get photos uploaded in a specific month
  List<Map<String, dynamic>> _getPhotosForMonth(
    List<Map<String, dynamic>> allPhotos,
    MonthlyStats monthlyStat,
  ) {
    return allPhotos.where((photo) {
      if (photo['createdAt'] == null) return false;

      try {
        final createdAt = DateTime.parse(photo['createdAt'].toString());
        return createdAt.year == monthlyStat.year &&
            createdAt.month == monthlyStat.month;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Calculate average price from photos
  double _calculateAveragePrice(List<Map<String, dynamic>> photos) {
    if (photos.isEmpty) return 5.0;

    double totalPrice = 0;
    int count = 0;

    for (final photo in photos) {
      if (photo['price'] != null) {
        try {
          totalPrice += (photo['price'] as num).toDouble();
          count++;
        } catch (e) {
          // Skip invalid prices
        }
      }
    }

    return count > 0 ? totalPrice / count : 5.0;
  }

  /// Navigate to download details
  void openDownloadDetails(DownloadMonth month) {
    Get.toNamed(
      Routes.DOWNLOAD_DETAILS,
      arguments: {
        'monthId': month.id,
        'monthName': month.month,
        'year': month.year,
        'monthNumber': month.monthNumber,
        'allPhotos': _allPhotos,
      },
    );
  }

  /// Refresh downloads
  Future<void> refreshDownloads() async {
    await loadDownloadMonths();
  }
}

class ImageViewController extends GetxController {
  // Observable variables
  final RxString imageUrl = ''.obs;
  final RxInt lifetimeDownloads = 0.obs;
  final RxDouble lifetimeEarnings = 0.0.obs;
  final RxString photoId = ''.obs;
  final RxString categoryName = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  /// Load arguments from previous screen
  void _loadArguments() {
    final arguments = Get.arguments;
    if (arguments != null) {
      imageUrl.value = arguments['imageUrl'] ?? '';
      lifetimeDownloads.value = arguments['lifetimeDownloads'] ?? 0;
      lifetimeEarnings.value = arguments['lifetimeEarnings'] ?? 0.0;
      photoId.value = arguments['photoId'] ?? '';
      categoryName.value = arguments['categoryName'] ?? '';
    }
  }

  /// Download image (implement based on your app's download logic)
  Future<void> downloadImage() async {
    try {
      isLoading.value = true;

      // Implement your download logic here
      // For example, using url_launcher or custom download logic

      Get.snackbar(
        'Success',
        'Image downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Share image (implement based on your app's share logic)
  Future<void> shareImage() async {
    try {
      // Implement your share logic here
      // For example, using share_plus package

      Get.snackbar(
        'Success',
        'Share functionality coming soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// controllers/download_details_controller.dart

class DownloadDetailsController extends GetxController {
  // Observable variables
  final RxList<DownloadItem> downloadItems = <DownloadItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString monthName = ''.obs;
  final RxString monthId = ''.obs;
  final RxInt year = 0.obs;
  final RxInt monthNumber = 0.obs;

  // Cache for photos
  List<Map<String, dynamic>> _allPhotos = [];

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    loadDownloadItems();
  }

  /// Load arguments from previous screen
  void _loadArguments() {
    final arguments = Get.arguments;
    if (arguments != null) {
      monthId.value = arguments['monthId'] ?? '';
      monthName.value = arguments['monthName'] ?? '';
      year.value = arguments['year'] ?? 0;
      monthNumber.value = arguments['monthNumber'] ?? 0;
      _allPhotos = arguments['allPhotos'] as List<Map<String, dynamic>>? ?? [];
    }
  }

  /// Load download items for the month
  Future<void> loadDownloadItems() async {
    isLoading.value = true;

    try {
      if (year.value == 0 || monthNumber.value == 0) {
        throw Exception('Invalid month data');
      }

      // Get photos for this specific month
      final monthPhotos = _getPhotosForMonth();

      if (monthPhotos.isEmpty) {
        downloadItems.clear();
        return;
      }

      // Group photos by category
      final items = _groupPhotosByCategory(monthPhotos);

      downloadItems.assignAll(items);

      print('Loaded ${downloadItems.length} categories for ${monthName.value}');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load download details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error loading download items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get photos uploaded in the specific month
  List<Map<String, dynamic>> _getPhotosForMonth() {
    return _allPhotos.where((photo) {
      if (photo['createdAt'] == null) return false;

      try {
        final createdAt = DateTime.parse(photo['createdAt'].toString());
        return createdAt.year == year.value &&
            createdAt.month == monthNumber.value;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Group photos by category and create download items
  List<DownloadItem> _groupPhotosByCategory(List<Map<String, dynamic>> photos) {
    // Group photos by category
    final Map<String, List<Map<String, dynamic>>> photosByCategory = {};

    for (final photo in photos) {
      final category = _getCategoryFromPhoto(photo);

      if (!photosByCategory.containsKey(category)) {
        photosByCategory[category] = [];
      }
      photosByCategory[category]!.add(photo);
    }

    // Create download items for each category
    final List<DownloadItem> items = [];

    photosByCategory.forEach((category, categoryPhotos) {
      if (categoryPhotos.isNotEmpty) {
        // Use the first photo as representative
        final representativePhoto = categoryPhotos.first;

        // Calculate average price for this category
        final avgPrice = _calculateCategoryPrice(categoryPhotos);

        // Calculate downloads (mock data - in production, get from API)
        // For now, we'll use a formula based on number of photos
        final downloads = categoryPhotos.length * 10;

        final item = DownloadItem(
          id: representativePhoto['_id']?.toString() ?? '',
          name: category,
          downloadCount: downloads,
          earnings: downloads * avgPrice,
          imageUrl: representativePhoto['link']?.toString(),
          thumbnailUrl:
              representativePhoto['watermarked_link']?.toString() ??
              representativePhoto['access_image']?.toString(),
          createdAt:
              representativePhoto['createdAt'] != null
                  ? DateTime.tryParse(
                    representativePhoto['createdAt'].toString(),
                  )
                  : null,
          metadata: _getMetadataFromPhoto(representativePhoto),
        );

        items.add(item);
      }
    });

    // Sort by downloads (highest first)
    items.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));

    return items;
  }

  /// Extract category from photo
  String _getCategoryFromPhoto(Map<String, dynamic> photo) {
    try {
      if (photo['metadata'] != null) {
        Map<String, dynamic> metadata;

        if (photo['metadata'] is String) {
          metadata = json.decode(photo['metadata']);
        } else {
          metadata = Map<String, dynamic>.from(photo['metadata']);
        }

        if (metadata['category'] != null) {
          return metadata['category'].toString();
        } else if (metadata['fileName'] != null) {
          return metadata['fileName'].toString();
        }
      }
    } catch (e) {
      print('Error parsing category: $e');
    }

    return 'Uncategorized';
  }

  /// Extract metadata from photo
  Map<String, dynamic>? _getMetadataFromPhoto(Map<String, dynamic> photo) {
    try {
      if (photo['metadata'] != null) {
        if (photo['metadata'] is String) {
          return json.decode(photo['metadata']);
        } else {
          return Map<String, dynamic>.from(photo['metadata']);
        }
      }
    } catch (e) {
      print('Error parsing metadata: $e');
    }
    return null;
  }

  /// Calculate average price for category photos
  double _calculateCategoryPrice(List<Map<String, dynamic>> photos) {
    if (photos.isEmpty) return 5.0;

    double totalPrice = 0;
    int count = 0;

    for (final photo in photos) {
      if (photo['price'] != null) {
        try {
          totalPrice += (photo['price'] as num).toDouble();
          count++;
        } catch (e) {
          // Skip invalid prices
        }
      }
    }

    return count > 0 ? totalPrice / count : 5.0;
  }

  /// Navigate to image view
  void openImageView(DownloadItem item) {
    Get.toNamed(
      Routes.IMAGE_VIEW,
      arguments: {
        'imageUrl': item.thumbnailUrl ?? item.imageUrl ?? '',
        'lifetimeDownloads': item.downloadCount,
        'lifetimeEarnings': item.earnings,
        'photoId': item.id,
        'categoryName': item.name,
      },
    );
  }

  /// Refresh items
  Future<void> refreshItems() async {
    await loadDownloadItems();
  }
}
