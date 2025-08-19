// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class CreatorUploadFolderImage extends StatelessWidget {
  CreatorUploadFolderImage({super.key});

  final List<String> tabs = ['Folder Price', 'Basic Pack', 'Standard Pack'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: simpleAppBar(
          title: 'Table 15',
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.imagesEdit2,
                  height: 20,
                  color: kTertiaryColor,
                ),
              ],
            ),
            SizedBox(width: 20),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              padding: EdgeInsets.symmetric(horizontal: 20),
              labelPadding: EdgeInsets.symmetric(vertical: 12),
              dividerColor: kInputBorderColor,
              dividerHeight: 1,
              labelColor: kSecondaryColor,
              unselectedLabelColor: kQuaternaryColor,
              indicatorColor: kSecondaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              overlayColor: WidgetStatePropertyAll(
                kSecondaryColor.withOpacity(0.1),
              ),
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
            Expanded(
              child: TabBarView(
                children: [_FolderPrice(), _BasicPack(), _StandardPack()],
              ),
            ),
            // Padding(
            //   padding: AppSizes.DEFAULT,
            //   child: MyButton(
            //     borderWidth: 1,
            //     bgColor: Colors.transparent,
            //     textColor: kSecondaryColor,
            //     splashColor: kSecondaryColor.withOpacity(0.1),
            //     buttonText: 'Create Sub Folder',
            //     onTap: () {
            //       Get.to(() => CreatorAddNewFolder());
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _FolderPrice extends StatelessWidget {
  const _FolderPrice();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSizes.DEFAULT,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kInputBorderColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: 'Folder Price',
                    size: 13,
                    weight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                MyText(text: '\$500', weight: FontWeight.w600),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        ...List.generate(2, (index) {
          return _ImageTile(
            image: dummyImg,
            title: 'Image1234567890',
            size: '20mb',
            price: '\$10',
            onEdit: () {},
          );
        }),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {},
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Image.asset(Assets.imagesAdd, height: 18, color: kSecondaryColor),
              MyText(
                text: 'Upload Images',
                color: kSecondaryColor,
                weight: FontWeight.w500,
                paddingLeft: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BasicPack extends StatelessWidget {
  const _BasicPack();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSizes.DEFAULT,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kInputBorderColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Basic Pack',
                        size: 13,
                        weight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(text: '\$500', weight: FontWeight.w600),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'No of images included',
                        size: 12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(text: 'x5', size: 12, weight: FontWeight.w600),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Free images',
                        size: 12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(text: 'x1', size: 12, weight: FontWeight.w600),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        ...List.generate(2, (index) {
          return _ImageTile(
            image: dummyImg,
            title: 'Image1234567890',
            size: '20mb',
            price: '\$10',
            onEdit: () {},
          );
        }),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {},
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Image.asset(Assets.imagesAdd, height: 18, color: kSecondaryColor),
              MyText(
                text: 'Upload Images',
                color: kSecondaryColor,
                weight: FontWeight.w500,
                paddingLeft: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StandardPack extends StatelessWidget {
  const _StandardPack();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSizes.DEFAULT,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kInputBorderColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Standard Pack',
                        size: 13,
                        weight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(text: '\$500', weight: FontWeight.w600),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'No of images included',
                        size: 12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(text: 'x5', size: 12, weight: FontWeight.w600),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Free images',
                        size: 12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(text: 'x1', size: 12, weight: FontWeight.w600),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        ...List.generate(2, (index) {
          return _ImageTile(
            image: dummyImg,
            title: 'Image1234567890',
            size: '20mb',
            price: '\$10',
            onEdit: () {},
          );
        }),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {},
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Image.asset(Assets.imagesAdd, height: 18, color: kSecondaryColor),
              MyText(
                text: 'Upload Images',
                color: kSecondaryColor,
                weight: FontWeight.w500,
                paddingLeft: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String image, title, size, price;
  final VoidCallback onEdit;
  const _ImageTile({
    required this.image,
    required this.title,
    required this.size,
    required this.price,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CommonImageView(url: image, height: 48, width: 48, radius: 4),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyText(text: price, weight: FontWeight.w600),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Size: $size',
                        size: 12,
                        color: kQuaternaryColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MyButton(
                      height: 21,
                      width: 56,
                      radius: 6,
                      borderWidth: 1,
                      textSize: 10,
                      weight: FontWeight.w500,
                      textColor: kSecondaryColor,
                      bgColor: Colors.transparent,
                      splashColor: kSecondaryColor.withOpacity(0.1),
                      buttonText: 'Edit',
                      onTap: onEdit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
