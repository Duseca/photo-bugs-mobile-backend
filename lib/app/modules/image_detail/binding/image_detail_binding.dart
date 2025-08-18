import 'package:get/get.dart';
import 'package:photo_bug/app/modules/image_detail/controller/image_detail_controller.dart';

class ImageDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageDetailsController>(() => ImageDetailsController());
  }
}
