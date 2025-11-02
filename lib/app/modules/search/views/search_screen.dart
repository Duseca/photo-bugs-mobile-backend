// modules/search/views/search_screen.dart

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
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
import 'package:intl/intl.dart';

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Search Events'),
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
              onTap: _showFilterBottomSheet,
              child: Image.asset(Assets.imagesFilter, height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.isLoading.value && controller.searchResults.isEmpty) {
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
              weight: FontWeight.w500,
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
        return _buildEmptyState();
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

  Widget _buildEmptyState() {
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
              text: 'Try adjusting your filters',
              size: 14,
              color: Colors.grey.shade500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(Event event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => controller.navigateToSearchDetails(event),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child:
                    event.image != null && event.image!.isNotEmpty
                        ? CommonImageView(
                          url: event.image!,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.event,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
              ),

              // Event Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name
                    MyText(
                      text: event.name,
                      weight: FontWeight.w600,
                      size: 15,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Date
                    if (event.date != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: kQuaternaryColor,
                          ),
                          const SizedBox(width: 4),
                          MyText(
                            text: _formatDate(event.date!),
                            size: 12,
                            color: kQuaternaryColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),

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
                    if (event.type != null || event.role != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: MyText(
        text: text,
        size: 10,
        color: color,
        weight: FontWeight.w600,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatLocation(location) {
    if (location.latitude != null && location.longitude != null) {
      return 'Lat: ${location.latitude.toStringAsFixed(2)}, Lng: ${location.longitude.toStringAsFixed(2)}';
    }
    return 'Location';
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      isScrollControlled: true,
      _FilterBottomSheet(controller: controller),
    );
  }
}

// ==================== FILTER BOTTOM SHEET ====================

class _FilterBottomSheet extends StatelessWidget {
  final SearchController controller;

  const _FilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
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
                    text: 'Filter Events',
                    size: 16,
                    weight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: controller.clearFilters,
                  child: MyText(
                    text: 'Clear',
                    weight: FontWeight.w500,
                    color: kSecondaryColor,
                  ),
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
                      // Location Filter (coordinates format: lat,lng)
                      MyTextField(
                        label: 'Location (lat,lng)',
                        hint: 'e.g., 73.0479,33.6844',
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
                        text: 'Search Radius (km)',
                        size: 12,
                        color: kQuaternaryColor,
                        weight: FontWeight.w500,
                        paddingTop: 8,
                      ),
                      Obx(
                        () => Column(
                          children: [
                            SfRangeSliderTheme(
                              data: SfRangeSliderThemeData(
                                activeTrackHeight: 6,
                                inactiveTrackHeight: 6,
                                thumbColor: kSecondaryColor,
                                activeTrackColor: kSecondaryColor,
                                inactiveTrackColor: kInputBorderColor,
                                tooltipBackgroundColor: kSecondaryColor,
                                tooltipTextStyle: const TextStyle(
                                  fontSize: 12,
                                  color: kTertiaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFonts.inter,
                                ),
                              ),
                              child: SfRangeSlider(
                                min: 0.0,
                                max: 50.0,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text:
                                        '${controller.radiusRange.value.start.toInt()} km',
                                    size: 11,
                                    color: kQuaternaryColor,
                                  ),
                                  MyText(
                                    text:
                                        '${controller.radiusRange.value.end.toInt()} km',
                                    size: 11,
                                    color: kQuaternaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Apply Button
          Padding(
            padding: AppSizes.DEFAULT,
            child: MyButton(
              buttonText: 'Apply Filters',
              onTap: controller.applyFilters,
            ),
          ),
        ],
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
