import 'package:get/get.dart';
import 'package:photo_bug/app/data/services/app/app_service.dart';
import 'package:photo_bug/app/data/services/auth/auth_service.dart';

Future<void> initDependencies() async {
  await _initAppService();
}

Future<void> _initAppService() async {
  await Get.putAsync(() => AppService().init());
  await Get.putAsync(() => AuthService().init());
}
