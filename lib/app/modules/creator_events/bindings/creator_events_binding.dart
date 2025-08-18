import 'package:get/get.dart';
import '../controller/creator_events_controller.dart';

class CreatorEventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatorEventsController>(() => CreatorEventsController());
  }
}
