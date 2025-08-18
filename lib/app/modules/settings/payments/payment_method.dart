import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/settings/profile/edit_profile.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/payment_method_tile_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';
class PaymentMethod extends StatelessWidget {
  PaymentMethod({super.key});

  final List<Map<String, dynamic>> items = [
    {
      'icon': Assets.imagesCreditCard,
      'title': 'Card - 1234**********12',
    },
    {
      'icon': Assets.imagesPaypal,
      'title': 'Paypal',
    },
    {
      'icon': Assets.imagesApple,
      'title': 'Apple Pay',
    },
    {
      'icon': Assets.imagesGoogle,
      'title': 'Google Pay',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Payment Method'),
      body: Padding(
        padding: AppSizes.DEFAULT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyText(
              text: 'Select default payment method',
              size: 12,
              paddingBottom: 16,
            ),
            ...List.generate(
              4,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: PaymentMethodTile(
                          icon: items[index]['icon'],
                          title: items[index]['title'],
                          isSelected: index == 0,
                          onTap: () {},
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Image.asset(
                        Assets.imagesEdit2,
                        height: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              height: 9,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => _AddCard());
              },
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset(
                    Assets.imagesAdd,
                    height: 20,
                    color: kSecondaryColor,
                  ),
                  MyText(
                    text: 'Add Card',
                    color: kSecondaryColor,
                    weight: FontWeight.w500,
                    paddingLeft: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Add New Card'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: AppSizes.DEFAULT,
              children: [
                MyTextField(
                  label: 'Card Holder Name',
                ),
                MyTextField(
                  label: 'Card  Number',
                ),
                MyTextField(
                  label: 'Expiry Date',
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
                  label: 'CVV Code',
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Add Card',
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
