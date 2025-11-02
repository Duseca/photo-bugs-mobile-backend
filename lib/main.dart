// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/common_widget/global_errorwidget.dart';
import 'package:photo_bug/app/core/helpers/logger.dart';
import 'package:photo_bug/app/core/locators/service_locator.dart';
import 'package:photo_bug/app/core/theme/light_theme.dart';

import 'package:photo_bug/app/routes/app_pages.dart';

import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(details.toString());
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Async error: $error');
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return GlobalErrorWidget(errorDetails: errorDetails);
  };
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  await initDependencies();
  AppLogger.info('initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Bug',
      builder:
          (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
      theme: lightTheme,
      themeMode: ThemeMode.light,
      useInheritedMediaQuery: true,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

//DO NOT REMOVE Unless you find their usage.
String dummyImg = 'https://cdn-icons-png.flaticon.com/512/6780/6780628.png';

String dummyImg2 = 'https://cdn-icons-png.flaticon.com/512/6780/6780628.png';
