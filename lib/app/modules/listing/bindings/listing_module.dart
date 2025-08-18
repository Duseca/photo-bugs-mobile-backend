import 'package:get/get.dart';
import 'package:photo_bug/app/modules/listing/controllers/listing_controllers.dart';

class ListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingController>(() => ListingController());
  }
}

// bindings/listing_details_binding.dart
class ListingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingDetailsController>(() => ListingDetailsController());
  }
}
