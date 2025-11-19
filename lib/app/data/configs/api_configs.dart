import 'dart:io';

/// API Configuration class for Photo Bug application
/// Manages all API endpoints, configurations, and environment settings
class ApiConfig {
  // Private constructor for singleton pattern
  ApiConfig._internal();
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;

  // Base URL - Updated to match your Postman collection
  static const String baseUrl = 'https://photosbybugs.com';

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
  String get portfolio => '/portfolio';

  // ============================================================================
  // USER ENDPOINTS - Complete list from Postman
  // ============================================================================

  // Registration endpoints
  String get register => '$users/register';
  String get registerCreator =>
      '$users/register'; // Creator registration (duplicate kept as requested)
  String get registerSocial =>
      '$users/register'; // Social registration (duplicate kept as requested)

  // Login endpoints
  String get login => '$users/login';
  String get loginSocial =>
      '$users/login'; // Social login (duplicate kept as requested)

  // Email and verification
  String get sendEmail => '$users/send-email';
  String get verifyEmail => '$users/verify-email';
  String get generateTokens => '$users/generate-tokens';

  // User profile and info
  String get currentUser => '$users/me';
  String get allUsers => users;

  // Storage endpoints
  String get userStorage => '$users/storage';
  String get getStorageInfo =>
      '$users/storage'; // Alternative name (duplicate kept as requested)
  String get purchaseStorage => '$users/purchase-storage';
  String get getStorage =>
      '$users/purchase-storage'; // Alternative name (duplicate kept as requested)

  // User updates
  String get updateUser => '$users/update';
  String get updatePassword => '$users/update-password';

  // Favorites
  String userFavorites(String userId) => '$users/favorites/$userId';
  String addFavorite(String userId) =>
      '$users/favorites/$userId'; // Duplicate kept as requested
  String deleteFavorite(String userId) =>
      '$users/favorites/$userId'; // Duplicate kept as requested

  // Search
  String get searchCreator => '$users/search-creator';

  // ============================================================================
  // NOTIFICATION ENDPOINTS - Complete list from Postman
  // ============================================================================

  String get allNotifications => notifications;
  String get getAllNotifications =>
      notifications; // Alternative name (duplicate kept as requested)
  String notificationById(String id) => '$notifications/$id';
  String getNotificationById(String id) =>
      '$notifications/$id'; // Alternative name (duplicate kept as requested)
  String get userNotifications => '$notifications/user/me';
  String get currentUserNotifications =>
      '$notifications/user/me'; // Alternative name (duplicate kept as requested)
  String get getNotificationOfCurrentUser =>
      '$notifications/user/me'; // Alternative name (duplicate kept as requested)
  String get sendNotification => notifications;
  String get createNotification =>
      notifications; // Alternative name (duplicate kept as requested)
  String notificationSeen(String id) => '$notifications/$id/seen';
  String markAsSeen(String id) =>
      '$notifications/$id/seen'; // Alternative name (duplicate kept as requested)
  String markAsSeend(String id) =>
      '$notifications/$id/seen'; // Typo in Postman (duplicate kept as requested)
  String deleteNotification(String id) => '$notifications/$id';

  // ============================================================================
  // CHAT ENDPOINTS - Complete list from Postman
  // ============================================================================

  String get userChats => chats;
  String get getUserChats =>
      chats; // Alternative name (duplicate kept as requested)
  String get createChat => chats;
  String get createUserChat =>
      chats; // Alternative name (duplicate kept as requested)
  String chatById(String id) => '$chats/$id';
  String getChatById(String id) =>
      '$chats/$id'; // Alternative name (duplicate kept as requested)
  String chatMessages(String chatId) => '$chats/$chatId/messages';
  String sendMessage(String chatId) => '$chats/$chatId/messages';
  String markMessageAsRead(String chatId, String messageId) =>
      '$chats/$chatId/messages/$messageId';
  String markAsRead(String chatId, String messageId) =>
      '$chats/$chatId/messages/$messageId'; // Alternative name (duplicate kept as requested)

