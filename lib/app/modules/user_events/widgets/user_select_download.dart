import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';

import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/modules/user_events/widgets/user_select_payment_method.dart';

import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';


import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';


class UserSelectDownload extends StatelessWidget {
  UserSelectDownload({super.key});

  final List<String> items = [
    'Full Folder',
    'Basic Pack',
    'Standard Pack',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Select Download'),
      body: Padding(
        padding: AppSizes.DEFAULT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(
              3,
              (index) {
                return _CustomRadioTile(
                  text: items[index],
                  isSelected: index == 1,
                  onTap: () {},
                );
              },
            ),
            MyText(
              text: 'Pricing & details',
              size: 12,
              weight: FontWeight.w500,
              paddingBottom: 20,
            ),
            _DetailsRow(
              title: 'Type',
              subText: 'Full Folder',
            ),
            _DetailsRow(
              title: 'No of Images',
              subText: 'x5',
            ),
            _DetailsRow(
              title: 'Free Images',
              subText: 'x1',
            ),
            Row(
              children: [
                Expanded(
                  child: MyText(
                    text: 'Price',
                    size: 12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                MyText(
                  text: '\$5000',
                  color: kSecondaryColor,
                  weight: FontWeight.w700,
                ),
              ],
            ),
            Spacer(),
            MyButton(
              buttonText: 'Confirm & Pay',
              onTap: () {
                Get.to(() => UserSelectPaymentMethod());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  final String title, subText;
  const _DetailsRow({
    super.key,
    required this.title,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: title,
              size: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(
            text: subText,
            size: 12,
          ),
        ],
      ),
    );
  }
}

class _CustomRadioTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  const _CustomRadioTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1.5,
                  color: isSelected ? kSecondaryColor : kQuaternaryColor,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: AnimatedContainer(
                        width: 10,
                        height: 10,
                        duration: Duration(
                          microseconds: 220,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kSecondaryColor,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
            Expanded(
              child: MyText(
                text: text,
                color: isSelected ? kTertiaryColor : kQuaternaryColor,
                weight: isSelected ? FontWeight.w500 : FontWeight.w400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                paddingLeft: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
