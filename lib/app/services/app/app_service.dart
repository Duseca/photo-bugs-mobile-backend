import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/helpers/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';

class AppService extends GetxService {
  static AppService get instance => Get.find<AppService>();
  late final Stream<List<ConnectivityResult>> _connectivityResultStream;
  late final SharedPreferences _sharedPreferences;
  final _currentConnectivity = Rx<ConnectivityResult>(ConnectivityResult.none);

  Future<AppService> init() async {
    await _init();
    return this;
  }

  Future<void> _init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Stream<List<ConnectivityResult>> get connectivityResultStream =>
      _connectivityResultStream;

  ConnectivityResult get currentConnectivity => _currentConnectivity.value;

  bool get isInternetConnected =>
      currentConnectivity == ConnectivityResult.mobile ||
      currentConnectivity == ConnectivityResult.wifi ||
      currentConnectivity == ConnectivityResult.ethernet;

  /// shared prefrence instance
  SharedPreferences get sharedPreferences => _sharedPreferences;

  /// env value
  String? getEnv(String key) => dotenv.env[key];
}
