import 'package:get/get.dart';
import 'package:photo_bug/app/modules/storage/controller/buy_storage_controller.dart';
import 'package:photo_bug/app/modules/storage/controller/storage_controllers.dart';
import 'package:photo_bug/app/modules/storage/controller/storage_order_controller.dart';

class StorageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageController>(() => StorageController());
  }
}

class BuyStorageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuyStorageController>(() => BuyStorageController());
  }
}

class StorageOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageOrderController>(() => StorageOrderController());
  }
}
