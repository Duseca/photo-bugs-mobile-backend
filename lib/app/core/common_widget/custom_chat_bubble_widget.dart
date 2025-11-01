import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:flutter/material.dart';

/// Custom chat bubble widget for displaying messages
/// Supports both sent and received messages with user profile
class CustomChatBubbles extends StatelessWidget {
  const CustomChatBubbles({
    Key? key,
    required this.isMe,
    required this.profileImage,
    required this.name,
    required this.msg,
    this.time,
    this.isRead = false,
    this.isOnline = false,
  }) : super(key: key);

  final String name;
  final String msg;
  final bool isMe;
  final String profileImage;
  final String? time;
  final bool isRead;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show profile image only for received messages
          if (!isMe) ...[_buildProfileImage(), const SizedBox(width: 12)],

          // Message bubble
          Flexible(child: _buildMessageBubble(context)),

          // Show profile image for sent messages (optional)
          if (isMe) ...[const SizedBox(width: 12), _buildProfileImage()],
        ],
      ),
    );
  }

  /// Build profile image with online indicator
  Widget _buildProfileImage() {
    return Stack(
      children: [
        CommonImageView(
          url: profileImage,
          height: 32,
          width: 32,
          radius: 100,
          borderWidth: 1,
          borderColor: kInputBorderColor,
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Image.asset(Assets.imagesOnlineIndicator, height: 6),
          ),
      ],
    );
  }

  /// Build message bubble with styling
  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? kSecondaryColor : kInputBorderColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name (show for received messages)
          if (!isMe)
            MyText(
              text: name,
              size: 12,
              weight: FontWeight.w600,
              color: kSecondaryColor,
              paddingBottom: 4,
            ),

          // Message content
          MyText(
            text: msg,
            size: 14,
            color: isMe ? Colors.white : kTertiaryColor,
            textAlign: isMe ? TextAlign.right : TextAlign.left,
          ),

          // Time and read status
          if (time != null || isMe) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (time != null)
                  MyText(
                    text: time!,
                    size: 10,
                    color:
                        isMe ? Colors.white.withOpacity(0.8) : kQuaternaryColor,
                  ),
                if (isMe && time != null) const SizedBox(width: 4),
                // Read receipt for sent messages
                if (isMe)
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color:
                        isRead
                            ? Colors.blue[300]
                            : Colors.white.withOpacity(0.8),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
