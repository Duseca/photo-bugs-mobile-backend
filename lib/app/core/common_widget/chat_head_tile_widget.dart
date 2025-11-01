import 'package:flutter/material.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

/// Chat head tile widget for displaying conversation preview in chat list
/// Shows user profile, last message, time, and unread count
class ChatHeadTile extends StatelessWidget {
  final String image;
  final String name;
  final String lastMsg;
  final String time;
  final bool? isOnline;
  final bool? isNewMessage;
  final int unreadCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatHeadTile({
    Key? key,
    required this.image,
    required this.name,
    required this.lastMsg,
    required this.time,
    required this.onTap,
    this.isNewMessage = false,
    this.isOnline = false,
    this.unreadCount = 0,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MyRippleEffect(
        onTap: onTap,

        splashColor: kSecondaryColor.withOpacity(0.1),
        radius: 8,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isNewMessage! ? kSecondaryColor.withOpacity(0.05) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image with online indicator
              _buildProfileImage(),

              const SizedBox(width: 12),

              // Message preview section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name and time row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MyText(
                            text: name,
                            size: 14,
                            weight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            color: kTertiaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          text: isNewMessage! ? 'Now' : time,
                          size: 12,
                          color:
                              isNewMessage!
                                  ? kSecondaryColor
                                  : kQuaternaryColor,
                          weight:
                              isNewMessage! ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ],
                    ),

                    // Last message with unread badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: MyText(
                            text: lastMsg,
                            size: 12,
                            color:
                                isNewMessage!
                                    ? kTertiaryColor
                                    : kQuaternaryColor,
                            weight:
                                isNewMessage!
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            paddingTop: 4,
                          ),
                        ),

                        // Unread count badge
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          _buildUnreadBadge(),
                        ],
                      ],
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

  /// Build profile image with online/offline indicator
  Widget _buildProfileImage() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CommonImageView(
          url: image,
          height: 40,
          width: 40,
          radius: 100,
          borderWidth: isNewMessage! ? 2 : 1,
          borderColor: isNewMessage! ? kSecondaryColor : kInputBorderColor,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Image.asset(
            isOnline!
                ? Assets.imagesOnlineIndicator
                : Assets.imagesOfflineIndicator,
            height: 10,
          ),
        ),
      ],
    );
  }

  /// Build unread count badge
  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Center(
        child: Text(
          unreadCount > 99 ? '99+' : unreadCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
