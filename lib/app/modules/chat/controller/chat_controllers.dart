import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/chat_model.dart';
import 'package:photo_bug/app/models/allUsers.dart';
import 'package:photo_bug/app/modules/user_events/widgets/user_widget.dart';
import 'package:photo_bug/app/routes/app_pages.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';
import 'package:photo_bug/app/services/chat_service/chat_service.dart';

// chat_controllers.dart - ChatController class

class ChatController extends GetxController {
  final ChatService _chatService = ChatService.instance;
  final AuthService _authService = AuthService.instance;

  // Observable variables
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentChatId = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxString otherUserImage = ''.obs;
  final RxBool otherUserOnline = false.obs;

  // Text controller
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Timer for auto-refresh
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null) {
      currentChatId.value = arguments['chatId'] ?? '';
      otherUserName.value = arguments['userName'] ?? '';
      otherUserImage.value = arguments['userImage'] ?? '';
      otherUserOnline.value = arguments['isOnline'] ?? false;
    }

    loadMessages();
    _markAllMessagesAsRead(); // NEW: Mark messages as read when chat opens
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Load messages for current chat
  Future<void> loadMessages() async {
    if (currentChatId.value.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await _chatService.getChatById(currentChatId.value);

      if (response.success && response.data != null) {
        messages.assignAll(response.data!.messages);

        Future.delayed(const Duration(milliseconds: 100), () {
          scrollToBottom();
        });

        // NEW: Mark unread messages as read after loading
        await _markAllMessagesAsRead();
      } else {
        _showError(response.error ?? 'Failed to load messages');
      }
    } catch (e) {
      _showError('Failed to load messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark all unread messages as read - NEW METHOD
  Future<void> _markAllMessagesAsRead() async {
    if (currentChatId.value.isEmpty || messages.isEmpty) return;

    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) return;

      // Find unread messages from other user
      final unreadMessages =
          messages.where((msg) {
            return msg.createdBy != currentUserId && !msg.isRead;
          }).toList();

      print('📬 Unread messages to mark: ${unreadMessages.length}');

      // Mark each unread message as read
      for (final message in unreadMessages) {
        if (message.id != null) {
          print('✅ Marking message as read: ${message.id}');
          await _chatService.markMessageAsRead(
            currentChatId.value,
            message.id!,
          );
        }
      }

      // Refresh chat to update unread count
      if (unreadMessages.isNotEmpty) {
        print('🔄 Refreshing chat to update unread count...');
        final response = await _chatService.getChatById(currentChatId.value);
        if (response.success && response.data != null) {
          messages.assignAll(response.data!.messages);
        }
      }
    } catch (e) {
      print('❌ Error marking messages as read: $e');
      // Don't show error to user - this is a background operation
    }
  }

  /// Send a new message
  void sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty || currentChatId.value.isEmpty) return;

    messageController.clear();

    try {
      final response = await _chatService.sendMessage(
        chatId: currentChatId.value,
        content: messageText,
        type: 'Text',
      );

      if (response.success) {
        // Refresh messages immediately
        await loadMessages();
      } else {
        _showError(response.error ?? 'Failed to send message');
      }
    } catch (e) {
      _showError('Failed to send message: $e');
    }
  }

  /// Scroll to bottom
  void scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Check if message is from current user
  bool isMyMessage(Message message) {
    return message.createdBy == _authService.currentUser?.id;
  }

  /// Refresh messages manually
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}

class ChatHeadController extends GetxController {
  final ChatService chatService = ChatService.instance;
  final AuthService _authService = AuthService.instance;

  // Observable variables
  final RxList<Chat> chatHeads = <Chat>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt totalUnreadCount = 0.obs;

  // Timer for auto-refresh
  Timer? _refreshTimer;

