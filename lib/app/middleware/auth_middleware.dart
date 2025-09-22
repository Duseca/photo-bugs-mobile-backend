import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';

/// Single middleware that handles all navigation logic
class AppMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = AuthService.instance;

    // Don't redirect if still loading
    if (authService.isLoading) {
      return null;
    }

    // Current route
    final currentRoute = route ?? '';
    print('Current route: $currentRoute');
    print('Is authenticated: ${authService.isAuthenticated}');
    print('Should show onboarding: ${authService.shouldShowOnboarding}');

    // 1. First time user needs onboarding
    if (authService.shouldShowOnboarding &&
        currentRoute != Routes.WELCOME_SCREEN) {
      return const RouteSettings(name: Routes.WELCOME_SCREEN);
    }

    // 2. Onboarding completed, redirect from onboarding page
    if (!authService.shouldShowOnboarding &&
        currentRoute == Routes.WELCOME_SCREEN) {
      return RouteSettings(
        name:
            authService.isAuthenticated ? Routes.BOTTOM_NAV_BAR : Routes.LOGIN,
      );
    }

    // 3. Unauthenticated user trying to access protected routes
    if (!authService.isAuthenticated && _isProtectedRoute(currentRoute)) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // 4. Authenticated user trying to access auth routes
    if (authService.isAuthenticated && _isAuthRoute(currentRoute)) {
      return const RouteSettings(name: Routes.BOTTOM_NAV_BAR);
    }

    // Allow navigation
    return null;
  }

  /// Check if route requires authentication
  bool _isProtectedRoute(String route) {
    const protectedRoutes = {
      Routes.BOTTOM_NAV_BAR,
      Routes.HOME,
      Routes.ADD_NEW_LISTING,
      Routes.LISTING,
      Routes.LISTING_DETAILS,
      Routes.IMAGE_DETAILS,
      Routes.IMAGE_VIEW,
      Routes.SEARCH_SCREEN,
      Routes.SEARCH_DETAILS,
      Routes.DOWNLOADS,
      Routes.DOWNLOAD_DETAILS,
      Routes.STORAGE,
      Routes.BUY_STORAGE,
      Routes.STORAGE_ORDER_SUMMARY,
      Routes.CHAT_HEAD_SCREEN,
      Routes.CHAT_SCREEN,
      Routes.CREATOR_EVENTS,
      Routes.USER_EVENTS,
      Routes.FAVOURITES,
      Routes.PROFILE,
    };
    return protectedRoutes.contains(route);
  }

  /// Check if route is authentication related
  bool _isAuthRoute(String route) {
    const authRoutes = {
      Routes.LOGIN,
      Routes.SIGN_UP,
      Routes.AUTHENTICATION,
      Routes.COMPLETE_PROFILE,
    };
    return authRoutes.contains(route);
  }
}
