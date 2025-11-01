import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/chat/controller/chat_controllers.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_chat_bubble_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_button_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/send_field_widget.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: _buildMessageList()), _buildMessageInput()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: MyRippleEffect(
              onTap: () => Get.back(),
              splashColor: kSecondaryColor.withOpacity(0.1),
              radius: 100,
              child: Center(child: Image.asset(Assets.imagesBack, height: 12)),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Obx(
                () => CommonImageView(
                  url: controller.otherUserImage.value,
                  height: 36,
                  width: 36,
                  radius: 100,
                  borderWidth: 1.5,
                  borderColor: kInputBorderColor,
                ),
              ),
              Obx(
                () =>
                    controller.otherUserOnline.value
                        ? Positioned(
                          bottom: 2,
                          right: 2,
                          child: Image.asset(
                            Assets.imagesOnlineIndicator,
                            height: 6,
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => MyText(
                    text: controller.otherUserName.value,
                    size: 14,
                    color: kTertiaryColor,
                    weight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    paddingBottom: 4,
                  ),
                ),
                Obx(
                  () => MyText(
                    text:
                        controller.otherUserOnline.value ? 'Online' : 'Offline',
                    size: 12,
                    color: kQuaternaryColor,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Image.asset(Assets.imagesMenuVertical, height: 20),
            onSelected: (value) {
              if (value == 'refresh') {
                controller.refreshMessages();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
                ],
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (controller.isLoading.value && controller.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              MyText(
                text: 'No messages yet',
                size: 16,
                color: kQuaternaryColor,
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              MyText(
                text: 'Start a conversation!',
                size: 14,
                color: kQuaternaryColor,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: AppSizes.DEFAULT,
        itemCount: controller.messages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Date header at top
            return MyText(
              text: _formatDateHeader(
                controller.messages.isNotEmpty
                    ? controller.messages.first.createdAt ?? DateTime.now()
                    : DateTime.now(),
              ),
              size: 12,
              color: kQuaternaryColor,
              textAlign: TextAlign.center,
              paddingBottom: 24,
            );
          }

          final message = controller.messages[index - 1];
          final isMe = controller.isMyMessage(message);

          // Show date separator if day changed
          Widget? dateSeparator;
          if (index > 1) {
            final prevMessage = controller.messages[index - 2];
            if (_shouldShowDateSeparator(
              prevMessage.createdAt,
              message.createdAt,
            )) {
              dateSeparator = Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: MyText(
                  text: _formatDateHeader(message.createdAt ?? DateTime.now()),
                  size: 12,
                  color: kQuaternaryColor,
                  textAlign: TextAlign.center,
                ),
              );
            }
          }

          return Column(
            children: [
              if (dateSeparator != null) dateSeparator,
              CustomChatBubbles(
                isMe: isMe,
                profileImage: controller.otherUserImage.value,
                name: isMe ? 'You' : controller.otherUserName.value,
                msg: message.content,
                time: _formatMessageTime(message.createdAt),
                isRead: message.isRead,
                isOnline: controller.otherUserOnline.value,
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildMessageInput() {
    return SendField(
      controller: controller.messageController,
      onFieldSubmitted: (value) => controller.sendMessage(),
    );
  }

  bool _shouldShowDateSeparator(DateTime? prev, DateTime? current) {
    if (prev == null || current == null) return false;

    return prev.year != current.year ||
        prev.month != current.month ||
        prev.day != current.day;
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
    }
  }

  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final hour =
        dateTime.hour == 0
            ? 12
            : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
