import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_banner_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_bottom_sheet_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/modules/home/controller/home_controller.dart';
import 'package:photo_bug/app/modules/listing/views/listing.dart';
import 'package:photo_bug/app/modules/user_events/views/user_events.dart';
import 'package:photo_bug/app/modules/home/screens/app_feedback.dart';
import 'package:photo_bug/app/modules/search/views/search_screen.dart';
import 'package:photo_bug/app/modules/storage/views/storage.dart';
import 'package:photo_bug/app/modules/image_detail/view/image_detail_view.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/view/bottom_nav.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

// HomeController
class HomeController extends GetxController {
  // Observable variables
  final RxBool isListView = false.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedSortOption = ''.obs;

  // Dummy image URL
  final String dummyImg =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=764&q=80';

  // Quick actions data
  final List<Map<String, dynamic>> quickActions = [
    {
      'icon': Assets.imagesCalendar,
      'label': 'My listing',
      'onTap': () => Get.to(() => Listing()),
    },
    {
      'icon': Assets.imagesCalendar,
      'label': 'My Event',
      'onTap': () => Get.to(() => UserEvents()),
    },
    {
      'icon': Assets.imagesFeedback,
      'label': 'Feedback',
      'onTap': () => Get.to(() => AppFeedback()),
    },
    {
      'icon': Assets.imagesSearchCreator,
      'label': 'Search',
      'onTap': () => Get.to(() => SearchScreen()),
    },
    {
      'icon': Assets.imagesStorage,
      'label': 'My Storage',
      'onTap': () => Get.to(() => Storage()),
    },
  ];

  // Toggle view type
  void toggleViewType() {
    isListView.value = !isListView.value;
  }

  // Navigate to image details
  void navigateToImageDetails() {
    Get.to(() => ImageDetails());
  }

  // Show sort options
  void showSortOptions() {
    final sortOptions = [
      'Most Popular',
      'Newest',
      'Price: Low to High',
      'Price: High to Low',
      'Most Viewed',
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            MyText(text: 'Sort By', size: 18, weight: FontWeight.w600),
            const SizedBox(height: 20),
            ...sortOptions.map(
              (option) => ListTile(
                title: Text(option),
                trailing:
                    selectedSortOption.value == option
                        ? const Icon(Icons.check, color: kPrimaryColor)
                        : null,
                onTap: () {
                  selectedSortOption.value = option;
                  Get.back();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Report Controller
class ReportController extends GetxController {
  final RxString selectedReason = ''.obs;
  final RxString reportDescription = ''.obs;
  final RxBool isSubmitting = false.obs;
  final TextEditingController descriptionController = TextEditingController();

  final List<String> reportReasons = [
    'Bullying or unwanted contact',
    'Suicide, self-injury or eating disorders',
    'Inappropriate content',
  ];

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  void selectReason(int index) {
    selectedReason.value = reportReasons[index];
    _showReportDetailsBottomSheet();
  }

  void _showReportDetailsBottomSheet() {
    Get.bottomSheet(
      isScrollControlled: true,
      CustomBottomSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyText(
              text: 'Report',
              size: 18,
              weight: FontWeight.w600,
              textAlign: TextAlign.center,
              paddingBottom: 8,
            ),
            MyText(
              text:
                  'If you want to share more info about the report then write below in detail.',
              size: 12,
              textAlign: TextAlign.center,
              paddingLeft: 20,
              paddingRight: 20,
              paddingBottom: 20,
            ),
            Expanded(
              child: ListView(
                padding: AppSizes.HORIZONTAL,
                children: [
                  MyTextField(
                    label: 'Description',
                    maxLines: 5,
                    controller: descriptionController,
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSizes.DEFAULT,
              child: Obx(
                () => MyButton(
                  buttonText: 'Submit',
                  onTap: submitReport,
                  isLoading: isSubmitting.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitReport() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSubmitting.value = false;

    Get.dialog(
      CongratsDialog(
        title: 'Report Submitted',
        congratsText:
            'Your report has been submitted, our team is looking into it.',
        btnText: 'Continue',
        onTap: () {
          Get.offAll(() => BottomNavBar());
        },
      ),
    );
  }
}
