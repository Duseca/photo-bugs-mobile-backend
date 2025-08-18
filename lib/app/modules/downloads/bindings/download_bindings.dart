import 'package:get/get.dart';
import 'package:photo_bug/app/modules/downloads/controller/download_controller.dart';

class DownloadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadsController>(() => DownloadsController());
  }
}

// bindings/download_details_binding.dart
class DownloadDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadDetailsController>(() => DownloadDetailsController());
  }
}

// bindings/image_view_binding.dart
class ImageViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageViewController>(() => ImageViewController());
  }
}