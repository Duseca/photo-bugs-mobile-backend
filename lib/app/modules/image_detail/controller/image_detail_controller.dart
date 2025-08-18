import 'package:get/get.dart';
import 'package:photo_bug/app/modules/home/screens/order_summary.dart';
import 'package:photo_bug/app/models/image_detail_model/image_detail_model.dart';
import 'package:photo_bug/app/modules/user_events/widgets/other_user_profile.dart';

class ImageDetailsController extends GetxController {
  // Observable variables
  final Rx<ImageDetail?> imageDetail = Rx<ImageDetail?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxString imageId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get image ID from arguments
    final arguments = Get.arguments;
    if (arguments != null && arguments['imageId'] != null) {
      imageId.value = arguments['imageId'];
    }
    loadImageDetails();
  }

  // Load image details
  void loadImageDetails() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Sample data - replace with actual API data
      final sampleMetadata = ImageMetadata(
        resolution: '1024x768',
        size: '4mb',
        orientation: 'Landscape',
        camera: 'Cannon',
        cameraModel: 'EOS 400',
        isoSpeed: 'ISO-100',
        exposureBias: '0 step',
        focalLength: '135 mm',
      );

      final sampleKeywords = [
        'Nature',
        'Food',
        'Technology',
        'Travel',
        'People',
        'Food',
        'Science',
        'Outdoor',
        'Background',
        'Technology',
        'Abstract',
      ];

      final sampleImageDetail = ImageDetail(
        id: imageId.value.isNotEmpty ? imageId.value : 'sample_id',
        imageUrl: 'dummyImg', // Replace with actual image URL
        authorName: 'BakrBlazee',
        authorImage: 'dummyImg', // Replace with actual author image URL
        title: 'Nezuko wrapped sticker on a gtr car',
        viewCount: 200,
        price: 200.0,
        isFavorite: false,
        metadata: sampleMetadata,
        keywords: sampleKeywords,
      );
      
      imageDetail.value = sampleImageDetail;
      isFavorite.value = sampleImageDetail.isFavorite;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load image details');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle favorite status
  void toggleFavorite() async {
    try {
      isFavorite.value = !isFavorite.value;
      
      // Update the image detail object
      if (imageDetail.value != null) {
        imageDetail.value = imageDetail.value!.copyWith(
          isFavorite: isFavorite.value,
        );
      }
      
      // Simulate API call to update favorite status
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Here you would make actual API call
      // await apiService.toggleFavorite(imageDetail.value!.id, isFavorite.value);
      
    } catch (e) {
      // Revert on error
      isFavorite.value = !isFavorite.value;
      Get.snackbar('Error', 'Failed to update favorite status');
    }
  }

  // Share profile action
  void shareProfile() {
    // Implement share functionality
    Get.snackbar('Share', 'Profile shared successfully');
  }

  // Report user action
  void reportUser() {
    // Implement report functionality
    Get.snackbar('Report', 'User reported successfully');
  }

  // Navigate to author profile
  void openAuthorProfile() {
    if (imageDetail.value != null) {
      Get.to(
        () => const OtherUserProfile(),
        arguments: {
          'userId': imageDetail.value!.authorName,
          'userName': imageDetail.value!.authorName,
          'userImage': imageDetail.value!.authorImage,
        },
      );
    }
  }

  // Navigate to order summary
  void purchaseImage() {
    if (imageDetail.value != null) {
      Get.to(
        () => const OrderSummary(),
        arguments: {
          'imageId': imageDetail.value!.id,
          'imageUrl': imageDetail.value!.imageUrl,
          'title': imageDetail.value!.title,
          'price': imageDetail.value!.price,
          'authorName': imageDetail.value!.authorName,
        },
      );
    }
  }

  // Get visible keywords (excluding the +20 counter)
  List<String> get visibleKeywords {
    if (imageDetail.value == null) return [];
    final keywords = imageDetail.value!.keywords;
    return keywords.length > 10 ? keywords.take(10).toList() : keywords;
  }

  // Get additional keywords count
  int get additionalKeywordsCount {
    if (imageDetail.value == null) return 0;
    final keywords = imageDetail.value!.keywords;
    return keywords.length > 10 ? keywords.length - 10 : 0;
  }
}
