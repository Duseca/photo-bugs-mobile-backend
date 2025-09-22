import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_bug/app/data/models/user_model.dart' as models;
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/models/auth_models.dart' as auth_models;
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  late final SharedPreferences _prefs;
  late final AppService _appService;

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _currentUserKey = 'current_user';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _firstTimeKey = 'first_time_user';

  // Reactive variables
  final Rx<models.User?> _currentUser = Rx<models.User?>(null);
  final Rx<String?> _authToken = Rx<String?>(null);
  final RxBool _isLoading = true.obs;
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isFirstTime = true.obs;
  final RxBool _onboardingCompleted = false.obs;

  // Getters
  models.User? get currentUser => _currentUser.value;
  String? get authToken => _authToken.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoggedIn => isAuthenticated && currentUser != null;
  bool get isFirstTime => _isFirstTime.value;
  bool get onboardingCompleted => _onboardingCompleted.value;
  bool get shouldShowOnboarding => isFirstTime && !onboardingCompleted;

  // Streams for reactive UI
  Stream<models.User?> get userStream => _currentUser.stream;
  Stream<bool> get authStateStream => _isAuthenticated.stream;

  // User role helpers
  bool get isPhotographer => hasRole('photographer');
  bool get isCreator => hasRole('creator');
  bool get isAdmin => hasRole('admin');
  bool get isEmailVerified => currentUser?.isEmailVerified ?? false;

  Future<AuthService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _appService = Get.find<AppService>();

      await _loadStoredAuth();
      await _loadOnboardingStatus();
      await _checkInitialAuth();
    } catch (e) {
      print('AuthService initialization error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load stored authentication data
  Future<void> _loadStoredAuth() async {
    try {
      final token = _appService.sharedPreferences.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        _authToken.value = token;
      }

      final userJson = _appService.sharedPreferences.getString(_currentUserKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser.value = models.User.fromJson(userMap);
      }

      _updateAuthState();
    } catch (e) {
      print('Error loading stored auth: $e');
      await cleanStorage();
    }
  }

  /// Load onboarding status from storage
  Future<void> _loadOnboardingStatus() async {
    _onboardingCompleted.value = _prefs.getBool(_onboardingKey) ?? false;
    _isFirstTime.value = _prefs.getBool(_firstTimeKey) ?? true;
  }

  /// Check initial authentication state
  Future<void> _checkInitialAuth() async {
    if (authToken != null && currentUser != null) {
      final isValid = await _validateToken();
      if (!isValid) {
        await logout();
      }
    }
  }

  // ==================== AUTHENTICATION FLOW ====================
  // Flow: Send Email → Verify Email → Register → Login

  /// Step 1: Send verification email
  Future<ApiResponse<dynamic>> sendVerificationEmail(String email) async {
    try {
      _isLoading.value = true;

      return await _makeApiRequest(
        method: 'POST',
        endpoint: ApiConfig.endpoints.sendEmail,
        data: {'email': email},
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to send verification email: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Step 2: Verify email with code (before registration)
  Future<ApiResponse<dynamic>> verifyEmailCode(
    String email,
    String code,
  ) async {
    try {
      _isLoading.value = true;

      return await _makeApiRequest(
        method: 'POST',
        endpoint: ApiConfig.endpoints.verifyEmail,
        data: {'email': email, 'code': code},
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Email verification failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Step 3: Register with full user data (after email verification)
  Future<ApiResponse<auth_models.AuthResponse>> register(
    auth_models.RegisterRequest request,
  ) async {
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
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Registration failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Login with email and password
  Future<ApiResponse<auth_models.AuthResponse>> login(
    auth_models.LoginRequest request,
  ) async {
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
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Login failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== USER PROFILE ====================

  /// Get current user from API server
  Future<ApiResponse<models.User>> getCurrentUser() async {
    try {
      final response = await _makeApiRequest<models.User>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.currentUser,
        fromJson: (json) => models.User.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveUser(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse<models.User>(
        success: false,
        error: 'Failed to get current user: $e',
      );
    }
  }

  /// Update user profile
  // In AuthService.updateUser()
  Future<ApiResponse<models.User>> updateUser(
    Map<String, dynamic> userData,
  ) async {
    print('Updating user with data: $userData');
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<models.User>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updateUser,
        data: userData,
        fromJson: (json) => models.User.fromJson(json),
      );

      print('API Response: ${response.success}');
      print('Response data: ${response.data?.toJson()}'); // ← Add this

      if (response.success && response.data != null) {
        await _saveUser(response.data!);
      }

      return response;
    } catch (e) {
      print('Error updating user: $e');
      return ApiResponse<models.User>(
        success: false,
        error: 'Failed to update user: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update password
  Future<ApiResponse<dynamic>> updatePassword(
    auth_models.UpdatePasswordRequest request,
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

  // ==================== STORAGE & FAVORITES ====================

  /// Get storage info
  Future<ApiResponse<auth_models.StorageInfo>> getStorageInfo() async {
    try {
      return await _makeApiRequest<auth_models.StorageInfo>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.userStorage,
        fromJson: (json) => auth_models.StorageInfo.fromJson(json),
      );
    } catch (e) {
      return ApiResponse<auth_models.StorageInfo>(
        success: false,
        error: 'Failed to get storage info: $e',
      );
    }
  }

  /// Purchase storage
  Future<ApiResponse<dynamic>> purchaseStorage(
    auth_models.PurchaseStorageRequest request,
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

  // ==================== ONBOARDING ====================

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
    await _prefs.setBool(_firstTimeKey, false);
    _onboardingCompleted.value = true;
    _isFirstTime.value = false;
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    await _prefs.remove(_onboardingKey);
    await _prefs.remove(_firstTimeKey);
    _onboardingCompleted.value = false;
    _isFirstTime.value = true;
  }

  // ==================== LOGOUT ====================

  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Call API logout endpoint if available
      try {
        await _makeApiRequest(method: 'POST', endpoint: '/api/auth/logout');
      } catch (e) {
        print('API logout error (non-critical): $e');
      }

      await cleanStorage();
      _resetAuthState();
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

  // ==================== HELPER METHODS ====================

  /// Update authentication state
  void _updateAuthState() {
    _isAuthenticated.value =
        authToken != null && authToken!.isNotEmpty && currentUser != null;
  }

  /// Handle successful authentication
  Future<void> _handleAuthSuccess(auth_models.AuthResponse authResponse) async {
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
  Future<void> _saveUser(models.User user) async {
    print('AuthService: Saving user: ${user.toJson()}');

    // IMPORTANT: Force the reactive update by setting to null first
    // This ensures the stream listeners are triggered
    _currentUser.value = null;

    // Small delay to ensure the null value is processed
    await Future.delayed(Duration.zero);

    // Now set the actual user data
    _currentUser.value = user;

    // Save to SharedPreferences
    final userJson = jsonEncode(user.toJson());
    await _appService.sharedPreferences.setString(_currentUserKey, userJson);

    print(
      'AuthService: User saved and stream updated with: ${_currentUser.value?.name}',
    );
  }

  /// Validate token with API server
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
  Future<ApiResponse<auth_models.AuthResponse>> _makeAuthRequest({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    return await _makeApiRequest<auth_models.AuthResponse>(
      method: 'POST',
      endpoint: endpoint,
      data: data,
      fromJson: (json) => auth_models.AuthResponse.fromJson(json),
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
}
