import 'package:get/get.dart';
import 'package:photo_bug/app/modules/home/screens/order_summary.dart';
import 'package:photo_bug/app/models/image_detail_model/image_detail_model.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';

import 'package:photo_bug/app/modules/user_events/widgets/other_user_profile.dart';
import 'package:photo_bug/app/services/photo_service/photo_service.dart';
import 'package:photo_bug/main.dart';

class ImageDetailsController extends GetxController {
  // Services
  final PhotoService _photoService = PhotoService.instance;

  // Observable variables
  final Rx<ImageDetail?> imageDetail = Rx<ImageDetail?>(null);
  final Rx<Photo?> photo = Rx<Photo?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxString photoId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArgumentsAndData();
  }

  /// Load arguments and fetch data
  void _loadArgumentsAndData() async {
    try {
      final arguments = Get.arguments;

      if (arguments == null) {
        Get.snackbar('Error', 'No image data provided');
        return;
      }

      // Get photo object if passed directly
      if (arguments['photo'] != null && arguments['photo'] is Photo) {
        photo.value = arguments['photo'];
        photoId.value = photo.value!.id ?? '';
      } else if (arguments['photoId'] != null) {
        photoId.value = arguments['photoId'];
      } else if (arguments['imageId'] != null) {
        photoId.value = arguments['imageId'];
      }

      // If we have a photo object, convert it to ImageDetail
      if (photo.value != null) {
        _convertPhotoToImageDetail(photo.value!);
      } else if (photoId.value.isNotEmpty) {
        // Fetch photo by ID
        await loadImageDetails();
      } else {
        Get.snackbar('Error', 'No valid photo ID found');
      }
    } catch (e) {
      print('Error loading arguments: $e');
      Get.snackbar('Error', 'Failed to load image data');
    }
  }

  /// Load image details from API
  Future<void> loadImageDetails() async {
    if (photoId.value.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await _photoService.getPhotoById(photoId.value);

      if (response.success && response.data != null) {
        photo.value = response.data;
        _convertPhotoToImageDetail(response.data!);
      } else {
        Get.snackbar('Error', response.error ?? 'Failed to load image details');
      }
    } catch (e) {
      print('Error loading image details: $e');
      Get.snackbar('Error', 'Failed to load image details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Convert Photo model to ImageDetail model
  void _convertPhotoToImageDetail(Photo photoData) {
    try {
      // Parse metadata if it's a JSON string
      final metadata = photoData.metadata;
      final tags = metadata?.tags ?? [];
      final category = metadata?.category;

      // Create keywords list from tags and category
      final keywords = <String>[];
      if (category != null && category.isNotEmpty) {
        keywords.add(category);
      }
      keywords.addAll(tags);

      // Build photo info metadata
      final imageMetadata = ImageMetadata(
        resolution:
            metadata?.width != null && metadata?.height != null
                ? '${metadata!.width}x${metadata.height}'
                : 'Unknown',
        size:
            metadata?.fileSize != null
                ? _formatFileSize(metadata!.fileSize!)
                : 'Unknown',
        orientation: _getOrientation(metadata?.width, metadata?.height),
        camera: metadata?.cameraModel ?? 'Unknown',
        cameraModel: metadata?.cameraModel ?? 'Unknown',
        isoSpeed: 'Unknown', // Not available in API response
        exposureBias: 'Unknown', // Not available in API response
        focalLength: 'Unknown', // Not available in API response
      );

      // Get the best image URL (prefer watermarked for preview)
      final imageUrl =
          photoData.watermarkedLink ??
          photoData.link ??
          photoData.url ??
          dummyImg;

      // Get author info
      final authorName = photoData.creator?.name ?? 'Unknown Creator';
      final authorImage = photoData.creator?.profilePicture ?? dummyImg2;

      // Get title from filename or generate one
      final title =
          metadata?.fileName ?? 'Photo by $authorName' ?? 'Untitled Photo';

      // Get view count
      final viewCount = photoData.views ?? metadata?.views ?? 0;

      // Create ImageDetail object
      final imageDetailData = ImageDetail(
        id: photoData.id ?? '',
        imageUrl: imageUrl,
        authorName: authorName,
        authorImage: authorImage,
        title: title,
        viewCount: viewCount,
        price: photoData.price ?? 0.0,
        isFavorite: false, // TODO: Check from favorites API
        metadata: imageMetadata,
        keywords: keywords.isNotEmpty ? keywords : ['photo', 'image'],
      );

      imageDetail.value = imageDetailData;
      isFavorite.value = imageDetailData.isFavorite;
    } catch (e) {
      print('Error converting photo to image detail: $e');
      Get.snackbar('Error', 'Failed to process image data');
    }
  }

  /// Format file size to human-readable format
  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)}${suffixes[i]}';
  }

  /// Get orientation based on width and height
  String _getOrientation(int? width, int? height) {
    if (width == null || height == null) return 'Unknown';

    if (width > height) {
      return 'Landscape';
    } else if (height > width) {
      return 'Portrait';
    } else {
      return 'Square';
    }
  }

  /// Toggle favorite status
  void toggleFavorite() async {
    try {
      isFavorite.value = !isFavorite.value;

      // Update the image detail object
      if (imageDetail.value != null) {
        imageDetail.value = imageDetail.value!.copyWith(
          isFavorite: isFavorite.value,
        );
      }

      // TODO: Implement actual API call to toggle favorite
      // Example:
      // if (photoId.value.isNotEmpty) {
      //   if (isFavorite.value) {
      //     await UserService.instance.addToFavorites(photoId.value);
      //   } else {
      //     await UserService.instance.removeFromFavorites(photoId.value);
      //   }
      // }

      Get.snackbar(
        'Success',
        isFavorite.value ? 'Added to favorites' : 'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Revert on error
      isFavorite.value = !isFavorite.value;
      Get.snackbar('Error', 'Failed to update favorite status');
    }
  }

  /// Share profile action
  void shareProfile() {
    if (photo.value != null) {
      // TODO: Implement actual share functionality
      final shareText = '''
Check out this photo by ${photo.value!.creator?.name ?? 'Unknown'}!
Price: \$${photo.value!.price ?? 0}
''';

      // You can use share_plus package here
      Get.snackbar('Share', 'Share functionality coming soon!');
      print('Share text: $shareText');
    }
  }

  /// Report user action
  void reportUser() {
    // TODO: Implement actual report functionality
    Get.snackbar('Report', 'Report functionality coming soon!');
  }

  /// Navigate to author profile
  void openAuthorProfile() {
    if (photo.value != null && photo.value!.creator != null) {
      Get.to(
        () => const OtherUserProfile(),
        arguments: {
          'userId': photo.value!.creatorId ?? photo.value!.creator!.id,
          'userName': photo.value!.creator!.name ?? 'Unknown',
          'userImage': photo.value!.creator!.profilePicture ?? dummyImg2,
        },
      );
    } else {
      Get.snackbar('Error', 'Creator information not available');
    }
  }

  /// Navigate to order summary
  void purchaseImage() {
    if (imageDetail.value != null && photo.value != null) {
      // Check if photo is free
      if (photo.value!.price == null || photo.value!.price == 0) {
        Get.snackbar('Info', 'This photo is free to download!');
        _downloadPhoto();
        return;
      }

      // Navigate to order summary for paid photos
      Get.to(
        () => const OrderSummary(),
        arguments: {
          'photoId': photo.value!.id,
          'imageId': imageDetail.value!.id,
          'imageUrl': imageDetail.value!.imageUrl,
          'title': imageDetail.value!.title,
          'price': imageDetail.value!.price,
          'authorName': imageDetail.value!.authorName,
          'photo': photo.value,
        },
      );
    }
  }

  /// Download free photo
  void _downloadPhoto() {
    // TODO: Implement download functionality
    Get.snackbar('Download', 'Download starting...');
  }

  /// Refresh image details
  Future<void> refreshImageDetails() async {
    if (photoId.value.isNotEmpty) {
      await loadImageDetails();
    }
  }

  /// Get visible keywords (excluding the +X counter)
  List<String> get visibleKeywords {
    if (imageDetail.value == null) return [];
    final keywords = imageDetail.value!.keywords;
    return keywords.length > 10 ? keywords.take(10).toList() : keywords;
  }

  /// Get additional keywords count
  int get additionalKeywordsCount {
    if (imageDetail.value == null) return 0;
    final keywords = imageDetail.value!.keywords;
    return keywords.length > 10 ? keywords.length - 10 : 0;
  }
}
