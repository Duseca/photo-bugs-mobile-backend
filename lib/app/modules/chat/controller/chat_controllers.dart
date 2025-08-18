// ==================== CONTROLLERS ====================

// controllers/chat_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/models/chat_model/chat_models.dart';

class ChatController extends GetxController {
  // Observable variables
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxString currentChatId = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxString otherUserImage = ''.obs;
  final RxBool otherUserOnline = false.obs;

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from previous screen
    final arguments = Get.arguments;
    if (arguments != null) {
      currentChatId.value = arguments['chatId'] ?? '';
      otherUserName.value = arguments['userName'] ?? '';
      otherUserImage.value = arguments['userImage'] ?? '';
      otherUserOnline.value = arguments['isOnline'] ?? false;
    }
    loadMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Load messages for current chat
  void loadMessages() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample messages - replace with actual data from API
      final sampleMessages = [
        ChatMessage(
          id: '1',
          senderId: 'user1',
          senderName: 'Jonas',
          senderImage: 'dummyImg2', // Replace with actual image URL
          message:
              'Hello! are you available for a photoshoot for a wedding ceremony?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isMe: true,
        ),
        ChatMessage(
          id: '2',
          senderId: 'user2',
          senderName: 'Mark',
          senderImage: 'dummyImg', // Replace with actual image URL
          message: 'Hello, Please share xyz details...',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isMe: false,
        ),
      ];

      messages.assignAll(sampleMessages);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load messages',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Send a new message
  void sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'currentUserId', // Replace with actual current user ID
      senderName: 'You',
      senderImage: 'currentUserImage', // Replace with actual current user image
      message: messageText,
      timestamp: DateTime.now(),
      isMe: true,
    );

    // Add message to list immediately for better UX
    messages.insert(0, newMessage);
    messageController.clear();

    // Scroll to bottom
    scrollToBottom();

    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Here you would typically send the message to your backend
      // await chatService.sendMessage(newMessage);
    } catch (e) {
      // Remove message from list if sending failed
      messages.removeWhere((msg) => msg.id == newMessage.id);
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Scroll to bottom of messages
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Mark messages as read
  void markMessagesAsRead() {
    // Implement logic to mark messages as read
    // This would typically involve an API call
  }

  // Handle typing indicator
  void onTyping() {
    isTyping.value = true;
    // You can implement debouncing here to reduce API calls
  }

  void onStopTyping() {
    isTyping.value = false;
  }
}

// controllers/chat_head_controller.dart
class ChatHeadController extends GetxController {
  // Observable variables
  final RxList<ChatHead> chatHeads = <ChatHead>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Filtered chat heads based on search
  List<ChatHead> get filteredChatHeads {
    if (searchQuery.value.isEmpty) {
      return chatHeads;
    }
    return chatHeads
        .where(
          (chat) =>
              chat.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              chat.lastMessage.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadChatHeads();
  }

  // Load chat heads from API
  void loadChatHeads() async {
    isLoading.value = true;
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample chat heads - replace with actual data from API
      final sampleChatHeads = [
        ChatHead(
          id: '1',
          userId: 'user1',
          name: 'Kazumi K',
          image: 'dummyImg', // Replace with actual image URL
          lastMessage: 'Yes, that would be great!',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          isOnline: true,
          hasNewMessage: true,
          unreadCount: 3,
        ),
        ChatHead(
          id: '2',
          userId: 'user2',
          name: 'Angelina',
          image: 'dummyImg', // Replace with actual image URL
          lastMessage: 'Can you send me over all the file types?',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
          isOnline: false,
          hasNewMessage: false,
          unreadCount: 0,
        ),
        ChatHead(
          id: '3',
          userId: 'user3',
          name: 'Kazumi K',
          image: 'dummyImg', // Replace with actual image URL
          lastMessage: 'Thanks for the quick response!',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
          isOnline: false,
          hasNewMessage: false,
          unreadCount: 0,
        ),
      ];

      chatHeads.assignAll(sampleChatHeads);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load chats',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to chat screen
  void openChat(ChatHead chatHead) {
    // Mark as read when opening chat
    final updatedChatHead = chatHead.copyWith(
      hasNewMessage: false,
      unreadCount: 0,
    );

    final index = chatHeads.indexWhere((chat) => chat.id == chatHead.id);
    if (index != -1) {
      chatHeads[index] = updatedChatHead;
    }

    // Navigate to chat screen with arguments
    Get.toNamed(
      '/chat',
      arguments: {
        'chatId': chatHead.id,
        'userName': chatHead.name,
        'userImage': chatHead.image,
        'isOnline': chatHead.isOnline,
      },
    );
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  // Refresh chat heads
  Future<void> refreshChatHeads() async {}
}
