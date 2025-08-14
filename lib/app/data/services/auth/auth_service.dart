import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/models/auth_models.dart';
import 'package:photo_bug/app/data/models/user_model.dart';
import 'package:photo_bug/app/shared/locators/service_locator.dart';
import '../app/app_service.dart';

class AuthService extends GetxService {
  late final AppService _appService;

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _currentUserKey = 'current_user';
  static const String _refreshTokenKey = 'refresh_token';

  // Reactive variables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final Rx<String?> _authToken = Rx<String?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isAuthenticated = false.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  String? get authToken => _authToken.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoggedIn => isAuthenticated && currentUser != null;

  // Streams for reactive UI
  Stream<User?> get userStream => _currentUser.stream;
  Stream<bool> get authStateStream => _isAuthenticated.stream;

  Future<AuthService> init() async {
    await _init();
    return this;
  }

  @override
  void onReady() {
    super.onReady();
    _checkAuthState();
  }

  Future<void> _init() async {
    _appService = Get.find<AppService>();
    await _loadStoredAuth();
  }

  /// Load stored authentication data
  Future<void> _loadStoredAuth() async {
    try {
      // Load auth token
      final token = _appService.sharedPreferences.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        _authToken.value = token;
      }

      // Load current user
      final userJson = _appService.sharedPreferences.getString(_currentUserKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser.value = User.fromJson(userMap);
      }

      // Update authentication state
      _updateAuthState();
    } catch (e) {
      print('Error loading stored auth: $e');
      await cleanStorage();
    }
  }

  /// Check authentication state
  Future<void> _checkAuthState() async {
    if (authToken != null && currentUser != null) {
      // Validate token with server
      final isValid = await _validateToken();
      if (!isValid) {
        await logout();
      }
    }
  }

  /// Update authentication state
  void _updateAuthState() {
    _isAuthenticated.value =
        authToken != null && authToken!.isNotEmpty && currentUser != null;
  }

  /// Register new user
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      _isLoading.value = true;

      final response = await _makeAuthRequest(
        endpoint: ApiConfig.endpoints.register,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        await _handleAuthSuccess(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: 'Registration failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Login user
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      _isLoading.value = true;

      final response = await _makeAuthRequest(
        endpoint: ApiConfig.endpoints.login,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        await _handleAuthSuccess(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: 'Login failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verify email
  Future<ApiResponse<AuthResponse>> verifyEmail(
    EmailVerificationRequest request,
  ) async {
    try {
      _isLoading.value = true;

      return await _makeAuthRequest(
        endpoint: ApiConfig.endpoints.verifyEmail,
        data: request.toJson(),
      );
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: 'Email verification failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get current user from server
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _makeApiRequest<User>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.currentUser,
        fromJson: (json) => User.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveUser(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        error: 'Failed to get current user: $e',
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateUser(Map<String, dynamic> userData) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<User>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updateUser,
        data: userData,
        fromJson: (json) => User.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveUser(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        error: 'Failed to update user: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update password
  Future<ApiResponse<dynamic>> updatePassword(
    UpdatePasswordRequest request,
  ) async {
    try {
      _isLoading.value = true;

      return await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updatePassword,
        data: request.toJson(),
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to update password: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get storage info
  Future<ApiResponse<StorageInfo>> getStorageInfo() async {
    try {
      return await _makeApiRequest<StorageInfo>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.userStorage,
        fromJson: (json) => StorageInfo.fromJson(json),
      );
    } catch (e) {
      return ApiResponse<StorageInfo>(
        success: false,
        error: 'Failed to get storage info: $e',
      );
    }
  }

  /// Purchase storage
  Future<ApiResponse<dynamic>> purchaseStorage(
    PurchaseStorageRequest request,
  ) async {
    try {
      return await _makeApiRequest(
        method: 'POST',
        endpoint: ApiConfig.endpoints.purchaseStorage,
        data: request.toJson(),
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to purchase storage: $e',
      );
    }
  }

  /// Add user to favorites
  Future<ApiResponse<dynamic>> addFavorite(String userId) async {
    try {
      return await _makeApiRequest(
        method: 'POST',
        endpoint: ApiConfig.endpoints.userFavorites(userId),
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to add favorite: $e',
      );
    }
  }

  /// Remove user from favorites
  Future<ApiResponse<dynamic>> removeFavorite(String userId) async {
    try {
      return await _makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.userFavorites(userId),
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to remove favorite: $e',
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Call logout endpoint if available
      // await _makeApiRequest(method: 'POST', endpoint: '/logout');

      await cleanStorage();
      _resetAuthState();

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Clean storage
  Future<void> cleanStorage() async {
    await Future.wait([
      _appService.sharedPreferences.remove(_tokenKey),
      _appService.sharedPreferences.remove(_currentUserKey),
      _appService.sharedPreferences.remove(_refreshTokenKey),
    ]);
  }

  /// Reset authentication state
  void _resetAuthState() {
    _currentUser.value = null;
    _authToken.value = null;
    _isAuthenticated.value = false;
  }

  /// Handle successful authentication
  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    if (authResponse.token != null) {
      await _saveToken(authResponse.token!);
    }

    if (authResponse.user != null) {
      await _saveUser(authResponse.user!);
    }

    _updateAuthState();
  }

  /// Save authentication token
  Future<void> _saveToken(String token) async {
    _authToken.value = token;
    await _appService.sharedPreferences.setString(_tokenKey, token);
  }

  /// Save user data
  Future<void> _saveUser(User user) async {
    _currentUser.value = user;
    final userJson = jsonEncode(user.toJson());
    await _appService.sharedPreferences.setString(_currentUserKey, userJson);
  }

  /// Validate token with server
  Future<bool> _validateToken() async {
    if (authToken == null) return false;

    try {
      final response = await getCurrentUser();
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Make authentication request
  Future<ApiResponse<AuthResponse>> _makeAuthRequest({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    return await _makeApiRequest<AuthResponse>(
      method: 'POST',
      endpoint: endpoint,
      data: data,
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// Generic API request method
  Future<ApiResponse<T>> _makeApiRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = '${ApiConfig.fullApiUrl}$endpoint';
      final headers =
          authToken != null
              ? ApiConfig.authHeaders(authToken!)
              : ApiConfig.defaultHeaders;

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

      // Log response in development
      if (EnvironmentConfig.isDevelopment) {
        print('API Response [$statusCode]: ${response.bodyString}');
      }

      // Handle successful responses
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

      // Handle error responses
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

    // Log error in development
    if (EnvironmentConfig.isDevelopment) {
      print('API Error: $errorMessage');
    }

    return ApiResponse<T>(success: false, error: errorMessage);
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (isAuthenticated) {
      await getCurrentUser();
    }
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return currentUser?.role == role;
  }

  /// Check if user is photographer
  bool get isPhotographer => hasRole('photographer');

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');
}
