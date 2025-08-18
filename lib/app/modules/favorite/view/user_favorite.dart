import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/models/favourites_model/favourite_model.dart';
import 'package:photo_bug/app/modules/favorite/controller/favourite_controller.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class Favourite extends GetView<FavouriteController> {
  const Favourite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 20,
      title: MyText(
        text: 'Favorite',
        size: 18,
        color: kTertiaryColor,
        weight: FontWeight.w600,
      ),
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
                return controller.sortOptions.map((option) {
                  return PopupMenuItem(
                    height: 36,
                    onTap: () => controller.sortItems(option.type),
                    child: Obx(
                      () => Row(
                        children: [
                          Expanded(child: MyText(text: option.label, size: 12)),
                          if (controller.selectedSort.value == option.type)
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: kTertiaryColor,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: controller.refreshFavoriteItems,
      child: ListView(
        padding: AppSizes.HORIZONTAL,
        children: [_buildGridView()],
      ),
    );
  }

  Widget _buildGridView() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.filteredItems.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(child: Text('No favorite items found')),
        );
      }

      return StaggeredGridView.countBuilder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        crossAxisCount: 2,
        itemCount: controller.filteredItems.length,
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(1, index.isEven ? 1.6 : 1.2);
        },
        itemBuilder: (context, index) {
          final item = controller.filteredItems[index];
          return _buildGridItem(item, index);
        },
      );
    });
  }

  Widget _buildGridItem(FavoriteItem item, int index) {
    return GestureDetector(
      onTap: () => controller.openImageDetails(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CommonImageView(url: item.imageUrl, radius: 12),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => controller.toggleFavorite(item.id),
                    child: Obx(
                      () => Icon(
                        Icons.favorite_rounded,
                        color: item.isFavorite ? kSecondaryColor : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              CommonImageView(
                url: item.authorImage,
                height: 24,
                width: 24,
                radius: 100,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MyText(
                      text: item.authorName,
                      size: 12,
                      weight: FontWeight.w500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      paddingBottom: 2,
                    ),
                    MyText(
                      text: 'Size: ${item.size}',
                      size: 10,
                      color: kQuaternaryColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              MyText(
                text: '\$${item.price.toStringAsFixed(0)}',
                size: 13,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
