// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:photo_bug/app/data/models/photo_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import 'package:photo_bug/app/models/download_model/download_model.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

// ==================== ISOLATE FUNCTION ====================
// This must be a top-level function for isolate to work
Future<Map<String, dynamic>> _fetchTrendingPhotosIsolate(
  Map<String, dynamic> params,
) async {
  try {
    final url = params['url'] as String;
    final token = params['token'] as String;

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = json.decode(response.body);

      return {
        'success': true,
        'data': jsonResponse['results'] ?? jsonResponse['data'] ?? [],
        'message': jsonResponse['message'],
        'total': jsonResponse['total'],
      };
    } else {
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'error': errorData['message'] ?? errorData['error'] ?? 'Unknown error',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    return {'success': false, 'error': 'Network error: $e'};
  }
}

class PhotoService extends GetxService {
  static PhotoService get instance => Get.find<PhotoService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Photo> _creatorPhotos = <Photo>[].obs;
  final RxList<Photo> _trendingPhotos = <Photo>[].obs;
  final RxMap<String, List<Photo>> _photosByEvent = <String, List<Photo>>{}.obs;
  final RxMap<String, List<Photo>> _photosByFolder =
      <String, List<Photo>>{}.obs;
  final Rx<Photo?> _selectedPhoto = Rx<Photo?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isUploading = false.obs;
  final RxBool _isFetchingTrending = false.obs;
  final RxDouble _uploadProgress = 0.0.obs;

  // Getters
  List<Photo> get creatorPhotos => _creatorPhotos;
  List<Photo> get trendingPhotos => _trendingPhotos;
  Photo? get selectedPhoto => _selectedPhoto.value;
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value;
  bool get isFetchingTrending => _isFetchingTrending.value;
  double get uploadProgress => _uploadProgress.value;

  // Streams for reactive UI
  Stream<List<Photo>> get creatorPhotosStream => _creatorPhotos.stream;
  Stream<List<Photo>> get trendingPhotosStream => _trendingPhotos.stream;
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

  // ==================== TRENDING PHOTOS ====================

