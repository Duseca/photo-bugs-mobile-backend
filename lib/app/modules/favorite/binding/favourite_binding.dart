import 'package:get/get.dart';
import 'package:photo_bug/app/modules/favorite/controller/favourite_controller.dart';

class FavouriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavouriteController>(() => FavouriteController());
  }
}
