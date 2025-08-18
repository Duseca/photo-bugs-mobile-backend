// ==================== BINDINGS ====================

// bindings/chat_binding.dart
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/chat/controller/chat_controllers.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

// bindings/chat_head_binding.dart
class ChatHeadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatHeadController>(() => ChatHeadController());
  }
}

