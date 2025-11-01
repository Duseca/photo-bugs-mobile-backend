import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/modules/settings/profile/controller/profile_controller.dart';
import 'package:photo_bug/main.dart';

class EditPortfolio extends StatefulWidget {
  const EditPortfolio({super.key});

  @override
  State<EditPortfolio> createState() => _EditPortfolioState();
}

class _EditPortfolioState extends State<EditPortfolio> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Show dialog to add image URL
  void _showAddImageDialog(ProfileController controller) {
    _urlController.clear();

    Get.dialog(
      AlertDialog(
        title: MyText(text: 'Add Portfolio Image', weight: FontWeight.w600),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyText(
              text:
                  'Upload your image to Google Drive and paste the shareable link here.',
              size: 12,
              color: kQuaternaryColor,
              paddingBottom: 16,
            ),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: kQuaternaryColor),
                hintText: 'https://drive.google.com/...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            MyText(
              text: 'Note: Make sure the link is publicly accessible',
              size: 10,
              color: Colors.orange,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: MyText(text: 'Cancel', color: kQuaternaryColor),
          ),
          ElevatedButton(
            onPressed: () {
              final url = _urlController.text.trim();
              if (url.isNotEmpty) {
                Get.back();
                _addImageFromUrl(controller, url);
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid URL',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
            child: MyText(text: 'Add', color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Add image from URL using controller
  Future<void> _addImageFromUrl(
    ProfileController controller,
    String url,
  ) async {
    try {
      // Show loading
      Get.dialog(
        Center(child: CircularProgressIndicator(color: kSecondaryColor)),
        barrierDismissible: false,
      );

      final success = await controller.addImageToPortfolio(url);

      // Close loading
      Get.back();

      if (success) {
        Get.snackbar(
          'Success',
          'Image added to portfolio',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add image',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading if error
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(ProfileController controller, String imageUrl) {
    Get.dialog(
      AlertDialog(
        title: MyText(text: 'Delete Image', weight: FontWeight.w600),
        content: MyText(
          text:
              'Are you sure you want to remove this image from your portfolio?',
          size: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: MyText(text: 'Cancel', color: kQuaternaryColor),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteImage(controller, imageUrl);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: MyText(text: 'Delete', color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Delete image from portfolio using controller
  Future<void> _deleteImage(
    ProfileController controller,
    String imageUrl,
  ) async {
    try {
      // Show loading
      Get.dialog(
        Center(child: CircularProgressIndicator(color: kSecondaryColor)),
        barrierDismissible: false,
      );

      final success = await controller.deleteImageFromPortfolio(imageUrl);

      // Close loading
      Get.back();

      if (success) {
        Get.snackbar(
          'Success',
          'Image removed from portfolio',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete image',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading if error
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show instructions dialog
  void _showInstructionsDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: kSecondaryColor),
            SizedBox(width: 8),
            MyText(text: 'How to Upload', weight: FontWeight.w600),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInstructionStep(
                '1',
                'Upload to Google Drive',
                'Upload your image to Google Drive',
              ),
              _buildInstructionStep(
                '2',
                'Get Shareable Link',
                'Right-click the image → Get link → Copy link',
              ),
              _buildInstructionStep(
                '3',
                'Make it Public',
                'Change access to "Anyone with the link"',
              ),
              _buildInstructionStep(
                '4',
                'Paste Link Here',
                'Click "Upload Portfolio" and paste the link',
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: MyText(
                        text:
                            'Tip: You can also use Imgur, Cloudinary, or any image hosting service',
                        size: 11,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
            child: MyText(text: 'Got it', color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
    String number,
    String title,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: kSecondaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: MyText(
                text: number,
                color: Colors.white,
                weight: FontWeight.w600,
                size: 14,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: title, weight: FontWeight.w600, size: 14),
                SizedBox(height: 4),
                MyText(text: description, size: 12, color: kQuaternaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use existing ProfileController as bridge
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: simpleAppBar(
        title: 'Portfolio',
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: kSecondaryColor),
            onPressed: _showInstructionsDialog,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Obx(() {
              final isUploading = controller.isPortfolioUploading;

              return MyButton(
                borderWidth: 1,
                bgColor: Colors.transparent,
                splashColor: kSecondaryColor.withOpacity(0.1),
                buttonText: '',
                isLoading: isUploading,
                onTap:
                    isUploading ? null : () => _showAddImageDialog(controller),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.imagesAdd,
                      height: 18,
                      color: kSecondaryColor,
                    ),
                    Flexible(
                      child: MyText(
                        text: 'Upload Portfolio',
                        size: 16,
                        color: kSecondaryColor,
                        weight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        paddingLeft: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              final isLoading = controller.isPortfolioLoading;

              if (isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: kSecondaryColor),
                );
              }

              final images = controller.portfolioImages;

              if (images.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: kQuaternaryColor,
                      ),
                      SizedBox(height: 16),
                      MyText(
                        text: 'No portfolio images yet',
                        color: kQuaternaryColor,
                        size: 16,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        text: 'Tap "Upload Portfolio" to add images',
                        color: kQuaternaryColor,
                        size: 12,
                      ),
                      SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _showInstructionsDialog,
                        icon: Icon(Icons.help_outline, color: kSecondaryColor),
                        label: MyText(
                          text: 'How to upload?',
                          color: kSecondaryColor,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshPortfolio,
                child: GridView.builder(
                  padding: AppSizes.DEFAULT,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 160,
                  ),
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) {
                    final image = images[index];

                    return Stack(
                      children: [
                        CommonImageView(
                          url: image.url,
                          width: Get.width,
                          radius: 8,
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap:
                                () => _showDeleteConfirmation(
                                  controller,
                                  image.url,
                                ),
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
