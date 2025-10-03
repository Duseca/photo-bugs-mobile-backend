// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/folder_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

class FolderService extends GetxService {
  static FolderService get instance => Get.find<FolderService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Folder> _userFolders = <Folder>[].obs;
  final RxMap<String, List<Folder>> _foldersByEvent =
      <String, List<Folder>>{}.obs;
  final Rx<Folder?> _selectedFolder = Rx<Folder?>(null);
  final RxBool _isLoading = false.obs;

  // Getters
  List<Folder> get userFolders => _userFolders;
  Folder? get selectedFolder => _selectedFolder.value;
  bool get isLoading => _isLoading.value;

  // Streams for reactive UI
  Stream<List<Folder>> get userFoldersStream => _userFolders.stream;
  Stream<Folder?> get selectedFolderStream => _selectedFolder.stream;

  Future<FolderService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('FolderService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (!isAuthenticated) {
        _clearAllFolders();
      }
    });
  }

  // ==================== FOLDER CRUD OPERATIONS ====================

  /// Create a new folder
  Future<ApiResponse<Folder>> createFolder(CreateFolderRequest request) async {
    try {
      _isLoading.value = true;

      // Validation
      if (request.name.trim().isEmpty) {
        return ApiResponse<Folder>(
          success: false,
          error: 'Folder name cannot be empty',
        );
      }

      final response = await _makeApiRequest<Folder>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createFolder,
        data: request.toJson(),
        fromJson: (json) => Folder.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Add to folders list
        _userFolders.insert(0, response.data!);

        // Clear event cache if folder is associated with an event
        if (request.eventId != null) {
          _foldersByEvent.remove(request.eventId);
        }

        print('Folder created successfully: ${response.data!.name}');
      }

      return response;
    } catch (e) {
      return ApiResponse<Folder>(
        success: false,
        error: 'Failed to create folder: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get folder by ID
  Future<ApiResponse<Folder>> getFolderById(String folderId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Folder>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.folderById(folderId),
        fromJson: (json) => Folder.fromJson(json),
      );

      if (response.success && response.data != null) {
        _selectedFolder.value = response.data;

        // Update in lists if exists
        _updateFolderInLists(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse<Folder>(
        success: false,
        error: 'Failed to get folder: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get folders by event
  Future<ApiResponse<List<Folder>>> getFoldersByEvent(String eventId) async {
    try {
      _isLoading.value = true;

      // Check cache first
      if (_foldersByEvent.containsKey(eventId)) {
        return ApiResponse<List<Folder>>(
          success: true,
          data: _foldersByEvent[eventId],
        );
      }

      final response = await _makeApiRequest<List<Folder>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.foldersByEvent(eventId),
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Folder.fromJson(e)).toList();
          }
          return <Folder>[];
        },
      );

      if (response.success && response.data != null) {
        // Cache the result
        _foldersByEvent[eventId] = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Folder>>(
        success: false,
        error: 'Failed to get folders for event: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update folder (generic update)
  Future<ApiResponse<Folder>> updateFolder(
    String folderId,
    Map<String, dynamic> updates,
  ) async {
    try {
      _isLoading.value = true;

      // Note: API might not have a generic update endpoint
      // You may need to use specific update methods based on what you're updating
      final response = await _makeApiRequest<Folder>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.folderById(folderId),
        data: updates,
        fromJson: (json) => Folder.fromJson(json),
      );

      if (response.success && response.data != null) {
        _updateFolderInLists(response.data!);
        print('Folder updated successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Folder>(
        success: false,
        error: 'Failed to update folder: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete folder
  Future<ApiResponse<dynamic>> deleteFolder(String folderId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.folderById(folderId),
      );

      if (response.success) {
        _removeFolderFromLists(folderId);

        if (_selectedFolder.value?.id == folderId) {
          _selectedFolder.value = null;
        }

        print('Folder deleted successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to delete folder: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== FOLDER INVITATION MANAGEMENT ====================

  /// Accept folder invitation
  Future<ApiResponse<dynamic>> acceptFolderInvitation(String folderId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.folderAccept(folderId),
      );

      if (response.success) {
        // Refresh folder to get updated status
        await getFolderById(folderId);
        print('Folder invitation accepted');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to accept folder invitation: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Decline folder invitation
  Future<ApiResponse<dynamic>> declineFolderInvitation(String folderId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.folderDecline(folderId),
      );

      if (response.success) {
        // Remove from lists or update status
        _removeFolderFromLists(folderId);
        print('Folder invitation declined');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to decline folder invitation: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== FOLDER CONTENT MANAGEMENT ====================

  /// Add photos to folder
  Future<ApiResponse<Folder>> addPhotosToFolder(
    String folderId,
    List<String> photoIds,
  ) async {
    try {
      final updates = {'photo_ids': photoIds};

      return await updateFolder(folderId, updates);
    } catch (e) {
      return ApiResponse<Folder>(
        success: false,
        error: 'Failed to add photos to folder: $e',
      );
    }
  }

  /// Add bundles to folder
  Future<ApiResponse<Folder>> addBundlesToFolder(
    String folderId,
    List<String> bundleIds,
  ) async {
    try {
      final updates = {'bundle_ids': bundleIds};

      return await updateFolder(folderId, updates);
    } catch (e) {
      return ApiResponse<Folder>(
        success: false,
        error: 'Failed to add bundles to folder: $e',
      );
    }
  }

  /// Add recipients to folder
  Future<ApiResponse<Folder>> addRecipientsToFolder(
    String folderId,
    List<FolderRecipient> recipients,
  ) async {
    try {
      final updates = {
        'recipients': recipients.map((r) => r.toJson()).toList(),
      };

      return await updateFolder(folderId, updates);
    } catch (e) {
      return ApiResponse<Folder>(
        success: false,
        error: 'Failed to add recipients to folder: $e',
      );
    }
  }

  // ==================== FOLDER FILTERING & GROUPING ====================

  /// Get folders by status
  List<Folder> getFoldersByStatus(FolderStatus status) {
    return _userFolders.where((folder) => folder.status == status).toList();
  }

  /// Get active folders
  List<Folder> getActiveFolders() {
    return getFoldersByStatus(FolderStatus.active);
  }

  /// Get archived folders
  List<Folder> getArchivedFolders() {
    return getFoldersByStatus(FolderStatus.archived);
  }

  /// Get folders for specific event (from cache)
  List<Folder> getCachedFoldersByEvent(String eventId) {
    return _foldersByEvent[eventId] ?? [];
  }

  /// Get folders with pending invitations
  List<Folder> getFoldersWithPendingInvitations() {
    return _userFolders.where((folder) {
      if (folder.recipients == null) return false;

      return folder.recipients!.any(
        (recipient) => recipient.status == RecipientStatus.pending,
      );
    }).toList();
  }

  /// Get folders where current user is recipient
  List<Folder> getFoldersAsRecipient() {
    if (_authService.currentUser == null) return [];

    final userId = _authService.currentUser!.id;
    final userEmail = _authService.currentUser!.email;

    return _userFolders.where((folder) {
      if (folder.recipients == null) return false;

      return folder.recipients!.any(
        (recipient) =>
            (recipient.userId == userId) || (recipient.email == userEmail),
      );
    }).toList();
  }

  /// Get folders where current user is creator
  List<Folder> getFoldersAsCreator() {
    if (_authService.currentUser == null) return [];

    final userId = _authService.currentUser!.id;

    return _userFolders.where((folder) => folder.creatorId == userId).toList();
  }

  // ==================== FOLDER STATISTICS ====================

  /// Get total number of photos across all folders
  int getTotalPhotosCount() {
    return _userFolders.fold<int>(
      0,
      (sum, folder) => sum + (folder.photoIds?.length ?? 0),
    );
  }

  /// Get total number of bundles across all folders
  int getTotalBundlesCount() {
    return _userFolders.fold<int>(
      0,
      (sum, folder) => sum + (folder.bundleIds?.length ?? 0),
    );
  }

  /// Get folder count by status
  Map<FolderStatus, int> getFolderCountByStatus() {
    final counts = <FolderStatus, int>{};

    for (final status in FolderStatus.values) {
      counts[status] = getFoldersByStatus(status).length;
    }

    return counts;
  }

  /// Get folder with most photos
  Folder? getFolderWithMostPhotos() {
    if (_userFolders.isEmpty) return null;

    return _userFolders.reduce((current, next) {
      final currentCount = current.photoIds?.length ?? 0;
      final nextCount = next.photoIds?.length ?? 0;
      return currentCount >= nextCount ? current : next;
    });
  }

  // ==================== SORTING ====================

  /// Sort folders by name
  List<Folder> sortFoldersByName(
    List<Folder> folders, {
    bool ascending = true,
  }) {
    final sorted = List<Folder>.from(folders);
    sorted.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sort folders by date (most recent first)
  List<Folder> sortFoldersByDate(
    List<Folder> folders, {
    bool descending = true,
  }) {
    final sorted = List<Folder>.from(folders);
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return descending
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });
    return sorted;
  }

  /// Sort folders by photo count
  List<Folder> sortFoldersByPhotoCount(
    List<Folder> folders, {
    bool descending = true,
  }) {
    final sorted = List<Folder>.from(folders);
    sorted.sort((a, b) {
      final countA = a.photoIds?.length ?? 0;
      final countB = b.photoIds?.length ?? 0;
      return descending ? countB.compareTo(countA) : countA.compareTo(countB);
    });
    return sorted;
  }

  // ==================== HELPER METHODS ====================

  /// Update folder in all lists
  void _updateFolderInLists(Folder updatedFolder) {
    // Update in user folders
    final index = _userFolders.indexWhere((f) => f.id == updatedFolder.id);
    if (index != -1) {
      _userFolders[index] = updatedFolder;
    } else {
      // Add if not exists
      _userFolders.add(updatedFolder);
    }

    // Update in event cache
    if (updatedFolder.eventId != null) {
      _foldersByEvent.remove(updatedFolder.eventId);
    }

    // Update selected folder
    if (_selectedFolder.value?.id == updatedFolder.id) {
      _selectedFolder.value = updatedFolder;
    }
  }

  /// Remove folder from all lists
  void _removeFolderFromLists(String folderId) {
    final folder = _userFolders.firstWhereOrNull((f) => f.id == folderId);

    _userFolders.removeWhere((f) => f.id == folderId);

    // Remove from event cache
    if (folder?.eventId != null) {
      _foldersByEvent.remove(folder!.eventId);
    }
  }

  /// Clear all folders
  void _clearAllFolders() {
    _userFolders.clear();
    _foldersByEvent.clear();
    _selectedFolder.value = null;
  }

  /// Set selected folder
  void setSelectedFolder(Folder? folder) {
    _selectedFolder.value = folder;
  }

  /// Clear event cache
  void clearEventCache(String eventId) {
    _foldersByEvent.remove(eventId);
  }

  /// Clear all caches
  void clearAllCaches() {
    _foldersByEvent.clear();
  }

  /// Refresh folders for an event
  Future<void> refreshFoldersForEvent(String eventId) async {
    _foldersByEvent.remove(eventId);
    await getFoldersByEvent(eventId);
  }

  /// Check if user has access to folder
  bool hasAccessToFolder(Folder folder) {
    if (_authService.currentUser == null) return false;

    final userId = _authService.currentUser!.id;
    final userEmail = _authService.currentUser!.email;

    // User is creator
    if (folder.creatorId == userId) return true;

    // User is recipient
    if (folder.recipients != null) {
      return folder.recipients!.any(
        (recipient) =>
            (recipient.userId == userId) ||
            (recipient.email == userEmail &&
                recipient.status == RecipientStatus.accepted),
      );
    }

    return false;
  }

  /// Check if user is folder creator
  bool isFolderCreator(String folderId) {
    if (_authService.currentUser == null) return false;

    final folder = _userFolders.firstWhereOrNull((f) => f.id == folderId);
    return folder?.creatorId == _authService.currentUser!.id;
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
    _clearAllFolders();
    super.onClose();
  }
}
