import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/utils/helpers/logger.dart';

class AppService extends GetxService {
  static AppService get instance => Get.find<AppService>();
  late final Stream<List<ConnectivityResult>> _connectivityResultStream;
  late final SharedPreferences _sharedPreferences;
  final _currentConnectivity = Rx<ConnectivityResult>(ConnectivityResult.none);
  late final FlutterSecureStorage _secureStorage;
  Future<AppService> init() async {
    await _init();
    return this;
  }

  Future<void> _init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
  }

  Future<FilePickerResult?> pickFile({
    FileType type = FileType.any,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
      );
      if (result != null) {
        AppLogger.info("File(s) picked: ${result.paths}");
      } else {
        AppLogger.warning("File picking cancelled by user.");
      }
      return result;
    } catch (e) {
      AppLogger.error("Error picking file: $e");
      return null;
    }
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

  /// Secure Storage
  FlutterSecureStorage get secureStorage => _secureStorage;

  /// env value
  String? getEnv(String key) => dotenv.env[key];
}
