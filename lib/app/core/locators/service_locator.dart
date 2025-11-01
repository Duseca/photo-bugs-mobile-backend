import 'package:get/get.dart';
import 'package:photo_bug/app/services/app/app_service.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/chat_service/chat_service.dart';
import 'package:photo_bug/app/services/event_service.dart/event_service.dart';
import 'package:photo_bug/app/services/folder_service/folder_service.dart';
import 'package:photo_bug/app/services/notification_service/notification_service.dart';
import 'package:photo_bug/app/services/photo_service/photo_service.dart';
import 'package:photo_bug/app/services/review_service/portfolio_service.dart';
import 'package:photo_bug/app/services/review_service/review_service.dart';
// Import other services as you create them
// import 'package:photo_bug/app/data/services/notification/notification_service.dart';
// import 'package:photo_bug/app/data/services/chat/chat_service.dart';
// import 'package:photo_bug/app/data/services/event/event_service.dart';
// import 'package:photo_bug/app/data/services/photo/photo_service.dart';

/// Initialize all app dependencies
Future<void> initDependencies() async {
  await _initCoreServices();
  await _initApiServices();
  await _initUtilityServices();
}

/// Initialize core services first (AppService must be first)
Future<void> _initCoreServices() async {
  // AppService must be initialized first as other services depend on it
  await Get.putAsync(() => AppService().init(), permanent: true);
}

/// Initialize API services (these depend on AppService)
Future<void> _initApiServices() async {
  // Initialize AuthService (depends on AppService)
  await Get.putAsync(() => AuthService().init(), permanent: true);

  await Get.putAsync(() => EventService().init(), permanent: true);

  await Get.putAsync(() => ReviewService().init(), permanent: true);

  await Get.putAsync(() => PhotoService().init(), permanent: true);

  await Get.putAsync(() => FolderService().init(), permanent: true);

  await Get.putAsync(() => PortfolioService().init(), permanent: true);

  await Get.putAsync(() => ChatService().init(), permanent: true);

  await Get.putAsync(() => NotificationService().init(), permanent: true);
}

/// Initialize utility services (these can depend on core and API services)
Future<void> _initUtilityServices() async {
  // Add utility services here
  // await Get.putAsync(() => CacheService().init(), permanent: true);
  // await Get.putAsync(() => ConnectivityService().init(), permanent: true);
  // await Get.putAsync(() => NotificationHandlerService().init(), permanent: true);
}

/// Service locator for easy access to services throughout the app
class ServiceLocator {
  // Singleton pattern
  static ServiceLocator? _instance;
  ServiceLocator._internal();
  static ServiceLocator get instance =>
      _instance ??= ServiceLocator._internal();

  // Core services
  AppService get app => Get.find<AppService>();
  AuthService get auth => Get.find<AuthService>();

  // Add getters for other services as you create them
  // NotificationService get notification => Get.find<NotificationService>();
  // ChatService get chat => Get.find<ChatService>();
  // EventService get event => Get.find<EventService>();
  // PhotoService get photo => Get.find<PhotoService>();

  // Utility methods
  bool isServiceRegistered<T>() => Get.isRegistered<T>();

  T getService<T>() {
    if (!Get.isRegistered<T>()) {
      throw Exception('Service ${T.toString()} is not registered');
    }
    return Get.find<T>();
  }
}

/// Extension for easy access to services from anywhere in the app
extension ServiceExtension on GetInterface {
  ServiceLocator get services => ServiceLocator.instance;
}

/// Global service access - use this for quick access
final services = ServiceLocator.instance;

/// Service dependency validator
class ServiceDependencyValidator {
  static void validateDependencies() {
    final requiredServices = [AppService, AuthService];

    for (final serviceType in requiredServices) {
      if (!Get.isRegistered(tag: serviceType.toString())) {
        throw Exception('Required service $serviceType is not registered');
      }
    }
  }

  static void logRegisteredServices() {
    final registeredServices = [
      'AppService: ${Get.isRegistered<AppService>()}',
      'AuthService: ${Get.isRegistered<AuthService>()}',
      // Add other services here
    ];

    print('=== Registered Services ===');
    for (final service in registeredServices) {
      print(service);
    }
    print('==========================');
  }
}

/// Service status checker for debugging
class ServiceStatus {
  static Map<String, dynamic> getStatus() {
    return {
      'app_service': {
        'registered': Get.isRegistered<AppService>(),
        'initialized': Get.isRegistered<AppService>() ? 'Yes' : 'No',
      },
      'auth_service': {
        'registered': Get.isRegistered<AuthService>(),
        'initialized': Get.isRegistered<AuthService>() ? 'Yes' : 'No',
        'authenticated':
            Get.isRegistered<AuthService>()
                ? Get.find<AuthService>().isAuthenticated
                : false,
      },
      // Add other services status here
    };
  }

  static void printStatus() {
    final status = getStatus();
    print('=== Service Status ===');
    status.forEach((key, value) {
      print('$key: $value');
    });
    print('=====================');
  }
}

/// Service cleanup utility
class ServiceCleanup {
  static Future<void> cleanupAllServices() async {
    // Cleanup in reverse order of initialization
    if (Get.isRegistered<AuthService>()) {
      await Get.find<AuthService>().cleanStorage();
    }

    // Add cleanup for other services

    // Clear all GetX dependencies
    await Get.deleteAll(force: true);
  }

  static Future<void> resetServices() async {
    await cleanupAllServices();
    await initDependencies();
  }
}
