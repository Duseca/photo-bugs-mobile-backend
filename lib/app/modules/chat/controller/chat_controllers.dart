// controllers/chat_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/chat_model.dart';
import 'package:photo_bug/app/routes/app_pages.dart';

import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/chat_service/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService.instance;
  final AuthService _authService = AuthService.instance;

  // Observable variables
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxString currentChatId = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxString otherUserImage = ''.obs;
  final RxBool otherUserOnline = false.obs;
  final Rx<Chat?> currentChat = Rx<Chat?>(null);

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
    if (currentChatId.value.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await _chatService.getChatMessages(currentChatId.value);

      if (response.success && response.data != null) {
        // Reverse messages so newest appear at bottom
        messages.assignAll(response.data!.reversed.toList());

        // Mark messages as read
        await _chatService.markMessagesAsRead(currentChatId.value);

        // Scroll to bottom after loading
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollToBottom();
        });
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to load messages',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load messages: $e',
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
    if (messageText.isEmpty || currentChatId.value.isEmpty) return;

    // Clear input immediately
    messageController.clear();
    onStopTyping();

    try {
      final response = await _chatService.sendMessage(
        chatId: currentChatId.value,
        content: messageText,
        type: MessageType.text,
      );

      if (response.success && response.data != null) {
        // Add message to list
        messages.add(response.data!);

        // Scroll to bottom
        scrollToBottom();
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to send message',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
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
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Handle typing indicator
  void onTyping() {
    isTyping.value = true;
  }

  void onStopTyping() {
    isTyping.value = false;
  }

  // Check if message is from current user
  bool isMyMessage(Message message) {
    return message.senderId == _authService.currentUser?.id;
  }
}

// controllers/chat_head_controller.dart
class ChatHeadController extends GetxController {
  final ChatService _chatService = ChatService.instance;
  final AuthService _authService = AuthService.instance;

  // Observable variables
  final RxList<Chat> chatHeads = <Chat>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Filtered chat heads based on search
  List<Chat> get filteredChatHeads {
    if (searchQuery.value.isEmpty) {
      return chatHeads;
    }

    return chatHeads.where((chat) {
      final lastMessage = chat.lastMessage?.content.toLowerCase() ?? '';
      return lastMessage.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadChatHeads();

    // Listen to chat updates
    _setupChatListener();
  }

  // Setup listener for real-time chat updates
  void _setupChatListener() {
    _chatService.userChatsStream.listen((chats) {
      chatHeads.assignAll(chats);
    });
  }

  // Load chat heads from API
  void loadChatHeads() async {
    isLoading.value = true;
    try {
      final response = await _chatService.getUserChats();

      if (response.success && response.data != null) {
        chatHeads.assignAll(response.data!);
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to load chats',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load chats: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to chat screen
  void openChat(Chat chat) async {
    if (chat.id == null) return;

    // Mark messages as read
    await _chatService.markMessagesAsRead(chat.id!);

    // Set selected chat in service
    _chatService.setSelectedChat(chat);

    // Get other participant ID
    final otherParticipantId = _chatService.getOtherParticipantId(chat);

    // Navigate to chat screen with arguments
    Get.toNamed(
      Routes.CHAT_SCREEN,
      arguments: {
        'chatId': chat.id,
        'userName': 'User', // You'll need to fetch user details
        'userImage': '', // You'll need to fetch user details
        'isOnline': false, // You'll need to implement online status
      },
    );
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  // Refresh chat heads
  Future<void> refreshChatHeads() async {
    await _chatService.refreshChats();
  }

  // Get unread count for a chat
  int getUnreadCount(Chat chat) {
    if (chat.id == null) return 0;
    return _chatService.getUnreadCountForChat(chat.id!);
  }

  // Check if chat has unread messages
  bool hasUnreadMessages(Chat chat) {
    return getUnreadCount(chat) > 0;
  }
}
