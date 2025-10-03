// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/notification_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Notification> _userNotifications = <Notification>[].obs;
  final Rx<Notification?> _selectedNotification = Rx<Notification?>(null);
  final RxBool _isLoading = false.obs;
  final RxInt _unreadCount = 0.obs;

  // Getters
  List<Notification> get userNotifications => _userNotifications;
  Notification? get selectedNotification => _selectedNotification.value;
  bool get isLoading => _isLoading.value;
  int get unreadCount => _unreadCount.value;

  // Streams for reactive UI
  Stream<List<Notification>> get notificationsStream =>
      _userNotifications.stream;
  Stream<Notification?> get selectedNotificationStream =>
      _selectedNotification.stream;
  Stream<int> get unreadCountStream => _unreadCount.stream;

  Future<NotificationService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      // Load user notifications if authenticated
      if (_authService.isAuthenticated) {
        await loadUserNotifications();
      }

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('NotificationService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        loadUserNotifications();
      } else {
        _clearAllNotifications();
      }
    });
  }

  // ==================== NOTIFICATION CRUD OPERATIONS ====================

  /// Get all notifications
  Future<ApiResponse<List<Notification>>> getAllNotifications() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Notification>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.notifications,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Notification.fromJson(e)).toList();
          }
          return <Notification>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Notification>>(
        success: false,
        error: 'Failed to get all notifications: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get notification by ID
  Future<ApiResponse<Notification>> getNotificationById(
    String notificationId,
  ) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Notification>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.notificationById(notificationId),
        fromJson: (json) => Notification.fromJson(json),
      );

      if (response.success && response.data != null) {
        _selectedNotification.value = response.data;
      }

      return response;
    } catch (e) {
      return ApiResponse<Notification>(
        success: false,
        error: 'Failed to get notification: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get current user's notifications
  Future<ApiResponse<List<Notification>>> getUserNotifications() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Notification>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.userNotifications,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Notification.fromJson(e)).toList();
          }
          return <Notification>[];
        },
      );

      if (response.success && response.data != null) {
        _userNotifications.value = response.data!;
        _updateUnreadCount();
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Notification>>(
        success: false,
        error: 'Failed to get user notifications: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Send a notification (admin/system use)
  Future<ApiResponse<Notification>> sendNotification(
    SendNotificationRequest request,
  ) async {
    try {
      _isLoading.value = true;

      // Validation
      if (request.description.trim().isEmpty) {
        return ApiResponse<Notification>(
          success: false,
          error: 'Notification description cannot be empty',
        );
      }

      final response = await _makeApiRequest<Notification>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.notifications,
        data: request.toJson(),
        fromJson: (json) => Notification.fromJson(json),
      );

      if (response.success) {
        print('Notification sent successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Notification>(
        success: false,
        error: 'Failed to send notification: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Mark notification as seen
  Future<ApiResponse<dynamic>> markNotificationAsSeen(
    String notificationId,
  ) async {
    try {
      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.notificationSeen(notificationId),
      );

      if (response.success) {
        // Update in local list
        final index = _userNotifications.indexWhere(
          (n) => n.id == notificationId,
        );
        if (index != -1) {
          _userNotifications[index] = _userNotifications[index].copyWith(
            isSeen: true,
          );
        }

        // Update selected notification
        if (_selectedNotification.value?.id == notificationId) {
          _selectedNotification.value = _selectedNotification.value!.copyWith(
            isSeen: true,
          );
        }

        _updateUnreadCount();
        print('Notification marked as seen');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to mark notification as seen: $e',
      );
    }
  }

  /// Delete notification
  Future<ApiResponse<dynamic>> deleteNotification(String notificationId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.notificationById(notificationId),
      );

      if (response.success) {
        _userNotifications.removeWhere((n) => n.id == notificationId);

        if (_selectedNotification.value?.id == notificationId) {
          _selectedNotification.value = null;
        }

        _updateUnreadCount();
        print('Notification deleted successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to delete notification: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Mark all notifications as seen
  Future<ApiResponse<Map<String, dynamic>>> markAllAsSeen() async {
    try {
      _isLoading.value = true;

      final unseenNotifications = getUnseenNotifications();
      int successCount = 0;
      int failCount = 0;

      for (final notification in unseenNotifications) {
        if (notification.id != null) {
          final response = await markNotificationAsSeen(notification.id!);
          if (response.success) {
            successCount++;
          } else {
            failCount++;
          }
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        success: failCount == 0,
        data: {
          'total': unseenNotifications.length,
          'success': successCount,
          'failed': failCount,
        },
        message:
            'Marked $successCount of ${unseenNotifications.length} notifications as seen',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Failed to mark all as seen: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete all notifications
  Future<ApiResponse<Map<String, dynamic>>> deleteAllNotifications() async {
    try {
      _isLoading.value = true;

      final notificationIds =
          _userNotifications
              .where((n) => n.id != null)
              .map((n) => n.id!)
              .toList();

      int successCount = 0;
      int failCount = 0;

      for (final notificationId in notificationIds) {
        final response = await deleteNotification(notificationId);
        if (response.success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        success: failCount == 0,
        data: {
          'total': notificationIds.length,
          'success': successCount,
          'failed': failCount,
        },
        message:
            'Deleted $successCount of ${notificationIds.length} notifications',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Failed to delete all notifications: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete seen notifications
  Future<ApiResponse<Map<String, dynamic>>> deleteSeenNotifications() async {
    try {
      _isLoading.value = true;

      final seenNotifications = getSeenNotifications();
      int successCount = 0;
      int failCount = 0;

      for (final notification in seenNotifications) {
        if (notification.id != null) {
          final response = await deleteNotification(notification.id!);
          if (response.success) {
            successCount++;
          } else {
            failCount++;
          }
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        success: failCount == 0,
        data: {
          'total': seenNotifications.length,
          'success': successCount,
          'failed': failCount,
        },
        message:
            'Deleted $successCount of ${seenNotifications.length} seen notifications',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Failed to delete seen notifications: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== NOTIFICATION FILTERING ====================

  /// Get unseen notifications
  List<Notification> getUnseenNotifications() {
    return _userNotifications.where((n) => !n.isSeen).toList();
  }

  /// Get seen notifications
  List<Notification> getSeenNotifications() {
    return _userNotifications.where((n) => n.isSeen).toList();
  }

  /// Get notifications by type
  List<Notification> getNotificationsByType(NotificationType type) {
    return _userNotifications.where((n) => n.type == type).toList();
  }

  /// Get event invite notifications
  List<Notification> getEventInviteNotifications() {
    return getNotificationsByType(NotificationType.eventInvite);
  }

  /// Get folder invite notifications
  List<Notification> getFolderInviteNotifications() {
    return getNotificationsByType(NotificationType.folderInvite);
  }

  /// Get photo upload notifications
  List<Notification> getPhotoUploadNotifications() {
    return getNotificationsByType(NotificationType.photoUpload);
  }

  /// Get purchase notifications
  List<Notification> getPurchaseNotifications() {
    return getNotificationsByType(NotificationType.purchase);
  }

  /// Get review notifications
  List<Notification> getReviewNotifications() {
    return getNotificationsByType(NotificationType.review);
  }

  /// Search notifications
  List<Notification> searchNotifications(String query) {
    if (query.trim().isEmpty) return _userNotifications;

    final lowerQuery = query.toLowerCase();

    return _userNotifications
        .where(
          (notification) =>
              notification.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  // ==================== SORTING ====================

  /// Sort notifications by date (most recent first)
  List<Notification> sortNotificationsByDate(
    List<Notification> notifications, {
    bool descending = true,
  }) {
    final sorted = List<Notification>.from(notifications);
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return descending
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });
    return sorted;
  }

  /// Sort notifications by seen status (unseen first)
  List<Notification> sortNotificationsBySeenStatus(
    List<Notification> notifications,
  ) {
    final sorted = List<Notification>.from(notifications);
    sorted.sort((a, b) {
      if (a.isSeen == b.isSeen) return 0;
      return a.isSeen ? 1 : -1;
    });
    return sorted;
  }

  // ==================== STATISTICS ====================

  /// Get notification count by type
  Map<NotificationType, int> getNotificationCountByType() {
    final counts = <NotificationType, int>{};

    for (final type in NotificationType.values) {
      counts[type] = getNotificationsByType(type).length;
    }

    return counts;
  }

  /// Get notifications from today
  List<Notification> getTodayNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _userNotifications.where((n) {
      if (n.createdAt == null) return false;
      final notificationDate = DateTime(
        n.createdAt!.year,
        n.createdAt!.month,
        n.createdAt!.day,
      );
      return notificationDate.isAtSameMomentAs(today);
    }).toList();
  }

  /// Get notifications from this week
  List<Notification> getWeekNotifications() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _userNotifications.where((n) {
      if (n.createdAt == null) return false;
      return n.createdAt!.isAfter(weekAgo);
    }).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<Notification> getRecentNotifications() {
    final dayAgo = DateTime.now().subtract(const Duration(hours: 24));

    return _userNotifications.where((n) {
      if (n.createdAt == null) return false;
      return n.createdAt!.isAfter(dayAgo);
    }).toList();
  }

  // ==================== HELPER METHODS ====================

  /// Load user notifications
  Future<void> loadUserNotifications() async {
    await getUserNotifications();
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadUserNotifications();
  }

  /// Update unread count
  void _updateUnreadCount() {
    _unreadCount.value = _userNotifications.where((n) => !n.isSeen).length;
  }

  /// Clear all notifications
  void _clearAllNotifications() {
    _userNotifications.clear();
    _selectedNotification.value = null;
    _unreadCount.value = 0;
  }

  /// Set selected notification
  void setSelectedNotification(Notification? notification) {
    _selectedNotification.value = notification;

    // Auto-mark as seen when selected
    if (notification != null &&
        !notification.isSeen &&
        notification.id != null) {
      markNotificationAsSeen(notification.id!);
    }
  }

  /// Add new notification (for real-time updates via WebSocket/FCM)
  void addNotification(Notification notification) {
    _userNotifications.insert(0, notification);
    _updateUnreadCount();
  }

  /// Check if has unread notifications
  bool get hasUnreadNotifications => _unreadCount.value > 0;

  /// Get grouped notifications by date
  Map<String, List<Notification>> getGroupedNotificationsByDate() {
    final grouped = <String, List<Notification>>{};
    final now = DateTime.now();

    for (final notification in _userNotifications) {
      if (notification.createdAt == null) continue;

      String key;
      final diff = now.difference(notification.createdAt!);

      if (diff.inDays == 0) {
        key = 'Today';
      } else if (diff.inDays == 1) {
        key = 'Yesterday';
      } else if (diff.inDays < 7) {
        key = 'This Week';
      } else if (diff.inDays < 30) {
        key = 'This Month';
      } else {
        key = 'Older';
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(notification);
    }

    return grouped;
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
    _clearAllNotifications();
    super.onClose();
  }
}
