import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class HelpCenter extends StatelessWidget {
  HelpCenter({super.key});

  final List<String> tabs = ['FAQs', 'Contact Us'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: simpleAppBar(title: 'Help Center'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              labelPadding: EdgeInsets.only(bottom: 12),
              dividerColor: kInputBorderColor,
              dividerHeight: 1,
              labelColor: kSecondaryColor,
              unselectedLabelColor: kQuaternaryColor,
              indicatorColor: kSecondaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                fontSize: 14,
                color: kSecondaryColor,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.inter,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                color: kQuaternaryColor,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.inter,
              ),
              tabs: tabs.map((e) => Text(e)).toList(),
            ),
            Expanded(child: TabBarView(children: [_Faqs(), _ContactUs()])),
          ],
        ),
      ),
    );
  }
}

class _ContactUs extends StatelessWidget {
  const _ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kInputBorderColor),
            ),
            child: Row(
              children: [
                Image.asset(Assets.imagesCustomerService, height: 24),
                Expanded(
                  child: MyText(
                    text: 'Customer Service',
                    weight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    paddingLeft: 8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kInputBorderColor),
            ),
            child: Row(
              children: [
                Image.asset(Assets.imagesWeb, height: 24),
                Expanded(
                  child: MyText(
                    text: 'Website',
                    weight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    paddingLeft: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Faqs extends StatelessWidget {
  _Faqs({super.key});

  final List<String> items = [
    'How do I create an account?',
    'How do I book a shootr?',
    'How do I start a chat?',
    'How do I give review to seller?',
    'How do I manage my notifications?',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSizes.DEFAULT,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _CustomExpandable(
          title: items[index],
          text:
              'To create an account, download Shootr App from the App Store or Google Play. Open the app, tap "Sign Up," and follow the instructions to register with your email, phone number, or social media account.',
        );
      },
    );
  }
}

class ExpandableControllerManagment extends GetxController {
  final RxBool isExpanded = false.obs;
  late ExpandableController _expandableController;

  @override
  void onInit() {
    super.onInit();
    _expandableController = ExpandableController(initialExpanded: false);
  }

  void toggleExpansion() {
    isExpanded.value = !isExpanded.value;
    _expandableController.toggle();
  }

  @override
  void onClose() {
    _expandableController.dispose();
    super.onClose();
  }
}

class _CustomExpandable extends StatelessWidget {
  final String title, text;

  const _CustomExpandable({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpandableControllerManagment(), tag: title);

    return Obx(
      () => Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                controller.isExpanded.value
                    ? kSecondaryColor
                    : kInputBorderColor,
          ),
        ),
        child: ExpandablePanel(
          controller: controller._expandableController,
          theme: ExpandableThemeData(
            hasIcon: false,
            inkWellBorderRadius: BorderRadius.circular(8),
          ),
          header: GestureDetector(
            onTap: controller.toggleExpansion,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      text: title,
                      size: 13,
                      color:
                          controller.isExpanded.value
                              ? kSecondaryColor
                              : kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 12),
                  RotatedBox(
                    quarterTurns: controller.isExpanded.value ? 2 : 0,
                    child: Image.asset(
                      Assets.imagesDropDown,
                      height: 18,
                      color:
                          controller.isExpanded.value
                              ? kSecondaryColor
                              : kTertiaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          collapsed: SizedBox(),
          expanded: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 1,
                color: kInputBorderColor,
                margin: EdgeInsets.symmetric(horizontal: 14),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: MyText(text: text, size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
