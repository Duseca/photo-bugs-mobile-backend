import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/storage/views/storage_order_summary.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_select_payment_method.dart';
import 'package:super_tooltip/super_tooltip.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Order Summary'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                DetailsTile(title: 'Photo - SQFT 100- 2,000', subText: '\$200'),
                DetailsTile(title: 'Category', subText: 'Outdoor'),
                Container(height: 1, color: kInputBorderColor),
                SizedBox(height: 24),
                Row(
                  children: [
                    MyText(text: 'service fee', size: 13, paddingRight: 4),
                    SuperTooltip(
                      arrowLength: 12,
                      arrowTipDistance: 4,
                      popupDirection: TooltipDirection.up,
                      barrierColor: Colors.transparent,
                      backgroundColor: kInputBorderColor,
                      borderColor: Colors.transparent,
                      hasShadow: false,
                      hideTooltipOnTap: true,
                      constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                      content: MyText(
                        text:
                            'This fee helps to run smoothly and ensures you get exactly what you paid for.',
                        size: 12,
                      ),
                      child: Image.asset(Assets.imagesInfo2, height: 16),
                    ),
                    Expanded(
                      child: MyText(
                        text: '\$2.00',
                        size: 13,
                        weight: FontWeight.w500,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                DetailsTile(title: 'Taxes', subText: '\$10.00'),
                Container(height: 1, color: kInputBorderColor),
                SizedBox(height: 24),
                Row(
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
                      text: '\$232.00',
                      color: kSecondaryColor,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Confirm Pay',
              onTap: () {
                Get.to(
                  () => UserSelectPaymentMethod(isSingleImagePayment: true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
