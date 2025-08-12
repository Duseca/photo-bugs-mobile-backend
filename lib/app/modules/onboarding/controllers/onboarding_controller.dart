import 'package:get/get.dart';
import 'package:photo_bug/app/shared/constants/app_images.dart';

class OnboardingController extends GetxController {
  // Observable current index
  var currentIndex = 0.obs;

  // Onboarding items data
  final List<Map<String, dynamic>> items = [
    {
      'image': Assets.imagesEventOnboarding,
      'title': 'My Event',
      'subTitle':
          'Discover events that need your talent and apply to get paid! Whether you’re a photographer, videographer, or any type of creator, find the perfect opportunities here.',
    },
    {
      'image': Assets.imagesListingOnboarding,
      'title': 'My Listing',
      'subTitle':
          'Add your listing and let them find you! Whether it’s your birthday, wedding, or any special occasion, you can specify the type of creator you’re looking for. Make your event unforgettable with the perfect match!',
    },
    {
      'image': Assets.imagesFeedbackOnboarding,
      'title': 'Give Feedback',
      'subTitle':
          'We want to hear from you! Let us know what’s missing so we can add it in the next release. If something isn’t working to your liking, please report it here so we can make the necessary adjustments. Your feedback helps us continuously improve and ensure we’re doing everything possible to help you sell your media.',
    },
    {
      'image': Assets.imagesSearchOnboarding,
      'title': 'Search',
      'subTitle':
          'Find the ideal creator for your special occasion. Search through our listings to connect with talented professionals who can make your event unforgettable.',
    },
    {
      'image': Assets.imagesStorageOnboarding,
      'title': 'Need More Storage',
      'subTitle':
          'Upgrade your storage to keep all your full-resolution media content safe and accessible. Start with a default of 25MB to get you going, and easily purchase additional storage as your needs grow. Ensure your media is always available in its highest quality!',
    },
    {
      'image': Assets.imagesLastOnboarding,
      'title': 'Capture and Control',
      'subTitle':
          'Looking to sell your uncompressed photos online or planning an event? Photo Bugs has you covered! Whether you need photographers, videographers, or other creative professionals, we have everything you need to collaborate and make your next event a success.',
    },
  ];

  // Getters for current item data
  String get currentImage => items[currentIndex.value]['image'];
  String get currentTitle => items[currentIndex.value]['title'];
  String get currentSubTitle => items[currentIndex.value]['subTitle'];
  bool get isLastPage => currentIndex.value == items.length - 1;

  // Continue button action
  void onContinue() {
    if (isLastPage) {
      // Navigate to login screen
      Get.offAllNamed('/login');
    } else {
      // Go to next page
      currentIndex.value++;
    }
  }

  // Skip to login (optional)
  void skipToLogin() {
    Get.offAllNamed('/login');
  }

  // Go to specific page (for indicators)
  void goToPage(int index) {
    if (index >= 0 && index < items.length) {
      currentIndex.value = index;
    }
  }

  // Go back (optional)
  void goBack() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }
}
