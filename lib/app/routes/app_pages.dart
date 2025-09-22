import 'package:get/get.dart';
import 'package:photo_bug/app/middleware/auth_middleware.dart';
import 'package:photo_bug/app/modules/add_new_listing/binding/add_listing_binding.dart';
import 'package:photo_bug/app/modules/add_new_listing/view/add_new_listing.dart';
import 'package:photo_bug/app/modules/authentication/screens/complete_profile_screen.dart';
import 'package:photo_bug/app/modules/authentication/screens/login_screen.dart';
import 'package:photo_bug/app/modules/authentication/screens/signup_screen.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/bindings/bottom_nav_binding.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/view/bottom_nav.dart';
import 'package:photo_bug/app/modules/chat/bindings/chat_bindings.dart';
import 'package:photo_bug/app/modules/chat/views/chat_head.dart';
import 'package:photo_bug/app/modules/chat/views/chat_screen.dart';
import 'package:photo_bug/app/modules/creator_events/bindings/creator_events_binding.dart';
import 'package:photo_bug/app/modules/creator_events/view/creator_events.dart';
import 'package:photo_bug/app/modules/downloads/bindings/download_bindings.dart';
import 'package:photo_bug/app/modules/downloads/view/download_details.dart';
import 'package:photo_bug/app/modules/downloads/view/downloads.dart';
import 'package:photo_bug/app/modules/downloads/view/image_view.dart';
import 'package:photo_bug/app/modules/favorite/binding/favourite_binding.dart';
import 'package:photo_bug/app/modules/favorite/view/user_favorite.dart';
import 'package:photo_bug/app/modules/home/binding/home_binding.dart';
import 'package:photo_bug/app/modules/home/view/home_view.dart';
import 'package:photo_bug/app/modules/image_detail/binding/image_detail_binding.dart';
import 'package:photo_bug/app/modules/image_detail/view/image_detail_view.dart';
import 'package:photo_bug/app/modules/launch/bindings/launch_bindings.dart';
import 'package:photo_bug/app/modules/launch/views/on_boarding.dart';
import 'package:photo_bug/app/modules/launch/views/splash_screen.dart';
import 'package:photo_bug/app/modules/launch/views/welcome_screen.dart';
import 'package:photo_bug/app/modules/listing/bindings/listing_module.dart';
import 'package:photo_bug/app/modules/listing/views/listing.dart';
import 'package:photo_bug/app/modules/listing/views/listing_details.dart';
import 'package:photo_bug/app/modules/search/binding/search_bindings.dart';
import 'package:photo_bug/app/modules/search/views/search_details.dart';
import 'package:photo_bug/app/modules/search/views/search_screen.dart';
import 'package:photo_bug/app/modules/settings/profile/bindings/profile_binding.dart';
import 'package:photo_bug/app/modules/settings/profile/profile.dart';
import 'package:photo_bug/app/modules/storage/bindings/storage_binding.dart';
import 'package:photo_bug/app/modules/storage/views/buy_storage.dart';
import 'package:photo_bug/app/modules/storage/views/storage.dart';
import 'package:photo_bug/app/modules/storage/views/storage_order_summary.dart';
import 'package:photo_bug/app/modules/user_events/bindings/user_events_binding.dart';
import 'package:photo_bug/app/modules/user_events/views/user_events.dart';

import '../modules/authentication/bindings/authentication_binding.dart';
import '../modules/authentication/views/authentication_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME_SCREEN,
      page: () => const WelcomeScreen(),
      binding: WelcomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
      middlewares: [
        AppMiddleware(),
      ], // Ensure this is the first route to handle onboarding
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnBoarding(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTICATION,
      page: () => const AuthenticationView(),
      binding: AuthenticationBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const Login(),
      binding: AuthenticationBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUp(),
      binding: AuthenticationBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: _Paths.COMPLETE_PROFILE,
      page: () => const CompleteProfile(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOM_NAV_BAR,
      page: () => BottomNavBar(),
      binding: BottomNavBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const Home(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ADD_NEW_LISTING,
      page: () => const AddNewListing(),
      binding: AddNewListingBinding(),
    ),
    GetPage(
      name: _Paths.LISTING,
      page: () => const Listing(),
      binding: ListingBinding(),
    ),
    GetPage(
      name: _Paths.LISTING_DETAILS,
      page: () => const ListingDetails(),
      binding: ListingDetailsBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_DETAILS,
      page: () => const ImageDetails(),
      binding: ImageDetailsBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_VIEW,
      page: () => const ImageView(),
      binding: ImageViewBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_SCREEN,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_DETAILS,
      page: () => const SearchDetails(),
      binding: SearchDetailBinding(),
    ),
    GetPage(
      name: _Paths.DOWNLOADS,
      page: () => const Downloads(),
      binding: DownloadsBinding(),
    ),
    GetPage(
      name: _Paths.DOWNLOAD_DETAILS,
      page: () => const DownloadDetails(),
      binding: DownloadDetailsBinding(),
    ),
    GetPage(
      name: _Paths.STORAGE,
      page: () => const Storage(),
      binding: StorageBinding(),
    ),
    GetPage(
      name: _Paths.BUY_STORAGE,
      page: () => const BuyStorage(),
      binding: BuyStorageBinding(),
    ),
    GetPage(
      name: _Paths.STORAGE_ORDER_SUMMARY,
      page: () => const StorageOrderSummary(),
      binding: StorageOrderBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_HEAD_SCREEN,
      page: () => const ChatHeadScreen(),
      binding: ChatHeadBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_SCREEN,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.CREATOR_EVENTS,
      page: () => const CreatorEvents(),
      binding: CreatorEventsBinding(),
    ),
    GetPage(
      name: _Paths.USER_EVENTS,
      page: () => const UserEvents(),
      binding: UserEventsBinding(),
    ),
    GetPage(
      name: _Paths.FAVOURITES,
      page: () => const Favourite(),
      binding: FavouriteBinding(),
      // Your existing Favourite widget
      // Your existing binding
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const Profile(),
      binding: ProfileBinding(),
    ),
  ];
}
