import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/modules/chat/controller/chat_controllers.dart';
import 'package:photo_bug/app/modules/user_events/widgets/other_user_profile.dart';
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
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
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
              child: Center(
                child: Image.asset(
                  Assets.imagesBack,
                  height: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const OtherUserProfile()),
            child: Stack(
              children: [
                Obx(() => CommonImageView(
                  url: controller.otherUserImage.value,
                  height: 36,
                  width: 36,
                  radius: 100,
                  borderWidth: 1.5,
                  borderColor: kInputBorderColor,
                )),
                Obx(() => controller.otherUserOnline.value
                    ? Positioned(
                        bottom: 2,
                        right: 2,
                        child: Image.asset(
                          Assets.imagesOnlineIndicator,
                          height: 6,
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() => MyText(
                  text: controller.otherUserName.value,
                  size: 14,
                  color: kTertiaryColor,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  paddingBottom: 4,
                )),
                Obx(() => MyText(
                  text: controller.otherUserOnline.value ? 'Online' : 'Offline',
                  size: 12,
                  color: kQuaternaryColor,
                )),
              ],
            ),
          ),
          Image.asset(
            Assets.imagesMenuVertical,
            height: 20,
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.messages.isEmpty) {
        return const Center(
          child: Text('No messages yet. Start a conversation!'),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: AppSizes.DEFAULT,
        reverse: true,
        itemCount: controller.messages.length + 1, // +1 for date header
        itemBuilder: (context, index) {
          if (index == controller.messages.length) {
            // Date header
            return MyText(
              text: _formatDateHeader(controller.messages.isNotEmpty 
                  ? controller.messages.first.timestamp 
                  : DateTime.now()),
              size: 12,
              color: kQuaternaryColor,
              textAlign: TextAlign.center,
              paddingBottom: 24,
            );
          }

          final message = controller.messages[index];
          return CustomChatBubbles(
            isMe: message.isMe,
            profileImage: message.senderImage,
            name: message.senderName,
            msg: message.message,
          );
        },
      );
    });
  }

  Widget _buildMessageInput() {
    return SendField(
      controller: controller.messageController,
      onFieldSubmitted: (value) => controller.sendMessage(),
      onChanged: (value) {
        if (value.isNotEmpty) {
          controller.onTyping();
        } else {
          controller.onStopTyping();
        }
      },
    );
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute$period';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

