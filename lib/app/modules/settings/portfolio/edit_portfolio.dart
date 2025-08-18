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

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';
class EditPortfolio extends StatelessWidget {
  const EditPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Portfolio'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: MyButton(
              borderWidth: 1,
              bgColor: Colors.transparent,
              splashColor: kSecondaryColor.withOpacity(0.1),
              buttonText: '',
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.imagesAdd,
                    height: 18,
                    color: kSecondaryColor,
                  ),
                  Flexible(
                    child: MyText(
                      text: 'Upload Portfolio',
                      size: 16,
                      color: kSecondaryColor,
                      weight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      paddingLeft: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: AppSizes.DEFAULT,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 160,
              ),
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    CommonImageView(
                      url: dummyImg,
                      width: Get.width,
                      radius: 8,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Image.asset(
                        Assets.imagesDeleteBg,
                        height: 28,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
