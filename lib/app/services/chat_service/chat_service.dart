// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/chat_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

class ChatService extends GetxService {
  static ChatService get instance => Get.find<ChatService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Chat> _userChats = <Chat>[].obs;
  final RxMap<String, List<Message>> _messagesByChat =
      <String, List<Message>>{}.obs;
  final Rx<Chat?> _selectedChat = Rx<Chat?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isSendingMessage = false.obs;
  final RxInt _unreadCount = 0.obs;

  // Getters
  List<Chat> get userChats => _userChats;
  Chat? get selectedChat => _selectedChat.value;
  bool get isLoading => _isLoading.value;
  bool get isSendingMessage => _isSendingMessage.value;
  int get unreadCount => _unreadCount.value;

  // Streams for reactive UI
  Stream<List<Chat>> get userChatsStream => _userChats.stream;
  Stream<Chat?> get selectedChatStream => _selectedChat.stream;
  Stream<int> get unreadCountStream => _unreadCount.stream;

  Future<ChatService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      // Load user chats if authenticated
      if (_authService.isAuthenticated) {
        await loadUserChats();
      }

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('ChatService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        loadUserChats();
      } else {
        _clearAllChats();
      }
    });
  }

  // ==================== CHAT OPERATIONS ====================

  /// Get all user chats
  Future<ApiResponse<List<Chat>>> getUserChats() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Chat>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.userChats,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Chat.fromJson(e)).toList();
          }
          return <Chat>[];
        },
      );

      if (response.success && response.data != null) {
        _userChats.value = response.data!;
        _updateUnreadCount();
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Chat>>(
        success: false,
        error: 'Failed to get user chats: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create a new chat
  Future<ApiResponse<Chat>> createChat(CreateChatRequest request) async {
    try {
      _isLoading.value = true;

      // Validation
      if (request.participantId.isEmpty) {
        return ApiResponse<Chat>(
          success: false,
          error: 'Participant ID is required',
        );
      }

      // Check if chat already exists with this participant
      final existingChat = _findChatWithParticipant(request.participantId);
      if (existingChat != null) {
        _selectedChat.value = existingChat;
        return ApiResponse<Chat>(
          success: true,
          data: existingChat,
          message: 'Chat already exists',
        );
      }

      final response = await _makeApiRequest<Chat>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createChat,
        data: request.toJson(),
        fromJson: (json) => Chat.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Add to chats list
        _userChats.insert(0, response.data!);
        _selectedChat.value = response.data;
        print('Chat created successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Chat>(
        success: false,
        error: 'Failed to create chat: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get or create chat with participant
  Future<ApiResponse<Chat>> getOrCreateChat(String participantId) async {
    // Check if chat exists
    final existingChat = _findChatWithParticipant(participantId);
    if (existingChat != null) {
      _selectedChat.value = existingChat;
      return ApiResponse<Chat>(success: true, data: existingChat);
    }

    // Create new chat
    return await createChat(CreateChatRequest(participantId: participantId));
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Get messages for a chat
  Future<ApiResponse<List<Message>>> getChatMessages(String chatId) async {
    try {
      _isLoading.value = true;

      // Check cache first
      if (_messagesByChat.containsKey(chatId)) {
        return ApiResponse<List<Message>>(
          success: true,
          data: _messagesByChat[chatId],
        );
      }

      // Note: API endpoint for getting messages is not in the Postman collection
      // You may need to add this endpoint or use WebSocket for messages
      final response = await _makeApiRequest<List<Message>>(
        method: 'GET',
        endpoint: '${ApiConfig.endpoints.chats}/$chatId/messages',
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Message.fromJson(e)).toList();
          }
          return <Message>[];
        },
      );

      if (response.success && response.data != null) {
        _messagesByChat[chatId] = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Message>>(
        success: false,
        error: 'Failed to get chat messages: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Send a message
  Future<ApiResponse<Message>> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isSendingMessage.value = true;

      // Validation
      if (content.trim().isEmpty) {
        return ApiResponse<Message>(
          success: false,
          error: 'Message content cannot be empty',
        );
      }

      final messageData = {
        'chatId': chatId,
        'content': content.trim(),
        'type': type.value,
        if (metadata != null) 'metadata': metadata,
      };

      // Note: API endpoint for sending messages is not in the Postman collection
      // This would typically be handled via WebSocket in real-time chat
      final response = await _makeApiRequest<Message>(
        method: 'POST',
        endpoint: '${ApiConfig.endpoints.chats}/$chatId/messages',
        data: messageData,
        fromJson: (json) => Message.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Add message to cache
        if (_messagesByChat.containsKey(chatId)) {
          _messagesByChat[chatId]!.add(response.data!);
        } else {
          _messagesByChat[chatId] = [response.data!];
        }

        // Update chat's last message
        _updateChatLastMessage(chatId, response.data!);

        print('Message sent successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Message>(
        success: false,
        error: 'Failed to send message: $e',
      );
    } finally {
      _isSendingMessage.value = false;
    }
  }

  /// Mark messages as read
  Future<ApiResponse<dynamic>> markMessagesAsRead(String chatId) async {
    try {
      // Note: API endpoint for marking messages as read is not in Postman collection
      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: '${ApiConfig.endpoints.chats}/$chatId/read',
      );

      if (response.success) {
        // Update local messages
        if (_messagesByChat.containsKey(chatId)) {
          _messagesByChat[chatId] =
              _messagesByChat[chatId]!
                  .map((msg) => msg.copyWith(isRead: true))
                  .toList();
        }

        _updateUnreadCount();
        print('Messages marked as read');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to mark messages as read: $e',
      );
    }
  }

  // ==================== REAL-TIME MESSAGE HANDLING ====================
  // Note: These methods would integrate with WebSocket for real-time updates

  /// Add received message (called when message received via WebSocket)
  void addReceivedMessage(Message message) {
    final chatId = message.chatId;

    // Add to messages cache
    if (_messagesByChat.containsKey(chatId)) {
      _messagesByChat[chatId]!.add(message);
    } else {
      _messagesByChat[chatId] = [message];
    }

    // Update chat's last message
    _updateChatLastMessage(chatId, message);

    // Update unread count if message is from other user
    if (message.senderId != _authService.currentUser?.id) {
      _updateUnreadCount();
    }
  }

  /// Update message status (for read receipts, delivery status, etc.)
  void updateMessageStatus(String messageId, {bool? isRead}) {
    for (final messages in _messagesByChat.values) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(isRead: isRead);
        break;
      }
    }

    if (isRead == true) {
      _updateUnreadCount();
    }
  }

  // ==================== CHAT FILTERING & SORTING ====================

  /// Get active chats
  List<Chat> getActiveChats() {
    return _userChats.where((chat) => chat.isActive).toList();
  }

  /// Get chats with unread messages
  List<Chat> getChatsWithUnreadMessages() {
    return _userChats.where((chat) {
      final messages = _messagesByChat[chat.id];
      if (messages == null) return false;

      return messages.any(
        (msg) => !msg.isRead && msg.senderId != _authService.currentUser?.id,
      );
    }).toList();
  }

  /// Search chats by participant name or last message
  List<Chat> searchChats(String query) {
    if (query.trim().isEmpty) return _userChats;

    final lowerQuery = query.toLowerCase();

    return _userChats.where((chat) {
      // Search in last message content
      if (chat.lastMessage?.content.toLowerCase().contains(lowerQuery) ??
          false) {
        return true;
      }

      // Note: To search by participant name, you'd need user data
      // This would require additional API calls or caching user info
      return false;
    }).toList();
  }

  /// Sort chats by last message date
  List<Chat> sortChatsByDate(List<Chat> chats, {bool descending = true}) {
    final sorted = List<Chat>.from(chats);
    sorted.sort((a, b) {
      final dateA = a.lastMessage?.createdAt ?? a.updatedAt ?? a.createdAt;
      final dateB = b.lastMessage?.createdAt ?? b.updatedAt ?? b.createdAt;

      if (dateA == null || dateB == null) return 0;

      return descending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });
    return sorted;
  }

  // ==================== MESSAGE FILTERING ====================

  /// Get messages by chat
  List<Message> getMessagesByChat(String chatId) {
    return _messagesByChat[chatId] ?? [];
  }

  /// Get unread messages for a chat
  List<Message> getUnreadMessages(String chatId) {
    final messages = _messagesByChat[chatId] ?? [];
    return messages
        .where(
          (msg) => !msg.isRead && msg.senderId != _authService.currentUser?.id,
        )
        .toList();
  }

  /// Get messages by type
  List<Message> getMessagesByType(String chatId, MessageType type) {
    final messages = _messagesByChat[chatId] ?? [];
    return messages.where((msg) => msg.type == type).toList();
  }

  /// Get media messages (images and photos)
  List<Message> getMediaMessages(String chatId) {
    final messages = _messagesByChat[chatId] ?? [];
    return messages
        .where(
          (msg) =>
              msg.type == MessageType.image || msg.type == MessageType.photo,
        )
        .toList();
  }

  // ==================== STATISTICS ====================

  /// Get total unread message count
  int getTotalUnreadCount() {
    int count = 0;

    for (final chat in _userChats) {
      final messages = _messagesByChat[chat.id];
      if (messages != null) {
        count +=
            messages
                .where(
                  (msg) =>
                      !msg.isRead &&
                      msg.senderId != _authService.currentUser?.id,
                )
                .length;
      }
    }

    return count;
  }

  /// Get unread count for specific chat
  int getUnreadCountForChat(String chatId) {
    final messages = _messagesByChat[chatId] ?? [];
    return messages
        .where(
          (msg) => !msg.isRead && msg.senderId != _authService.currentUser?.id,
        )
        .length;
  }

  /// Get total message count
  int getTotalMessageCount() {
    return _messagesByChat.values.fold<int>(
      0,
      (sum, messages) => sum + messages.length,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Load user chats
  Future<void> loadUserChats() async {
    await getUserChats();
  }

  /// Refresh chats
  Future<void> refreshChats() async {
    await loadUserChats();
  }

  /// Find chat with specific participant
  Chat? _findChatWithParticipant(String participantId) {
    return _userChats.firstWhereOrNull(
      (chat) => chat.participants.contains(participantId),
    );
  }

  /// Update chat's last message
  void _updateChatLastMessage(String chatId, Message message) {
    final index = _userChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      _userChats[index] = _userChats[index].copyWith(
        lastMessage: message,
        updatedAt: DateTime.now(),
      );

      // Move chat to top of list
      final chat = _userChats.removeAt(index);
      _userChats.insert(0, chat);
    }
  }

  /// Update unread count
  void _updateUnreadCount() {
    _unreadCount.value = getTotalUnreadCount();
  }

  /// Clear all chats
  void _clearAllChats() {
    _userChats.clear();
    _messagesByChat.clear();
    _selectedChat.value = null;
    _unreadCount.value = 0;
  }

  /// Set selected chat
  void setSelectedChat(Chat? chat) {
    _selectedChat.value = chat;

    // Load messages for selected chat if not already loaded
    if (chat != null && !_messagesByChat.containsKey(chat.id)) {
      getChatMessages(chat.id!);
    }
  }

  /// Clear messages cache for a chat
  void clearChatMessages(String chatId) {
    _messagesByChat.remove(chatId);
  }

  /// Clear all message caches
  void clearAllMessageCaches() {
    _messagesByChat.clear();
  }

  /// Check if chat has other participant
  String? getOtherParticipantId(Chat chat) {
    if (_authService.currentUser == null) return null;

    final currentUserId = _authService.currentUser!.id;
    return chat.participants.firstWhereOrNull((id) => id != currentUserId);
  }

  /// Delete chat (archive)
  Future<ApiResponse<dynamic>> deleteChat(String chatId) async {
    try {
      _isLoading.value = true;

      // Note: Delete endpoint not in Postman collection
      final response = await _makeApiRequest(
        method: 'DELETE',
        endpoint: '${ApiConfig.endpoints.chats}/$chatId',
      );

      if (response.success) {
        _userChats.removeWhere((chat) => chat.id == chatId);
        _messagesByChat.remove(chatId);

        if (_selectedChat.value?.id == chatId) {
          _selectedChat.value = null;
        }

        print('Chat deleted successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to delete chat: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== API REQUEST METHOD ====================

  /// Generic API request method
  Future<ApiResponse<T>> _makeApiRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      // Check authentication
      if (_authService.authToken == null) {
        return ApiResponse<T>(
          success: false,
          error: 'Authentication required',
          statusCode: 401,
        );
      }

      final url = '${ApiConfig.fullApiUrl}$endpoint';
      final headers = ApiConfig.authHeaders(_authService.authToken!);

      final getConnect = GetConnect(timeout: ApiConfig.connectTimeout);

      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await getConnect.get(url, headers: headers);
          break;
        case 'POST':
          response = await getConnect.post(url, data, headers: headers);
          break;
        case 'PUT':
          response = await getConnect.put(url, data, headers: headers);
          break;
        case 'DELETE':
          response = await getConnect.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final responseData = response.body;

        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: responseData['message'],
          data:
              fromJson != null && responseData['data'] != null
                  ? fromJson(responseData['data'])
                  : responseData['data'],
          metadata: responseData['metadata'],
        );
      }

      final errorData = response.body ?? {};
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        error: errorData['message'] ?? errorData['error'] ?? 'Unknown error',
        message: errorData['message'],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle request errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    String errorMessage;

    if (error.toString().contains('SocketException')) {
      errorMessage = 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'Request timeout';
    } else {
      errorMessage = 'Network error: $error';
    }

    return ApiResponse<T>(success: false, error: errorMessage);
  }

  @override
  void onClose() {
    _clearAllChats();
    super.onClose();
  }
}
