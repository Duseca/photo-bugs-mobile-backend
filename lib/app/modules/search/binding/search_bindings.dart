// ==================== BINDINGS ====================

import 'package:get/get.dart';

import 'package:photo_bug/app/modules/search/controller/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
  }
}

class SearchDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchDetailsController>(() => SearchDetailsController());
  }
}
