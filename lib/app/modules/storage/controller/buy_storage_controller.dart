// controllers/buy_storage_controller.dart

import 'package:get/get.dart';

import 'package:photo_bug/app/modules/storage/views/storage_order_summary.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_select_payment_method.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

class BuyStorageController extends GetxController {
  // Observable variables
  final RxInt selectedIndex = 2.obs; // Default to 25GB option
  final RxBool isLoading = false.obs;

  // Storage options
  final List<Map<String, dynamic>> storageOptions = [
    {'title': '5GB', 'price': '\$1', 'value': 5},
    {'title': '10GB', 'price': '\$2', 'value': 10},
    {'title': '25GB', 'price': '\$5', 'value': 25},
    {'title': '50GB', 'price': '\$10', 'value': 50},
    {'title': '100GB', 'price': '\$20', 'value': 100},
    {'title': '250GB', 'price': '\$50', 'value': 250},
    {'title': '500GB', 'price': '\$100', 'value': 500},
  ];

  // Select storage option
  void selectOption(int index) {
    selectedIndex.value = index;
  }

  // Get selected option details
  Map<String, dynamic> get selectedOption =>
      storageOptions[selectedIndex.value];

  // Navigate to order summary
  void proceedToBuy() {
    if (selectedIndex.value >= 0) {
      Get.toNamed(
        Routes.STORAGE_ORDER_SUMMARY,
        arguments: {
          'selectedOption': selectedOption,
          'selectedIndex': selectedIndex.value,
        },
      );
    }
  }
}
