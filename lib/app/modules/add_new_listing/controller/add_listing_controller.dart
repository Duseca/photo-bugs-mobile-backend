// controllers/add_listing_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/services/photo_service/listing_service.dart';
import 'dart:convert';

class AddListingController extends GetxController {
  late final ListingService _listingService;
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  final RxBool isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString imagePreviewUrl = ''.obs;

  // Form controllers
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final tagsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    priceController.dispose();
    categoryController.dispose();
    tagsController.dispose();
    super.onClose();
  }

  void _initializeService() {
    try {
      _listingService = ListingService.instance;
    } catch (e) {
      print('❌ Error initializing ListingService: $e');
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        imagePreviewUrl.value = image.path;
        print('✅ Image selected: ${image.path}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      _showError('Failed to pick image');
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        imagePreviewUrl.value = image.path;
        print('✅ Image captured: ${image.path}');
      }
    } catch (e) {
      print('❌ Error capturing image: $e');
      _showError('Failed to capture image');
    }
  }

  // Show image picker dialog
  void showImagePicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            if (selectedImage.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () {
                  Get.back();
                  removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Remove selected image
  void removeImage() {
    selectedImage.value = null;
    imagePreviewUrl.value = '';
  }

  // Validate form
  bool validateForm() {
    if (selectedImage.value == null) {
      _showError('Please select an image');
      return false;
    }

    if (priceController.text.isEmpty) {
      _showError('Please enter price');
      return false;
    }

    final price = double.tryParse(priceController.text);
    if (price == null || price < 0) {
      _showError('Please enter valid price');
      return false;
    }

    if (categoryController.text.isEmpty) {
      _showError('Please enter category');
      return false;
    }

    return true;
  }

  // Upload photo
  Future<void> uploadPhoto() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      print('🔄 Starting photo upload...');

      // Read image file
      final imageFile = selectedImage.value!;
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('📦 Image size: ${bytes.length} bytes');
      print('📦 Base64 length: ${base64Image.length}');

      // Parse price
      final price = double.parse(priceController.text);

      // Parse tags
      final tags =
          tagsController.text
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();

      // Create metadata
      final metadata = PhotoMetadata(
        category: categoryController.text.trim(),
        tags: tags.isNotEmpty ? tags : null,
        fileName: imageFile.path.split('/').last,
        fileSize: bytes.length,
        mimeType: 'image/${imageFile.path.split('.').last}',
      );

      print('📝 Metadata: ${metadata.toJson()}');

      // Create upload request
      final request = UploadPhotoRequest(
        file: base64Image,
        price: price,
        metadata: metadata,
      );

      print('🚀 Uploading photo...');

      // Upload photo
      final response = await _listingService.createListing(request);

      if (response.success && response.data != null) {
        print('✅ Photo uploaded successfully!');
        _showSuccess('Photo uploaded successfully!');

        // Clear form
        _clearForm();

        // Go back to listings
        Get.back(result: true);
      } else {
        print('❌ Upload failed: ${response.error}');
        _showError(response.error ?? 'Failed to upload photo');
      }
    } catch (e, stackTrace) {
      print('❌ Error uploading photo: $e');
      print('❌ Stack trace: $stackTrace');
      _showError('Failed to upload photo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void _clearForm() {
    selectedImage.value = null;
    imagePreviewUrl.value = '';
    priceController.clear();
    categoryController.clear();
    tagsController.clear();
  }

  // Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
}
