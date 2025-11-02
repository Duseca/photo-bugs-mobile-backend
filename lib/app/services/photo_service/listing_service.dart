// services/listing_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import 'package:photo_bug/app/models/listings_model/listings_model.dart';
import '../auth/auth_service.dart';

class ListingService extends GetxService {
  static ListingService get instance => Get.find<ListingService>();

  late final AuthService _authService;

  // Reactive variables
  final RxList<ListingItem> _userListings = <ListingItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;

  // Getters
  List<ListingItem> get userListings => _userListings;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;

  // Streams
  Stream<List<ListingItem>> get listingsStream => _userListings.stream;
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

  // ==================== GET USER LISTINGS ====================

  /// Get user's photo bundles (listings)
  /// Uses: GET {{baseUrl}}/api/photo-bundles/{{userId}}/user-photos
  Future<ApiResponse<List<ListingItem>>> getUserListings() async {
    try {
      _isLoading.value = true;

      // Get current user ID
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return ApiResponse<List<ListingItem>>(
          success: false,
          error: 'User not authenticated',
        );
      }

      print('🔄 Fetching listings for user: $userId');

      final response = await makeApiRequest<List<ListingItem>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getUserPhotos(userId),
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => ListingItem.fromJson(item)).toList();
          } else if (json is Map && json['data'] is List) {
            return (json['data'] as List)
                .map((item) => ListingItem.fromJson(item))
                .toList();
          }
          return <ListingItem>[];
        },
      );

      if (response.success && response.data != null) {
        _userListings.value = response.data!;
        print('✅ Listings loaded: ${response.data!.length} items');
      } else {
        print('❌ Failed to load listings: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error fetching listings: $e');
      return ApiResponse<List<ListingItem>>(
        success: false,
        error: 'Failed to get listings: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== GET LISTING BY ID ====================

  /// Get specific photo bundle by ID
  /// Uses: GET {{baseUrl}}/api/photo-bundles/{{id}}
  Future<ApiResponse<ListingItem>> getListingById(String listingId) async {
    try {
      print('🔄 Fetching listing details: $listingId');

      final response = await makeApiRequest<ListingItem>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getBundleById(listingId),
        fromJson: (json) => ListingItem.fromJson(json),
      );

      if (response.success && response.data != null) {
        print('✅ Listing details loaded: ${response.data!.title}');
      } else {
        print('❌ Failed to load listing details: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error fetching listing details: $e');
      return ApiResponse<ListingItem>(
        success: false,
        error: 'Failed to get listing details: $e',
      );
    }
  }

  // ==================== CREATE LISTING ====================

  /// Create a new photo bundle
  /// Uses: POST {{baseUrl}}/api/photo-bundles
  Future<ApiResponse<ListingItem>> createListing(
    CreateListingRequest request,
  ) async {
    try {
      print('🔄 Creating new listing: ${request.name}');

      final response = await makeApiRequest<ListingItem>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createPhotoBundle,
        data: request.toJson(),
        fromJson: (json) => ListingItem.fromJson(json),
      );

      if (response.success && response.data != null) {
        _userListings.insert(0, response.data!);
        print('✅ Listing created successfully');
      } else {
        print('❌ Failed to create listing: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error creating listing: $e');
      return ApiResponse<ListingItem>(
        success: false,
        error: 'Failed to create listing: $e',
      );
    }
  }

  // ==================== UPDATE LISTING ====================

  /// Update photo bundle
  /// Uses: PUT {{baseUrl}}/api/photo-bundles/{{id}}
  Future<ApiResponse<ListingItem>> updateListing(
    String listingId,
    UpdateListingRequest request,
  ) async {
    try {
      print('🔄 Updating listing: $listingId');

      final response = await makeApiRequest<ListingItem>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updatePhotoBundle(listingId),
        data: request.toJson(),
        fromJson: (json) => ListingItem.fromJson(json),
      );

      if (response.success && response.data != null) {
        _updateListingInCache(response.data!);
        print('✅ Listing updated successfully');
      } else {
        print('❌ Failed to update listing: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error updating listing: $e');
      return ApiResponse<ListingItem>(
        success: false,
        error: 'Failed to update listing: $e',
      );
    }
  }

  // ==================== DELETE LISTING ====================

  /// Delete photo bundle
  /// Uses: DELETE {{baseUrl}}/api/photo-bundles/{{id}}
  Future<ApiResponse<void>> deleteListing(String listingId) async {
    try {
      print('🔄 Deleting listing: $listingId');

      final response = await makeApiRequest<void>(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.deletePhotoBundle(listingId),
      );

      if (response.success) {
        _removeListingFromCache(listingId);
        print('✅ Listing deleted successfully');
      } else {
        print('❌ Failed to delete listing: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Error deleting listing: $e');
      return ApiResponse<void>(
        success: false,
        error: 'Failed to delete listing: $e',
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
  void _updateListingInCache(ListingItem updatedListing) {
    final index = _userListings.indexWhere((l) => l.id == updatedListing.id);
    if (index != -1) {
      _userListings[index] = updatedListing;
    }
  }

  /// Remove listing from cache
  void _removeListingFromCache(String listingId) {
    _userListings.removeWhere((l) => l.id == listingId);
  }

  /// Clear all listings
  void _clearListings() {
    _userListings.clear();
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
      final token = _authService.authToken;
      print('➡️ Making $token request to $url');

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

// ==================== REQUEST MODELS ====================

class CreateListingRequest {
  final String name;
  final double price;
  final String? folderId;
  final List<String> photoIds;
  final List<String>? bonusPhotoIds;
  final String? coverPhotoId;

  CreateListingRequest({
    required this.name,
    required this.price,
    this.folderId,
    required this.photoIds,
    this.bonusPhotoIds,
    this.coverPhotoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      if (folderId != null) 'folder_id': folderId,
      'photo_id': photoIds,
      if (bonusPhotoIds != null) 'bonus_photo_id': bonusPhotoIds,
      if (coverPhotoId != null) 'cover_photo_id': coverPhotoId,
    };
  }
}

class UpdateListingRequest {
  final String? name;
  final double? price;
  final String? folderId;
  final List<String>? photoIds;
  final List<String>? bonusPhotoIds;
  final String? coverPhotoId;

  UpdateListingRequest({
    this.name,
    this.price,
    this.folderId,
    this.photoIds,
    this.bonusPhotoIds,
    this.coverPhotoId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (name != null) map['name'] = name;
    if (price != null) map['price'] = price;
    if (folderId != null) map['folder_id'] = folderId;
    if (photoIds != null) map['photo_id'] = photoIds;
    if (bonusPhotoIds != null) map['bonus_photo_id'] = bonusPhotoIds;
    if (coverPhotoId != null) map['cover_photo_id'] = coverPhotoId;

    return map;
  }
}
