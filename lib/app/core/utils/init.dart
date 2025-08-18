import 'package:flutter/material.dart';
import 'package:photo_bug/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:get/get.dart';

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
}
