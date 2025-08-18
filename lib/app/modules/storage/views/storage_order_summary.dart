import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/storage/controller/storage_controllers.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/modules/storage/controller/storage_order_controller.dart';

class StorageOrderSummary extends GetView<StorageOrderController> {
  const StorageOrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Order Summary'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildOrderDetails()),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return ListView(
      padding: AppSizes.DEFAULT,
      children: [
        Obx(
          () => DetailsTile(
            title: 'Storage Capacity',
            subText: controller.storageCapacity.value,
          ),
        ),
        Container(height: 1, color: kInputBorderColor),
        const SizedBox(height: 24),
        Obx(
          () => DetailsTile(title: 'Taxes', subText: controller.formattedTaxes),
        ),
        _buildTotalSection(),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: MyText(
              text: 'Total (USD)',
              color: kSecondaryColor,
              weight: FontWeight.w700,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(
            text: controller.formattedTotal,
            color: kSecondaryColor,
            weight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: Obx(
        () => MyButton(
          buttonText: 'Confirm Pay',
          onTap: controller.proceedToPayment,
          isLoading: controller.isLoading.value,
        ),
      ),
    );
  }
}

class DetailsTile extends StatelessWidget {
  final String title, subText;
  const DetailsTile({super.key, required this.title, required this.subText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: title,
              size: 13,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(text: subText, size: 13, weight: FontWeight.w500),
        ],
      ),
    );
  }
}