  // ============================================================================
  // EVENT ENDPOINTS - Complete list from Postman
  // ============================================================================

  String get createEvent => events;
  String get allEvents => events;
  String get getAllEvents =>
      events; // Alternative name (duplicate kept as requested)
  String eventById(String id) => '$events/$id';
  String getEventById(String id) =>
      '$events/$id'; // Alternative name (duplicate kept as requested)
  String get searchEvents => '$events/search';
  String get searchEvent =>
      '$events/search'; // Alternative name (duplicate kept as requested)
  String get userCreatedEvents => '$events/me/created';
  String get currentUserEvents =>
      '$events/me/created'; // Alternative name (duplicate kept as requested)
  String get getCurrentUserEvents =>
      '$events/me/created'; // Alternative name (duplicate kept as requested)
  String get userPhotographerEvents => '$events/me/photographer';
  String get currentPhotographerEvents =>
      '$events/me/photographer'; // Alternative name (duplicate kept as requested)
  String get getCurrentPhotographerEvents =>
      '$events/me/photographer'; // Alternative name (duplicate kept as requested)
  String get updateEvent => '$events/update';
  String eventRecipients(String id) => '$events/$id/recipients';
  String addRecipient(String id) =>
      '$events/$id/recipients'; // Alternative name (duplicate kept as requested)
  String eventAccept(String id) => '$events/$id/accept';
  String acceptEventInvitation(String id) =>
      '$events/$id/accept'; // Alternative name (duplicate kept as requested)
  String acceptEventInvitiation(String id) =>
      '$events/$id/accept'; // Typo in Postman (duplicate kept as requested)
  String eventDecline(String id) => '$events/$id/decline';
  String declineEventInvitation(String id) =>
      '$events/$id/decline'; // Alternative name (duplicate kept as requested)
  String declineEventInvitiation(String id) =>
      '$events/$id/decline'; // Typo in Postman (duplicate kept as requested)
  String eventDelete(String id) => '$events/$id';
  String deleteEvent(String id) =>
      '$events/$id'; // Alternative name (duplicate kept as requested)

  // ============================================================================
  // REVIEW ENDPOINTS - Complete list from Postman
  // ============================================================================

  String get allReviews => reviews;
  String get getAllReviews =>
      reviews; // Alternative name (duplicate kept as requested)
  String reviewById(String id) => '$reviews/$id';
  String getReviewById(String id) =>
      '$reviews/$id'; // Alternative name (duplicate kept as requested)
  String reviewAverage(String userId) => '$reviews/average/$userId';
  String getAverageRatings(String userId) =>
      '$reviews/average/$userId'; // Alternative name (duplicate kept as requested)
  String getAverageRatingsOfUser(String userId) =>
      '$reviews/average/$userId'; // Alternative name (duplicate kept as requested)
  String get createReview => reviews;
  String updateReview(String id) => '$reviews/$id';
  String deleteReview(String id) => '$reviews/$id';

  // ============================================================================
  // FOLDER ENDPOINTS - Complete list from Postman
  // ============================================================================

  String get createFolder => folders;
  String foldersByEvent(String eventId) => '$folders/event/$eventId';
  String getFoldersByEvent(String eventId) =>
      '$folders/event/$eventId'; // Alternative name (duplicate kept as requested)
  String folderById(String id) => '$folders/$id';
  String getFoldersById(String id) =>
      '$folders/$id'; // Alternative name (duplicate kept as requested)
  String folderAccept(String folderId) => '$folders/$folderId/accept';
  String acceptInvite(String folderId) =>
      '$folders/$folderId/accept'; // Alternative name (duplicate kept as requested)
  String folderDecline(String folderId) => '$folders/$folderId/decline';
  String declineInvite(String folderId) =>
      '$folders/$folderId/decline'; // Alternative name (duplicate kept as requested)

  // ============================================================================
  // PHOTO ENDPOINTS - Complete list from Postman (FIXED: No duplicate /api prefix)
  // ============================================================================

