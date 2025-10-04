import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/location_model.dart';
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
      body: RefreshIndicator(
        onRefresh: controller.refreshResults,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildSearchBar(), Expanded(child: _buildSearchResults())],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: MyTextField(
        hint: 'Search events...',
        controller: controller.searchTextController,
        textInputAction: TextInputAction.search,
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
          child: Obx(
            () => MyText(
              text: controller.resultsText,
              size: 13,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
      if (controller.isSearching.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                MyText(
                  text: 'No events found',
                  size: 18,
                  weight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                MyText(
                  text: 'Try adjusting your search or filters',
                  size: 14,
                  color: Colors.grey.shade500,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final event = controller.searchResults[index];
          return _buildResultItem(event);
        },
      );
    });
  }

  Widget _buildResultItem(Event event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => controller.navigateToSearchDetails(event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Image
            CommonImageView(
              imagePath: event.image ?? Assets.imagesEventImage,
              height: 180,
              radius: 8,
            ),
            const SizedBox(height: 8),

            // Event Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Name
                      MyText(
                        text: event.name,
                        weight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Date
                      if (event.date != null)
                        MyText(
                          text: _formatDate(event.date!),
                          size: 12,
                          color: kQuaternaryColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),

                      // Location
                      if (event.location != null)
                        Row(
                          children: [
                            Image.asset(Assets.imagesLocation, height: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: MyText(
                                text: _formatLocation(event.location!),
                                size: 11,
                                color: kQuaternaryColor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      // Type & Role Badges
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (event.type != null && event.type!.isNotEmpty)
                              _buildBadge(event.type!, kSecondaryColor),
                            if (event.role != null && event.role!.isNotEmpty)
                              _buildBadge(event.role!, kPrimaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(Assets.imagesMenuHorizontal, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: MyText(
        text: text,
        size: 10,
        color: color,
        weight: FontWeight.w500,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatLocation(Location location) {
    // Format coordinates as "Lat: X.XX, Lng: Y.YY"
    return 'Lat: ${location.latitude.toStringAsFixed(2)}, Lng: ${location.longitude.toStringAsFixed(2)}';
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
          // Header
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
                  text: 'Clear',
                  weight: FontWeight.w500,
                  color: kSecondaryColor,
                  onTap: controller.clearFilters,
                ),
              ],
            ),
          ),

          // Filter Options
          Expanded(
            child: ListView(
              padding: AppSizes.VERTICAL,
              children: [
                Padding(
                  padding: AppSizes.HORIZONTAL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Filter
                      MyTextField(
                        label: 'Location',
                        controller: controller.locationController,
                        onChanged: (value) {
                          controller.locationFilter.value = value;
                        },
                        suffix: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Assets.imagesLocation, height: 16),
                          ],
                        ),
                      ),

                      // Event Type Filter
                      Obx(
                        () => CustomDropDown(
                          hint: 'Event Type',
                          selectedValue:
                              controller.typeFilter.value.isEmpty
                                  ? null
                                  : controller.typeFilter.value,
                          items: controller.typeOptions,
                          onChanged:
                              (value) =>
                                  controller.setTypeFilter(value as String?),
                        ),
                      ),

                      // Role Filter
                      Obx(
                        () => CustomDropDown(
                          hint: 'Role',
                          selectedValue:
                              controller.roleFilter.value.isEmpty
                                  ? null
                                  : controller.roleFilter.value,
                          items: controller.roleOptions,
                          onChanged:
                              (value) =>
                                  controller.setRoleFilter(value as String?),
                        ),
                      ),

                      // Radius Slider
                      MyText(
                        text: 'Radius (km)',
                        size: 12,
                        color: kQuaternaryColor,
                        weight: FontWeight.w500,
                      ),
                      Obx(
                        () => SfRangeSliderTheme(
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
                            values: SfRangeValues(
                              controller.radiusRange.value.start,
                              controller.radiusRange.value.end,
                            ),
                            onChanged: (dynamic value) {
                              controller.setRadiusRange(
                                RangeValues(value.start, value.end),
                              );
                            },
                            trackShape: _SfTrackShape(),
                            enableTooltip: true,
                          ),
                        ),
                      ),

                      // Ratings Filter
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

                // Rating Buttons
                SizedBox(
                  height: 34,
                  child: Obx(
                    () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IntrinsicWidth(
                            child: _RatingToggleButton(
                              text: index == 0 ? 'All' : '$index',
                              haveStar: index != 0,
                              isSelected:
                                  controller.selectedRating.value == index,
                              onTap: () => controller.setSelectedRating(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Apply Button
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Apply',
              onTap: controller.applyFilters,
            ),
          ),
        ],
      ),
    );
  }
}

// Rating Toggle Button Widget
class _RatingToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool haveStar;
  final VoidCallback onTap;

  const _RatingToggleButton({
    required this.text,
    required this.isSelected,
    this.haveStar = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 34,
      duration: const Duration(milliseconds: 220),
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
              if (haveStar)
                Image.asset(
                  Assets.imagesStar,
                  height: 15,
                  color: isSelected ? kTertiaryColor : kInputBorderColor,
                ),
              Flexible(
                child: MyText(
                  text: text,
                  size: 12,
                  color: isSelected ? kTertiaryColor : kQuaternaryColor,
                  paddingLeft: haveStar ? 4 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Track Shape for Slider
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
