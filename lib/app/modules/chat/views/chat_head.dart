import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/modules/chat/controller/chat_controllers.dart';
import 'package:photo_bug/app/core/common_widget/chat_head_tile_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class ChatHeadScreen extends GetView<ChatHeadController> {
  const ChatHeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: MyText(
          text: 'Inbox',
          size: 18,
          color: kTertiaryColor,
          weight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshChatHeads,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatHeads = controller.filteredChatHeads;

          if (chatHeads.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            itemCount: chatHeads.length,
            itemBuilder: (context, index) {
              final chat = chatHeads[index];
              final hasUnread = controller.hasUnreadMessages(chat);
              final unreadCount = controller.getUnreadCount(chat);

              return ChatHeadTile(
                image: '', // You'll need to fetch user image from user service
                name:
                    'User ${chat.participants.first}', // You'll need to fetch actual user name
                lastMsg: chat.lastMessage?.content ?? 'No messages yet',
                time: _formatTime(
                  chat.lastMessage?.createdAt ??
                      chat.updatedAt ??
                      chat.createdAt ??
                      DateTime.now(),
                ),
                isOnline: false, // You'll need to implement online status
                isNewMessage: hasUnread,
                onTap: () => controller.openChat(chat),
              );
            },
          );
        }),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Conversations'),
            content: TextField(
              onChanged: controller.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by message...',
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.onSearchChanged('');
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
