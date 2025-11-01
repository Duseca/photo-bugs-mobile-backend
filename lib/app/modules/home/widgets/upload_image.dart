import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/modules/home/controller/home_controller.dart';

class PhotoUploadScreen extends GetView<HomeController> {
  const PhotoUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kBlackColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: MyText(text: 'Upload', size: 16, weight: FontWeight.w600),
        centerTitle: false,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: AppSizes.DEFAULT,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Upload Image/Video Button
              _buildUploadButton(),

              const SizedBox(height: 24),

              // Image Preview (if image is selected)
              if (controller.selectedImageFile.value != null)
                _buildImagePreview(),

              const SizedBox(height: 24),

              // Image Title Field
              _buildTextField(
                label: 'Image title',
                controller: controller.imageTitleController,
              ),

              const SizedBox(height: 20),

              // Category Dropdown
              _buildDropdownField(
                label: 'Category',
                hint: 'Select category',
                value:
                    controller.selectedCategory.value.isEmpty
                        ? null
                        : controller.selectedCategory.value,
                items: controller.categories,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCategory.value = value;
                  }
                },
              ),

              const SizedBox(height: 20),

              // Sub Category Dropdown
              _buildDropdownField(
                label: 'Sub Category',
                hint: 'Select sub category',
                value:
                    controller.selectedSubCategory.value.isEmpty
                        ? null
                        : controller.selectedSubCategory.value,
                items: controller.subCategories,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedSubCategory.value = value;
                  }
                },
              ),

              const SizedBox(height: 20),

              // Price on image Field
              _buildTextField(
                label: 'Price on image',
                controller: controller.priceController,
                keyboardType: TextInputType.number,
                prefix: MyText(
                  text: '\$ ',
                  size: 14,
                  weight: FontWeight.w500,
                  paddingLeft: 12,
                ),
              ),

              const SizedBox(height: 20),

              // Keywords Field
              _buildTextField(
                label: 'Keywords at least 20',
                controller: controller.keywordsController,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Mature content Toggle
              _buildToggleRow(
                label: 'Mature content',
                value: controller.isMatureContent.value,
                onChanged: (value) {
                  controller.isMatureContent.value = value;
                },
              ),

              const SizedBox(height: 16),

              // Redescription Toggle
              _buildToggleRow(
                label: 'Redescription',
                value: controller.isRedescription.value,
                onChanged: (value) {
                  controller.isRedescription.value = value;
                },
              ),

              const SizedBox(height: 32),

              // Upload Button
              MyButton(
                buttonText: 'Upload',
                onTap: controller.uploadPhoto,
                isLoading: controller.isUploadingPhoto.value,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: controller.pickImageForUpload,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: kSecondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: kSecondaryColor.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: kSecondaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            MyText(
              text: 'Upload Image/Video',
              size: 14,
              weight: FontWeight.w500,
              color: kSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(controller.selectedImageFile.value!.path),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: controller.clearSelectedImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: label,
          size: 14,
          weight: FontWeight.w500,
          color: kBlackColor.withOpacity(0.6),
          paddingBottom: 8,
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: kBlackColor.withOpacity(0.3),
              fontSize: 14,
            ),
            prefix: prefix,
            filled: true,
            fillColor: kQuaternaryColor.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: label,
          size: 14,
          weight: FontWeight.w500,
          color: kBlackColor.withOpacity(0.6),
          paddingBottom: 8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: kQuaternaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(
                  color: kBlackColor.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: kBlackColor.withOpacity(0.5),
              ),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(text: label, size: 14, weight: FontWeight.w500),
        Switch(value: value, onChanged: onChanged, activeColor: kPrimaryColor),
      ],
    );
  }
}
