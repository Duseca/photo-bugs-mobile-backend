import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/data/models/chat_model.dart';
import 'package:photo_bug/app/modules/chat/controller/chat_controllers.dart';
import 'package:photo_bug/app/core/common_widget/chat_head_tile_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';

class ChatHeadScreen extends GetView<ChatHeadController> {
  const ChatHeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [_buildSearchBar(), Expanded(child: _buildChatList())],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_fab', // Fixed hero tag
        onPressed: () {
          Get.snackbar(
            'Coming Soon',
            'User selection screen will be implemented',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        backgroundColor: kSecondaryColor,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 20,
      elevation: 0,
      title: Row(
        children: [
          MyText(
            text: 'Inbox',
            size: 18,
            color: kTertiaryColor,
            weight: FontWeight.w600,
          ),
          const SizedBox(width: 8),
          Obx(() {
            final count = controller.totalUnreadCount.value;
            if (count > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MyText(
                  text: count > 99 ? '99+' : count.toString(),
                  size: 12,
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(Get.context!),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'refresh') {
              controller.refreshChatHeads();
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Obx(() {
      if (controller.searchQuery.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        color: Colors.grey[100],
        child: Row(
          children: [
            const Icon(Icons.search, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: MyText(
                text: 'Searching: "${controller.searchQuery.value}"',
                size: 14,
                color: kQuaternaryColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: controller.clearSearch,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChatList() {
    return RefreshIndicator(
      onRefresh: controller.refreshChatHeads,
      child: Obx(() {
        if (controller.isLoading.value && controller.chatHeads.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatHeads = controller.filteredChatHeads;

        if (chatHeads.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          itemCount: chatHeads.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chat = chatHeads[index];
            return _buildChatTile(chat);
          },
        );
      }),
    );
  }

  Widget _buildChatTile(Chat chat) {
    final hasUnread = controller.hasUnreadMessages(chat);
    final unreadCount = controller.getUnreadCount(chat);
    final lastMessageTime =
        chat.lastMessage?.createdAt ?? chat.updatedAt ?? chat.createdAt;

    final otherParticipant = controller.chatService.getOtherParticipant(chat);

    return ChatHeadTile(
      image: otherParticipant?.profilePicture ?? '',
      name: otherParticipant?.name ?? 'User',
      lastMsg: chat.lastMessage?.content ?? 'No messages yet',
      time: controller.formatMessageTime(lastMessageTime),
      isOnline: false, // TODO: Implement online status
      isNewMessage: hasUnread,
      unreadCount: unreadCount,
      onTap: () => controller.openChat(chat),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          MyText(
            text: 'No conversations yet',
            size: 16,
            color: kQuaternaryColor,
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          MyText(
            text: 'Start a conversation with someone',
            size: 14,
            color: kQuaternaryColor,
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController(
      text: controller.searchQuery.value,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Conversations'),
            content: TextField(
              controller: searchController,
              onChanged: controller.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by name or message...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.clearSearch();
                  searchController.clear();
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
}