  String get creatorPhotos => photos;
  String get getCreatorImages =>
      photos; // Alternative name (duplicate kept as requested)
  String photoById(String id) => '$photos/$id';
  String getImageById(String id) =>
      '$photos/$id'; // Alternative name (duplicate kept as requested)
  String get uploadPhoto => photos;
  String get uploadImage =>
      photos; // Alternative name (duplicate kept as requested)
  String updatePhoto(String id) => '$photos/$id';
  String updateImage(String id) =>
      '$photos/$id'; // Alternative name (duplicate kept as requested)
  String deletePhoto(String id) => '$photos/$id';
  String deleteImage(String id) =>
      '$photos/$id'; // Alternative name (duplicate kept as requested)
  String get searchPhotos => '$photos/search-photos';
  String trackDownload(String id) => '$photos/track-download/$id';
  String trackDownloadStats(String id) =>
      '$photos/track-download/$id'; // Alternative name (duplicate kept as requested)
  String get getDownloadStats => '$photos/get-download-stats';
  String get downloadStats =>
      '$photos/get-download-stats'; // Alternative name (duplicate kept as requested)
  String get getAllPhotos => photos;
  String get allPhotos =>
      photos; // Alternative name (duplicate kept as requested)
  String get getTrendingPhotos =>
      '$photos/get-trending-photos'; // FIXED: No /api prefix

  // ============================================================================
  // PHOTO BUNDLE ENDPOINTS - Complete list from Postman
  // ============================================================================

  String bundlesByFolder(String folderId) => '$photoBundles/folder/$folderId';
  String getBundlesByFolder(String folderId) =>
      '$photoBundles/folder/$folderId'; // Alternative name (duplicate kept as requested)
  String bundleById(String id) => '$photoBundles/$id';
  String getBundleById(String id) =>
      '$photoBundles/$id'; // Alternative name (duplicate kept as requested)
  String get createBundle => photoBundles;
  String get createPhotoBundle =>
      photoBundles; // Alternative name (duplicate kept as requested)
  String updateBundle(String id) => '$photoBundles/$id';
  String updatePhotoBundle(String id) =>
      '$photoBundles/$id'; // Alternative name (duplicate kept as requested)
  String deleteBundle(String id) => '$photoBundles/$id';
  String deletePhotoBundle(String id) =>
      '$photoBundles/$id'; // Alternative name (duplicate kept as requested)
  String userPhotos(String userId) => '$photoBundles/$userId/user-photos';
  String getUserPhotos(String userId) =>
      '$photoBundles/$userId/user-photos'; // Alternative name (duplicate kept as requested)

  // ============================================================================
  // TRANSACTION ENDPOINTS - Complete list from Postman
  // ============================================================================

  String get allTransactions => transactions;
  String get getAllTransactions =>
      transactions; // Alternative name (duplicate kept as requested)
  String transactionById(String id) => '$transactions/$id';
  String getTransactionById(String id) =>
      '$transactions/$id'; // Alternative name (duplicate kept as requested)
  String sellerTransactions(String sellerId) =>
      '$transactions/seller/$sellerId';
  String getSellerTransactions(String sellerId) =>
      '$transactions/seller/$sellerId'; // Alternative name (duplicate kept as requested)
  String buyerTransactions(String buyerId) => '$transactions/buyer/$buyerId';
  String getBuyerTransactions(String buyerId) =>
      '$transactions/buyer/$buyerId'; // Alternative name (duplicate kept as requested)

  // ============================================================================
  // PORTFOLIO ENDPOINTS - Complete list from Postman
  // ============================================================================

  String get createPortfolio => portfolio;
  String get getPortfolio => portfolio;
  String portfolioByCreator(String creatorId) =>
      '$portfolio/creator/$creatorId';
  String getPortfolioByCreator(String creatorId) =>
      '$portfolio/creator/$creatorId'; // Alternative name (duplicate kept as requested)
  String deletePortfolio(String id) => '$portfolio/$id';
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
