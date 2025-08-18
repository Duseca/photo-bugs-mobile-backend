import 'package:get/get.dart';
import 'package:photo_bug/app/modules/storage/views/buy_storage.dart';
import 'package:photo_bug/app/modules/storage/views/storage_order_summary.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_select_payment_method.dart';

class StorageController extends GetxController {
  // Observable variables for storage data
  final RxDouble totalStorage = 20.0.obs;
  final RxDouble usedStorage = 3.6.obs;
  final RxDouble availableStorage = 16.4.obs;
  final RxInt totalSteps = 20.obs;
  final RxInt currentStep = 15.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStorageData();
  }

  // Load storage data from API
  void loadStorageData() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data - replace with actual API data
      totalStorage.value = 20.0;
      usedStorage.value = 3.6;
      availableStorage.value = 16.4;

      // Calculate progress steps
      final usagePercentage = (usedStorage.value / totalStorage.value) * 100;
      currentStep.value =
          (totalSteps.value * (100 - usagePercentage) / 100).round();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load storage data');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to buy storage
  void navigateToBuyStorage() {
    Get.to(() => BuyStorage());
  }

  // Get formatted storage strings
  String get formattedTotalStorage =>
      '${totalStorage.value.toStringAsFixed(1)} GB';
  String get formattedUsedStorage =>
      '${usedStorage.value.toStringAsFixed(1)} GB';
  String get formattedAvailableStorage =>
      '${availableStorage.value.toStringAsFixed(1)} GB';

  // Get usage percentage
  double get usagePercentage => (usedStorage.value / totalStorage.value) * 100;

  // Check if storage is running low
  bool get isStorageLow => usagePercentage > 80;
}
