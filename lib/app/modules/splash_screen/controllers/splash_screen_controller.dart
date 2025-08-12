import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/modules/welcome_screen/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  // Observable variables
  var isLoading = true.obs;
  var currentSchemeIndex = 0.obs;

  // Define the three color schemes from your Figma designs
  final List<SplashColorScheme> colorSchemes = [
    // Light Cream Theme (First design)
    SplashColorScheme(
      backgroundColor: const Color(0xFFFAF7F0), // Cream/beige color
      name: 'Light',
    ),

    // Orange Theme (Second design)
    SplashColorScheme(
      backgroundColor: const Color(0xFFFF8C42), // Orange color
      name: 'Orange',
    ),

    // Dark Theme (Third design)
    SplashColorScheme(
      backgroundColor: const Color(0xFF2D2D2D), // Dark color
      name: 'Dark',
    ),
  ];

  // Current color scheme getter
  SplashColorScheme get currentColorScheme =>
      colorSchemes[currentSchemeIndex.value];

  @override
  void onInit() {
    super.onInit();

    // Remove native splash screen when Flutter UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // Initialize animations
    _initAnimations();

    // Start splash handler
    _splashHandler();
  }

  void _initAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    animationController.forward();
  }

  Future<void> _splashHandler() async {
    try {
      // Minimum splash duration for smooth experience
      await Future.delayed(const Duration(milliseconds: 5000));

      bool shouldShowWelcome = await _shouldShowWelcome();

      if (shouldShowWelcome) {
        Get.offAll(() => WelcomeScreen());
      } else {
        // Navigate to main screen if user has already seen welcome
        Get.offAllNamed('/home'); // or whatever your main route is
      }
    } catch (e) {
      // Handle errors gracefully
      print('Splash initialization error: $e');
      Get.offAllNamed('/welcome'); // Default fallback
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _shouldShowWelcome() async {
    // Check if this is first launch or user needs to see welcome
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

    // You can add more conditions here
    // - Check if user is logged in
    // - Check app version for updates
    // - etc.

    return !hasSeenWelcome;
  }

  // Method to manually change color scheme if needed
  void changeColorScheme(int index) {
    if (index >= 0 && index < colorSchemes.length) {
      currentSchemeIndex.value = index;
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

// Simple color scheme model
class SplashColorScheme {
  final Color backgroundColor;
  final String name;

  SplashColorScheme({required this.backgroundColor, required this.name});
}
