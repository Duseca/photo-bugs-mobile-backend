import 'package:get/get.dart';
import 'package:photo_bug/app/modules/user_events/controllers/user_events_controller.dart';

class UserEventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserEventsController>(() => UserEventsController());
  }
}
