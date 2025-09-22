import 'package:get/get.dart';
import 'package:photo_bug/app/modules/settings/profile/controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
      fenix: true, // Keeps the controller alive even when not in use
    );
  }
}
