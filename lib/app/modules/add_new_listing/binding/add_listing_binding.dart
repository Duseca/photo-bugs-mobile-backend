import 'package:get/get.dart';
import '../controller/add_listing_controller.dart';

class AddNewListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddListingController>(() => AddListingController());
  }
}
