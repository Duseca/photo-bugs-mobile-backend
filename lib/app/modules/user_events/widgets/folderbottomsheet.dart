// widgets/folder_details_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/data/models/folder_model.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/services/folder_service/folder_service.dart';
import 'package:photo_bug/app/services/photo_service/listing_service.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:intl/intl.dart';

class FolderDetailsBottomSheet extends StatefulWidget {
  final Folder folder;
  final VoidCallback onRefresh;

  const FolderDetailsBottomSheet({
    super.key,
    required this.folder,
    required this.onRefresh,
  });

  @override
  State<FolderDetailsBottomSheet> createState() =>
      _FolderDetailsBottomSheetState();
}

class _FolderDetailsBottomSheetState extends State<FolderDetailsBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FolderService _folderService = FolderService.instance;
  final ListingService _listingService = ListingService.instance;

  final RxList<Photo> _allPhotos = <Photo>[].obs;
  final RxList<Photo> _ownedPhotos = <Photo>[].obs;
  final RxList<Photo> _notOwnedPhotos = <Photo>[].obs;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPhotos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    if (widget.folder.photoIds == null || widget.folder.photoIds!.isEmpty) {
      _allPhotos.clear();
      _ownedPhotos.clear();
      _notOwnedPhotos.clear();
      return;
    }

    try {
      _isLoading.value = true;
      final photosList = <Photo>[];

      for (String photoId in widget.folder.photoIds!) {
        try {
          final response = await _listingService.getListingById(photoId);
          if (response.success && response.data != null) {
            photosList.add(response.data!);
          }
        } catch (e) {
          print('❌ Error loading photo $photoId: $e');
        }
      }

      _allPhotos.value = photosList;
      _ownedPhotos.value =
          photosList.where((p) => p.ownership?.isNotEmpty == true).toList();
      _notOwnedPhotos.value =
          photosList.where((p) => p.ownership?.isEmpty != false).toList();
    } catch (e) {
      print('❌ Error loading photos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildFolderInfo(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kInputBorderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: widget.folder.name,
              size: 18,
              weight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderInfo() {
    final photoCount = widget.folder.photoIds?.length ?? 0;
    final bundleCount = widget.folder.bundleIds?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              icon: Icons.photo_library,
              label: 'Photos',
              value: '$photoCount',
            ),
          ),
          Container(width: 1, height: 40, color: kInputBorderColor),
          Expanded(
            child: _buildInfoItem(
              icon: Icons.folder_special,
              label: 'Bundles',
              value: '$bundleCount',
            ),
          ),
          Container(width: 1, height: 40, color: kInputBorderColor),
          Expanded(
            child: _buildInfoItem(
              icon: Icons.calendar_today,
              label: 'Created',
              value: _formatDate(widget.folder.createdAt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: kSecondaryColor, size: 20),
        const SizedBox(height: 4),
        MyText(
          text: value,
          size: 14,
          weight: FontWeight.w700,
          color: kSecondaryColor,
        ),
        MyText(text: label, size: 10, color: kQuaternaryColor),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kInputBorderColor)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: kSecondaryColor,
        unselectedLabelColor: kQuaternaryColor,
        indicatorColor: kSecondaryColor,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Owned'),
          Tab(text: 'Not Owned'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Obx(() {
      if (_isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return TabBarView(
        controller: _tabController,
        children: [
          _buildPhotoList(_allPhotos),
          _buildPhotoList(_ownedPhotos),
          _buildPhotoList(_notOwnedPhotos),
        ],
      );
    });
  }

  Widget _buildPhotoList(RxList<Photo> photos) {
    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            MyText(text: 'No photos found', size: 14, color: Colors.grey),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSizes.DEFAULT,
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _buildPhotoItem(photo);
      },
    );
  }

  Widget _buildPhotoItem(Photo photo) {
    final isOwned = photo.ownership?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kInputBorderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: CommonImageView(
                url: photo.previewUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text:
                          photo.metadata?.fileName ??
                          'Photo ${photo.id?.substring(0, 8)}',
                      size: 14,
                      weight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (photo.metadata?.fileSize != null)
                      MyText(
                        text: _formatFileSize(photo.metadata!.fileSize!),
                        size: 11,
                        color: kQuaternaryColor,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (photo.price != null && photo.price! > 0) ...[
                          const Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Colors.green,
                          ),
                          MyText(
                            text: '\$${photo.price!.toStringAsFixed(2)}',
                            size: 11,
                            color: Colors.green,
                            weight: FontWeight.w600,
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isOwned
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isOwned ? Colors.green : Colors.orange,
                            ),
                          ),
                          child: MyText(
                            text: isOwned ? 'OWNED' : 'NOT OWNED',
                            size: 9,
                            color: isOwned ? Colors.green : Colors.orange,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
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
      child: Obx(() {
        final currentTab = _tabController.index;

        if (currentTab == 1) {
          // Owned tab
          return Row(
            children: [
              Expanded(
                child: MyButton(
                  buttonText: 'Download All',
                  onTap: _downloadAll,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyButton(
                  buttonText: 'Share',
                  bgColor: Colors.transparent,
                  textColor: kSecondaryColor,
                  borderWidth: 1,
                  borderColor: kSecondaryColor,
                  onTap: _shareFolder,
                ),
              ),
            ],
          );
        } else {
          // All or Not Owned tabs
          return MyButton(buttonText: 'Download in Bulk', onTap: _downloadBulk);
        }
      }),
    );
  }

  void _downloadAll() {
    Get.snackbar(
      'Info',
      'Download all functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _shareFolder() {
    Get.snackbar(
      'Info',
      'Share folder functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _downloadBulk() {
    Get.snackbar(
      'Info',
      'Bulk download functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d').format(date);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
