import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/modules/user_events/widgets/user_select_download.dart';

import 'package:photo_bug/app/core/common_widget/image_tile_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';

import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class ImageFolderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final RxInt currentIndex = 0.obs;
  final List<String> tabs = ['All', 'Owned', 'Not Owned'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.animation!.addListener(() {
      currentIndex.value = (tabController.animation!.value).round();
    });
  }

  void onSortItemTap(int index) {
    // Handle sort logic here
    final List<String> items = [
      'Low size first',
      'High size first',
      'Price low first',
      'Price high first',
    ];
    print('Selected sort: ${items[index]}');
  }

  void onDownloadAllTap() {
    if (currentIndex.value == 1) {
      // Handle download all for owned images
    } else {
      Get.to(() => UserSelectDownload());
    }
  }

  void onShareTap() {
    // Handle share logic
  }

  void onDownloadBulkTap() {
    if (currentIndex.value == 1) {
      // Handle bulk download for owned images
    } else {
      Get.to(() => UserSelectDownload());
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class UserImageFolderDetails extends StatelessWidget {
  const UserImageFolderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageFolderController());

    return Scaffold(
      appBar: simpleAppBar(
        title: 'Samuel Images',
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PopupMenuButton(
                surfaceTintColor: Colors.transparent,
                color: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(Assets.imagesSliderIcon, height: 20),
                itemBuilder: (ctx) {
                  return List.generate(4, (index) {
                    final List<String> items = [
                      'Low size first',
                      'High size first',
                      'Price low first',
                      'Price high first',
                    ];
                    return PopupMenuItem(
                      height: 36,
                      onTap: () => controller.onSortItemTap(index),
                      child: MyText(text: items[index], size: 12),
                    );
                  });
                },
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
            controller: controller.tabController,
            padding: EdgeInsets.symmetric(horizontal: 20),
            labelPadding: EdgeInsets.symmetric(vertical: 12),
            dividerColor: kInputBorderColor,
            dividerHeight: 1,
            labelColor: kSecondaryColor,
            unselectedLabelColor: kQuaternaryColor,
            indicatorColor: kSecondaryColor,
            overlayColor: WidgetStatePropertyAll(
              kSecondaryColor.withOpacity(0.1),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
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
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [_All(), _Owned(), _NotOwned()],
            ),
          ),
          Obx(
            () =>
                controller.currentIndex.value == 1
                    ? Padding(
                      padding: AppSizes.DEFAULT,
                      child: Row(
                        children: [
                          Expanded(
                            child: MyButton(
                              buttonText: 'Download All',
                              onTap: controller.onDownloadAllTap,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: MyButton(
                              borderWidth: 1,
                              bgColor: Colors.transparent,
                              textColor: kSecondaryColor,
                              buttonText: 'Share',
                              onTap: controller.onShareTap,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Padding(
                      padding: AppSizes.DEFAULT,
                      child: MyButton(
                        buttonText: 'Download in Bulk',
                        onTap: controller.onDownloadBulkTap,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _All extends StatelessWidget {
  const _All();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSizes.DEFAULT,
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return ImageTile(
          image: dummyImg,
          name: 'Image1234567890',
          size: '60mb',
          price: '\$10',
          isDownloaded: index.isEven,
          onTap: () {},
        );
      },
    );
  }
}

class _Owned extends StatelessWidget {
  const _Owned();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSizes.DEFAULT,
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return ImageTile(
          image: dummyImg,
          name: 'Image1234567890',
          size: '60mb',
          price: '\$10',
          isDownloaded: true,
          onTap: () {},
        );
      },
    );
  }
}

class _NotOwned extends StatelessWidget {
  const _NotOwned();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSizes.DEFAULT,
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return ImageTile(
          image: dummyImg,
          name: 'Image1234567890',
          size: '60mb',
          price: '\$10',
          isDownloaded: false,
          onTap: () {},
        );
      },
    );
  }
}
