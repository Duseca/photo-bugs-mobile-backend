// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/bottom_nav_bar/view/bottom_nav.dart';

import 'package:photo_bug/app/modules/user_events/widgets/user_download_image.dart';

import 'package:photo_bug/app/core/common_widget/congrats_dialog_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/core/common_widget/payment_method_tile_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class UserSelectPaymentMethod extends StatelessWidget {
  final bool? isSingleImagePayment, isStoragePayment;
  UserSelectPaymentMethod({
    super.key,
    this.isSingleImagePayment = false,
    this.isStoragePayment = false,
  });

  final List<Map<String, dynamic>> items = [
    {'icon': Assets.imagesCreditCard, 'title': 'Card - 1234**********12'},
    {'icon': Assets.imagesPaypal, 'title': 'Paypal'},
    {'icon': Assets.imagesApple, 'title': 'Apple Pay'},
    {'icon': Assets.imagesGoogle, 'title': 'Google Pay'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Select Payment Method'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              padding: AppSizes.DEFAULT,
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PaymentMethodTile(
                    icon: items[index]['icon'],
                    title: items[index]['title'],
                    isSelected: index == 0,
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Confirm Pay',
              onTap: () {
                if (isSingleImagePayment!) {
                  Get.dialog(
                    CongratsDialog(
                      title: 'Payment Successful',
                      congratsText:
                          'You successfully purchased Image12347974.jpg.',
                      btnText: 'Browse more images',
                      onTap: () {
                        Get.offAll(() => BottomNavBar());
                      },
                    ),
                  );
                } else if (isStoragePayment!) {
                  Get.dialog(
                    CongratsDialog(
                      title: 'Storage Upgraded!',
                      congratsText:
                          'Wohoo! Your storage capacity has been upgraded.',
                      btnText: 'Continue',
                      onTap: () {
                        Get.offAll(() => BottomNavBar());
                      },
                    ),
                  );
                } else {
                  Get.dialog(
                    CongratsDialog(
                      title: 'Payment Successful',
                      congratsText: 'Congrats! on getting your picks.',
                      btnText: 'Continue',
                      onTap: () {
                        Get.to(() => UserDownloadImage());
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard();

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
                MyTextField(label: 'Card Holder Name'),
                MyTextField(label: 'Card  Number'),
                MyTextField(
                  label: 'Expiry Date',
                  suffix: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(Assets.imagesCalendar, height: 18)],
                  ),
                ),
                MyTextField(label: 'CVV Code'),
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
