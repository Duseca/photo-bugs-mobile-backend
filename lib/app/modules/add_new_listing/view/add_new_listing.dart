// views/add_new_listing.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/add_new_listing/controller/add_listing_controller.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';

class AddNewListing extends GetView<AddListingController> {
  const AddNewListing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: 'Upload Photo'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 24),
                  _buildPriceField(),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                  const SizedBox(height: 16),
                  _buildTagsField(),
                  const SizedBox(height: 24),
                  _buildUploadInfo(),
                ],
              ),
            ),
          ),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(() {
      final hasImage = controller.selectedImage.value != null;

      return GestureDetector(
        onTap: controller.showImagePicker,
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage ? kSecondaryColor : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child:
              hasImage
                  ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          controller.selectedImage.value!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: controller.removeImage,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Tap to change image',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      MyText(
                        text: 'Tap to select image',
                        size: 16,
                        color: Colors.grey[600]!,
                        weight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: 'JPG, PNG, WEBP',
                        size: 12,
                        color: Colors.grey[500]!,
                      ),
                    ],
                  ),
        ),
      );
    });
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: 'Price *',
          size: 14,
          weight: FontWeight.w600,
          paddingBottom: 8,
        ),
        TextField(
          controller: controller.priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter price (e.g., 100)',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kInputBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kInputBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kSecondaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: 'Category *',
          size: 14,
          weight: FontWeight.w600,
          paddingBottom: 8,
        ),
        TextField(
          controller: controller.categoryController,
          decoration: InputDecoration(
            hintText: 'Enter category (e.g., profile)',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kInputBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kInputBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kSecondaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: 'Tags (Optional)',
          size: 14,
          weight: FontWeight.w600,
          paddingBottom: 8,
        ),
        TextField(
          controller: controller.tagsController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enter tags separated by comma (e.g., nature, hd)',
            prefixIcon: const Icon(Icons.tag),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kInputBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kInputBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kSecondaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Upload Guidelines',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Image will be uploaded to your listings\n'
            '• All fields marked with * are required\n'
            '• Set appropriate price for your photo\n'
            '• Use relevant tags for better discovery',
            style: TextStyle(color: Colors.blue[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      padding: AppSizes.DEFAULT,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => MyButton(
          buttonText: 'Upload Photo',
          onTap: controller.uploadPhoto,
          isLoading: controller.isLoading.value,
        ),
      ),
    );
  }
}
