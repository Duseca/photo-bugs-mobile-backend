import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';

import 'package:photo_bug/app/modules/settings/profile/controller/profile_controller.dart';
import 'package:photo_bug/app/modules/settings/profile/edit_profile.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/main.dart';

class PersonalInformation extends StatelessWidget {
  const PersonalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ProfileController instance
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: simpleAppBar(
        title: 'Personal Information',
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => EditProfile());
                },
                child: Image.asset(Assets.imagesEdit, height: 20),
              ),
            ],
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Obx(() {
        final user = profileController.currentUser;

        return ListView(
          padding: AppSizes.VERTICAL,
          children: [
            Center(
              child: Stack(
                children: [
                  CommonImageView(
                    url: user?.profilePicture ?? dummyImg,
                    height: 84,
                    width: 84,
                    radius: 100,
                    borderColor: kInputBorderColor,
                    borderWidth: 2,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Handle profile picture change
                        // You can add image picker functionality here
                      },
                      child: Image.asset(Assets.imagesEditBg, height: 24),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              padding: AppSizes.HORIZONTAL,
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.1),
                border: Border.symmetric(
                  horizontal: BorderSide(color: kInputBorderColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DetailRow(
                    title: 'Username',
                    subText: user?.userName ?? 'Not set',
                  ),
                  _DetailRow(
                    title: 'First Name',
                    subText: _getFirstName(user?.name),
                  ),
                  _DetailRow(
                    title: 'Last Name',
                    subText: _getLastName(user?.name),
                  ),
                  _DetailRow(
                    title: 'Role',
                    subText: _capitalizeFirst(user?.role ?? 'Not set'),
                  ),
                  _DetailRow(
                    title: 'Bio',
                    subText:
                        user?.bio?.isNotEmpty == true
                            ? user!.bio!
                            : 'No bio available',
                  ),
                  _DetailRow(title: 'Email', subText: user?.email ?? 'Not set'),
                  _DetailRow(
                    title: 'Phone Number',
                    subText: user?.phone ?? 'Not set',
                  ),
                  _DetailRow(
                    title: 'Gender',
                    subText: _capitalizeFirst(user?.gender ?? 'Not set'),
                  ),
                  _DetailRow(
                    title: 'Date of Birth',
                    subText: _formatDate(user?.dateOfBirth),
                  ),
                  _DetailRow(
                    title: 'Country',
                    subText: user?.address?.country ?? 'Not set',
                  ),
                  _DetailRow(
                    title: 'Town',
                    subText: user?.address?.town ?? 'Not set',
                  ),
                  _DetailRow(
                    title: 'Address',
                    subText: user?.address?.address ?? 'Not set',
                    haveDivider: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Refresh button
            if (profileController.isLoading.value)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }

  // Helper method to get first name from full name
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Not set';
    final nameParts = fullName.split(' ');
    return nameParts.isNotEmpty ? nameParts.first : 'Not set';
  }

  // Helper method to get last name from full name
  String _getLastName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Not set';
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return nameParts.sublist(1).join(' ');
    }
    return 'Not set';
  }

  // Helper method to format date
  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper method to capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class _DetailRow extends StatelessWidget {
  final String title, subText;
  final bool? haveDivider;

  const _DetailRow({
    super.key,
    required this.title,
    required this.subText,
    this.haveDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border:
            haveDivider == true
                ? Border(bottom: BorderSide(color: kInputBorderColor))
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: MyText(
              text: title,
              size: 12,
              color: kQuaternaryColor,
              weight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: MyText(
              text: subText,
              size: 12,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
