// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

class PhotoService extends GetxService {
  static PhotoService get instance => Get.find<PhotoService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Photo> _creatorPhotos = <Photo>[].obs;
  final RxMap<String, List<Photo>> _photosByEvent = <String, List<Photo>>{}.obs;
  final RxMap<String, List<Photo>> _photosByFolder =
      <String, List<Photo>>{}.obs;
  final Rx<Photo?> _selectedPhoto = Rx<Photo?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isUploading = false.obs;
  final RxDouble _uploadProgress = 0.0.obs;

  // Getters
  List<Photo> get creatorPhotos => _creatorPhotos;
  Photo? get selectedPhoto => _selectedPhoto.value;
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value;
  double get uploadProgress => _uploadProgress.value;

  // Streams for reactive UI
  Stream<List<Photo>> get creatorPhotosStream => _creatorPhotos.stream;
  Stream<Photo?> get selectedPhotoStream => _selectedPhoto.stream;
  Stream<bool> get uploadingStream => _isUploading.stream;
  Stream<double> get uploadProgressStream => _uploadProgress.stream;

  Future<PhotoService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      // Load creator photos if authenticated
      if (_authService.isAuthenticated) {
        await loadCreatorPhotos();
      }

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('PhotoService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        loadCreatorPhotos();
      } else {
        _clearAllPhotos();
      }
    });
  }

  // ==================== PHOTO CRUD OPERATIONS ====================

  /// Get all creator photos
  Future<ApiResponse<List<Photo>>> getCreatorPhotos() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Photo>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.creatorPhotos,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Photo.fromJson(e)).toList();
          }
          return <Photo>[];
        },
      );

      if (response.success && response.data != null) {
        _creatorPhotos.value = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Photo>>(
        success: false,
        error: 'Failed to get creator photos: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get photo by ID
  Future<ApiResponse<Photo>> getPhotoById(String photoId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Photo>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.photoById(photoId),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
        _selectedPhoto.value = response.data;
      }

      return response;
    } catch (e) {
      return ApiResponse<Photo>(
        success: false,
        error: 'Failed to get photo: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Upload a photo
  Future<ApiResponse<Photo>> uploadPhoto(UploadPhotoRequest request) async {
    try {
      _isUploading.value = true;
      _uploadProgress.value = 0.0;

      // Note: Actual file upload would use FormData with GetConnect
      // This is a simplified version - you'll need to implement proper file upload
      final response = await _makeApiRequest<Photo>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.uploadPhoto,
        data: request.toJson(),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Add to creator photos list
        _creatorPhotos.insert(0, response.data!);

        // Update storage usage if needed
        await _authService.getStorageInfo();

        print('Photo uploaded successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Photo>(
        success: false,
        error: 'Failed to upload photo: $e',
      );
    } finally {
      _isUploading.value = false;
      _uploadProgress.value = 0.0;
    }
  }

  /// Upload photo with file (proper multipart/form-data upload)
  Future<ApiResponse<Photo>> uploadPhotoWithFile({
    required File file,
    double? price,
    PhotoMetadata? metadata,
  }) async {
    try {
      _isUploading.value = true;
      _uploadProgress.value = 0.0;

      if (!await file.exists()) {
        return ApiResponse<Photo>(success: false, error: 'File does not exist');
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > ApiConfig.maxFileSize) {
        return ApiResponse<Photo>(
          success: false,
          error: 'File size exceeds maximum allowed size',
        );
      }

      final url = '${ApiConfig.fullApiUrl}${ApiConfig.endpoints.uploadPhoto}';
      final headers = ApiConfig.authHeaders(_authService.authToken!);

      final formData = FormData({
        'file': MultipartFile(file, filename: file.path.split('/').last),
        if (price != null) 'price': price.toString(),
        if (metadata != null) 'metadata': metadata.toJson(),
      });

      final getConnect = GetConnect(timeout: ApiConfig.sendTimeout);

      final response = await getConnect.post(
        url,
        formData,
        headers: headers,
        uploadProgress: (percent) {
          _uploadProgress.value = percent / 100;
        },
      );

      final apiResponse = _handleResponse<Photo>(
        response,
        (json) => Photo.fromJson(json),
      );

      if (apiResponse.success && apiResponse.data != null) {
        _creatorPhotos.insert(0, apiResponse.data!);
        await _authService.getStorageInfo();
        print('Photo uploaded successfully with file');
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse<Photo>(
        success: false,
        error: 'Failed to upload photo: $e',
      );
    } finally {
      _isUploading.value = false;
      _uploadProgress.value = 0.0;
    }
  }

  /// Update photo
  Future<ApiResponse<Photo>> updatePhoto(
    String photoId,
    UpdatePhotoRequest request,
  ) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Photo>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updatePhoto(photoId),
        data: request.toJson(),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Update in lists
        _updatePhotoInLists(response.data!);
        print('Photo updated successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Photo>(
        success: false,
        error: 'Failed to update photo: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete photo
  Future<ApiResponse<dynamic>> deletePhoto(String photoId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.deletePhoto(photoId),
      );

      if (response.success) {
        // Remove from lists
        _removePhotoFromLists(photoId);

        if (_selectedPhoto.value?.id == photoId) {
          _selectedPhoto.value = null;
        }

        // Update storage usage
        await _authService.getStorageInfo();

        print('Photo deleted successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to delete photo: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== PHOTO FILTERING & GROUPING ====================

  /// Get photos by event
  List<Photo> getPhotosByEvent(String eventId) {
    if (_photosByEvent.containsKey(eventId)) {
      return _photosByEvent[eventId]!;
    }

    final photos =
        _creatorPhotos.where((photo) => photo.eventId == eventId).toList();

    _photosByEvent[eventId] = photos;
    return photos;
  }

  /// Get photos by folder
  List<Photo> getPhotosByFolder(String folderId) {
    if (_photosByFolder.containsKey(folderId)) {
      return _photosByFolder[folderId]!;
    }

    final photos =
        _creatorPhotos.where((photo) => photo.folderId == folderId).toList();

    _photosByFolder[folderId] = photos;
    return photos;
  }

  /// Get photos by status
  List<Photo> getPhotosByStatus(PhotoStatus status) {
    return _creatorPhotos.where((photo) => photo.status == status).toList();
  }

  /// Get active photos
  List<Photo> getActivePhotos() {
    return getPhotosByStatus(PhotoStatus.active);
  }

  /// Get archived photos
  List<Photo> getArchivedPhotos() {
    return getPhotosByStatus(PhotoStatus.archived);
  }

  /// Get photos by price range
  List<Photo> getPhotosByPriceRange({double? minPrice, double? maxPrice}) {
    return _creatorPhotos.where((photo) {
      if (photo.price == null) return false;

      if (minPrice != null && photo.price! < minPrice) return false;
      if (maxPrice != null && photo.price! > maxPrice) return false;

      return true;
    }).toList();
  }

  /// Get free photos
  List<Photo> getFreePhotos() {
    return _creatorPhotos
        .where((photo) => photo.price == null || photo.price == 0)
        .toList();
  }

  /// Get paid photos
  List<Photo> getPaidPhotos() {
    return _creatorPhotos
        .where((photo) => photo.price != null && photo.price! > 0)
        .toList();
  }

  // ==================== SORTING ====================

  /// Sort photos by date (most recent first)
  List<Photo> sortPhotosByDate(List<Photo> photos, {bool descending = true}) {
    final sorted = List<Photo>.from(photos);
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return descending
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });
    return sorted;
  }

  /// Sort photos by price
  List<Photo> sortPhotosByPrice(List<Photo> photos, {bool descending = true}) {
    final sorted = List<Photo>.from(photos);
    sorted.sort((a, b) {
      final priceA = a.price ?? 0;
      final priceB = b.price ?? 0;
      return descending ? priceB.compareTo(priceA) : priceA.compareTo(priceB);
    });
    return sorted;
  }

  /// Sort photos by file size
  List<Photo> sortPhotosBySize(List<Photo> photos, {bool descending = true}) {
    final sorted = List<Photo>.from(photos);
    sorted.sort((a, b) {
      final sizeA = a.metadata?.fileSize ?? 0;
      final sizeB = b.metadata?.fileSize ?? 0;
      return descending ? sizeB.compareTo(sizeA) : sizeA.compareTo(sizeB);
    });
    return sorted;
  }

  // ==================== STATISTICS ====================

  /// Get total storage used by photos
  int getTotalStorageUsed() {
    return _creatorPhotos.fold<int>(
      0,
      (sum, photo) => sum + (photo.metadata?.fileSize ?? 0),
    );
  }

  /// Get total revenue potential
  double getTotalRevenuePotential() {
    return _creatorPhotos.fold<double>(
      0.0,
      (sum, photo) => sum + (photo.price ?? 0),
    );
  }

  /// Get photo count by status
  Map<PhotoStatus, int> getPhotoCountByStatus() {
    final counts = <PhotoStatus, int>{};

    for (final status in PhotoStatus.values) {
      counts[status] = getPhotosByStatus(status).length;
    }

    return counts;
  }

  /// Get average photo price
  double getAveragePhotoPrice() {
    final paidPhotos = getPaidPhotos();
    if (paidPhotos.isEmpty) return 0.0;

    final total = paidPhotos.fold<double>(
      0.0,
      (sum, photo) => sum + (photo.price ?? 0),
    );

    return total / paidPhotos.length;
  }

  // ==================== BATCH OPERATIONS ====================

  /// Delete multiple photos
  Future<ApiResponse<Map<String, dynamic>>> deleteMultiplePhotos(
    List<String> photoIds,
  ) async {
    try {
      _isLoading.value = true;

      final results = <String, bool>{};
      int successCount = 0;
      int failCount = 0;

      for (final photoId in photoIds) {
        final response = await deletePhoto(photoId);
        results[photoId] = response.success;

        if (response.success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        success: failCount == 0,
        data: {
          'total': photoIds.length,
          'success': successCount,
          'failed': failCount,
          'results': results,
        },
        message: 'Deleted $successCount of ${photoIds.length} photos',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Failed to delete multiple photos: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update price for multiple photos
  Future<ApiResponse<Map<String, dynamic>>> updateMultiplePhotosPrices(
    List<String> photoIds,
    double newPrice,
  ) async {
    try {
      _isLoading.value = true;

      final results = <String, bool>{};
      int successCount = 0;
      int failCount = 0;

      for (final photoId in photoIds) {
        final request = UpdatePhotoRequest(price: newPrice);
        final response = await updatePhoto(photoId, request);
        results[photoId] = response.success;

        if (response.success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        success: failCount == 0,
        data: {
          'total': photoIds.length,
          'success': successCount,
          'failed': failCount,
          'results': results,
        },
        message: 'Updated $successCount of ${photoIds.length} photos',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Failed to update multiple photos: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Load creator photos
  Future<void> loadCreatorPhotos() async {
    await getCreatorPhotos();
  }

  /// Refresh photos
  Future<void> refreshPhotos() async {
    await loadCreatorPhotos();
  }

  /// Update photo in all lists
  void _updatePhotoInLists(Photo updatedPhoto) {
    // Update in creator photos
    final index = _creatorPhotos.indexWhere((p) => p.id == updatedPhoto.id);
    if (index != -1) {
      _creatorPhotos[index] = updatedPhoto;
    }

    // Update in cached event photos
    if (updatedPhoto.eventId != null) {
      _photosByEvent.remove(updatedPhoto.eventId);
    }

    // Update in cached folder photos
    if (updatedPhoto.folderId != null) {
      _photosByFolder.remove(updatedPhoto.folderId);
    }

    // Update selected photo
    if (_selectedPhoto.value?.id == updatedPhoto.id) {
      _selectedPhoto.value = updatedPhoto;
    }
  }

  /// Remove photo from all lists
  void _removePhotoFromLists(String photoId) {
    final photo = _creatorPhotos.firstWhereOrNull((p) => p.id == photoId);

    _creatorPhotos.removeWhere((p) => p.id == photoId);

    // Remove from cached lists
    if (photo?.eventId != null) {
      _photosByEvent.remove(photo!.eventId);
    }

    if (photo?.folderId != null) {
      _photosByFolder.remove(photo!.folderId);
    }
  }

  /// Clear all photos
  void _clearAllPhotos() {
    _creatorPhotos.clear();
    _photosByEvent.clear();
    _photosByFolder.clear();
    _selectedPhoto.value = null;
  }

  /// Set selected photo
  void setSelectedPhoto(Photo? photo) {
    _selectedPhoto.value = photo;
  }

  /// Clear cache for event
  void clearEventCache(String eventId) {
    _photosByEvent.remove(eventId);
  }

  /// Clear cache for folder
  void clearFolderCache(String folderId) {
    _photosByFolder.remove(folderId);
  }

  /// Clear all caches
  void clearAllCaches() {
    _photosByEvent.clear();
    _photosByFolder.clear();
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
    _clearAllPhotos();
    super.onClose();
  }
}
