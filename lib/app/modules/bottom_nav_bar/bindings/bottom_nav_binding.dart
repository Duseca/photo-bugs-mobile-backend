import 'package:get/get.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/controller/bottom_nav_controller.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavController>(
      () => BottomNavController(),
      fenix: true, // Keep the controller alive during the app lifecycle
    );
  }
}
