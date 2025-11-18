// services/listing_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import 'package:photo_bug/app/data/models/photo_model.dart';
import '../auth/auth_service.dart';

class ListingService extends GetxService {
  static ListingService get instance => Get.find<ListingService>();

  late final AuthService _authService;

  // Reactive variables
  final RxList<Photo> _userListings = <Photo>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;

  // Getters
  List<Photo> get userListings => _userListings;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;

  // Streams
  Stream<List<Photo>> get listingsStream => _userListings.stream;
  Stream<bool> get loadingStream => _isLoading.stream;

  Future<ListingService> init() async {
    await _initialize();
    return this;
  }

  Future<void> _initialize() async {
    try {
      _authService = Get.find<AuthService>();

      // Load listings if authenticated
      if (_authService.isAuthenticated) {
        await loadUserListings();
      }

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('❌ ListingService initialization error: $e');
    }
  }

  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        loadUserListings();
      } else {
        _clearListings();
      }
    });
  }

  // ==================== GET USER LISTINGS (PHOTOS) ====================

  /// Get user's photos as listings
  /// Uses: GET {{baseUrl}}/api/photos
  Future<ApiResponse<List<Photo>>> getUserListings() async {
    try {
      _isLoading.value = true;

      print('🔄 Fetching user photos (listings)');

      final response = await makeApiRequest<List<Photo>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.photos,
        fromJson: (json) {
          print('📦 Raw response type: ${json.runtimeType}');

          List<dynamic> photosList;
          int total = 0;

          if (json is Map) {
            print('📦 Response is Map with keys: ${json.keys}');

            if (json.containsKey('totalPhotos')) {
              total = json['totalPhotos'] as int? ?? 0;
              print('✅ Total photos from API: $total');
            }

            if (json.containsKey('data')) {
              photosList = json['data'] as List;
            } else {
              photosList = [];
            }
          } else if (json is List) {
            photosList = json;
            total = photosList.length;
          } else {
            photosList = [];
          }

          print('✅ Listings loaded: ${photosList.length} photos');

          final photos = <Photo>[];
          for (var i = 0; i < photosList.length; i++) {
            try {
              final photo = Photo.fromJson(
                photosList[i] as Map<String, dynamic>,
              );
              photos.add(photo);
              print(
                '✅ Parsed photo ${i + 1}/${photosList.length}: ${photo.id}',
              );
            } catch (e) {
              print('⚠️ Error parsing photo at index $i: $e');
            }
          }

          print('✅ Successfully loaded ${photos.length} listings');
          return photos;
        },
      );

      if (response.success && response.data != null) {
        _userListings.value = response.data!;
        print('✅ User photos updated: ${_userListings.length} items');
      } else {
        print('❌ Failed to load listings: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error fetching listings: $e');
      return ApiResponse<List<Photo>>(
        success: false,
        error: 'Failed to get listings: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== GET LISTING BY ID ====================

  /// Get specific photo by ID
  /// Uses: GET {{baseUrl}}/api/photos/{{id}}
  Future<ApiResponse<Photo>> getListingById(String photoId) async {
    try {
      print('🔄 Fetching photo details: $photoId');

      final response = await makeApiRequest<Photo>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.photoById(photoId),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
        print('✅ Photo details loaded');
      } else {
        print('❌ Failed to load photo details: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error fetching photo details: $e');
      return ApiResponse<Photo>(
        success: false,
        error: 'Failed to get photo details: $e',
      );
    }
  }

  // ==================== CREATE LISTING (UPLOAD PHOTO) ====================

  /// Create a new listing (upload photo)
  /// Uses: POST {{baseUrl}}/api/photos
  Future<ApiResponse<Photo>> createListing(UploadPhotoRequest request) async {
    try {
      print('🔄 Creating new listing (uploading photo)');

      final response = await makeApiRequest<Photo>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.uploadPhoto,
        data: request.toJson(),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
        _userListings.insert(0, response.data!);
        print('✅ Photo uploaded successfully');
      } else {
        print('❌ Failed to upload photo: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error uploading photo: $e');
      return ApiResponse<Photo>(
        success: false,
        error: 'Failed to upload photo: $e',
      );
    }
  }

  // ==================== UPDATE LISTING ====================

  /// Update photo listing
  /// Uses: PUT {{baseUrl}}/api/photos/{{id}}
  Future<ApiResponse<Photo>> updateListing(
    String photoId,
    UpdatePhotoRequest request,
  ) async {
    try {
      print('🔄 Updating listing: $photoId');

      final response = await makeApiRequest<Photo>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updatePhoto(photoId),
        data: request.toJson(),
        fromJson: (json) => Photo.fromJson(json),
      );

      if (response.success && response.data != null) {
        _updateListingInCache(response.data!);
        print('✅ Photo updated successfully');
      } else {
        print('❌ Failed to update photo: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error updating photo: $e');
      return ApiResponse<Photo>(
        success: false,
        error: 'Failed to update photo: $e',
      );
    }
  }

  // ==================== DELETE LISTING ====================

  /// Delete photo listing
  /// Uses: DELETE {{baseUrl}}/api/photos/{{id}}
  Future<ApiResponse<void>> deleteListing(String photoId) async {
    try {
      print('🔄 Deleting listing: $photoId');

      final response = await makeApiRequest<void>(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.deletePhoto(photoId),
      );

      if (response.success) {
        _removeListingFromCache(photoId);
        print('✅ Photo deleted successfully');
      } else {
        print('❌ Failed to delete photo: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error deleting photo: $e');
      return ApiResponse<void>(
        success: false,
        error: 'Failed to delete photo: $e',
      );
    }
  }

  // ==================== SEARCH LISTINGS ====================

  /// Search photos
  /// Uses: GET {{baseUrl}}/api/photos/search-photos
  Future<ApiResponse<List<Photo>>> searchListings({
    String? creatorId,
    String? eventId,
    String? folderId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      print('🔄 Searching photos');

      // Build query parameters
      final queryParams = <String, String>{};
      if (creatorId != null) queryParams['created_by'] = creatorId;
      if (eventId != null) queryParams['event_id'] = eventId;
      if (folderId != null) queryParams['folder_id'] = folderId;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = '${ApiConfig.endpoints.searchPhotos}?$queryString';

      final response = await makeApiRequest<List<Photo>>(
        method: 'GET',
        endpoint: endpoint,
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => Photo.fromJson(item)).toList();
          } else if (json is Map && json['data'] is List) {
            return (json['data'] as List)
                .map((item) => Photo.fromJson(item))
                .toList();
          }
          return <Photo>[];
        },
      );

      if (response.success) {
        print('✅ Search completed: ${response.data?.length ?? 0} results');
      }

      return response;
    } catch (e) {
      print('❌ Error searching photos: $e');
      return ApiResponse<List<Photo>>(
        success: false,
        error: 'Failed to search photos: $e',
      );
    }
  }

  // ==================== HELPER METHODS ====================

  /// Load user listings
  Future<void> loadUserListings() async {
    await getUserListings();
  }

  /// Refresh listings
  Future<void> refreshListings() async {
    _isRefreshing.value = true;
    await getUserListings();
    _isRefreshing.value = false;
  }

  /// Update listing in cache
  void _updateListingInCache(Photo updatedPhoto) {
    final index = _userListings.indexWhere((p) => p.id == updatedPhoto.id);
    if (index != -1) {
      _userListings[index] = updatedPhoto;
    }
  }

  /// Remove listing from cache
  void _removeListingFromCache(String photoId) {
    _userListings.removeWhere((p) => p.id == photoId);
  }

  /// Clear all listings
  void _clearListings() {
    _userListings.clear();
  }

  /// Get listings count
  int get listingsCount => _userListings.length;

  /// Check if has listings
  bool get hasListings => _userListings.isNotEmpty;

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
      final token = _authService.authToken;

      if (token == null) {
        return ApiResponse<T>(success: false, error: 'Authentication required');
      }

      final headers = ApiConfig.authHeaders(token);

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(data),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(data),
          );
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('❌ API request error: $e');
      return ApiResponse<T>(success: false, error: 'Network error: $e');
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        final responseData = jsonDecode(response.body);

        dynamic dataToProcess;
        if (responseData is Map<String, dynamic>) {
          dataToProcess =
              responseData['data'] ?? responseData['results'] ?? responseData;
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
        );
      }

      final errorData = jsonDecode(response.body);
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        error: errorData['message'] ?? errorData['error'] ?? 'Unknown error',
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

  @override
  void onClose() {
    _clearListings();
    super.onClose();
  }
}
