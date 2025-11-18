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

  // Streams
  Stream<List<Photo>> get creatorPhotosStream => _creatorPhotos.stream;
  Stream<List<Photo>> get trendingPhotosStream => _trendingPhotos.stream;
  Stream<Photo?> get selectedPhotoStream => _selectedPhoto.stream;
  Stream<bool> get uploadingStream => _isUploading.stream;
  Stream<double> get uploadProgressStream => _uploadProgress.stream;

  Future<PhotoService> init() async {
    await _initialize();
    return this;
  }

  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      if (_authService.isAuthenticated) {
        await loadCreatorPhotos();
      }

      _setupAuthListener();
    } catch (e) {
      print('PhotoService initialization error: $e');
    }
  }

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

  Future<ApiResponse<List<Photo>>> getTrendingPhotos() async {
    try {
      _isFetchingTrending.value = true;

      return await makeApiRequest<List<Photo>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getTrendingPhotos,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Photo.fromJson(e)).toList();
          }
          return <Photo>[];
        },
      );
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

  Future<void> loadTrendingPhotosWithIsolate() async {
    try {
      _isFetchingTrending.value = true;

      final token = _authService.authToken;
      if (token == null) {
        await getTrendingPhotos();
        return;
      }

      final params = {
        'url':
            '${ApiConfig.fullApiUrl}${ApiConfig.endpoints.getTrendingPhotos}',
        'token': token,
      };

      final result = await compute(_fetchTrendingPhotosIsolate, params);

      if (result['success'] == true && result['data'] != null) {
        final photos =
            (result['data'] as List)
                .map((json) => Photo.fromJson(json))
                .toList();

        _trendingPhotos.value = photos;
        print('Trending photos loaded via isolate: ${photos.length}');
      }
    } catch (e) {
      print('Error loading trending photos: $e');
      await getTrendingPhotos();
    } finally {
      _isFetchingTrending.value = false;
    }
  }

  Future<void> refreshTrendingPhotos() async {
    await loadTrendingPhotosWithIsolate();
  }

  void clearTrendingCache() {
    _trendingPhotos.clear();
  }

  // ==================== PHOTO CRUD ====================

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

  // ==================== FIXED UPLOAD WITH GOOGLE DRIVE TOKEN ====================

  /// ✅ FIXED: Upload photo with proper multipart handling and Google Drive token
  Future<ApiResponse<Photo>> uploadPhotoWithFile({
    required File file,
    double? price,
    PhotoMetadata? metadata,
  }) async {
    try {
      _isUploading.value = true;
      _uploadProgress.value = 0.0;

      print('📤 Starting photo upload...');

      // Validate file
      if (!await file.exists()) {
        print('❌ File does not exist: ${file.path}');
        return ApiResponse<Photo>(success: false, error: 'File does not exist');
      }

      final fileSize = await file.length();
      print('📁 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      if (fileSize > ApiConfig.maxFileSize) {
        print('❌ File too large: $fileSize bytes');
        return ApiResponse<Photo>(
          success: false,
          error:
              'File size exceeds ${ApiConfig.maxFileSize / 1024 / 1024} MB limit',
        );
      }

      // Get auth token
      final token = _authService.authToken;
      if (token == null) {
        print('❌ No auth token available');
        return ApiResponse<Photo>(
          success: false,
          error: 'Authentication required',
        );
      }

      // ✅ NEW: Get Google Drive access token if available
      String? googleAccessToken;
      if (_authService.isGoogleDriveConnected) {
        googleAccessToken = await _authService.getValidGoogleAccessToken();
        if (googleAccessToken != null) {
          print('✅ Using Google Drive access token for upload');
        } else {
          print('⚠️ Google Drive connected but token not available');
        }
      } else {
        print('ℹ️ Google Drive not connected');
      }

      final url = '${ApiConfig.fullApiUrl}${ApiConfig.endpoints.uploadPhoto}';
      print('📍 Upload URL: $url');

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll({'Authorization': 'Bearer $token'});

      print('🔑 Authorization header added');

      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        file.path,
      );

      request.files.add(multipartFile);
      print('📎 File added to request: ${file.path.split('/').last}');

      // Add price if provided
      if (price != null) {
        request.fields['price'] = price.toString();
        print('💰 Price added: $price');
      }

      // ✅ FIXED: Add metadata as JSON string
      if (metadata != null) {
        final metadataJson = jsonEncode(metadata.toJson());
        request.fields['metadata'] = metadataJson;
        print('📋 Metadata added: $metadataJson');
      }

      // ✅ NEW: Add Google Drive token if available
      if (googleAccessToken != null && googleAccessToken.isNotEmpty) {
        request.fields['idToken'] = googleAccessToken;
        print('🔐 Google Drive token added to request');
      }

      print('🚀 Sending upload request...');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response received: ${response.statusCode}');
      print(
        '📄 Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
      );

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonResponse = json.decode(response.body);
          print('✅ JSON parsed successfully');

          // ✅ FIXED: Handle multiple possible response structures
          dynamic photoData;

          if (jsonResponse is Map<String, dynamic>) {
            if (jsonResponse['data'] != null) {
              photoData = jsonResponse['data'];
              print('📦 Photo data found in "data" field');
            } else if (jsonResponse['photo'] != null) {
              photoData = jsonResponse['photo'];
              print('📦 Photo data found in "photo" field');
            } else if (jsonResponse['result'] != null) {
              photoData = jsonResponse['result'];
              print('📦 Photo data found in "result" field');
            } else if (jsonResponse['_id'] != null ||
                jsonResponse['id'] != null) {
              photoData = jsonResponse;
              print('📦 Response itself is photo data');
            }
          }

          if (photoData == null) {
            print('❌ Could not find photo data in response');
            print('Response structure: ${jsonResponse.keys.toList()}');
            return ApiResponse<Photo>(
              success: false,
              error: 'Invalid response structure from server',
              statusCode: response.statusCode,
            );
          }

          // Parse photo
          final photo = Photo.fromJson(photoData);
          print('✅ Photo parsed: ${photo.id}');

          // Update local state
          _creatorPhotos.insert(0, photo);
          print('✅ Photo added to creator photos list');

          // Refresh storage info
          await _authService.getStorageInfo();
          print('✅ Storage info refreshed');

          return ApiResponse<Photo>(
            success: true,
            data: photo,
            message: jsonResponse['message'] ?? 'Photo uploaded successfully',
            statusCode: response.statusCode,
          );
        } catch (e, stackTrace) {
          print('❌ Error parsing upload response: $e');
          print('Stack trace: $stackTrace');
          print('Response body: ${response.body}');

          return ApiResponse<Photo>(
            success: false,
            error: 'Failed to parse server response: $e',
            statusCode: response.statusCode,
          );
        }
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');

        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ?? errorData['error'] ?? 'Upload failed';
          print('❌ Error message: $errorMessage');

          return ApiResponse<Photo>(
            success: false,
            error: errorMessage,
            statusCode: response.statusCode,
          );
        } catch (e) {
          print('❌ Could not parse error response: $e');
          return ApiResponse<Photo>(
            success: false,
            error: 'Upload failed: HTTP ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Upload exception: $e');
      print('Stack trace: $stackTrace');

      return ApiResponse<Photo>(success: false, error: 'Upload failed: $e');
    } finally {
      _isUploading.value = false;
      _uploadProgress.value = 0.0;
    }
  }

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

  Future<void> loadCreatorPhotos() async {
    await getCreatorPhotos();
  }

  Future<void> refreshPhotos() async {
    await loadCreatorPhotos();
  }

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

  void _clearAllPhotos() {
    _creatorPhotos.clear();
    _trendingPhotos.clear();
    _photosByEvent.clear();
    _photosByFolder.clear();
    _selectedPhoto.value = null;
  }

  // ==================== API REQUEST ====================

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

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final responseData = response.body;

        dynamic dataToProcess;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            dataToProcess = responseData['data'];
          } else if (responseData.containsKey('results')) {
            dataToProcess = responseData['results'];
          } else {
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
                  ? fromJson(dataToProcess)
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

  Future<ApiResponse<DownloadStats>> getDownloadStats() async {
    try {
      final response = await makeApiRequest<DownloadStats>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getDownloadStats,
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            return DownloadStats.fromJson(json);
          }
          throw Exception('Invalid response format');
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<DownloadStats>(
        success: false,
        error: 'Failed to get download statistics: $e',
      );
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAllPhotos() async {
    try {
      final response = await makeApiRequest<List<Map<String, dynamic>>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getAllPhotos,
        fromJson: (json) {
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

      return response;
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        error: 'Failed to get photos: $e',
      );
    }
  }

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

      return response;
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        error: 'Failed to get user photos: $e',
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
    _clearAllPhotos();
    super.onClose();
  }
}
