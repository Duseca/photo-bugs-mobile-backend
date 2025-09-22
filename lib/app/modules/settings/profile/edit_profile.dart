import 'package:adoptive_calendar/adoptive_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';

import 'package:photo_bug/app/core/common_widget/custom_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/modules/settings/profile/controller/profile_controller.dart';
import 'package:photo_bug/main.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ProfileController instance
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: simpleAppBar(title: 'Edit Profile'),
      body: Form(
        key: profileController.completeProfileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: AppSizes.DEFAULT,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Obx(() {
                          final user = profileController.currentUser;
                          return CommonImageView(
                            url: user?.profilePicture ?? dummyImg,
                            height: 84,
                            width: 84,
                            radius: 100,
                            borderColor: kInputBorderColor,
                            borderWidth: 2,
                          );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Handle profile picture change
                              // Add image picker functionality here
                            },
                            child: Image.asset(Assets.imagesEditBg, height: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  MyTextField(
                    label: 'First Name',
                    controller: profileController.firstNameController,
                    validator:
                        (value) => profileController.validateRequired(
                          value,
                          'First Name',
                        ),
                  ),
                  MyTextField(
                    label: 'Last Name',
                    controller: profileController.lastNameController,
                    validator:
                        (value) => profileController.validateRequired(
                          value,
                          'Last Name',
                        ),
                  ),

                  MyTextField(
                    label: 'Phone Number',
                    controller: profileController.phoneController,
                    validator: profileController.validatePhone,
                  ),
                  Obx(
                    () => CustomDropDown(
                      hint: 'Gender',
                      selectedValue: profileController.selectedGender.value,
                      items: ['Male', 'Female', 'Prefer not to say'],
                      onChanged: (value) {
                        profileController.selectGender(value!);
                      },
                    ),
                  ),
                  Obx(
                    () => MyTextField(
                      label: 'Date of Birth',
                      initialValue:
                          profileController.selectedDateOfBirth.value != null
                              ? DateFormat('dd/MM/yyyy').format(
                                profileController.selectedDateOfBirth.value!,
                              )
                              : '',
                      readOnly: true,
                      onTap: () {
                        Get.dialog(
                          CustomDialog(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AdoptiveCalendar(
                                  initialDate:
                                      profileController
                                          .selectedDateOfBirth
                                          .value ??
                                      DateTime.now().subtract(
                                        Duration(days: 365 * 18),
                                      ),
                                  onSelection: (dateTime) {
                                    profileController.selectDateOfBirth(
                                      dateTime!,
                                    );
                                  },
                                  minYear: 1900,
                                  maxYear:
                                      DateTime.now().year -
                                      13, // Minimum age 13
                                  datePickerOnly: true,
                                  contentPadding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  iconColor: kTertiaryColor,
                                  fontColor: kTertiaryColor,
                                  headingColor: kTertiaryColor,
                                  selectedColor: kSecondaryColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: MyButton(
                                    buttonText: 'Continue',
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                      suffix: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Assets.imagesCalendar, height: 18),
                        ],
                      ),
                    ),
                  ),
                  MyTextField(
                    label: 'City',
                    controller: profileController.cityController,
                  ),

                  MyTextField(
                    label: 'Country',
                    controller: profileController.countryController,
                  ),
                  MyTextField(
                    label: 'Full Address',
                    controller: profileController.addressController,
                  ),
                  MyTextField(
                    label: 'Bio',
                    controller: profileController.bioController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSizes.DEFAULT,
              child: Obx(
                () => MyButton(
                  buttonText: 'Save changes',
                  isLoading: profileController.isLoading.value,
                  onTap: () async {
                    // Update profile and go back if successful
                    await profileController.updateProfile();
                    if (!profileController.isLoading.value) {
                      // Only go back if the update was successful (loading finished)
                      Get.back();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
