import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/models/onboarding/onboarding_model.dart';
import 'package:photo_bug/app/modules/authentication/screens/login_screen.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  // Observable variables
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool canProceed = true.obs;

  // Onboarding items
  List<OnboardingItem> items = [
    OnboardingItem(
      image: Assets.imagesEventOnboarding,
      title: 'My Event',
      subTitle:
          'Discover events that need your talent and apply to get paid! Whether you\'re a photographer, videographer, or any type of creator, find the perfect opportunities here.',
    ),
    OnboardingItem(
      image: Assets.imagesListingOnboarding,
      title: 'My Listing',
      subTitle:
          'Add your listing and let them find you! Whether it\'s your birthday, wedding, or any special occasion, you can specify the type of creator you\'re looking for. Make your event unforgettable with the perfect match!',
    ),
    OnboardingItem(
      image: Assets.imagesFeedbackOnboarding,
      title: 'Give Feedback',
      subTitle:
          'We want to hear from you! Let us know what\'s missing so we can add it in the next release. If something isn\'t working to your liking, please report it here so we can make the necessary adjustments. Your feedback helps us continuously improve and ensure we\'re doing everything possible to help you sell your media.',
    ),
    OnboardingItem(
      image: Assets.imagesSearchOnboarding,
      title: 'Search',
      subTitle:
          'Find the ideal creator for your special occasion. Search through our listings to connect with talented professionals who can make your event unforgettable.',
    ),
    OnboardingItem(
      image: Assets.imagesStorageOnboarding,
      title: 'Need More Storage',
      subTitle:
          'Upgrade your storage to keep all your full-resolution media content safe and accessible. Start with a default of 25MB to get you going, and easily purchase additional storage as your needs grow. Ensure your media is always available in its highest quality!',
    ),
    OnboardingItem(
      image: Assets.imagesLastOnboarding,
      title: 'Capture and Control',
      subTitle:
          'Looking to sell your uncompressed photos online or planning an event? Photo Bugs has you covered! Whether you need photographers, videographers, or other creative professionals, we have everything you need to collaborate and make your next event a success.',
    ),
  ];

  // Get current item
  OnboardingItem get currentItem => items[currentIndex.value];

  // Check if is last page
  bool get isLastPage => currentIndex.value == items.length - 1;

  // Get button text
  String get buttonText => isLastPage ? 'Let\'s Get Started' : 'next';

  // Continue to next page or complete onboarding
  void continueOnboarding() {
    if (isLastPage) {
      _completeOnboarding();
    } else {
      _nextPage();
    }
  }

  // Go to next page
  void _nextPage() {
    if (currentIndex.value < items.length - 1) {
      currentIndex.value++;
    }
  }

  // Go to previous page
  void previousPage() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  // Skip to last page
  void skipOnboarding() {
    currentIndex.value = items.length - 1;
  }

  // Complete onboarding and navigate to login
  void _completeOnboarding() {
    isLoading.value = true;

    // Save onboarding completion status
    _saveOnboardingStatus();

    // Navigate to login
    Future.delayed(const Duration(milliseconds: 500), () {
      isLoading.value = false;
      Get.toNamed(Routes.LOGIN);
    });
  }

  // Save onboarding completion status (implement with your storage solution)
  void _saveOnboardingStatus() {
    // Example: SharedPreferences, GetStorage, etc.
    // await GetStorage().write('onboarding_completed', true);
  }

  // Jump to specific page
  void jumpToPage(int index) {
    if (index >= 0 && index < items.length) {
      currentIndex.value = index;
    }
  }

  // Get progress percentage
  double get progress => (currentIndex.value + 1) / items.length;
}
