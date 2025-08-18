import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/main.dart';

class TransactionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<String> tabs = ['Total Spent', 'Total Earned'];
  final RxString selectedPeriod = 'This Week'.obs;
  final RxDouble amount = 180.30.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      update(); // Update UI when tab changes
    });
  }

  void onPeriodChanged(String? value) {
    if (value != null) {
      selectedPeriod.value = value;
      // Update amount based on selected period
      _updateAmountForPeriod(value);
    }
  }

  void _updateAmountForPeriod(String period) {
    // Mock data - replace with actual logic
    switch (period) {
      case 'This Week':
        amount.value = 180.30;
        break;
      case 'This Month':
        amount.value = 720.50;
        break;
      case 'This Year':
        amount.value = 8640.00;
        break;
    }
  }

  String get amountText => '\$${amount.value.toStringAsFixed(2)}';

  String get amountDescription =>
      tabController.index == 0 ? 'Total amount spent' : 'Total amount earned';

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class ExpandableItemController extends GetxController {
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

class TransactionHistory extends StatelessWidget {
  TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());

    return Scaffold(
      appBar: simpleAppBar(title: 'Transaction History'),
      body: ListView(
        padding: AppSizes.DEFAULT,
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  controller: controller.tabController,
                  labelPadding: EdgeInsets.symmetric(vertical: 10),
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  labelColor: kSecondaryColor,
                  unselectedLabelColor: kDarkGreyColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: kTertiaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  overlayColor: WidgetStatePropertyAll(
                    kSecondaryColor.withOpacity(0.1),
                  ),
                  splashBorderRadius: BorderRadius.circular(8),
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
                  tabs: controller.tabs.map((e) => Text(e)).toList(),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Amount',
                        size: 12,
                        color: kDarkGreyColor,
                        weight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Obx(
                        () => CustomDropDown(
                          hint: 'This Week',
                          selectedValue: controller.selectedPeriod.value,
                          items: ['This Week', 'This Month', 'This Year'],
                          onChanged: (c) => controller.onPeriodChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => MyText(
                    text: controller.amountText,
                    size: 32,
                    weight: FontWeight.w700,
                  ),
                ),
                GetBuilder<TransactionController>(
                  builder:
                      (controller) =>
                          MyText(text: controller.amountDescription, size: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return _CustomExpandable(
                image: dummyImg,
                title: 'Image123456',
                subTitle: '01/01/2025 8:00 AM',
                price: '-\$40',
                expand: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        color: kInputBorderColor,
                        margin: EdgeInsets.only(bottom: 8),
                      ),
                      _buildDetailTile(
                        text: 'No of images included',
                        subText: 'x4',
                      ),
                      _buildDetailTile(text: 'Free images', subText: 'x1'),
                      Container(
                        height: 1,
                        color: kInputBorderColor,
                        margin: EdgeInsets.only(bottom: 8),
                      ),
                      _buildDetailTile(
                        text: 'Payment Method',
                        subText: 'Visacard 123***********01',
                      ),
                      _buildDetailTile(text: 'Amount', subText: '\$38'),
                      _buildDetailTile(text: 'Tax', subText: '\$1.2'),
                      _buildDetailTile(
                        text: 'Service Charges',
                        subText: '\$0.8',
                      ),
                      Container(
                        height: 1,
                        color: kInputBorderColor,
                        margin: EdgeInsets.only(bottom: 8),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: MyText(
                              text: 'Total',
                              size: 12,
                              weight: FontWeight.w600,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          MyText(
                            text: '\$40',
                            size: 12,
                            weight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({required String text, required String subText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: text,
              size: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(
            text: subText,
            size: 12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CustomExpandable extends StatelessWidget {
  final String image, title, subTitle, price;
  final Widget expand;

  const _CustomExpandable({
    required this.title,
    required this.subTitle,
    required this.expand,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ExpandableItemController(),
      tag: '$title$subTitle', // Unique tag for each item
    );

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
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CommonImageView(url: image, height: 48, width: 48, radius: 8),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          text: title,
                          size: 13,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          paddingBottom: 2,
                        ),
                        MyText(
                          text: subTitle,
                          size: 11,
                          color: kQuaternaryColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  MyText(
                    text: price,
                    color: kRedColor,
                    weight: FontWeight.w500,
                    paddingRight: 8,
                  ),
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
          expanded: expand,
        ),
      ),
    );
  }
}
