import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import 'package:photo_bug/app/data/models/portfolio_model.dart';
import 'package:photo_bug/app/services/auth/auth_service.dart';

class PortfolioService extends GetxService {
  static PortfolioService get instance => Get.find<PortfolioService>();

  late final AuthService _authService;

  // Reactive variables
  final Rx<Portfolio?> _userPortfolio = Rx<Portfolio?>(null);
  final RxMap<String, Portfolio> _portfolioCache = <String, Portfolio>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isUploading = false.obs;

  // Getters
  Portfolio? get userPortfolio => _userPortfolio.value;
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value;
  List<PortfolioMedia> get portfolioImages => _userPortfolio.value?.media ?? [];

  // Streams
  Stream<Portfolio?> get portfolioStream => _userPortfolio.stream;
  Stream<bool> get loadingStream => _isLoading.stream;

  Future<PortfolioService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _authService = Get.find<AuthService>();

      // Load user portfolio if authenticated
      if (_authService.isAuthenticated) {
        await loadUserPortfolio();
      }

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('PortfolioService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        loadUserPortfolio();
      } else {
        _clearPortfolio();
      }
    });
  }

  // ==================== PORTFOLIO CRUD OPERATIONS ====================

  /// Get user's own portfolio
  Future<ApiResponse<Portfolio>> getUserPortfolio() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<dynamic>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.getPortfolio,
        fromJson: (json) {
          if (json is List) {
            return json;
          }
          return [];
        },
      );

      if (response.success &&
          response.data != null &&
          response.data!.isNotEmpty) {
        final portfolioJson = response.data!.first;
        final portfolio = Portfolio.fromJson(portfolioJson);

        _userPortfolio.value = portfolio;
        print('✅ User portfolio loaded: ${portfolio.media.length} media items');

        return ApiResponse<Portfolio>(
          success: true,
          data: portfolio,
          message: 'Portfolio loaded successfully',
        );
      } else if (response.success &&
          (response.data == null || response.data!.isEmpty)) {
        print('ℹ️ No portfolio found for user');
        _userPortfolio.value = null;

        return ApiResponse<Portfolio>(
          success: true,
          data: null,
          message: 'No portfolio found',
        );
      }

      return ApiResponse<Portfolio>(
        success: false,
        error: response.error ?? 'Failed to get portfolio',
      );
    } catch (e) {
      print('❌ Exception in getUserPortfolio: $e');
      return ApiResponse<Portfolio>(
        success: false,
        error: 'Failed to get portfolio: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get portfolio by creator ID
  Future<ApiResponse<Portfolio>> getPortfolioByCreator(String creatorId) async {
    try {
      _isLoading.value = true;

      if (_portfolioCache.containsKey(creatorId)) {
        return ApiResponse<Portfolio>(
          success: true,
          data: _portfolioCache[creatorId],
        );
      }

      final response = await _makeApiRequest<Portfolio>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.portfolioByCreator(creatorId),
        fromJson: (json) => Portfolio.fromJson(json),
      );

      if (response.success && response.data != null) {
        _portfolioCache[creatorId] = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<Portfolio>(
        success: false,
        error: 'Failed to get portfolio: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create portfolio with image URLs
  Future<ApiResponse<Portfolio>> createPortfolio(
    CreatePortfolioRequest request,
  ) async {
    try {
      _isUploading.value = true;

      if (request.media.isEmpty) {
        return ApiResponse<Portfolio>(
          success: false,
          error: 'At least one image is required',
        );
      }

      final mediaList =
          request.media.map((m) {
            if (m.urls.isEmpty) {
              throw Exception('Each media item must include at least one URL');
            }
            return {
              'url': m.urls,
              'type': m.type.isNotEmpty ? m.type : 'image',
            };
          }).toList();

      final requestData = {'media': mediaList};

      print('📤 Creating portfolio with data: $requestData');

      final response = await _makeApiRequest<Portfolio>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createPortfolio,
        data: requestData,
        fromJson: (json) => Portfolio.fromJson(json),
      );

      if (response.success && response.data != null) {
        _userPortfolio.value = response.data;
        print(
          '✅ Portfolio created successfully with ${response.data!.media.length} media items',
        );
      } else {
        print('❌ Failed to create portfolio: ${response.error}');
      }

      return response;
    } catch (e) {
      print('❌ Exception in createPortfolio: $e');
      return ApiResponse<Portfolio>(
        success: false,
        error: 'Failed to create portfolio: $e',
      );
    } finally {
      _isUploading.value = false;
    }
  }

  /// Add image to existing portfolio - BULLETPROOF VERSION
  Future<ApiResponse<Portfolio>> addImageToPortfolio(String imageUrl) async {
    Portfolio? originalPortfolio;

    try {
      _isUploading.value = true;

      if (imageUrl.isEmpty) {
        return ApiResponse<Portfolio>(
          success: false,
          error: 'Image URL cannot be empty',
        );
      }

      // Store original portfolio for potential rollback
      originalPortfolio = _userPortfolio.value;
      final currentPortfolio = originalPortfolio;

      // Prepare media list by including ALL existing images + new one
      List<Map<String, dynamic>> mediaList;

      if (currentPortfolio == null || currentPortfolio.media.isEmpty) {
        print('📝 Creating new portfolio with first image');
        mediaList = [
          {
            'url': [imageUrl],
            'type': 'image',
          },
        ];
      } else {
        print(
          '📝 Adding to existing portfolio (${currentPortfolio.media.length} images)',
        );

        // CRITICAL: Include ALL existing images
        mediaList = [
          ...currentPortfolio.media.map((m) => {'url': m.urls, 'type': m.type}),
          {
            'url': [imageUrl],
            'type': 'image',
          },
        ];
      }

      final requestData = {'media': mediaList};
      final expectedCount = mediaList.length;

      print('📤 Adding image to portfolio: $imageUrl');
      print('📊 Total images in request: $expectedCount');

      // Make API call
      final response = await _makeApiRequest<dynamic>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createPortfolio,
        data: requestData,
      );

      print('🔍 POST Response Success: ${response.success}');
      print('🔍 POST Response Data: ${response.data}');

      // BULLETPROOF: Always fetch fresh data after POST
      // This handles all edge cases:
      // 1. API returns incomplete data
      // 2. API processes asynchronously
      // 3. Response structure differs from GET

      if (response.success) {
        print('✅ POST successful, fetching fresh portfolio data...');

        // Small delay to ensure server has processed
        await Future.delayed(Duration(milliseconds: 300));

        // Fetch the authoritative data
        final freshResponse = await getUserPortfolio();

        if (freshResponse.success && freshResponse.data != null) {
          final actualCount = freshResponse.data!.media.length;
          print('📊 Expected $expectedCount images, got $actualCount images');

          if (actualCount == expectedCount) {
            print('✅ Image added successfully - count matches!');
            return freshResponse;
          } else if (actualCount > (originalPortfolio?.media.length ?? 0)) {
            print(
              '⚠️ Image added but count mismatch (expected: $expectedCount, got: $actualCount)',
            );
            return freshResponse;
          } else {
            print('❌ Image count did not increase after add');
            return ApiResponse<Portfolio>(
              success: false,
              error: 'Failed to verify image was added',
            );
          }
        } else {
          print('❌ Failed to fetch fresh portfolio after POST');
          return ApiResponse<Portfolio>(
            success: false,
            error: 'Failed to verify image addition',
          );
        }
      } else {
        print('❌ POST request failed: ${response.error}');
        return ApiResponse<Portfolio>(
          success: false,
          error: response.error ?? 'Failed to add image',
        );
      }
    } catch (e) {
      print('❌ Exception in addImageToPortfolio: $e');

      // Rollback on error
      if (originalPortfolio != null) {
        _userPortfolio.value = originalPortfolio;
      }

      return ApiResponse<Portfolio>(
        success: false,
        error: 'Failed to add image: $e',
      );
    } finally {
      _isUploading.value = false;
    }
  }

  /// Delete portfolio
  Future<ApiResponse<dynamic>> deletePortfolio(String portfolioId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.deletePortfolio(portfolioId),
      );

      if (response.success) {
        if (_userPortfolio.value?.id == portfolioId) {
          _userPortfolio.value = null;
        }
        _portfolioCache.remove(portfolioId);
        print('✅ Portfolio deleted successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to delete portfolio: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete specific image from portfolio - BULLETPROOF VERSION
  Future<ApiResponse<Portfolio>> deleteImageFromPortfolio(
    String imageUrl,
  ) async {
    Portfolio? originalPortfolio;

    try {
      _isLoading.value = true;

      originalPortfolio = _userPortfolio.value;

      if (originalPortfolio == null) {
        return ApiResponse<Portfolio>(
          success: false,
          error: 'No portfolio found',
        );
      }

      print('🗑️ Attempting to remove image: $imageUrl');
      print(
        '📊 Current portfolio has: ${originalPortfolio.media.length} images',
      );

      // Remove the image from media list
      final updatedMedia =
          originalPortfolio.media.where((m) {
            final shouldKeep = !m.urls.contains(imageUrl) && m.url != imageUrl;
            if (!shouldKeep) {
              print('🎯 Found image to remove: ${m.url}');
            }
            return shouldKeep;
          }).toList();

      final expectedCount = updatedMedia.length;
      print('📊 After removal: $expectedCount images should remain');

      if (updatedMedia.isEmpty) {
        // Delete entire portfolio if no images left
        print('🗑️ Deleting entire portfolio (no images remaining)');
        await deletePortfolio(originalPortfolio.id);
        return ApiResponse<Portfolio>(
          success: true,
          message: 'Portfolio deleted (no images remaining)',
        );
      }

      // Update portfolio with remaining images
      final mediaList =
          updatedMedia.map((m) => {'url': m.urls, 'type': m.type}).toList();

      final requestData = {'media': mediaList};

      print('📤 Updating portfolio with $expectedCount images');

      // Make API call
      final response = await _makeApiRequest<dynamic>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createPortfolio,
        data: requestData,
      );

      print('🔍 POST Response Success: ${response.success}');

      // BULLETPROOF: Always fetch fresh data after POST
      if (response.success) {
        print('✅ POST successful, fetching fresh portfolio data...');

        // Small delay to ensure server has processed
        await Future.delayed(Duration(milliseconds: 300));

        // Fetch the authoritative data
        final freshResponse = await getUserPortfolio();

        if (freshResponse.success && freshResponse.data != null) {
          final actualCount = freshResponse.data!.media.length;
          print('📊 Expected $expectedCount images, got $actualCount images');

          if (actualCount == expectedCount) {
            print('✅ Image removed successfully - count matches!');
            return freshResponse;
          } else if (actualCount < originalPortfolio.media.length) {
            print(
              '⚠️ Image removed but count mismatch (expected: $expectedCount, got: $actualCount)',
            );
            return freshResponse;
          } else {
            print('❌ Image count did not decrease after delete');
            return ApiResponse<Portfolio>(
              success: false,
              error: 'Failed to verify image was removed',
            );
          }
        } else {
          print('❌ Failed to fetch fresh portfolio after POST');
          return ApiResponse<Portfolio>(
            success: false,
            error: 'Failed to verify image removal',
          );
        }
      } else {
        print('❌ POST request failed: ${response.error}');
        return ApiResponse<Portfolio>(
          success: false,
          error: response.error ?? 'Failed to delete image',
        );
      }
    } catch (e) {
      print('❌ Exception in deleteImageFromPortfolio: $e');

      // Rollback on error
      if (originalPortfolio != null) {
        _userPortfolio.value = originalPortfolio;
      }

      return ApiResponse<Portfolio>(
        success: false,
        error: 'Failed to delete image: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Upload image file to a cloud service and get URL
  Future<ApiResponse<String>> uploadImageFile(File imageFile) async {
    try {
      _isUploading.value = true;

      if (!await imageFile.exists()) {
        return ApiResponse<String>(
          success: false,
          error: 'File does not exist',
        );
      }

      final fileSize = await imageFile.length();
      if (fileSize > ApiConfig.maxFileSize) {
        return ApiResponse<String>(
          success: false,
          error: 'File size exceeds maximum allowed size',
        );
      }

      return ApiResponse<String>(
        success: false,
        error:
            'Image upload service not implemented. Please upload to Google Drive and use the URL',
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: 'Failed to upload image: $e',
      );
    } finally {
      _isUploading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Load user portfolio
  Future<void> loadUserPortfolio() async {
    await getUserPortfolio();
  }

  /// Refresh portfolio
  Future<void> refreshPortfolio() async {
    await loadUserPortfolio();
  }

  /// Clear portfolio
  void _clearPortfolio() {
    _userPortfolio.value = null;
    _portfolioCache.clear();
  }

  /// Clear cache for specific creator
  void clearCreatorCache(String creatorId) {
    _portfolioCache.remove(creatorId);
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

        dynamic dataToProcess;
        String? message;

        if (responseData is List) {
          dataToProcess = responseData;
          message = 'Success';
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            dataToProcess = responseData['data'];
          } else if (responseData.containsKey('results')) {
            dataToProcess = responseData['results'];
          } else if (responseData.containsKey('portfolio')) {
            dataToProcess = responseData['portfolio'];
          } else {
            dataToProcess = responseData;
          }
          message = responseData['message'];
        } else {
          dataToProcess = responseData;
        }

        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: message,
          data:
              fromJson != null && dataToProcess != null
                  ? fromJson(dataToProcess)
                  : dataToProcess,
          metadata: responseData is Map ? responseData['metadata'] : null,
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
      print('Response body: ${response.body}');
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
    _clearPortfolio();
    super.onClose();
  }
}
