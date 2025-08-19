import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/storage/controller/buy_storage_controller.dart';

import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class BuyStorage extends GetView<BuyStorageController> {
  const BuyStorage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Buy More Storage'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildStorageOptionsList()),
          _buildBuyButton(),
        ],
      ),
    );
  }

  Widget _buildStorageOptionsList() {
    return ListView.builder(
      padding: AppSizes.DEFAULT,
      itemCount: controller.storageOptions.length,
      itemBuilder: (context, index) {
        final option = controller.storageOptions[index];
        return Obx(
          () => CustomRadioTile(
            title: option['title'],
            price: option['price'],
            isSelected: controller.selectedIndex.value == index,
            onTap: () => controller.selectOption(index),
          ),
        );
      },
    );
  }

  Widget _buildBuyButton() {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: Obx(
        () => MyButton(
          buttonText: 'Buy',
          onTap: controller.proceedToBuy,
          isLoading: controller.isLoading.value,
        ),
      ),
    );
  }
}

class CustomRadioTile extends StatelessWidget {
  final String title, price;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomRadioTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            _buildRadioButton(),
            _buildTitleSection(),
            _buildPriceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 1.5,
          color: isSelected ? kSecondaryColor : kQuaternaryColor,
        ),
      ),
      child:
          isSelected
              ? Center(
                child: AnimatedContainer(
                  width: 10,
                  height: 10,
                  duration: const Duration(milliseconds: 220),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kSecondaryColor,
                  ),
                ),
              )
              : const SizedBox(),
    );
  }

  Widget _buildTitleSection() {
    return Expanded(
      child: MyText(
        text: title,
        color: isSelected ? kSecondaryColor : kQuaternaryColor,
        weight: isSelected ? FontWeight.w500 : FontWeight.w400,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        paddingLeft: 8,
      ),
    );
  }

  Widget _buildPriceSection() {
    return MyText(
      text: price,
      color: isSelected ? kSecondaryColor : kQuaternaryColor,
      weight: isSelected ? FontWeight.w500 : FontWeight.w400,
    );
  }
}
