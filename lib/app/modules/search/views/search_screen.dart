import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/search/controller/search_controller.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_bottom_sheet_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Search'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildSearchBar(), Expanded(child: _buildSearchResults())],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: MyTextField(
        hint: 'Search',
        controller: controller.searchTextController,
        textInputAction: TextInputAction.done,
        marginBottom: 0,
        prefix: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset(Assets.imagesSearch, height: 20)],
        ),
        suffix: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showFilterBottomSheet(),
              child: Image.asset(Assets.imagesFilter, height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: AppSizes.DEFAULT,
        children: [
          _buildResultsHeader(),
          const SizedBox(height: 16),
          _buildResultsList(),
        ],
      );
    });
  }

  Widget _buildResultsHeader() {
    return Row(
      children: [
        Expanded(
          child: MyText(
            text: controller.resultsText,
            size: 13,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
              onTap: controller.showMapView,
              child: MyText(
                text: 'View on map',
                size: 13,
                color: kSecondaryColor,
                weight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                paddingRight: 8,
              ),
            ),
            GestureDetector(
              onTap: controller.showMapView,
              child: Image.asset(Assets.imagesViewMap, height: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              MyText(
                text: 'No results found',
                size: 18,
                weight: FontWeight.w600,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              MyText(
                text: 'Try adjusting your search or filters',
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final result = controller.searchResults[index];
          return _buildResultItem(result);
        },
      );
    });
  }

  Widget _buildResultItem(Map<String, dynamic> result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => controller.navigateToSearchDetails(result),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonImageView(
              imagePath: Assets.imagesEventImage,
              height: 180,
              radius: 8,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: MyText(
                    text: result['title'],
                    weight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Image.asset(Assets.imagesMenuHorizontal, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(isScrollControlled: true, _filterBottomSheet());
  }

  Widget _filterBottomSheet() {
    return CustomBottomSheet(
      height: Get.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: 'Filter',
                    size: 16,
                    weight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                MyText(
                  text: 'Cancel',
                  weight: FontWeight.w500,
                  onTap: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: AppSizes.VERTICAL,
              children: [
                Padding(
                  padding: AppSizes.HORIZONTAL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyTextField(label: 'Username'),
                      MyTextField(
                        label: 'Location',
                        suffix: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Assets.imagesLocation, height: 16),
                          ],
                        ),
                      ),
                      CustomDropDown(
                        hint: 'Search Type',
                        selectedValue: null,
                        items: ['Creator', 'Event'],
                        onChanged: (v) {},
                      ),
                      CustomDropDown(
                        hint: 'Role',
                        selectedValue: null,
                        items: [],
                        onChanged: (v) {},
                      ),
                      MyText(
                        text: 'Radius (km)',
                        size: 12,
                        color: kQuaternaryColor,
                        weight: FontWeight.w500,
                      ),
                      SfRangeSliderTheme(
                        data: SfRangeSliderThemeData(
                          activeTrackHeight: 6,
                          inactiveTrackHeight: 6,
                          thumbColor: kSecondaryColor,
                          activeTrackColor: kSecondaryColor,
                          inactiveTrackColor: kInputBorderColor,
                          tooltipBackgroundColor: kSecondaryColor,
                          tooltipTextStyle: TextStyle(
                            fontSize: 12,
                            color: kTertiaryColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.inter,
                          ),
                        ),
                        child: SfRangeSlider(
                          min: 0.0,
                          max: 30.0,
                          values: SfRangeValues(0, 15),
                          onChanged: (dynamic value) {},
                          trackShape: _SfTrackShape(),
                          enableTooltip: true,
                        ),
                      ),
                      MyText(
                        text: 'Ratings',
                        size: 12,
                        color: kQuaternaryColor,
                        weight: FontWeight.w500,
                        paddingBottom: 16,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: 6,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: IntrinsicWidth(
                          child: _RatingToggleButton(
                            text: index == 0 ? 'All' : '$index',
                            haveStar: index == 0 ? false : true,
                            isSelected: index == 0,
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Apply',
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

class _RatingToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool? haveStar;
  final VoidCallback onTap;
  const _RatingToggleButton({
    super.key,
    required this.text,
    required this.isSelected,
    this.haveStar = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 34,
      duration: 220.milliseconds,
      decoration: BoxDecoration(
        color: isSelected ? kSecondaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        border: isSelected ? null : Border.all(color: kInputBorderColor),
      ),
      child: MyRippleEffect(
        onTap: onTap,
        radius: 50,
        splashColor: kSecondaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              haveStar!
                  ? Image.asset(
                    Assets.imagesStar,
                    height: 15,
                    color: isSelected ? kTertiaryColor : kInputBorderColor,
                  )
                  : SizedBox(),
              Flexible(
                child: MyText(
                  text: text,
                  size: 12,
                  color: isSelected ? kTertiaryColor : kQuaternaryColor,
                  paddingLeft: haveStar! ? 4 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SfTrackShape extends SfTrackShape {
  @override
  Rect getPreferredRect(
    RenderBox parentBox,
    SfSliderThemeData themeData,
    Offset offset, {
    bool? isActive,
  }) {
    final trackHeight = themeData.activeTrackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 20;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
