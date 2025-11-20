// CORRECTED VERSION - Google Sign-In v7.2.0
// GoogleSignInAuthentication ab sirf idToken provide karta hai
// accessToken ab directly available nahi hai

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/google_tokens_model.dart';
import 'package:photo_bug/app/services/auth/token_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_bug/app/data/models/user_model.dart' as models;
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/models/auth_models.dart' as auth_models;
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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

  // Google Drive specific
  final RxBool _isGoogleDriveConnected = false.obs;
  final Rx<GoogleTokens?> _googleTokens = Rx<GoogleTokens?>(null);

  // Getters
  models.User? get currentUser => _currentUser.value;
  String? get authToken => _authToken.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoggedIn => isAuthenticated && currentUser != null;
  bool get isFirstTime => _isFirstTime.value;
  bool get onboardingCompleted => _onboardingCompleted.value;
  bool get shouldShowOnboarding => isFirstTime && !onboardingCompleted;
  bool get isGoogleDriveConnected => _isGoogleDriveConnected.value;
  GoogleTokens? get googleTokens => _googleTokens.value;

  // Check if user needs Google Drive authorization
  bool get needsGoogleDriveAuth {
    if (currentUser?.googleTokens == null) return true;
    return currentUser!.googleTokens!.isExpired;
  }

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
      await _initializeGoogleSignIn();
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

        // Check Google Drive connection status
        if (_currentUser.value?.googleTokens != null) {
          _googleTokens.value = _currentUser.value!.googleTokens;
          _isGoogleDriveConnected.value =
              !_currentUser.value!.googleTokens!.isExpired;
        }
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

  /// Step 2: Verify email with code
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

  /// Step 3: Register with full user data
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
        _updateGoogleDriveStatus();
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
        _updateGoogleDriveStatus();
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
      if (response.data != null) {
        print('Response data: ${response.data?.toJson()}');
      }

      if (response.success && response.data != null) {
        await _saveUser(response.data!);
        _updateGoogleDriveStatus();
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

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
    await _prefs.setBool(_firstTimeKey, false);
    _onboardingCompleted.value = true;
    _isFirstTime.value = false;
  }

  Future<void> resetOnboarding() async {
    await _prefs.remove(_onboardingKey);
    await _prefs.remove(_firstTimeKey);
    _onboardingCompleted.value = false;
    _isFirstTime.value = true;
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await signOutFromSocialProviders();

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

  Future<void> cleanStorage() async {
    await Future.wait([
      _appService.sharedPreferences.remove(_tokenKey),
      _appService.sharedPreferences.remove(_currentUserKey),
      _appService.sharedPreferences.remove(_refreshTokenKey),
    ]);
  }

  void _resetAuthState() {
    _currentUser.value = null;
    _authToken.value = null;
    _isAuthenticated.value = false;
    _googleTokens.value = null;
    _isGoogleDriveConnected.value = false;
  }

  // ==================== HELPER METHODS ====================

  void _updateAuthState() {
    _isAuthenticated.value =
        authToken != null && authToken!.isNotEmpty && currentUser != null;
  }

  void _updateGoogleDriveStatus() {
    if (currentUser?.googleTokens != null) {
      _googleTokens.value = currentUser!.googleTokens;
      _isGoogleDriveConnected.value = !currentUser!.googleTokens!.isExpired;
    } else {
      _googleTokens.value = null;
      _isGoogleDriveConnected.value = false;
    }
  }

  Future<void> _handleAuthSuccess(auth_models.AuthResponse authResponse) async {
    if (authResponse.token != null) {
      await _saveToken(authResponse.token!);
    }

    if (authResponse.user != null) {
      await _saveUser(authResponse.user!);
    }

    _updateAuthState();
    _updateGoogleDriveStatus();
  }

  Future<void> _saveToken(String token) async {
    _authToken.value = token;
    await _appService.sharedPreferences.setString(_tokenKey, token);
  }

  Future<void> _saveUser(models.User user) async {
    print('AuthService: Saving user: ${user.toJson()}');

    _currentUser.value = null;
    await Future.delayed(Duration.zero);
    _currentUser.value = user;

    final userJson = jsonEncode(user.toJson());
    await _appService.sharedPreferences.setString(_currentUserKey, userJson);

    print('AuthService: User saved: ${_currentUser.value?.name}');
  }

  Future<bool> _validateToken() async {
    if (authToken == null) return false;

    try {
      final response = await getCurrentUser();
      return response.success;
    } catch (e) {
      return false;
    }
  }

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

  Future<void> refreshUserData() async {
    if (isAuthenticated) {
      await getCurrentUser();
    }
  }

  bool hasRole(String role) {
    return currentUser?.role == role;
  }

  bool get needsProfileCompletion {
    if (currentUser == null) return false;

    final user = currentUser!;

    return user.phone == '+1234567890' ||
        user.phone == null ||
        user.phone!.isEmpty ||
        user.address == null ||
        user.interests == null ||
        user.interests!.isEmpty ||
        user.gender == null ||
        user.gender!.isEmpty ||
        user.dateOfBirth == null;
  }

  // ==================== GOOGLE SIGN-IN V7.2.0 CORRECTED ====================

  GoogleSignIn? _googleSignIn;
  bool _isGoogleSignInInitialized = false;

  /// Initialize Google Sign-In - CORRECTED VERSION
  Future<void> _initializeGoogleSignIn() async {
    try {
      _googleSignIn = GoogleSignIn.instance;

      // Initialize call
      await _googleSignIn!.initialize();

      _isGoogleSignInInitialized = true;
      print('✅ Google Sign-In v7.2.0 initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Google Sign-In: $e');
      _isGoogleSignInInitialized = false;
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized || _googleSignIn == null) {
      await _initializeGoogleSignIn();
    }
  }

  /// Google Sign-In - CORRECTED VERSION
  /// Google Sign-In - CORRECTED VERSION WITH TOKEN DIALOG
  // Updated signInWithGoogle method with token generation
  Future<ApiResponse<auth_models.AuthResponse>> signInWithGoogle() async {
    String? accessToken;
    String? serverAuthCode;

    try {
      _isLoading.value = true;

      print('🔵 Step 1: Starting Google Sign-In');
      await _ensureGoogleSignInInitialized();

      if (!_isGoogleSignInInitialized || _googleSignIn == null) {
        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: 'Google Sign-In initialization failed',
        );
      }

      final scopes = [
        'email',
        'profile',
        'https://www.googleapis.com/auth/drive.file',
      ];

      GoogleSignInAccount? googleUser;

      try {
        googleUser = await _googleSignIn!.authenticate();

        print('✅ ============ GOOGLE USER DETAILS ============');
        print('✅ Google User ID: ${googleUser.id}');
        print('✅ Google Email: ${googleUser.email}');
        print('✅ Google Display Name: ${googleUser.displayName}');
        print('✅ Google Photo URL: ${googleUser.photoUrl}');
        print('✅ ===========================================');
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return ApiResponse<auth_models.AuthResponse>(
            success: false,
            error: 'Google sign-in was cancelled',
          );
        }

        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: 'Google sign-in failed: ${e.description}',
        );
      } catch (e) {
        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: 'Google sign-in failed: $e',
        );
      }

      if (googleUser == null) {
        print('❌ googleUser is null');
        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: 'Google sign-in failed - no user returned',
        );
      }

      print('🔵 Step 2: Getting authentication tokens');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get server auth code
      final GoogleSignInServerAuthorization? serverAuth = await googleUser
          .authorizationClient
          .authorizeServer(scopes);

      if (serverAuth != null && serverAuth.serverAuthCode != null) {
        serverAuthCode = serverAuth.serverAuthCode;
        print(
          '✅ Server Auth Code obtained: ${serverAuthCode!.substring(0, 20)}...',
        );
      } else {
        print('⚠️ Server Auth Code not available.');
        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: 'Failed to obtain server auth code',
        );
      }

      // Get access token
      try {
        final authorizedUser = await googleUser.authorizationClient
            .authorizeScopes(scopes);
        accessToken = authorizedUser.accessToken;

        if (accessToken != null && accessToken.length > 50) {
          print('✅ Access Token obtained: ${accessToken.substring(0, 50)}...');
        }
      } catch (e) {
        print('❌ Failed to get access token: $e');
      }

      final idToken = googleAuth.idToken ?? '';

      if (idToken.isEmpty) {
        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: 'Failed to get Google ID token',
        );
      }

      print('🔵 Step 3: Creating tokens object');
      // Create tokens object with the data we have
      final tokens = GoogleTokens(
        accessToken: accessToken ?? '',
        expiryDate:
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );

      final socialUserInfo = auth_models.SocialUserInfo(
        id: googleUser.id,
        provider: 'google',
        email: googleUser.email,
        name: googleUser.displayName ?? '',
        profilePicture: googleUser.photoUrl,
      );

      print('🔵 Step 4: Processing social authentication');
      final response = await _handleSocialAuthWithTokens(
        socialUserInfo,
        tokens,
      );

      // Step 5: After successful authentication, generate backend tokens
      if (response.success && serverAuthCode != null) {
        print('🔵 Step 5: User authenticated, now generating backend tokens');
        final tokenResponse = await _generateGoogleTokens(
          email: googleUser.email,
          serverAuthCode: serverAuthCode,
        );

        if (tokenResponse.success) {
          print('✅ Backend tokens generated and stored successfully');
          // Refresh user data to get the updated tokens from backend
          await refreshUserData();
        } else {
          print('⚠️ Backend token generation failed but user is authenticated');
        }
      }

      return response;
    } catch (e) {
      print('❌ Top-level error: $e');
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Google sign-in failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // NEW METHOD: Generate tokens from backend
  // NOTE: This must be called AFTER user is authenticated and has authToken
  Future<ApiResponse<dynamic>> _generateGoogleTokens({
    required String email,
    required String serverAuthCode,
  }) async {
    try {
      print('📤 Sending token generation request to backend');
      print('   Email: $email');
      print('   Server Auth Code: ${serverAuthCode.substring(0, 20)}...');
      print('   Auth Token available: ${authToken != null}');

      // This endpoint requires authentication, so we need authToken
      if (authToken == null) {
        print(
          '⚠️ Warning: No auth token available for generate-tokens endpoint',
        );
        print('⚠️ This call will be made after authentication completes');
        return ApiResponse<dynamic>(
          success: false,
          error: 'No authentication token available yet',
        );
      }

      final url =
          '${ApiConfig.fullApiUrl}${ApiConfig.endpoints.generateTokens}';
      final headers = ApiConfig.authHeaders(authToken!);

      print('📤 Request URL: $url');
      print('📤 Request Headers: $headers');

      final getConnect = GetConnect(timeout: ApiConfig.connectTimeout);

      final response = await getConnect.post(url, {
        'email': email,
        'serverAuthCode': serverAuthCode,
      }, headers: headers);

      print('📥 Backend response status: ${response.statusCode}');
      print('📥 Backend response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Token generation successful');

        return ApiResponse<dynamic>(
          success: true,
          statusCode: response.statusCode,
          data: response.body,
          message: 'Tokens generated successfully',
        );
      } else {
        final errorMessage =
            response.body is Map
                ? (response.body['message'] ??
                    response.body['error'] ??
                    'Token generation failed')
                : 'Token generation failed';

        print('❌ Token generation failed: $errorMessage');

        return ApiResponse<dynamic>(
          success: false,
          statusCode: response.statusCode,
          error: errorMessage,
        );
      }
    } catch (e) {
      print('❌ Token generation error: $e');
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to generate tokens: $e',
      );
    }
  }

  // Updated _handleSocialAuthWithTokens to include token generation
  Future<ApiResponse<auth_models.AuthResponse>> _handleSocialAuthWithTokens(
    auth_models.SocialUserInfo socialUserInfo,
    GoogleTokens tokens,
  ) async {
    try {
      // First, try to login with existing account
      final loginResponse = await _attemptSocialLogin(socialUserInfo);

      if (loginResponse.success && loginResponse.data != null) {
        print('✅ Existing Google user logged in');

        // Save tokens to backend
        final tokenSaveResponse = await _saveGoogleTokensToBackend(tokens);

        if (tokenSaveResponse.success) {
          // Refresh user data to get updated tokens from backend
          await refreshUserData();
          print(
            '✅ Google tokens updated and user data refreshed for existing user',
          );
        } else {
          print('⚠️ Failed to save Google tokens: ${tokenSaveResponse.error}');
        }

        return loginResponse;
      }

      // For new users, tokens are included in registration
      print('🔵 New user - proceeding with registration');
      return await _attemptSocialRegisterWithTokens(socialUserInfo, tokens);
    } catch (e) {
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Social authentication failed: $e',
      );
    }
  }

  /// Facebook Sign In
  Future<ApiResponse<auth_models.AuthResponse>> signInWithFacebook() async {
    try {
      _isLoading.value = true;

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        String errorMessage = 'Facebook sign-in failed';

        switch (result.status) {
          case LoginStatus.cancelled:
            errorMessage = 'Facebook sign-in was cancelled';
            break;
          case LoginStatus.failed:
            errorMessage = 'Facebook sign-in failed: ${result.message}';
            break;
          case LoginStatus.operationInProgress:
            errorMessage = 'Facebook sign-in is already in progress';
            break;
          default:
            errorMessage = 'Facebook sign-in failed with unknown error';
        }

        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: errorMessage,
        );
      }

      final Map<String, dynamic> userData = await FacebookAuth.instance
          .getUserData(
            fields: "name,email,picture.width(200),first_name,last_name",
          );

      if (userData.isEmpty) {
        return ApiResponse<auth_models.AuthResponse>(
          success: false,
          error: 'Failed to get user data from Facebook',
        );
      }

      final socialUserInfo = auth_models.SocialUserInfo.fromFacebookLogin({
        'id': userData['id'],
        'name': userData['name'],
        'email': userData['email'],
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
        'picture': userData['picture'],
      });

      return await _handleSocialAuth(socialUserInfo);
    } catch (e) {
      print('Facebook sign-in error: $e');
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Facebook sign-in failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<ApiResponse<auth_models.AuthResponse>> _handleSocialAuth(
    auth_models.SocialUserInfo socialUserInfo,
  ) async {
    try {
      final loginResponse = await _attemptSocialLogin(socialUserInfo);

      if (loginResponse.success) {
        print('Existing social user logged in successfully');
        return loginResponse;
      }

      print('New social user - attempting registration');
      return await _attemptSocialRegister(socialUserInfo);
    } catch (e) {
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Social authentication failed: $e',
      );
    }
  }

  Future<ApiResponse<auth_models.AuthResponse>> _attemptSocialLogin(
    auth_models.SocialUserInfo socialUserInfo,
  ) async {
    try {
      final request = auth_models.SocialLoginRequest(
        socialProvider: socialUserInfo.provider,
        socialId: socialUserInfo.id,
        deviceToken: await _getDeviceToken(),
      );

      final response = await _makeAuthRequest(
        endpoint: ApiConfig.endpoints.login,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        await _handleAuthSuccess(response.data!);
        print('Social login successful for existing user');
      }

      return response;
    } catch (e) {
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Social login failed: $e',
      );
    }
  }

  Future<ApiResponse<auth_models.AuthResponse>>
  _attemptSocialRegisterWithTokens(
    auth_models.SocialUserInfo socialUserInfo,
    GoogleTokens tokens,
  ) async {
    try {
      final request = auth_models.SocialRegisterRequest(
        name: socialUserInfo.name,
        userName: socialUserInfo.generatedUsername,
        email: socialUserInfo.email,
        phone: '+1234567890',
        deviceToken: await _getDeviceToken(),
        role: 'creator',
        profilePicture: socialUserInfo.profilePicture,
        socialProvider: socialUserInfo.provider,
        socialId: socialUserInfo.id,
      );

      final requestData = request.toJson();
      requestData['googleTokens'] = tokens.toJson();

      final response = await _makeAuthRequest(
        endpoint: ApiConfig.endpoints.register,
        data: requestData,
      );

      if (response.success && response.data != null) {
        await _handleAuthSuccess(response.data!);
        print('✅ Google registration successful with Drive tokens');
      }

      return response;
    } catch (e) {
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Social registration failed: $e',
      );
    }
  }

  Future<ApiResponse<auth_models.AuthResponse>> _attemptSocialRegister(
    auth_models.SocialUserInfo socialUserInfo,
  ) async {
    try {
      final request = auth_models.SocialRegisterRequest(
        name: socialUserInfo.name,
        userName: socialUserInfo.generatedUsername,
        email: socialUserInfo.email,
        phone: '+1234567890',
        deviceToken: await _getDeviceToken(),
        role: 'creator',
        profilePicture: socialUserInfo.profilePicture,
        socialProvider: socialUserInfo.provider,
        socialId: socialUserInfo.id,
      );

      final response = await _makeAuthRequest(
        endpoint: ApiConfig.endpoints.register,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        await _handleAuthSuccess(response.data!);
        print('Social registration successful');
      }

      return response;
    } catch (e) {
      return ApiResponse<auth_models.AuthResponse>(
        success: false,
        error: 'Social registration failed: $e',
      );
    }
  }

  // ==================== GOOGLE DRIVE AUTHORIZATION - CORRECTED ====================

  /// Authorize Google Drive for email/password users
  Future<ApiResponse<GoogleTokens>> authorizeGoogleDrive() async {
    try {
      _isLoading.value = true;

      await _ensureGoogleSignInInitialized();

      if (!_isGoogleSignInInitialized || _googleSignIn == null) {
        return ApiResponse<GoogleTokens>(
          success: false,
          error: 'Google Sign-In initialization failed',
        );
      }

      GoogleSignInAccount? googleUser;
      final scopes = [
        'email',
        'profile',
        'https://www.googleapis.com/auth/drive.file', // For Drive access
      ];

      try {
        // v7.2.0 authenticate() method - scopeHint parameter bhi available nahi hai
        // Scopes constructor mein already define hain
        googleUser = await _googleSignIn!.authenticate();
      } on GoogleSignInException catch (e) {
        print('Google Drive auth error: ${e.code.name} - ${e.description}');

        if (e.code == GoogleSignInExceptionCode.canceled) {
          return ApiResponse<GoogleTokens>(
            success: false,
            error: 'Google Drive authorization was cancelled',
          );
        }

        return ApiResponse<GoogleTokens>(
          success: false,
          error: 'Google Drive authorization failed: ${e.description}',
        );
      } catch (e) {
        return ApiResponse<GoogleTokens>(
          success: false,
          error: 'Google Drive authorization failed: $e',
        );
      }

      // ignore: unnecessary_null_comparison
      if (googleUser == null) {
        return ApiResponse<GoogleTokens>(
          success: false,
          error: 'Google Drive authorization failed',
        );
      }

      // Get authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      String? accessToken;
      try {
        final authorizedUser = await googleUser.authorizationClient
            .authorizeScopes(scopes);

        accessToken = authorizedUser.accessToken;

        // ignore: unnecessary_null_comparison
        if (accessToken != null && accessToken.length > 50) {
          print(
            '✅ Access Token (First 50 chars): ${accessToken.substring(0, 50)}...',
          );
        }
      } catch (e) {
        print('❌ Failed to get access token: $e');
      }
      final idToken = googleAuth.idToken ?? '';

      if (idToken.isEmpty) {
        return ApiResponse<GoogleTokens>(
          success: false,
          error: 'Failed to get Google ID token',
        );
      }

      // Create tokens object
      final tokens = GoogleTokens(
        accessToken: accessToken ?? '',

        expiryDate:
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );

      // Save to backend
      final saveResponse = await _saveGoogleTokensToBackend(tokens);

      if (saveResponse.success) {
        _googleTokens.value = tokens;
        _isGoogleDriveConnected.value = true;
        await refreshUserData();
        print('✅ Google Drive authorized successfully');
      }

      return saveResponse;
    } catch (e) {
      print('Google Drive authorization error: $e');
      return ApiResponse<GoogleTokens>(
        success: false,
        error: 'Google Drive authorization failed: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Save Google tokens to backend
  Future<ApiResponse<GoogleTokens>> _saveGoogleTokensToBackend(
    GoogleTokens tokens,
  ) async {
    try {
      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updateUser,
        data: {'googleTokens': tokens.toJson()},
      );

      if (response.success) {
        return ApiResponse<GoogleTokens>(
          success: true,
          data: tokens,
          message: 'Google tokens saved successfully',
        );
      } else {
        return ApiResponse<GoogleTokens>(
          success: false,
          error: response.error ?? 'Failed to save tokens',
        );
      }
    } catch (e) {
      return ApiResponse<GoogleTokens>(
        success: false,
        error: 'Failed to save Google tokens: $e',
      );
    }
  }

  /// Refresh Google Drive tokens
  Future<ApiResponse<GoogleTokens>> refreshGoogleDriveTokens() async {
    try {
      if (currentUser?.googleTokens == null) {
        return ApiResponse<GoogleTokens>(
          success: false,
          error: 'No Google tokens found. Please authorize Google Drive.',
        );
      }

      await _ensureGoogleSignInInitialized();
      final scopes = [
        'email',
        'profile',
        'https://www.googleapis.com/auth/drive.file', // For Drive access
      ];
      if (_googleSignIn == null) {
        return authorizeGoogleDrive();
      }

      // Try silent sign-in
      GoogleSignInAccount? googleUser =
          await _googleSignIn!.attemptLightweightAuthentication();

      if (googleUser == null) {
        // Silent sign-in failed, need interactive authorization
        return authorizeGoogleDrive();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken ?? '';
      String? accessToken;
      try {
        final authorizedUser = await googleUser.authorizationClient
            .authorizeScopes(scopes);

        accessToken = authorizedUser.accessToken;

        // ignore: unnecessary_null_comparison
        if (accessToken != null && accessToken.length > 50) {
          print(
            '✅ Access Token (First 50 chars): ${accessToken.substring(0, 50)}...',
          );
        }
      } catch (e) {
        print('❌ Failed to get access token: $e');
      }

      if (idToken.isEmpty) {
        return authorizeGoogleDrive();
      }

      final tokens = GoogleTokens(
        accessToken: accessToken ?? '',
        expiryDate:
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );

      final response = await _saveGoogleTokensToBackend(tokens);

      if (response.success) {
        _googleTokens.value = tokens;
        _isGoogleDriveConnected.value = true;
        await refreshUserData();
        print('✅ Google tokens refreshed');
      }

      return response;
    } catch (e) {
      print('Token refresh error: $e');
      return ApiResponse<GoogleTokens>(
        success: false,
        error: 'Failed to refresh tokens: $e',
      );
    }
  }

  /// Ensure Google Drive access is valid
  Future<bool> ensureGoogleDriveAccess() async {
    if (currentUser?.googleTokens == null) {
      print('❌ No Google tokens found - authorization needed');
      return false;
    }

    if (currentUser!.googleTokens!.isExpired) {
      print('⏰ Google tokens expired - refreshing...');
      final response = await refreshGoogleDriveTokens();
      return response.success;
    }

    _isGoogleDriveConnected.value = true;
    return true;
  }

  /// Get valid Google access token for API calls
  Future<String?> getValidGoogleAccessToken() async {
    try {
      final hasAccess = await ensureGoogleDriveAccess();

      if (!hasAccess) {
        print('❌ Google Drive access not available');
        return null;
      }

      if (currentUser?.googleTokens?.isExpired ?? true) {
        final refreshResponse = await refreshGoogleDriveTokens();
        if (!refreshResponse.success) {
          return null;
        }
      }

      return currentUser?.googleTokens?.accessToken;
    } catch (e) {
      print('Error getting Google access token: $e');
      return null;
    }
  }

  /// Disconnect Google Drive
  Future<void> disconnectGoogleDrive() async {
    try {
      await _googleSignIn?.signOut();

      await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updateUser,
        data: {'googleTokens': null},
      );

      _googleTokens.value = null;
      _isGoogleDriveConnected.value = false;

      await refreshUserData();

      print('✅ Google Drive disconnected');
    } catch (e) {
      print('Error disconnecting Google Drive: $e');
    }
  }

  /// Get device token
  Future<String?> _getDeviceToken() async {
    try {
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  /// Sign out from social providers
  Future<void> signOutFromSocialProviders() async {
    try {
      if (_isGoogleSignInInitialized && _googleSignIn != null) {
        try {
          await _googleSignIn!.signOut();
          print('✅ Signed out from Google');
        } catch (e) {
          print('Error signing out from Google: $e');
        }
      }

      try {
        await FacebookAuth.instance.logOut();
        print('✅ Signed out from Facebook');
      } catch (e) {
        print('Error signing out from Facebook: $e');
      }
    } catch (e) {
      print('Error signing out from social providers: $e');
    }
  }
}
