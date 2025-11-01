// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/controller/bottom_nav_controller.dart';
import 'package:photo_bug/app/modules/favorite/controller/favourite_controller.dart';

// Import your screen widgets
import 'package:photo_bug/app/modules/home/view/home_view.dart';
import 'package:photo_bug/app/modules/chat/views/chat_head.dart';
import 'package:photo_bug/app/modules/downloads/view/downloads.dart';
import 'package:photo_bug/app/modules/favorite/view/user_favorite.dart';
import 'package:photo_bug/app/modules/settings/profile/profile.dart';

class BottomNavBar extends GetView<BottomNavController> {
  BottomNavBar({Key? key}) : super(key: key);

  // Define screens that will be displayed
  final List<Widget> screens = const [
    Home(), // Home screen
    ChatHeadScreen(), // Chat screen
    Downloads(), // Downloads screen
    _FavoriteScreenWrapper(), // Favorites screen with reload wrapper
    Profile(), // Profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !controller.handleBackButton();
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: screens,
          ),
        ),
        bottomNavigationBar: Obx(() => _buildBottomNavigationBar()),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: kTertiaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              controller.navItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = controller.isTabSelected(index);
    final hasBadge = controller.hasTabBadge(index);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabPressed(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  // Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform:
                        Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                    child: Image.asset(
                      controller.getTabIcon(index),
                      width: 24,
                      height: 24,
                      color: isSelected ? kSecondaryColor : kQuaternaryColor,
                    ),
                  ),
                  // Badge
                  if (hasBadge)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          controller.getTabBadgeCount(index).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                controller.getTabLabel(index),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? kSecondaryColor : kQuaternaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabPressed(int index) {
    switch (index) {
      case 0:
        controller.onHomeTabPressed();
        break;
      case 1:
        controller.onChatTabPressed();
        break;
      case 2:
        controller.onDownloadsTabPressed();
        break;
      case 3:
        controller.onFavoritesTabPressed();
        break;
      case 4:
        controller.onProfileTabPressed();
        break;
    }
  }
}

/// Wrapper widget for Favourite screen that reloads on visibility
class _FavoriteScreenWrapper extends StatefulWidget {
  const _FavoriteScreenWrapper({Key? key}) : super(key: key);

  @override
  State<_FavoriteScreenWrapper> createState() => _FavoriteScreenWrapperState();
}

class _FavoriteScreenWrapperState extends State<_FavoriteScreenWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupVisibilityListener();
  }

  /// Setup listener for when this tab becomes visible
  void _setupVisibilityListener() {
    // Listen to bottom nav controller changes
    final bottomNavController = Get.find<BottomNavController>();

    ever(bottomNavController.currentIndex, (index) {
      // If favorites tab (index 3) is selected
      if (index == 3) {
        print('❤️ Favorites tab now visible - reloading data...');
        _reloadFavorites();
      }
    });
  }

  /// Reload favorites data
  Future<void> _reloadFavorites() async {
    try {
      if (Get.isRegistered<FavouriteController>()) {
        final favouriteController = Get.find<FavouriteController>();
        await favouriteController.refreshFavoriteItems();
        print('✅ Favorites reloaded successfully');
      }
    } catch (e) {
      print('❌ Error reloading favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Favourite();
  }
}
