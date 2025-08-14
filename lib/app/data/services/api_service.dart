import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:photo_bug/app/data/configs/api_configs.dart';
import 'package:photo_bug/app/data/models/api_response.dart';

/// Base API Service extending GetxService for dependency injection
/// Provides common HTTP methods and error handling for all API services
abstract class BaseApiService extends GetxService {
  late final http.Client _httpClient;

  // Authentication token reactive variable
  final Rx<String?> _authToken = Rx<String?>(null);
  String? get authToken => _authToken.value;
  set authToken(String? token) => _authToken.value = token;

  @override
  void onInit() {
    super.onInit();
    _httpClient = http.Client();
    _initializeService();
  }

  @override
  void onClose() {
    _httpClient.close();
    super.onClose();
  }

  /// Initialize service - override in child classes if needed
  void _initializeService() {
    // Load saved auth token if exists
    _loadAuthToken();
  }

  /// Load auth token from storage - implement in child class
  Future<void> _loadAuthToken() async {
    // Override in implementation to load from secure storage
  }

  /// Save auth token to storage - implement in child class
  Future<void> saveAuthToken(String token) async {
    authToken = token;
    // Override in implementation to save to secure storage
  }

  /// Clear auth token
  Future<void> clearAuthToken() async {
    authToken = null;
    // Override in implementation to clear from secure storage
  }

  /// Check if user is authenticated
  bool get isAuthenticated => authToken != null && authToken!.isNotEmpty;

  /// Get request headers
  Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final headers =
        isAuthenticated
            ? ApiConfig.authHeaders(authToken!)
            : ApiConfig.defaultHeaders;

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Build full URL
  String _buildUrl(String endpoint, {Map<String, dynamic>? queryParams}) {
    final url = Uri.parse('${ApiConfig.fullApiUrl}$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      return url
          .replace(
            queryParameters: queryParams.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          )
          .toString();
    }

    return url.toString();
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await _httpClient
          .get(Uri.parse(url), headers: _getHeaders(customHeaders: headers))
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final body = data != null ? jsonEncode(data) : null;

      final response = await _httpClient
          .post(
            Uri.parse(url),
            headers: _getHeaders(customHeaders: headers),
            body: body,
          )
          .timeout(ApiConfig.sendTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final body = data != null ? jsonEncode(data) : null;

      final response = await _httpClient
          .put(
            Uri.parse(url),
            headers: _getHeaders(customHeaders: headers),
            body: body,
          )
          .timeout(ApiConfig.sendTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = _buildUrl(endpoint);

      final response = await _httpClient
          .delete(Uri.parse(url), headers: _getHeaders(customHeaders: headers))
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Upload file with multipart request
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Function(int, int)? onProgress,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll(_getHeaders(customHeaders: headers));

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode;
      final responseBody = response.body;

      // Log response in development
      if (EnvironmentConfig.isDevelopment) {
        print('API Response [${response.statusCode}]: $responseBody');
      }

      // Parse JSON
      final Map<String, dynamic> jsonData =
          responseBody.isNotEmpty
              ? jsonDecode(responseBody)
              : <String, dynamic>{};

      // Handle successful responses
      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: jsonData['message'],
          data:
              fromJson != null && jsonData['data'] != null
                  ? fromJson(jsonData['data'])
                  : jsonData['data'],
          metadata: jsonData['metadata'],
        );
      }

      // Handle error responses
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        error: jsonData['message'] ?? jsonData['error'] ?? 'Unknown error',
        message: jsonData['message'],
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
    String errorCode;

    if (error is SocketException) {
      errorMessage = 'No internet connection';
      errorCode = ApiErrorCodes.networkError;
    } else if (error is HttpException) {
      errorMessage = 'HTTP error: ${error.message}';
      errorCode = ApiErrorCodes.serverError;
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'Request timeout';
      errorCode = ApiErrorCodes.timeoutError;
    } else {
      errorMessage = 'Unknown error: $error';
      errorCode = ApiErrorCodes.unknownError;
    }

    // Log error in development
    if (EnvironmentConfig.isDevelopment) {
      print('API Error: $errorMessage');
    }

    return ApiResponse<T>(success: false, error: errorMessage);
  }

  /// Retry mechanism for failed requests
  Future<ApiResponse<T>> _retryRequest<T>(
    Future<ApiResponse<T>> Function() request, {
    int maxAttempts = 3,
  }) async {
    ApiResponse<T>? lastResponse;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      lastResponse = await request();

      if (lastResponse.success || attempt == maxAttempts) {
        return lastResponse;
      }

      // Wait before retry
      await Future.delayed(ApiConfig.retryDelay * attempt);
    }

    return lastResponse!;
  }

  /// Get paginated data
  Future<PaginatedResponse<T>> getPaginated<T>(
    String endpoint, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final params = {'page': page, 'limit': limit, ...?queryParams};

    final response = await get(endpoint, queryParams: params);

    if (response.success && response.data != null) {
      return PaginatedResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } else {
      throw Exception(response.error ?? 'Failed to fetch paginated data');
    }
  }

  /// Check API health
  Future<bool> checkApiHealth() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
