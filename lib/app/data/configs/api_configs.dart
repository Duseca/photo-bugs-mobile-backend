import 'dart:io';

/// API Configuration class for Photo Bug application
/// Manages all API endpoints, configurations, and environment settings
class ApiConfig {
  // Private constructor for singleton pattern
  ApiConfig._internal();
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;

  // Base URL - Updated to match your Postman collection
  static const String baseUrl = 'https://photo-bugs-custom-backend.vercel.app';

  // API versioning
  static const String apiVersion = 'v1';
  static String get apiPrefix => '/api';
  static String get fullApiUrl => '$baseUrl$apiPrefix';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
    'X-API-Version': apiVersion,
    'X-Platform': Platform.isAndroid ? 'android' : 'ios',
  };

  // Authentication headers
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    HttpHeaders.authorizationHeader: 'Bearer $token',
  };

  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File upload configurations
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
  ];

  // Cache configurations
  static const Duration cacheMaxAge = Duration(minutes: 5);
  static const Duration cacheStaleWhileRevalidate = Duration(minutes: 10);

  // Retry configurations
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // API Endpoints
  static const _ApiEndpoints endpoints = _ApiEndpoints();
}

/// API Endpoints configuration - Updated to match Postman collection
class _ApiEndpoints {
  const _ApiEndpoints();

  // Base endpoints
  String get users => '/users';
  String get notifications => '/notifications';
  String get chats => '/chats';
  String get events => '/events';
  String get reviews => '/reviews';
  String get folders => '/folders';
  String get photos => '/photos';
  String get photoBundles => '/photo-bundles';
  String get transactions => '/transactions';

  // User endpoints - Updated with send-email endpoint
  String get sendEmail => '$users/send-email';
  String get register => '$users/register';
  String get login => '$users/login';
  String get verifyEmail => '$users/verify-email';
  String get currentUser => '$users/me';
  String get userStorage => '$users/storage';
  String get updateUser => '$users/update';
  String get updatePassword => '$users/update-password';
  String get purchaseStorage => '$users/purchase-storage';
  String userFavorites(String userId) => '$users/favorites/$userId';

  // Notification endpoints
  String notificationById(String id) => '$notifications/$id';
  String get userNotifications => '$notifications/user/me';
  String notificationSeen(String id) => '$notifications/$id/seen';

  // Chat endpoints
  String get userChats => chats;
  String get createChat => chats;

  // Event endpoints
  String get createEvent => events;
  String get allEvents => events;
  String eventById(String id) => '$events/$id';
  String get searchEvents => '$events/search';
  String get userCreatedEvents => '$events/me/created';
  String get userPhotographerEvents => '$events/me/photographer';
  String get updateEvent => '$events/update';
  String eventRecipients(String id) => '$events/$id/recipients';
  String eventAccept(String id) => '$events/$id/accept';
  String eventDecline(String id) => '$events/$id/decline';
  String eventDelete(String id) => '$events/$id';

  // Review endpoints
  String get allReviews => reviews;
  String reviewById(String id) => '$reviews/$id';
  String reviewAverage(String userId) => '$reviews/average/$userId';
  String get createReview => reviews;
  String updateReview(String id) => '$reviews/$id';
  String deleteReview(String id) => '$reviews/$id';

  // Folder endpoints
  String get createFolder => folders;
  String foldersByEvent(String eventId) => '$folders/event/$eventId';
  String folderById(String id) => '$folders/$id';
  String folderAccept(String folderId) => '$folders/$folderId/accept';
  String folderDecline(String folderId) => '$folders/$folderId/decline';

  // Photo endpoints
  String get creatorPhotos => photos;
  String photoById(String id) => '$photos/$id';
  String get uploadPhoto => photos;
  String updatePhoto(String id) => '$photos/$id';
  String deletePhoto(String id) => '$photos/$id';

  // Photo Bundle endpoints
  String bundlesByFolder(String folderId) => '$photoBundles/folder/$folderId';
  String bundleById(String id) => '$photoBundles/$id';
  String get createBundle => photoBundles;
  String updateBundle(String id) => '$photoBundles/$id';
  String deleteBundle(String id) => '$photoBundles/$id';

  // Transaction endpoints
  String get allTransactions => transactions;
  String transactionById(String id) => '$transactions/$id';
  String sellerTransactions(String sellerId) =>
      '$transactions/seller/$sellerId';
  String buyerTransactions(String buyerId) => '$transactions/buyer/$buyerId';
}

/// API Error Codes
class ApiErrorCodes {
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String validationError = 'VALIDATION_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
}

/// HTTP Status Codes
class HttpStatusCodes {
  static const int ok = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int unprocessableEntity = 422;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
}

/// Simple environment configuration without multiple environments
class EnvironmentConfig {
  static bool get isDevelopment => false;
  static bool get isStaging => false;
  static bool get isProduction => true;
  static String get environmentName => 'Production';
}
