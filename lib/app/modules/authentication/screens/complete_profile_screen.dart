import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart'
    show kTertiaryColor, kSecondaryColor, kQuaternaryColor, kInputBorderColor;
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:adoptive_calendar/adoptive_calendar.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  late final AuthController authController;
  late final TextEditingController dobDisplayController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    dobDisplayController = TextEditingController();

    // Set initial value if date is already selected
    if (authController.selectedDateOfBirth.value != null) {
      dobDisplayController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(authController.selectedDateOfBirth.value!);
    }

    // Update display when date changes
    ever(authController.selectedDateOfBirth, (DateTime? date) {
      if (mounted) {
        if (date != null) {
          dobDisplayController.text = DateFormat('dd/MM/yyyy').format(date);
        } else {
          dobDisplayController.clear();
        }
      }
    });
  }

  @override
  void dispose() {
    dobDisplayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Expanded(
              child: MyText(
                text: 'Profile Completion',
                size: 18,
                color: kTertiaryColor,
                fontFamily: AppFonts.inter,
                weight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: authController.skipStep,
              child: MyText(
                text: 'Skip',
                size: 12,
                color: kSecondaryColor,
                weight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Form(
              key: authController.completeProfileFormKey,
              child: ListView(
                padding: AppSizes.DEFAULT,
                children: [
                  // Profile Photo Upload
                  _buildProfilePhotoSection(),

                  // Username
                  MyTextField(
                    label: 'Username',
                    controller: authController.usernameController,
                    marginBottom: 4,
                    validator: authController.validateUsername,
                  ),

                  MyText(
                    text: 'Note: Username can\'t be changed once created.',
                    size: 9,
                    paddingBottom: 16,
                    color: kQuaternaryColor,
                  ),

                  // Gender Dropdown
                  Obx(
                    () => CustomDropDown(
                      hint: 'Gender',
                      selectedValue: authController.selectedGender.value,
                      items: const ['Male', 'Female', 'Prefer not to say'],
                      onChanged: (val) {
                        authController.selectGender(val);
                      },
                    ),
                  ),

                  // Date of Birth - Fixed version
                  MyTextField(
                    label: 'Date of Birth',
                    controller: dobDisplayController,
                    readOnly: true,
                    onTap: () => _showDatePicker(),
                    suffix: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(Assets.imagesCalendar, height: 18),
                      ],
                    ),
                  ),
                  MyTextField(
                    label: 'Phone Number',
                    controller: authController.phoneController,
                    validator:
                        (value) => authController.validateRequired(
                          value,
                          'phone Number',
                        ),
                  ),

                  // City
                  MyTextField(
                    label: 'City',
                    controller: authController.cityController,
                    validator:
                        (value) =>
                            authController.validateRequired(value, 'City'),
                  ),

                  // State
                  MyTextField(
                    label: 'State',
                    controller: authController.stateController,
                    validator:
                        (value) =>
                            authController.validateRequired(value, 'State'),
                  ),

                  // Country
                  MyTextField(
                    label: 'Country',
                    controller: authController.countryController,
                    validator:
                        (value) =>
                            authController.validateRequired(value, 'Country'),
                  ),

                  // Full Address
                  MyTextField(
                    label: 'Full Address',
                    controller: authController.addressController,
                    validator:
                        (value) =>
                            authController.validateRequired(value, 'Address'),
                  ),

                  // Bio
                  MyTextField(
                    label: 'Bio',
                    controller: authController.bioController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          // Next Button
          Padding(
            padding: AppSizes.DEFAULT,
            child: Obx(
              () => MyButton(
                buttonText: 'Next',
                isLoading: authController.isLoading.value,
                onTap: authController.completeProfile,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CommonImageView(
                height: 128,
                width: 128,
                radius: 100,
                borderWidth: 1,
                borderColor: kInputBorderColor,
                imagePath: Assets.imagesUnicon,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Info',
                      'Image upload functionality to be implemented',
                      snackPosition: SnackPosition.TOP,
                    );
                  },
                  child: Image.asset(Assets.imagesAddBg, height: 40),
                ),
              ),
            ],
          ),
        ),
        MyText(
          text: 'Upload profile photo',
          color: kQuaternaryColor,
          textAlign: TextAlign.center,
          paddingTop: 16,
          paddingBottom: 42,
        ),
      ],
    );
  }

  void _showDatePicker() {
    Get.dialog(
      CustomDialog(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdoptiveCalendar(
              initialDate:
                  authController.selectedDateOfBirth.value ?? DateTime.now(),
              onSelection: (date) {
                if (date != null) {
                  authController.selectDateOfBirth(date);
                }
              },
              minYear: 1900,
              maxYear: DateTime.now().year,
              datePickerOnly: true,
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              iconColor: kTertiaryColor,
              fontColor: kTertiaryColor,
              headingColor: kTertiaryColor,
              selectedColor: kSecondaryColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MyButton(
                buttonText: 'Continue',
                onTap: () {
                  Get.back();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
