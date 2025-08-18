import 'package:adoptive_calendar/adoptive_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        title: 'Edit Profile',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CommonImageView(
                        url: dummyImg,
                        height: 84,
                        width: 84,
                        radius: 100,
                        borderColor: kInputBorderColor,
                        borderWidth: 2,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Image.asset(
                          Assets.imagesEditBg,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                MyTextField(
                  label: 'Username',
                ),
                MyTextField(
                  label: 'First Name',
                ),
                MyTextField(
                  label: 'Last Name',
                ),
                MyTextField(
                  label: 'Email',
                ),
                MyTextField(
                  label: 'Phone Number',
                ),
                CustomDropDown(
                  hint: 'Gender',
                  selectedValue: null,
                  items: [
                    'Male',
                    'Female',
                    'Prefer not to say',
                  ],
                  onChanged: (v) {},
                ),
                MyTextField(
                  label: 'Date of Birth',
                  readOnly: true,
                  onTap: () {
                    Get.dialog(
                      CustomDialog(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AdoptiveCalendar(
                              initialDate: DateTime.now(),
                              onSelection: (dateTime) {},
                              minYear: 1900,
                              maxYear: 2024,
                              datePickerOnly: true,
                              contentPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              iconColor: kTertiaryColor,
                              fontColor: kTertiaryColor,
                              headingColor: kTertiaryColor,
                              selectedColor: kSecondaryColor,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: MyButton(
                                buttonText: 'Continue',
                                onTap: () {
                                  Get.back();
                                },
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.imagesCalendar,
                        height: 18,
                      ),
                    ],
                  ),
                ),
                MyTextField(
                  label: 'City',
                ),
                MyTextField(
                  label: 'State',
                ),
                MyTextField(
                  label: 'Country',
                ),
                MyTextField(
                  label: 'Full Address',
                ),
                MyTextField(
                  initialValue: 'Nah, I am a computer student',
                  label: 'Bio',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Save changes',
              onTap: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
