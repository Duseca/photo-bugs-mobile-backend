import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/modules/favorite/controller/favourite_controller.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

// Import your existing controllers to ensure they're available
import 'package:photo_bug/app/modules/home/controller/home_controller.dart';
import 'package:photo_bug/app/modules/chat/controller/chat_controllers.dart';
import 'package:photo_bug/app/modules/downloads/controller/download_controller.dart';

class BottomNavController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable current index
  final currentIndex = 0.obs;

  // Animation controller for custom animations
  late AnimationController animationController;

  // Navigation items configuration
  final List<BottomNavItem> navItems = [
    BottomNavItem(
      iconActive: Assets.imagesHomeB,
      iconInactive: Assets.imagesHomeA,
      label: 'Home',
      routeName: Routes.HOME,
    ),
    BottomNavItem(
      iconActive: Assets.imagesChatB,
      iconInactive: Assets.imagesChatA,
      label: 'Chat',
      routeName: Routes.CHAT_HEAD_SCREEN,
    ),
    BottomNavItem(
      iconActive: Assets.imagesDownloadB,
      iconInactive: Assets.imagesDownloadA,
      label: 'Downloads',
      routeName: Routes.DOWNLOADS,
    ),
    BottomNavItem(
      iconActive: Assets.imagesFavoriteB,
      iconInactive: Assets.imagesFavoriteA,
      label: 'Favorites',
      routeName: Routes.FAVOURITES,
    ),
    BottomNavItem(
      iconActive: Assets.imagesProfileB,
      iconInactive: Assets.imagesProfileA,
      label: 'Profile',
      routeName: Routes.PROFILE,
    ),
  ];

  // Track navigation history for back button handling
  final navigationHistory = <int>[].obs;

  // Badge management for tabs
  final tabBadges = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Add initial page to history
    navigationHistory.add(currentIndex.value);

    // Initialize controllers for each tab
    _initializeControllers();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  // Initialize controllers for all tabs to avoid "not found" errors
  void _initializeControllers() {
    // Initialize controllers with try-catch to handle cases where they might already exist
    try {
      if (!Get.isRegistered<HomeController>()) {
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
      }
    } catch (e) {
      print('HomeController already exists or failed to initialize: $e');
    }

    try {
      if (!Get.isRegistered<ChatHeadController>()) {
        Get.lazyPut<ChatHeadController>(
          () => ChatHeadController(),
          fenix: true,
        );
      }
    } catch (e) {
      print('ChatHeadController already exists or failed to initialize: $e');
    }

    try {
      if (!Get.isRegistered<DownloadsController>()) {
        Get.lazyPut<DownloadsController>(
          () => DownloadsController(),
          fenix: true,
        );
      }
    } catch (e) {
      print('DownloadsController already exists or failed to initialize: $e');
    }

    try {
      if (!Get.isRegistered<FavouriteController>()) {
        Get.lazyPut<FavouriteController>(
          () => FavouriteController(),
          fenix: true,
        );
      }
    } catch (e) {
      print('FavoriteController already exists or failed to initialize: $e');
    }

    // try {
    //   if (!Get.isRegistered<ProfileController>()) {
    //     Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    //   }
    // } catch (e) {
    //   print('ProfileController already exists or failed to initialize: $e');
    // }
  }

  // Change tab with validation
  void changeTab(int index) {
    if (index == currentIndex.value || index < 0 || index >= navItems.length) {
      return;
    }

    final previousIndex = currentIndex.value;

    // Update current index
    currentIndex.value = index;

    // Add to navigation history
    _updateNavigationHistory(index);

    // Trigger animation
    animationController.forward().then((_) {
      animationController.reset();
    });

    // Analytics tracking
    _trackNavigation(previousIndex, index);
  }

  // Update navigation history
  void _updateNavigationHistory(int index) {
    if (navigationHistory.isEmpty || navigationHistory.last != index) {
      navigationHistory.add(index);

      // Limit history to prevent memory issues
      if (navigationHistory.length > 10) {
        navigationHistory.removeAt(0);
      }
    }
  }

  // Handle back button for Android
  bool handleBackButton() {
    if (navigationHistory.length > 1) {
      // Remove current page from history
      navigationHistory.removeLast();

      // Navigate to previous page
      final previousIndex = navigationHistory.last;
      currentIndex.value = previousIndex;

      return true; // Handled by custom navigation
    } else if (currentIndex.value != 0) {
      // If not on home, go to home
      changeTab(0);
      return true;
    }

    return false; // Let system handle (exit app)
  }

  // Check if tab is selected
  bool isTabSelected(int index) {
    return currentIndex.value == index;
  }

  // Get icon for tab
  String getTabIcon(int index) {
    final item = navItems[index];
    return isTabSelected(index) ? item.iconActive : item.iconInactive;
  }

  // Get tab label
  String getTabLabel(int index) {
    return navItems[index].label;
  }

  // Reset to home tab
  void resetToHome() {
    changeTab(0);
    navigationHistory.clear();
    navigationHistory.add(0);
  }

  // Navigate to specific tab by route name
  void navigateToRoute(String routeName) {
    final index = navItems.indexWhere((item) => item.routeName == routeName);
    if (index != -1) {
      changeTab(index);
    }
  }

  // Badge management methods
  void updateTabBadge(int tabIndex, int count) {
    if (count > 0) {
      tabBadges[tabIndex] = count;
    } else {
      tabBadges.remove(tabIndex);
    }
  }

  int getTabBadgeCount(int tabIndex) {
    return tabBadges[tabIndex] ?? 0;
  }

  bool hasTabBadge(int tabIndex) {
    return tabBadges.containsKey(tabIndex) && tabBadges[tabIndex]! > 0;
  }

  // Track navigation for analytics
  void _trackNavigation(int from, int to) {
    // Implement analytics tracking here
    print('Navigation: ${navItems[from].label} -> ${navItems[to].label}');
  }

  // Tab specific actions with double-tap handling
  void onHomeTabPressed() {
    if (currentIndex.value == 0) {
      // Handle double tap on home - scroll to top or refresh
      try {
        final homeController = Get.find<HomeController>();
        // homeController.refreshHome();
      } catch (e) {
        print('HomeController not found: $e');
      }
    } else {
      changeTab(0);
    }
  }

  void onChatTabPressed() {
    if (currentIndex.value == 1) {
      // Handle double tap on chat
      try {
        final chatController = Get.find<ChatHeadController>();
        // chatController.scrollToTop();
      } catch (e) {
        print('ChatHeadController not found: $e');
      }
    } else {
      changeTab(1);
    }
  }

  void onDownloadsTabPressed() {
    if (currentIndex.value == 2) {
      // Handle double tap on downloads
      try {
        final downloadsController = Get.find<DownloadsController>();
        // downloadsController.refreshDownloads();
      } catch (e) {
        print('DownloadsController not found: $e');
      }
    } else {
      changeTab(2);
    }
  }

  void onFavoritesTabPressed() {
    if (currentIndex.value == 3) {
      // Handle double tap on favorites
      try {
        // final favoriteController = Get.find<FavoriteController>();
        // favoriteController.refreshFavorites();
      } catch (e) {
        print('FavoriteController not found: $e');
      }
    } else {
      changeTab(3);
    }
  }

  void onProfileTabPressed() {
    if (currentIndex.value == 4) {
      // Handle double tap on profile
      try {
        // final profileController = Get.find<ProfileController>();
        // profileController.refreshProfile();
      } catch (e) {
        print('ProfileController not found: $e');
      }
    } else {
      changeTab(4);
    }
  }
}

// Bottom navigation item model
class BottomNavItem {
  final String iconActive;
  final String iconInactive;
  final String label;
  final String routeName;

  BottomNavItem({
    required this.iconActive,
    required this.iconInactive,
    required this.label,
    required this.routeName,
  });
}

// Extension for easy controller access
extension BottomNavControllerExtension on GetxController {
  BottomNavController get bottomNavController =>
      Get.find<BottomNavController>();
}
