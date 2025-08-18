import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/utils/event_type.dart';
import 'package:photo_bug/app/core/utils/services_needed.dart';
import 'package:photo_bug/app/modules/add_new_listing/view/add_creator_listing.dart';

import 'package:photo_bug/app/core/common_widget/custom_bottom_sheet_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_search_bar_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class AddHostEvent extends StatelessWidget {
  const AddHostEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSizes.DEFAULT,
      children: [
        MyTextField(
          label: 'Event Name',
        ),
        GestureDetector(
          onTap: () {
            Get.bottomSheet(
              isScrollControlled: true,
              _evenTypeBottomSheet(),
            );
          },
          child: CustomDropDown(
            hint: 'Event Type',
            selectedValue: null,
            items: [],
            onChanged: (v) {},
          ),
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
          label: 'Host/Organizer Name',
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
        MyTextField(
          label: 'Expected Number of Attendees',
        ),
        GestureDetector(
          onTap: () {
            Get.bottomSheet(
              isScrollControlled: true,
              _servicesNeededBottomSheet(),
            );
          },
          child: CustomDropDown(
            hint: 'Services Needed',
            selectedValue: null,
            items: [],
            onChanged: (v) {},
          ),
        ),
        MyTextField(
          label: 'Budget/Compensation',
        ),
        MyTextField(
          label: 'Special Requirements or Preferences',
          maxLines: 3,
        ),
        MyTextField(
          label: 'Event Theme',
        ),
        MyTextField(
          label: 'Application Deadline',
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
      ],
    );
  }

  Widget _evenTypeBottomSheet() {
    return CustomBottomSheet(
      height: Get.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Event Type',
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
                  itemCount: eventTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          text: eventTypes[index]['title'],
                          size: 14,
                          weight: FontWeight.w600,
                          paddingBottom: 8,
                          paddingTop: index == 0 ? 0 : 12,
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            eventTypes[index]['items'].length,
                            (i) {
                              return IntrinsicWidth(
                                child: CustomToggleButton(
                                  text: eventTypes[index]['items'][i],
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
                  hint: 'Enter Other Event Type',
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

  Widget _servicesNeededBottomSheet() {
    return CustomBottomSheet(
      height: Get.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Services Needed',
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
                  itemCount: servicesNeeded.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          text: servicesNeeded[index]['title'],
                          size: 14,
                          weight: FontWeight.w600,
                          paddingBottom: 8,
                          paddingTop: index == 0 ? 0 : 12,
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            servicesNeeded[index]['items'].length,
                            (i) {
                              return IntrinsicWidth(
                                child: CustomToggleButton(
                                  text: servicesNeeded[index]['items'][i],
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

