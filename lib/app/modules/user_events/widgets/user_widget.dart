// user_selector_dialog.dart - COMPLETE FIXED VERSION

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_field_widget.dart';

import 'package:photo_bug/app/models/allUsers.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';

class UserSelectorDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool showOnlyPhotographers;

  const UserSelectorDialog({
    Key? key,
    this.title = 'Select Photographer',
    this.subtitle,
    this.showOnlyPhotographers = false,
  }) : super(key: key);

  @override
  State<UserSelectorDialog> createState() => _UserSelectorDialogState();
}

class _UserSelectorDialogState extends State<UserSelectorDialog> {
  final AuthService _authService = AuthService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<UserBasicInfo> _allUsers = [];
  List<UserBasicInfo> _filteredUsers = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      print('📥 Loading users...');
      final response = await _authService.getAllUsers();

      print('📦 API Response Success: ${response.success}');

      if (response.success && response.data != null) {
        setState(() {
          _allUsers = response.data!.data;

          print('👥 Total users loaded: ${_allUsers.length}');

          // Filter photographers if needed
          if (widget.showOnlyPhotographers) {
            _allUsers =
                _allUsers.where((user) => user.role == 'creator').toList();
            print('📸 Filtered photographers: ${_allUsers.length}');
          }

          _filteredUsers = _allUsers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load users';
          _isLoading = false;
        });
        print('❌ Error: $_error');
      }
    } catch (e, stackTrace) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
      print('❌ Exception loading users: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers =
            _allUsers.where((user) => user.searchText.contains(query)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          text: widget.title,
                          size: 18,
                          weight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    MyText(
                      text: widget.subtitle!,
                      size: 13,
                      color: kQuaternaryColor,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Search Field
                  MyTextField(
                    controller: _searchController,
                    hint: 'Search by name, username, or email...',
                    prefix: const Icon(Icons.search, size: 20),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // User List
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              MyText(
                text: _error,
                textAlign: TextAlign.center,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _loadUsers, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              MyText(
                text:
                    _searchController.text.isEmpty
                        ? 'No users found'
                        : 'No users match your search',
                textAlign: TextAlign.center,
                color: kQuaternaryColor,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _filteredUsers.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _UserListTile(user: user, onTap: () => Get.back(result: user));
      },
    );
  }
}

class _UserListTile extends StatelessWidget {
  final UserBasicInfo user;
  final VoidCallback onTap;

  const _UserListTile({Key? key, required this.user, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Picture - FIXED with CommonImageView
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CommonImageView(
                url: user.profilePicture,
                imagePath: Assets.imagesCreatorIcon, // Fallback image
                height: 48,
                width: 48,
                radius: 24,
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: user.displayName,
                    size: 15,
                    weight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: '@${user.userName}',
                    size: 12,
                    color: kQuaternaryColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.interests != null && user.interests!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    MyText(
                      text: user.interests!.take(2).join(', '),
                      size: 11,
                      color: kSecondaryColor.withOpacity(0.7),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Arrow Icon
            const Icon(Icons.chevron_right, color: kQuaternaryColor),
          ],
        ),
      ),
    );
  }
}
