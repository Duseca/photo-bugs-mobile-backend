// controllers/storage_order_controller.dart

import 'package:get/get.dart';

import 'package:photo_bug/app/modules/user_events/widgets/user_select_payment_method.dart';

class StorageOrderController extends GetxController {
  // Observable variables
  final RxString storageCapacity = '25GB'.obs;
  final RxDouble basePrice = 5.0.obs;
  final RxDouble taxes = 1.0.obs;
  final RxDouble totalPrice = 6.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get data from previous screen
    final arguments = Get.arguments;
    if (arguments != null) {
      final selectedOption = arguments['selectedOption'];
      if (selectedOption != null) {
        storageCapacity.value = selectedOption['title'];
        basePrice.value =
            double.tryParse(selectedOption['price'].replaceAll('\$', '')) ??
            5.0;
        _calculateTotal();
      }
    }
  }

  // Calculate total price including taxes
  void _calculateTotal() {
    taxes.value = basePrice.value * 0.2; // 20% tax
    totalPrice.value = basePrice.value + taxes.value;
  }

  // Navigate to payment
  void proceedToPayment() {
    Get.to(
      () => UserSelectPaymentMethod(isStoragePayment: true),
      arguments: {
        'storageCapacity': storageCapacity.value,
        'totalAmount': totalPrice.value,
        'orderType': 'storage',
      },
    );
  }

  // Get formatted price strings
  String get formattedBasePrice => '\$${basePrice.value.toStringAsFixed(2)}';
  String get formattedTaxes => '\$${taxes.value.toStringAsFixed(2)}';
  String get formattedTotal => '\$${totalPrice.value.toStringAsFixed(2)}';
}
