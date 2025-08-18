import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/storage/controller/storage_controllers.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class Storage extends GetView<StorageController> {
  const Storage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'My Storage'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildStorageDetails()),
            _buildBuyMoreButton(),
          ],
        );
      }),
    );
  }

  Widget _buildStorageDetails() {
    return ListView(
      padding: AppSizes.DEFAULT,
      children: [
        _buildStorageIndicator(),
        const SizedBox(height: 32),
        _buildStorageInfoSection(),
      ],
    );
  }

  Widget _buildStorageIndicator() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: kTertiaryColor,
            width: 4,
          ),
        ),
        child: Obx(() => CircularStepProgressIndicator(
          height: 156,
          width: 156,
          totalSteps: controller.totalSteps.value,
          currentStep: controller.currentStep.value,
          padding: 0,
          selectedStepSize: 10,
          unselectedStepSize: 10,
          selectedColor: kSecondaryColor,
          unselectedColor: kInputBorderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               MyText(
                text: 'Available',
                paddingBottom: 2,
              ),
              Obx(() => MyText(
                text: controller.formattedAvailableStorage,
                size: 16,
                weight: FontWeight.w600,
                paddingBottom: 2,
              )),
              Obx(() => MyText(
                text: 'Total ${controller.formattedTotalStorage}',
              )),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildStorageInfoSection() {
    return Column(
      children: [
        _buildStorageInfoItem(
          color: kTertiaryColor,
          title: 'Total Storage',
          value: controller.formattedTotalStorage,
        ),
        const SizedBox(height: 24),
        _buildStorageInfoItem(
          color: kSecondaryColor,
          title: 'Available Storage',
          value: controller.formattedAvailableStorage,
        ),
        const SizedBox(height: 24),
        _buildStorageInfoItem(
          color: kInputBorderColor,
          title: 'Used Storage',
          value: controller.formattedUsedStorage,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStorageInfoItem({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyText(
                text: title,
                size: 16,
                weight: FontWeight.w600,
                lineHeight: 1,
                paddingBottom: 4,
              ),
              Obx(() => MyText(text: value)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBuyMoreButton() {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: MyButton(
        borderWidth: 1,
        bgColor: Colors.transparent,
        textColor: kSecondaryColor,
        splashColor: kSecondaryColor.withOpacity(0.1),
        buttonText: 'Buy More Storage',
        onTap: controller.navigateToBuyStorage,
      ),
    );
  }
}