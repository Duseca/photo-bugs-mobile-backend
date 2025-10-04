import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart' show Assets;
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomDropDown extends StatelessWidget {
  CustomDropDown({
    required this.hint,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.bgColor,
    this.marginBottom = 16,
    this.radius = 8,
    this.headingWeight,
    this.heading,
    this.searchController,
    this.onMenuStateChange,
    this.searchMatchFn,
    this.haveSearchField = false,
    this.prefix,
  });

  final List<dynamic>? items;
  String? selectedValue, heading;
  final ValueChanged<dynamic>? onChanged;
  String hint;
  Color? bgColor;
  double? marginBottom;
  FontWeight? headingWeight;
  final TextEditingController? searchController;
  final OnMenuStateChangeFn? onMenuStateChange;
  final SearchMatchFn? searchMatchFn;
  final bool? haveSearchField;
  final Widget? prefix;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heading != null)
            MyText(
              text: heading!,
              size: 12,
              weight: FontWeight.w500,
              paddingBottom: 8,
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              hint: MyText(text: '$hint', size: 12, color: kHintColor),
              items:
                  items!
                      .map(
                        (item) => DropdownMenuItem<dynamic>(
                          value: item,
                          child: MyText(text: item, size: 12),
                        ),
                      )
                      .toList(),
              value: selectedValue,
              onChanged: onChanged,
              buttonStyleData: ButtonStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius!),
                ),
              ),

              customButton: Container(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius!),
                  border: Border.all(width: 1.0, color: kInputBorderColor),
                ),
                child: Row(
                  children: [
                    if (prefix != null) prefix!,
                    Expanded(
                      child: MyText(
                        text: selectedValue == null ? hint : selectedValue!,
                        size: 12,
                        color:
                            selectedValue == null ? kHintColor : kTertiaryColor,
                        weight: FontWeight.w400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        paddingLeft: prefix != null ? 12 : 0,
                      ),
                    ),
                    Image.asset(Assets.imagesDropDown, height: 18),
                  ],
                ),
              ),
              menuItemStyleData: MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 14),
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 3,
                maxHeight: 300,
                offset: Offset(0, -5),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  border: Border.all(color: kInputBorderColor, width: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownSearchData:
                  haveSearchField!
                      ? DropdownSearchData(
                        searchController: searchController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: searchController,
                            style: TextStyle(
                              fontSize: 12,
                              color: kTertiaryColor,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFonts.inter,
                            ),
                            decoration: InputDecoration(
                              // isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                              hintText: 'Search here...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: kHintColor,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFonts.inter,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1,
                                  color: kInputBorderColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: kSecondaryColor,
                                ),
                              ),
                              // errorBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(5),
                              //   borderSide: BorderSide(
                              //     width: 1,
                              //     color: Colors.red,
                              //   ),
                              // ),
                              // focusedErrorBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(5),
                              //   borderSide: BorderSide(
                              //     width: 1,
                              //     color: Colors.red,
                              //   ),
                              // ),
                            ),
                          ),
                        ),
                        searchMatchFn: searchMatchFn,
                      )
                      : null,
              //This to clear the search value when you close the menu
              onMenuStateChange: onMenuStateChange,
            ),
          ),
        ],
      ),
    );
  }
}
