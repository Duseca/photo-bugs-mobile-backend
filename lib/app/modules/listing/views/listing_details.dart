// views/listing_details.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/modules/listing/controllers/listing_controllers.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:intl/intl.dart';
import 'package:photo_bug/app/modules/listing/views/write_review_dialog.dart';

class ListingDetails extends GetView<ListingDetailsController> {
  const ListingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: Obx(() => _buildBody()));
  }

  PreferredSizeWidget _buildAppBar() {
    return simpleAppBar(
      title: 'Photo Details',
      actions: [
        Obx(() {
          if (controller.hasPhoto) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    controller.sharePhoto();
                    break;
                  case 'edit':
                    controller.editPhoto();
                    break;
                  case 'download':
                    controller.downloadPhoto();
                    break;
                  case 'delete':
                    controller.deletePhoto();
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 12),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 12),
                          Text('Download'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value && !controller.hasPhoto) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty && !controller.hasPhoto) {
      return _buildErrorState();
    }

    if (!controller.hasPhoto) {
      return _buildNoPhotoState();
    }

    final photo = controller.photo.value!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSizes.DEFAULT,
            children: [
              _buildImage(photo),
              const SizedBox(height: 16),
              _buildQuickStats(photo),
              const SizedBox(height: 16),
              _buildInfoSection(photo),
              const SizedBox(height: 16),
              _buildMetadataSection(photo),
              const SizedBox(height: 16),
              if (photo.creator != null) _buildCreatorSection(photo.creator!),
              const SizedBox(height: 80),
            ],
          ),
        ),
        _buildActionButtons(photo),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          MyText(
            text: 'Failed to Load Details',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Obx(
              () => MyText(
                text: controller.errorMessage.value,
                size: 14,
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.loadPhotoDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPhotoState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.imagesFolder, height: 64, color: Colors.grey),
          const SizedBox(height: 16),
          MyText(
            text: 'No photo data available',
            size: 18,
            weight: FontWeight.w600,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Photo photo) {
    final imageUrl = photo.displayUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          imageUrl.isNotEmpty
              ? CommonImageView(url: imageUrl, height: 300, fit: BoxFit.cover)
              : Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey, size: 80),
                ),
              ),
    );
  }

  Widget _buildQuickStats(Photo photo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kSecondaryColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSecondaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.attach_money,
              label: 'Price',
              value: controller.priceDisplay,
              color: Colors.green,
            ),
          ),
          Container(width: 1, height: 50, color: kInputBorderColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.visibility,
              label: 'Views',
              value: controller.viewsDisplay,
              color: kSecondaryColor,
            ),
          ),
          Container(width: 1, height: 50, color: kInputBorderColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.info,
              label: 'Status',
              value: _getStatusText(photo.status),
              color: _getStatusColor(photo.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        MyText(text: value, size: 14, weight: FontWeight.w700, color: color),
        const SizedBox(height: 2),
        MyText(text: label, size: 11, color: kQuaternaryColor),
      ],
    );
  }

  Widget _buildInfoSection(Photo photo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kInputBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: 'Photo Information',
            size: 16,
            weight: FontWeight.w700,
            paddingBottom: 12,
          ),
          _buildInfoRow(
            icon: Icons.fingerprint,
            label: 'Photo ID',
            value: photo.id ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Created',
            value: _formatDate(photo.createdAt),
          ),
          if (photo.updatedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.update,
              label: 'Updated',
              value: _formatDate(photo.updatedAt),
            ),
          ],
          if (photo.eventId != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.event,
              label: 'Event ID',
              value: photo.eventId!,
            ),
          ],
          if (photo.folderId != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.folder,
              label: 'Folder ID',
              value: photo.folderId!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataSection(Photo photo) {
    if (photo.metadata == null) return const SizedBox.shrink();

    final metadata = photo.metadata!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kInputBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: 'Metadata',
            size: 16,
            weight: FontWeight.w700,
            paddingBottom: 12,
          ),
          if (metadata.fileName != null) ...[
            _buildInfoRow(
              icon: Icons.insert_drive_file,
              label: 'File Name',
              value: metadata.fileName!,
            ),
            const SizedBox(height: 8),
          ],
          if (metadata.fileSize != null) ...[
            _buildInfoRow(
              icon: Icons.storage,
              label: 'File Size',
              value: _formatFileSize(metadata.fileSize!),
            ),
            const SizedBox(height: 8),
          ],
          if (metadata.width != null && metadata.height != null) ...[
            _buildInfoRow(
              icon: Icons.aspect_ratio,
              label: 'Dimensions',
              value: '${metadata.width} × ${metadata.height}',
            ),
            const SizedBox(height: 8),
          ],
          if (metadata.mimeType != null) ...[
            _buildInfoRow(
              icon: Icons.image,
              label: 'Format',
              value: metadata.mimeType!,
            ),
            const SizedBox(height: 8),
          ],
          if (metadata.category != null) ...[
            _buildInfoRow(
              icon: Icons.category,
              label: 'Category',
              value: metadata.category!,
            ),
            const SizedBox(height: 8),
          ],
          if (metadata.cameraModel != null) ...[
            _buildInfoRow(
              icon: Icons.camera_alt,
              label: 'Camera',
              value: metadata.cameraModel!,
            ),
            const SizedBox(height: 8),
          ],
          if (metadata.dateTaken != null) ...[
            _buildInfoRow(
              icon: Icons.date_range,
              label: 'Date Taken',
              value: _formatDate(metadata.dateTaken),
            ),
            const SizedBox(height: 8),
          ],
          if (metadata.location != null) ...[
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Location',
              value: metadata.location!,
            ),
          ],
          if (metadata.tags != null && metadata.tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            MyText(
              text: 'Tags',
              size: 12,
              weight: FontWeight.w600,
              color: kQuaternaryColor,
              paddingBottom: 8,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  metadata.tags!.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kSecondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kSecondaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: MyText(
                        text: tag,
                        size: 12,
                        color: kSecondaryColor,
                        weight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreatorSection(CreatorInfo creator) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kInputBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyText(text: 'Creator', size: 16, weight: FontWeight.w700),
              const Spacer(),
              // Write Review Button
              if (creator.id != null)
                TextButton.icon(
                  onPressed: () => _showWriteReviewDialog(creator),
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text('Write Review'),
                  style: TextButton.styleFrom(
                    foregroundColor: kSecondaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: kSecondaryColor.withOpacity(0.3)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child:
                    creator.profilePicture != null &&
                            creator.profilePicture!.isNotEmpty
                        ? CommonImageView(
                          url: creator.profilePicture!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 50,
                          width: 50,
                          color: kSecondaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            color: kSecondaryColor,
                            size: 30,
                          ),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: creator.email ?? 'Unknown Creator',
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                    if (creator.userName != null) ...[
                      const SizedBox(height: 4),
                      MyText(
                        text: '@${creator.userName}',
                        size: 12,
                        color: kQuaternaryColor,
                      ),
                    ],
                    if (creator.role != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kSecondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: MyText(
                          text: creator.role!.toUpperCase(),
                          size: 10,
                          color: kSecondaryColor,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(CreatorInfo creator) {
    if (creator.id == null) {
      Get.snackbar(
        'Error',
        'Creator information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Use email as name, or userName, or fallback to "Creator"
    String creatorName = 'Creator';
    if (creator.email != null && creator.email!.isNotEmpty) {
      creatorName = creator.email!;
    } else if (creator.userName != null && creator.userName!.isNotEmpty) {
      creatorName = creator.userName!;
    } else if (creator.name != null && creator.name!.isNotEmpty) {
      creatorName = creator.name!;
    }

    Get.showWriteReviewDialog(
      creatorId: creator.id!,
      creatorName: creatorName,
      creatorImage: creator.profilePicture,
    ).then((result) {
      if (result == true) {
        // Refresh the page after successful review
        controller.loadPhotoDetails();
      }
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kSecondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: label,
                size: 12,
                weight: FontWeight.w600,
                color: kQuaternaryColor,
              ),
              const SizedBox(height: 2),
              MyText(
                text: value,
                size: 13,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Photo photo) {
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.sharePhoto,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kSecondaryColor,
                side: const BorderSide(color: kSecondaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MyButton(
              buttonText: 'Download',
              onTap: controller.downloadPhoto,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _getStatusText(PhotoStatus status) {
    switch (status) {
      case PhotoStatus.active:
        return 'Active';
      case PhotoStatus.processing:
        return 'Processing';
      case PhotoStatus.archived:
        return 'Archived';
      case PhotoStatus.deleted:
        return 'Deleted';
    }
  }

  Color _getStatusColor(PhotoStatus status) {
    switch (status) {
      case PhotoStatus.active:
        return Colors.green;
      case PhotoStatus.processing:
        return Colors.orange;
      case PhotoStatus.archived:
        return Colors.blue;
      case PhotoStatus.deleted:
        return Colors.red;
    }
  }
}
