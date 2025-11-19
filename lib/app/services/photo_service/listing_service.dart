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

  final RxList<Photo> _userListings = <Photo>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxInt _totalPhotos = 0.obs;

  List<Photo> get userListings => _userListings;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  int get totalPhotos => _totalPhotos.value;

  Stream<List<Photo>> get listingsStream => _userListings.stream;
  Stream<bool> get loadingStream => _isLoading.stream;

  Future<ListingService> init() async {
    await _initialize();
    return this;
  }

  Future<void> _initialize() async {
    try {
      _authService = Get.find<AuthService>();

      if (_authService.isAuthenticated) {
        await loadUserListings();
      }

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

  Future<ApiResponse<List<Photo>>> getUserListings() async {
    try {
      _isLoading.value = true;

      print('🔄 Fetching user photos (listings)');
      print('📍 Endpoint: ${ApiConfig.endpoints.photos}');
      print(
        '📍 Full URL: ${ApiConfig.fullApiUrl}${ApiConfig.endpoints.photos}',
      );

      final token = _authService.authToken;
      print('🔑 Token available: ${token != null ? "YES" : "NO"}');

      final response = await makeApiRequest<List<Photo>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.photos,
        fromJson: (json) {
          print('📦 Raw response received');
          print('📦 Response type: ${json.runtimeType}');

          List<dynamic> photosList = [];

          if (json is Map) {
            print('📦 Response is Map with keys: ${json.keys}');

            if (json.containsKey('totalPhotos')) {
              _totalPhotos.value = json['totalPhotos'] as int? ?? 0;
              print('✅ Total photos from API: ${_totalPhotos.value}');
            }

            if (json.containsKey('data') && json['data'] is List) {
              photosList = json['data'] as List;
              print('✅ Found data array with ${photosList.length} items');
            } else if (json.containsKey('photos') && json['photos'] is List) {
              photosList = json['photos'] as List;
              print('✅ Found photos array with ${photosList.length} items');
            } else if (json.containsKey('results') && json['results'] is List) {
              photosList = json['results'] as List;
              print('✅ Found results array with ${photosList.length} items');
            } else {
              print('❌ No data/photos/results array found');
              print('📦 Response structure: ${json.keys}');
            }
          } else if (json is List) {
            photosList = json;
            _totalPhotos.value = photosList.length;
            print('✅ Response is direct array with ${photosList.length} items');
          }

          print('🔄 Parsing ${photosList.length} photos...');

          final photos = <Photo>[];
          for (var i = 0; i < photosList.length; i++) {
            try {
              final photoData = photosList[i] as Map<String, dynamic>;
              final photo = Photo.fromJson(photoData);
              photos.add(photo);
            } catch (e) {
              print('❌ Error parsing photo at index $i: $e');
            }
          }

          print('✅ Successfully parsed ${photos.length} listings');
          return photos;
        },
      );

      if (response.success && response.data != null) {
        _userListings.value = response.data!;
        print('✅ User photos updated: ${_userListings.length} items');
      } else {
        print('❌ Failed to load listings: ${response.error}');
        print('❌ Status code: ${response.statusCode}');
      }

      return response;
    } catch (e, stackTrace) {
      print('❌ Error fetching listings: $e');
      print('❌ Stack trace: $stackTrace');
      return ApiResponse<List<Photo>>(
        success: false,
        error: 'Failed to get listings: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<ApiResponse<Photo>> getListingById(String photoId) async {
    try {
      print('🔄 Fetching photo details: $photoId');

      final response = await makeApiRequest<Photo>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.photoById(photoId),
        fromJson: (json) {
          if (json is Map && json.containsKey('data')) {
            return Photo.fromJson(json['data'] as Map<String, dynamic>);
          }
          return Photo.fromJson(json as Map<String, dynamic>);
        },
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

  Future<ApiResponse<Photo>> createListing(UploadPhotoRequest request) async {
    try {
      print('🔄 Creating new listing (uploading photo)');

      final response = await makeApiRequest<Photo>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.uploadPhoto,
        data: request.toJson(),
        fromJson: (json) {
          if (json is Map && json.containsKey('data')) {
            return Photo.fromJson(json['data'] as Map<String, dynamic>);
          }
          return Photo.fromJson(json as Map<String, dynamic>);
        },
      );

      if (response.success && response.data != null) {
        _userListings.insert(0, response.data!);
        _totalPhotos.value++;
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
        fromJson: (json) {
          if (json is Map && json.containsKey('data')) {
            return Photo.fromJson(json['data'] as Map<String, dynamic>);
          }
          return Photo.fromJson(json as Map<String, dynamic>);
        },
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

  Future<ApiResponse<void>> deleteListing(String photoId) async {
    try {
      print('🔄 Deleting listing: $photoId');

      final response = await makeApiRequest<void>(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.deletePhoto(photoId),
      );

      if (response.success) {
        _removeListingFromCache(photoId);
        _totalPhotos.value--;
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

  Future<ApiResponse<List<Photo>>> searchListings({
    String? creatorId,
    String? eventId,
    String? folderId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      print('🔄 Searching photos');

      final queryParams = <String, String>{};
      if (creatorId != null) queryParams['created_by'] = creatorId;
      if (eventId != null) queryParams['event_id'] = eventId;
      if (folderId != null) queryParams['folder_id'] = folderId;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint =
          queryString.isEmpty
              ? ApiConfig.endpoints.searchPhotos
              : '${ApiConfig.endpoints.searchPhotos}?$queryString';

      final response = await makeApiRequest<List<Photo>>(
        method: 'GET',
        endpoint: endpoint,
        fromJson: (json) {
          List<dynamic> photosList = [];

          if (json is List) {
            photosList = json;
          } else if (json is Map && json['data'] is List) {
            photosList = json['data'] as List;
          }

          return photosList
              .map((item) => Photo.fromJson(item as Map<String, dynamic>))
              .toList();
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

  Future<void> loadUserListings() async {
    await getUserListings();
  }

  Future<void> refreshListings() async {
    _isRefreshing.value = true;
    await getUserListings();
    _isRefreshing.value = false;
  }

  void _updateListingInCache(Photo updatedPhoto) {
    final index = _userListings.indexWhere((p) => p.id == updatedPhoto.id);
    if (index != -1) {
      _userListings[index] = updatedPhoto;
    }
  }

  void _removeListingFromCache(String photoId) {
    _userListings.removeWhere((p) => p.id == photoId);
  }

  void _clearListings() {
    _userListings.clear();
    _totalPhotos.value = 0;
  }

  int get listingsCount => _userListings.length;
  bool get hasListings => _userListings.isNotEmpty;

  Future<ApiResponse<T>> makeApiRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = '${ApiConfig.fullApiUrl}$endpoint';
      final token = _authService.authToken;

      print('🌐 Making $method request to: $url');

      if (token == null) {
        print('❌ No authentication token available');
        return ApiResponse<T>(success: false, error: 'Authentication required');
      }

      final headers = ApiConfig.authHeaders(token);
      print('📋 Request headers: ${headers.keys}');

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

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body length: ${response.body.length} bytes');

      return _handleResponse<T>(response, fromJson);
    } catch (e, stackTrace) {
      print('❌ API request error: $e');
      print('❌ Stack trace: $stackTrace');
      return ApiResponse<T>(success: false, error: 'Network error: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        if (response.body.isEmpty) {
          print('✅ Success with empty response');
          return ApiResponse<T>(success: true, statusCode: statusCode);
        }

        final responseData = jsonDecode(response.body);
        print('✅ Response decoded successfully');

        dynamic dataToProcess = responseData;
        String? message;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String?;

          // Try different data keys
          if (responseData.containsKey('data')) {
            dataToProcess = responseData['data'];
          } else if (responseData.containsKey('results')) {
            dataToProcess = responseData['results'];
          } else if (responseData.containsKey('photos')) {
            dataToProcess = responseData['photos'];
          } else {
            dataToProcess = responseData;
          }
        }

        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: message,
          data:
              fromJson != null && dataToProcess != null
                  ? fromJson(dataToProcess)
                  : dataToProcess,
        );
      }

      // Handle error responses
      print('❌ Error response: ${response.body}');
      final errorData = jsonDecode(response.body);
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        error: errorData['message'] ?? errorData['error'] ?? 'Unknown error',
      );
    } catch (e) {
      print('❌ Error parsing response: $e');
      print('❌ Response body: ${response.body}');
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
