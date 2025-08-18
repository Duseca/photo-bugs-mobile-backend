import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/utils/services_offered.dart';
import 'package:photo_bug/app/core/common_widget/custom_bottom_sheet_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_search_bar_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class AddCreatorListing extends StatelessWidget {
  const AddCreatorListing({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSizes.DEFAULT,
      children: [
        MyText(
          text: 'Profile Picture',
          weight: FontWeight.w500,
          paddingBottom: 8,
        ),
        Row(
          children: [
            Image.asset(
              Assets.imagesUploadImage,
              height: 80,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    text: 'Browse File',
                    size: 12,
                    color: kSecondaryColor,
                    weight: FontWeight.w500,
                    paddingBottom: 8,
                  ),
                  MyText(
                    text: 'Select photos to upload',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        MyTextField(
          label: 'Name',
        ),
        MyTextField(
          label: 'Location',
          suffix: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.imagesLocation,
                height: 18,
              ),
            ],
          ),
        ),
        MyTextField(
          label: 'Description',
          maxLines: 3,
        ),
        MyTextField(
          label: 'Date',
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
          label: 'Time Start',
          suffix: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.imagesClock,
                height: 18,
              ),
            ],
          ),
        ),
        MyTextField(
          label: 'Time End',
          suffix: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.imagesClock,
                height: 18,
              ),
            ],
          ),
        ),
        MyTextField(
          label: 'Keywords',
        ),
        MyTextField(
          label: 'Email',
        ),
        MyTextField(
          label: 'Phone Number',
        ),
        GestureDetector(
          onTap: () {
            Get.bottomSheet(
              isScrollControlled: true,
              _serviceOfferedBottomSheet(),
            );
          },
          child: CustomDropDown(
            hint: 'Services Offered',
            selectedValue: null,
            items: [],
            onChanged: (v) {},
          ),
        ),
        MyTextField(
          label: 'Prices',
        ),
        CustomDropDown(
          hint: 'Languages Spoken',
          selectedValue: null,
          items: [],
          onChanged: (v) {},
        ),
        MyTextField(
          label: 'Experience/Qualifications',
          maxLines: 3,
        ),
        MyTextField(
          label: 'Social Media Links',
          marginBottom: 10,
        ),
        MyText(
          text: '+Add',
          size: 12,
          color: kSecondaryColor,
          weight: FontWeight.w600,
          textAlign: TextAlign.end,
        ),
        MyText(
          text: 'Portfolio',
          weight: FontWeight.w500,
          paddingTop: 16,
          paddingBottom: 8,
        ),
        Row(
          children: [
            Image.asset(
              Assets.imagesUploadImage,
              height: 80,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    text: 'Browse File',
                    size: 12,
                    color: kSecondaryColor,
                    weight: FontWeight.w500,
                    paddingBottom: 8,
                  ),
                  MyText(
                    text: 'Select photos to upload',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceOfferedBottomSheet() {
    return CustomBottomSheet(
      height: Get.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Services Offered',
            size: 16,
            weight: FontWeight.w600,
            textAlign: TextAlign.center,
            paddingBottom: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomSearchBar(
              hint: 'Search',
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: servicesOffered.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          text: servicesOffered[index]['title'],
                          size: 14,
                          weight: FontWeight.w600,
                          paddingBottom: 8,
                          paddingTop: index == 0 ? 0 : 12,
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            servicesOffered[index]['items'].length,
                            (i) {
                              return IntrinsicWidth(
                                child: CustomToggleButton(
                                  text: servicesOffered[index]['items'][i],
                                  isSelected: i == 0 || i == 2,
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                MyTextField(
                  heading: 'Other',
                  hint: 'Enter Other Services',
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Continue',
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

class CustomToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  const CustomToggleButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 30,
      duration: 220.milliseconds,
      decoration: BoxDecoration(
        color: isSelected ? kSecondaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        border: isSelected
            ? null
            : Border.all(
                width: 1.0,
                color: kInputBorderColor,
              ),
      ),
      child: MyRippleEffect(
        onTap: onTap,
        radius: 50,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: MyText(
              text: text,
              size: 12,
              color: isSelected ? kTertiaryColor : kDarkGreyColor,
            ),
          ),
        ),
      ),
    );
  }
}