  /// Get trending photos using isolate for background processing
  Future<ApiResponse<List<Photo>>> getTrendingPhotos() async {
    try {
      _isFetchingTrending.value = true;

      final response = await makeApiRequest<List<Photo>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getTrendingPhotos,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Photo.fromJson(e)).toList();
          }
          return <Photo>[];
        },
      );

      if (response.success && response.data != null) {
        _trendingPhotos.value = response.data!;
        print('Trending photos loaded: ${response.data!.length} photos');
      }

      return response;
    } catch (e) {
      print('Error fetching trending photos: $e');
      return ApiResponse<List<Photo>>(
        success: false,
        error: 'Failed to get trending photos: $e',
      );
    } finally {
      _isFetchingTrending.value = false;
    }
  }

  /// Load trending photos using isolate for better performance
  Future<void> loadTrendingPhotosWithIsolate() async {
    try {
      _isFetchingTrending.value = true;

      // Get auth token
      final token = _authService.authToken;
      if (token == null) {
        print('No auth token available for trending photos');
        // Try without auth for public trending photos
        await getTrendingPhotos();
        return;
      }

      // Prepare data for isolate
      final params = {
        'url':
            '${ApiConfig.fullApiUrl}${ApiConfig.endpoints.getTrendingPhotos}',
        'token': token,
      };

      // Run in isolate for background processing
      final result = await compute(_fetchTrendingPhotosIsolate, params);

      if (result['success'] == true && result['data'] != null) {
        final photos =
            (result['data'] as List)
                .map((json) => Photo.fromJson(json))
                .toList();

        _trendingPhotos.value = photos;
        print('Trending photos loaded via isolate: ${photos.length} photos');
      } else {
        print('Failed to load trending photos: ${result['error']}');
      }
    } catch (e) {
      print('Error loading trending photos with isolate: $e');
      // Fallback to normal loading
      await getTrendingPhotos();
    } finally {
      _isFetchingTrending.value = false;
    }
  }

  /// Refresh trending photos
  Future<void> refreshTrendingPhotos() async {
    await loadTrendingPhotosWithIsolate();
  }

  /// Clear trending photos cache
  void clearTrendingCache() {
    _trendingPhotos.clear();
  }

  // ==================== PHOTO CRUD OPERATIONS ====================

  /// Get all creator photos
  Future<ApiResponse<List<Photo>>> getCreatorPhotos() async {
    try {
      _isLoading.value = true;

      final response = await makeApiRequest<List<Photo>>(
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

      final response = await makeApiRequest<Photo>(
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

      final response = await makeApiRequest<Photo>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.uploadPhoto,
        data: request.toJson(),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
        _creatorPhotos.insert(0, response.data!);
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

      final fileSize = await file.length();
      if (fileSize > ApiConfig.maxFileSize) {
        return ApiResponse<Photo>(
          success: false,
          error: 'File size exceeds maximum allowed size',
        );
      }

      final url = '${ApiConfig.fullApiUrl}${ApiConfig.endpoints.uploadPhoto}';
      final token = _authService.authToken;
      print('Uploading photo to $token');

      if (token == null) {
        return ApiResponse<Photo>(
          success: false,
          error: 'Authentication required',
        );
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Changed from 'file' to 'image' to match API
          file.path,
        ),
      );

      // Add price if provided
      if (price != null) {
        request.fields['price'] = price.toString();
      }

      // Add metadata as JSON string if provided
      if (metadata != null) {
        request.fields['metadata'] = jsonEncode(metadata.toJson());
      }

      // Send request and get response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonResponse = json.decode(response.body);

          // Handle different response structures
          dynamic photoData;
          if (jsonResponse['data'] != null) {
            photoData = jsonResponse['data'];
          } else if (jsonResponse['photo'] != null) {
            photoData = jsonResponse['photo'];
          } else if (jsonResponse['result'] != null) {
            photoData = jsonResponse['result'];
          } else {
            // If no nested data, use the response itself
            photoData = jsonResponse;
          }

          final photo = Photo.fromJson(photoData);
          _creatorPhotos.insert(0, photo);
          await _authService.getStorageInfo();

          print('Photo uploaded successfully: ${photo.id}');

          return ApiResponse<Photo>(
            success: true,
            data: photo,
            message: jsonResponse['message'] ?? 'Photo uploaded successfully',
            statusCode: response.statusCode,
          );
        } catch (e) {
          print('Error parsing upload response: $e');
          print('Response body: ${response.body}');

          return ApiResponse<Photo>(
            success: false,
            error: 'Failed to parse upload response',
            statusCode: response.statusCode,
          );
        }
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Photo>(
          success: false,
          error: errorData['message'] ?? errorData['error'] ?? 'Upload failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Upload error: $e');
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

      final response = await makeApiRequest<Photo>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updatePhoto(photoId),
        data: request.toJson(),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
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

      final response = await makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.deletePhoto(photoId),
      );

      if (response.success) {
        _removePhotoFromLists(photoId);

        if (_selectedPhoto.value?.id == photoId) {
          _selectedPhoto.value = null;
        }

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
    final index = _creatorPhotos.indexWhere((p) => p.id == updatedPhoto.id);
    if (index != -1) {
      _creatorPhotos[index] = updatedPhoto;
    }

    if (updatedPhoto.eventId != null) {
      _photosByEvent.remove(updatedPhoto.eventId);
    }

    if (updatedPhoto.folderId != null) {
      _photosByFolder.remove(updatedPhoto.folderId);
    }

    if (_selectedPhoto.value?.id == updatedPhoto.id) {
      _selectedPhoto.value = updatedPhoto;
    }
  }

  /// Remove photo from all lists
  void _removePhotoFromLists(String photoId) {
    final photo = _creatorPhotos.firstWhereOrNull((p) => p.id == photoId);

    _creatorPhotos.removeWhere((p) => p.id == photoId);

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
    _trendingPhotos.clear();
    _photosByEvent.clear();
    _photosByFolder.clear();
    _selectedPhoto.value = null;
  }

  // ==================== API REQUEST METHOD ====================

  /// Generic API request method
  Future<ApiResponse<T>> makeApiRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = '${ApiConfig.fullApiUrl}$endpoint';
      Map<String, String> headers = {'Content-Type': 'application/json'};

      if (_authService.authToken != null) {
        headers = ApiConfig.authHeaders(_authService.authToken!);
      }

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

  /// Handle HTTP response - UPDATED VERSION
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final responseData = response.body;

        // Determine what data to process
        dynamic dataToProcess;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            dataToProcess = responseData['data'];
          } else if (responseData.containsKey('results')) {
            dataToProcess = responseData['results'];
          } else {
            // Use entire response for endpoints like download stats
            dataToProcess = responseData;
          }
        } else {
          dataToProcess = responseData;
        }

        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: responseData is Map ? responseData['message'] : null,
          data:
              fromJson != null && dataToProcess != null
                  ? fromJson(
                    dataToProcess,
                  ) // ✅ This calls your fromJson callback
                  : dataToProcess,
          metadata:
              responseData is Map
                  ? (responseData['metadata'] ??
                      {'total': responseData['total']})
                  : null,
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
      print('❌ Error parsing response: $e');
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get download statistics
  // Replace your current getDownloadStats() method with this exact code

  /// Get download statistics
  Future<ApiResponse<DownloadStats>> getDownloadStats() async {
    try {
      print(
        '🔄 Fetching download stats from: ${ApiConfig.endpoints.getDownloadStats}',
      );

      final response = await makeApiRequest<DownloadStats>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getDownloadStats,
        fromJson: (json) {
          print('📦 Parsing download stats JSON: $json');

          // The API returns data directly at root level
          if (json is Map<String, dynamic>) {
            try {
              final stats = DownloadStats.fromJson(json);
              print('✅ Successfully parsed DownloadStats');
              return stats;
            } catch (e) {
              print('❌ Error parsing DownloadStats: $e');
              rethrow;
            }
          }

          throw Exception(
            'Invalid response format: expected Map, got ${json.runtimeType}',
          );
        },
      );

      if (response.success && response.data != null) {
        print('✅ Download stats loaded successfully');
        print('Total downloads: ${response.data!.totalDownloads}');
        print('Monthly stats: ${response.data!.monthlyStats.length} months');
      } else {
        print('❌ Failed to load download stats: ${response.error}');
      }

      return response;
    } catch (e, stackTrace) {
      print('❌ Error in getDownloadStats: $e');
      print('Stack trace: $stackTrace');
      return ApiResponse<DownloadStats>(
        success: false,
        error: 'Failed to get download statistics: $e',
      );
    }
  }

  /// Get all photos (used for download statistics calculations)
  /// This will return all photos including from other creators
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllPhotos() async {
    try {
      final response = await makeApiRequest<List<Map<String, dynamic>>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getAllPhotos,
        fromJson: (json) {
          // Handle different response structures
          if (json is List) {
            return json.map((e) => e as Map<String, dynamic>).toList();
          } else if (json is Map) {
            if (json['data'] is List) {
              return (json['data'] as List)
                  .map((e) => e as Map<String, dynamic>)
                  .toList();
            } else if (json['results'] is List) {
              return (json['results'] as List)
                  .map((e) => e as Map<String, dynamic>)
                  .toList();
            }
          }
          return <Map<String, dynamic>>[];
        },
      );

      if (response.success) {
        print('✅ All photos loaded: ${response.data?.length ?? 0} photos');
      } else {
        print('❌ Failed to load all photos: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error in getAllPhotos: $e');
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        error: 'Failed to get photos: $e',
      );
    }
  }

  /// Get only the current user's photos (creator photos)
  /// This uses the creator-specific endpoint
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserPhotosAsMap() async {
    try {
      final response = await makeApiRequest<List<Map<String, dynamic>>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.creatorPhotos,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => e as Map<String, dynamic>).toList();
          } else if (json is Map && json['data'] is List) {
            return (json['data'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList();
          }
          return <Map<String, dynamic>>[];
        },
      );

      if (response.success) {
        print('✅ User photos loaded: ${response.data?.length ?? 0} photos');
      } else {
        print('❌ Failed to load user photos: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error in getUserPhotosAsMap: $e');
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        error: 'Failed to get user photos: $e',
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