  // Filtered chat heads based on search
  List<Chat> get filteredChatHeads {
    if (searchQuery.value.isEmpty) {
      return chatService.sortChatsByDate(chatHeads);
    }

    final filtered = chatService.searchChats(searchQuery.value);
    return chatService.sortChatsByDate(filtered);
  }

  @override
  void onInit() {
    super.onInit();
    loadChatHeads();
    _setupListeners();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  /// Setup listeners
  void _setupListeners() {
    chatService.userChatsStream.listen((chats) {
      chatHeads.assignAll(chats);
    });

    chatService.unreadCountStream.listen((count) {
      totalUnreadCount.value = count;
    });
  }

  /// Start auto-refresh for real-time updates
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshSilently();
    });
  }

  /// Refresh silently without showing loader
  Future<void> _refreshSilently() async {
    try {
      await chatService.getUserChats();
    } catch (e) {
      // Silently fail
    }
  }

  /// Load chat heads from API
  Future<void> loadChatHeads() async {
    isLoading.value = true;
    try {
      final response = await chatService.getUserChats();

      if (response.success && response.data != null) {
        chatHeads.assignAll(response.data!);
        print('✅ Loaded ${chatHeads.length} chats');
      } else {
        _showError(response.error ?? 'Failed to load chats');
      }
    } catch (e) {
      _showError('Failed to load chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to chat screen
  void openChat(Chat chat) async {
    if (chat.id == null) return;

    chatService.setSelectedChat(chat);

    final otherParticipant = chatService.getOtherParticipant(chat);

    Get.toNamed(
      Routes.CHAT_SCREEN,
      arguments: {
        'chatId': chat.id,
        'userName': otherParticipant?.name ?? 'User',
        'userImage': otherParticipant?.profilePicture ?? '',
        'isOnline': false,
      },
    );
  }

  /// Create new chat with user - UPDATED
  Future<void> createChatWithUser(String userId) async {
    try {
      isLoading.value = true;

      print('📩 Creating chat with user: $userId');

      final response = await chatService.getOrCreateChat(userId);

      if (response.success && response.data != null) {
        print('✅ Chat created/retrieved successfully');

        // Refresh chat list
        await loadChatHeads();

        // Open the chat
        openChat(response.data!);
      } else {
        _showError(response.error ?? 'Failed to create chat');
      }
    } catch (e) {
      print('❌ Error creating chat: $e');
      _showError('Failed to create chat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Start new chat - NEW METHOD
  Future<void> startNewChat() async {
    try {
      print('🚀 Opening user selector dialog...');

      // Show user selector dialog
      final selectedUser = await Get.dialog<UserBasicInfo>(
        const UserSelectorDialog(
          title: 'Start New Chat',
          subtitle: 'Select a user to start chatting',
          showOnlyPhotographers: false, // Show all users
        ),
      );

      if (selectedUser != null) {
        print(
          '✅ User selected: ${selectedUser.displayName} (${selectedUser.id})',
        );

        // Check if chat already exists
        final existingChat = chatHeads.firstWhereOrNull(
          (chat) => chat.participants.any((p) => p.id == selectedUser.id),
        );

        if (existingChat != null) {
          print('💬 Chat already exists, opening...');
          openChat(existingChat);
        } else {
          print('📩 Creating new chat...');
          await createChatWithUser(selectedUser.id);
        }
      } else {
        print('❌ No user selected');
      }
    } catch (e) {
      print('❌ Error starting chat: $e');
      _showError('Failed to start chat: $e');
    }
  }

  /// Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Refresh chat heads
  Future<void> refreshChatHeads() async {
    await chatService.refreshChats();
  }

  /// Get unread count for a chat
  int getUnreadCount(Chat chat) {
    return chat.unreadCount;
  }

  /// Check if chat has unread messages
  bool hasUnreadMessages(Chat chat) {
    return chat.unreadCount > 0;
  }

  /// Format message time
  String formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return _formatTime(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return _getDayName(dateTime.weekday);
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour =
        dateTime.hour == 0
            ? 12
            : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
