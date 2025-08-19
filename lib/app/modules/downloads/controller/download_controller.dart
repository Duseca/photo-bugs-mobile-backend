import 'package:get/get.dart';
import 'package:photo_bug/app/models/download_model/download_model.dart';
import 'package:photo_bug/app/modules/downloads/view/download_details.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

class DownloadsController extends GetxController {
  // Observable variables
  final RxList<DownloadMonth> downloadMonths = <DownloadMonth>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDownloadMonths();
  }

  // Load download months data
  void loadDownloadMonths() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data - replace with actual API data
      final sampleData = [
        DownloadMonth(
          id: '1',
          month: 'September',
          downloadCount: 50,
          earnings: 250.0,
        ),
        DownloadMonth(
          id: '2',
          month: 'August',
          downloadCount: 35,
          earnings: 175.0,
        ),
      ];

      downloadMonths.assignAll(sampleData);
    } catch (e) {
      // Handle error
      Get.snackbar('Error', 'Failed to load downloads');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to download details
  void openDownloadDetails(DownloadMonth month) {
    Get.toNamed(
      Routes.DOWNLOAD_DETAILS,
      arguments: {'monthId': month.id, 'monthName': month.month},
    );
  }
}

// controllers/download_details_controller.dart
class DownloadDetailsController extends GetxController {
  // Observable variables
  final RxList<DownloadItem> downloadItems = <DownloadItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString monthName = ''.obs;
  final RxString monthId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments from previous screen
    final arguments = Get.arguments;
    if (arguments != null) {
      monthId.value = arguments['monthId'] ?? '';
      monthName.value = arguments['monthName'] ?? '';
    }
    loadDownloadItems();
  }

  // Load download items for the month
  void loadDownloadItems() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data - replace with actual API data
      final sampleData = [
        DownloadItem(
          id: '1',
          name: 'Nature',
          downloadCount: 120,
          earnings: 250.0,
          imageUrl: 'dummyImg', // Replace with actual image URL
        ),
        DownloadItem(
          id: '2',
          name: 'Landscape',
          downloadCount: 85,
          earnings: 170.0,
          imageUrl: 'dummyImg', // Replace with actual image URL
        ),
      ];

      downloadItems.assignAll(sampleData);
    } catch (e) {
      // Handle error
      Get.snackbar('Error', 'Failed to load download details');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to image view
  void openImageView(DownloadItem item) {
    // Get.to(
    //   () => const ImageView(),
    //   arguments: {
    //     'imageUrl': item.imageUrl,
    //     'lifetimeDownloads': item.downloadCount,
    //     'lifetimeEarnings': item.earnings,
    //   },
    // );
  }
}

// controllers/image_view_controller.dart
class ImageViewController extends GetxController {
  // Observable variables
  final RxString imageUrl = ''.obs;
  final RxInt lifetimeDownloads = 0.obs;
  final RxDouble lifetimeEarnings = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments from previous screen
    final arguments = Get.arguments;
    if (arguments != null) {
      imageUrl.value = arguments['imageUrl'] ?? '';
      lifetimeDownloads.value = arguments['lifetimeDownloads'] ?? 0;
      lifetimeEarnings.value = arguments['lifetimeEarnings'] ?? 0.0;
    }
  }
}
