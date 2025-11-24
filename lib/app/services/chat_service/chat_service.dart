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

  // Streams
  Stream<List<Chat>> get userChatsStream => _userChats.stream;
  Stream<Chat?> get selectedChatStream => _selectedChat.stream;
  Stream<int> get unreadCountStream => _unreadCount.stream;

  Future<ChatService> init() async {
    await _initialize();
    return this;
  }

  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      if (_authService.isAuthenticated) {
        await loadUserChats();
      }

      _setupAuthListener();
    } catch (e) {
      print('ChatService initialization error: $e');
    }
  }

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
  /// Endpoint: GET /api/chats
  Future<ApiResponse<List<Chat>>> getUserChats() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Chat>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getUserChats,
        fromJson: (json) {
          print('🔍 Raw JSON type: ${json.runtimeType}');
          print('🔍 Raw JSON: $json');

          if (json is List) {
            print('✅ JSON is List with ${json.length} items');
            try {
              final chats =
                  json.map((e) {
                    print('📦 Parsing chat: ${e['_id']}');
                    return Chat.fromJson(e);
                  }).toList();
              print('✅ Successfully parsed ${chats.length} chats');
              return chats;
            } catch (e) {
              print('❌ Error parsing chats: $e');
              rethrow;
            }
          }
          print('⚠️ JSON is not a List, returning empty');
          return <Chat>[];
        },
      );

      if (response.success && response.data != null) {
        _userChats.value = response.data!;
        _updateUnreadCount();
        print('✅ Loaded ${response.data!.length} chats to _userChats');
        print('✅ Current _userChats length: ${_userChats.length}');
      } else {
        print('❌ Response failed or data is null');
        print('❌ Success: ${response.success}');
        print('❌ Data: ${response.data}');
        print('❌ Error: ${response.error}');
      }

      return response;
    } catch (e, stackTrace) {
      print('❌ Error getting chats: $e');
      print('❌ StackTrace: $stackTrace');
      return ApiResponse<List<Chat>>(
        success: false,
        error: 'Failed to get user chats: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get chat by ID
  /// Endpoint: GET /api/chats/{id}
  Future<ApiResponse<Chat>> getChatById(String chatId) async {
    try {
      final response = await _makeApiRequest<Chat>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getChatById(chatId),
        fromJson: (json) => Chat.fromJson(json),
      );

      if (response.success && response.data != null) {
        final index = _userChats.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          _userChats[index] = response.data!;
        } else {
          _userChats.add(response.data!);
        }
        print('✅ Loaded chat: $chatId');
      }

      return response;
    } catch (e) {
      print('❌ Error getting chat: $e');
      return ApiResponse<Chat>(success: false, error: 'Failed to get chat: $e');
    }
  }

  /// Create a new chat
  /// Endpoint: POST /api/chats
  Future<ApiResponse<Chat>> createChat(CreateChatRequest request) async {
    try {
      _isLoading.value = true;

      if (request.participantId.isEmpty) {
        return ApiResponse<Chat>(
          success: false,
          error: 'Participant ID is required',
        );
      }

      // Check if chat already exists
      final existingChat = _findChatWithParticipant(request.participantId);
      if (existingChat != null) {
        _selectedChat.value = existingChat;
        print('✅ Chat already exists');
        return ApiResponse<Chat>(
          success: true,
          data: existingChat,
          message: 'Chat already exists',
        );
      }

      final response = await _makeApiRequest<Chat>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createUserChat,
        data: request.toJson(),
        fromJson: (json) => Chat.fromJson(json),
      );

      if (response.success && response.data != null) {
        _userChats.insert(0, response.data!);
        _selectedChat.value = response.data;
        print('✅ Chat created successfully');
      }

      return response;
    } catch (e) {
      print('❌ Error creating chat: $e');
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
    final existingChat = _findChatWithParticipant(participantId);
    if (existingChat != null) {
      _selectedChat.value = existingChat;
      return ApiResponse<Chat>(success: true, data: existingChat);
    }
    return await createChat(CreateChatRequest(participantId: participantId));
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send a message
  /// Endpoint: POST /api/chats/{chatId}/messages
  Future<ApiResponse<Message>> sendMessage({
    required String chatId,
    required String content,
    String type = 'Text',
  }) async {
    try {
      _isSendingMessage.value = true;

      if (content.trim().isEmpty) {
        return ApiResponse<Message>(
          success: false,
          error: 'Message content cannot be empty',
        );
      }

      final messageData = {'content': content.trim(), 'type': type};

      final response = await _makeApiRequest<Message>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.sendMessage(chatId),
        data: messageData,
        fromJson: (json) => Message.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Reload chat to get updated messages
        await getChatById(chatId);
        print('✅ Message sent successfully');
      }

      return response;
    } catch (e) {
      print('❌ Error sending message: $e');
      return ApiResponse<Message>(
        success: false,
        error: 'Failed to send message: $e',
      );
    } finally {
      _isSendingMessage.value = false;
    }
  }

  /// Mark message as read
  /// Endpoint: PUT /api/chats/{chatId}/messages/{messageId}
  /// Mark message as read - UPDATED VERSION
  Future<ApiResponse<dynamic>> markMessageAsRead(
    String chatId,
    String messageId,
  ) async {
    try {
      print('📩 Marking message as read...');
      print('   Chat ID: $chatId');
      print('   Message ID: $messageId');

      final requestData = {'markAsRead': true, 'chatId': chatId};

      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.markAsRead(chatId, messageId),
        data: requestData,
      );

      if (response.success) {
        print('✅ Message marked as read successfully');

        // Update local chat data
        final chatIndex = _userChats.indexWhere((c) => c.id == chatId);
        if (chatIndex != -1) {
          // Reload chat to get updated data
          await getChatById(chatId);
        }

        // Update unread count
        _updateUnreadCount();
      } else {
        print('❌ Failed to mark as read: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error marking as read: $e');
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to mark message as read: $e',
      );
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get messages for a chat
  List<Message> getMessagesByChat(String chatId) {
    final chat = _userChats.firstWhereOrNull((c) => c.id == chatId);
    return chat?.messages ?? [];
  }

  /// Get unread count for a chat
  int getUnreadCountForChat(String chatId) {
    final chat = _userChats.firstWhereOrNull((c) => c.id == chatId);
    return chat?.unreadCount ?? 0;
  }

  /// Get total unread count
  int getTotalUnreadCount() {
    return _userChats.fold<int>(0, (sum, chat) => sum + chat.unreadCount);
  }

  /// Find chat with specific participant
  Chat? _findChatWithParticipant(String participantId) {
    return _userChats.firstWhereOrNull(
      (chat) => chat.participants.any((p) => p.id == participantId),
    );
  }

  /// Get other participant in chat
  Participant? getOtherParticipant(Chat chat) {
    if (_authService.currentUser == null) return null;

    final currentUserId = _authService.currentUser!.id;
    return chat.participants.firstWhereOrNull((p) => p.id != currentUserId);
  }

  /// Get other participant ID
  String? getOtherParticipantId(Chat chat) {
    final participant = getOtherParticipant(chat);
    return participant?.id;
  }

  /// Update unread count
  void _updateUnreadCount() {
    _unreadCount.value = getTotalUnreadCount();
  }

  /// Clear all chats
  void _clearAllChats() {
    _userChats.clear();
    _selectedChat.value = null;
    _unreadCount.value = 0;
  }

  /// Set selected chat
  void setSelectedChat(Chat? chat) {
    _selectedChat.value = chat;
  }

  /// Load user chats
  Future<void> loadUserChats() async {
    await getUserChats();
  }

  /// Refresh chats
  Future<void> refreshChats() async {
    await loadUserChats();
  }

  /// Search chats
  List<Chat> searchChats(String query) {
    if (query.trim().isEmpty) return _userChats;

    final lowerQuery = query.toLowerCase();
    return _userChats.where((chat) {
      // Search in last message
      final lastMsg = chat.lastMessage?.content.toLowerCase() ?? '';
      if (lastMsg.contains(lowerQuery)) return true;

      // Search in participant names
      return chat.participants.any(
        (p) => p.name.toLowerCase().contains(lowerQuery),
      );
    }).toList();
  }

  /// Sort chats by date
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

  // ==================== API REQUEST METHOD ====================

  Future<ApiResponse<T>> _makeApiRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      if (_authService.authToken == null) {
        print('❌ No auth token available');
        return ApiResponse<T>(
          success: false,
          error: 'Authentication required',
          statusCode: 401,
        );
      }

      final url = '${ApiConfig.fullApiUrl}$endpoint';
      final headers = ApiConfig.authHeaders(_authService.authToken!);

      print('🌐 $method $url');
      print('🔑 Token: ${_authService.authToken?.substring(0, 20)}...');
      if (data != null) print('📤 Data: $data');

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

      print('📥 Status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleResponse<T>(response, fromJson);
    } catch (e, stackTrace) {
      print('❌ API Error: $e');
      print('❌ StackTrace: $stackTrace');
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode ?? 0;
      print('🔍 Status Code: $statusCode');

      if (statusCode >= 200 && statusCode < 300) {
        final responseData = response.body;
        print('🔍 Response Data Type: ${responseData.runtimeType}');
        print('🔍 Response Data: $responseData');

        if (responseData is Map && responseData['success'] == true) {
          print('✅ Success: ${responseData['message'] ?? 'OK'}');

          final data = responseData['data'];
          print('🔍 Data field type: ${data.runtimeType}');
          print('🔍 Data field: $data');

          return ApiResponse<T>(
            success: true,
            statusCode: statusCode,
            message: responseData['message'],
            data: fromJson != null && data != null ? fromJson(data) : data,
          );
        } else {
          print('⚠️ Response success is not true or not a Map');
          print('⚠️ Response data: $responseData');
        }
      }

      final errorData = response.body ?? {};
      print('❌ Error: ${errorData['message'] ?? 'Unknown error'}');
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        error: errorData['message'] ?? errorData['error'] ?? 'Unknown error',
      );
    } catch (e, stackTrace) {
      print('❌ Parse Error: $e');
      print('❌ StackTrace: $stackTrace');
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

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
