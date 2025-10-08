// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/event_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

class EventService extends GetxService {
  static EventService get instance => Get.find<EventService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Event> _userCreatedEvents = <Event>[].obs;
  final RxList<Event> _userPhotographerEvents = <Event>[].obs;
  final RxList<Event> _searchResults = <Event>[].obs;
  final Rx<Event?> _selectedEvent = Rx<Event?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isSearching = false.obs;

  // Getters
  List<Event> get userCreatedEvents => _userCreatedEvents;
  List<Event> get userPhotographerEvents => _userPhotographerEvents;
  List<Event> get searchResults => _searchResults;
  Event? get selectedEvent => _selectedEvent.value;
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;

  // Streams for reactive UI
  Stream<List<Event>> get createdEventsStream => _userCreatedEvents.stream;
  Stream<List<Event>> get photographerEventsStream =>
      _userPhotographerEvents.stream;
  Stream<Event?> get selectedEventStream => _selectedEvent.stream;

  Future<EventService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      // Load user events if authenticated
      // if (_authService.isAuthenticated) {
      //   await _loadUserEvents();
      // }

      // Listen to auth state changes
      // _setupAuthListener();
    } catch (e) {
      print('EventService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        _loadUserEvents();
      } else {
        _clearAllEvents();
      }
    });
  }

  // ==================== EVENT CRUD OPERATIONS ====================

  /// Create a new event
  Future<ApiResponse<Event>> createEvent(CreateEventRequest request) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Event>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.createEvent,
        data: request.toJson(),
        fromJson: (json) => Event.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Add to created events list
        _userCreatedEvents.insert(0, response.data!);
        print('Event created successfully: ${response.data!.name}');
      }

      return response;
    } catch (e) {
      return ApiResponse<Event>(
        success: false,
        error: 'Failed to create event: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get all events
  Future<ApiResponse<List<Event>>> getAllEvents() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Event>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.allEvents,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Event.fromJson(e)).toList();
          }
          return <Event>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Event>>(
        success: false,
        error: 'Failed to get all events: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get event by ID
  Future<ApiResponse<Event>> getEventById(String eventId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Event>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.eventById(eventId),
        fromJson: (json) => Event.fromJson(json),
      );

      if (response.success && response.data != null) {
        _selectedEvent.value = response.data;
      }

      return response;
    } catch (e) {
      return ApiResponse<Event>(
        success: false,
        error: 'Failed to get event: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update event
  Future<ApiResponse<Event>> updateEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<Event>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.updateEvent,
        data: {'id': eventId, ...updates},
        fromJson: (json) => Event.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Update in lists
        _updateEventInLists(response.data!);
        print('Event updated successfully: ${response.data!.name}');
      }

      return response;
    } catch (e) {
      return ApiResponse<Event>(
        success: false,
        error: 'Failed to update event: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete event
  Future<ApiResponse<dynamic>> deleteEvent(String eventId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'DELETE',
        endpoint: ApiConfig.endpoints.eventDelete(eventId),
      );

      if (response.success) {
        // Remove from lists
        _removeEventFromLists(eventId);
        if (_selectedEvent.value?.id == eventId) {
          _selectedEvent.value = null;
        }
        print('Event deleted successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to delete event: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== EVENT SEARCH ====================

  /// Search events with filters
  Future<ApiResponse<List<Event>>> searchEvents(
    EventSearchParams params,
  ) async {
    print(params.distance);
    print(params.type);
    print(params.role);
    print(params.location);
    try {
      _isSearching.value = true;

      final queryParams = params.toQueryParams();
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint =
          queryString.isEmpty
              ? ApiConfig.endpoints.searchEvents
              : '${ApiConfig.endpoints.searchEvents}?$queryString';

      final response = await _makeApiRequest<List<Event>>(
        method: 'GET',
        endpoint: endpoint,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Event.fromJson(e)).toList();
          }
          return <Event>[];
        },
      );

      if (response.success && response.data != null) {
        _searchResults.value = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Event>>(
        success: false,
        error: 'Failed to search events: $e',
      );
    } finally {
      _isSearching.value = false;
    }
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults.clear();
  }

  // ==================== USER EVENTS ====================

  /// Get current user's created events
  // Update these methods in your EventService class

  /// Get current user's created events
  Future<ApiResponse<List<Event>>> getUserCreatedEvents() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Event>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.userCreatedEvents,
        fromJson: (json) {
          // Handle paginated response
          if (json is Map<String, dynamic> && json.containsKey('data')) {
            final List<dynamic> dataList = json['data'] as List<dynamic>;
            return dataList.map((e) => Event.fromJson(e)).toList();
          }
          // Handle direct array response
          if (json is List) {
            return json.map((e) => Event.fromJson(e)).toList();
          }
          return <Event>[];
        },
      );

      if (response.success && response.data != null) {
        _userCreatedEvents.value = response.data!;
      } else {
        print('Failed to load created events: ${response.error}');
      }

      return response;
    } catch (e) {
      print('Error loading created events: $e');
      return ApiResponse<List<Event>>(
        success: false,
        error: 'Failed to get created events: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get current user's photographer events
  Future<ApiResponse<List<Event>>> getUserPhotographerEvents() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Event>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.userPhotographerEvents,
        fromJson: (json) {
          // Handle paginated response
          if (json is Map<String, dynamic> && json.containsKey('data')) {
            final List<dynamic> dataList = json['data'] as List<dynamic>;
            return dataList.map((e) => Event.fromJson(e)).toList();
          }
          // Handle direct array response
          if (json is List) {
            return json.map((e) => Event.fromJson(e)).toList();
          }
          return <Event>[];
        },
      );

      if (response.success && response.data != null) {
        _userPhotographerEvents.value = response.data!;
        print('Loaded ${response.data!.length} photographer events');
      } else {
        print('Failed to load photographer events: ${response.error}');
      }

      return response;
    } catch (e) {
      print('Error loading photographer events: $e');
      return ApiResponse<List<Event>>(
        success: false,
        error: 'Failed to get photographer events: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load all user events
  Future<void> _loadUserEvents() async {
    await Future.wait([getUserCreatedEvents(), getUserPhotographerEvents()]);
  }

  // ==================== RECIPIENT MANAGEMENT ====================

  /// Add recipients to an event
  Future<ApiResponse<dynamic>> addRecipients(
    String eventId,
    AddRecipientsRequest request,
  ) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'POST',
        endpoint: ApiConfig.endpoints.eventRecipients(eventId),
        data: request.toJson(),
      );

      if (response.success) {
        // Refresh event to get updated recipients
        await getEventById(eventId);
        print('Recipients added successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to add recipients: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Accept event invitation
  Future<ApiResponse<dynamic>> acceptEventInvitation(String eventId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.eventAccept(eventId),
      );

      if (response.success) {
        // Refresh user events
        await _loadUserEvents();
        print('Event invitation accepted');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to accept invitation: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Decline event invitation
  Future<ApiResponse<dynamic>> declineEventInvitation(String eventId) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.eventDecline(eventId),
      );

      if (response.success) {
        // Refresh user events
        await _loadUserEvents();
        print('Event invitation declined');
      }

      return response;
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to decline invitation: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Update event in all lists
  void _updateEventInLists(Event updatedEvent) {
    // Update in created events
    final createdIndex = _userCreatedEvents.indexWhere(
      (e) => e.id == updatedEvent.id,
    );
    if (createdIndex != -1) {
      _userCreatedEvents[createdIndex] = updatedEvent;
    }

    // Update in photographer events
    final photographerIndex = _userPhotographerEvents.indexWhere(
      (e) => e.id == updatedEvent.id,
    );
    if (photographerIndex != -1) {
      _userPhotographerEvents[photographerIndex] = updatedEvent;
    }

    // Update in search results
    final searchIndex = _searchResults.indexWhere(
      (e) => e.id == updatedEvent.id,
    );
    if (searchIndex != -1) {
      _searchResults[searchIndex] = updatedEvent;
    }

    // Update selected event
    if (_selectedEvent.value?.id == updatedEvent.id) {
      _selectedEvent.value = updatedEvent;
    }
  }

  /// Remove event from all lists
  void _removeEventFromLists(String eventId) {
    _userCreatedEvents.removeWhere((e) => e.id == eventId);
    _userPhotographerEvents.removeWhere((e) => e.id == eventId);
    _searchResults.removeWhere((e) => e.id == eventId);
  }

  /// Clear all events
  void _clearAllEvents() {
    _userCreatedEvents.clear();
    _userPhotographerEvents.clear();
    _searchResults.clear();
    _selectedEvent.value = null;
  }

  /// Refresh all events
  Future<void> refreshAllEvents() async {
    if (_authService.isAuthenticated) {
      await _loadUserEvents();
    }
  }

  /// Set selected event
  void setSelectedEvent(Event? event) {
    _selectedEvent.value = event;
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
      // Check authentication
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
  /// Handle HTTP response - UPDATED VERSION
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode ?? 0;

      print('API Response - Status: $statusCode');
      print('API Response - Body: ${response.body}');

      // Handle successful responses
      if (statusCode >= 200 && statusCode < 300) {
        final responseData = response.body;

        // Check if response is the paginated structure
        if (responseData is Map<String, dynamic>) {
          // If it has 'data' key, it's paginated
          if (responseData.containsKey('data')) {
            return ApiResponse<T>(
              success: responseData['success'] ?? true,
              statusCode: statusCode,
              message: responseData['message'],
              data:
                  fromJson != null ? fromJson(responseData) : responseData as T,
              metadata: {
                'count': responseData['count'],
                'total': responseData['total'],
                'totalPages': responseData['totalPages'],
                'currentPage': responseData['currentPage'],
              },
            );
          }

          // If it has 'message' or 'success' keys, extract data
          if (responseData.containsKey('success')) {
            return ApiResponse<T>(
              success: responseData['success'] ?? true,
              statusCode: statusCode,
              message: responseData['message'],
              data:
                  fromJson != null && responseData['data'] != null
                      ? fromJson(responseData['data'])
                      : responseData['data'] as T,
              metadata: responseData['metadata'],
            );
          }
        }

        // Direct data response
        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          data: fromJson != null ? fromJson(responseData) : responseData as T,
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
      print('Error parsing response: $e');
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

  // ==================== UTILITY METHODS ====================

  /// Get events by status
  List<Event> getEventsByStatus(EventStatus status) {
    return _userCreatedEvents.where((e) => e.status == status).toList();
  }

  /// Get upcoming events
  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return _userCreatedEvents
        .where((e) => e.date != null && e.date!.isAfter(now))
        .toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));
  }

  /// Get past events
  List<Event> getPastEvents() {
    final now = DateTime.now();
    return _userCreatedEvents
        .where((e) => e.date != null && e.date!.isBefore(now))
        .toList()
      ..sort((a, b) => b.date!.compareTo(a.date!));
  }

  /// Check if user is event creator
  bool isEventCreator(String eventId) {
    return _userCreatedEvents.any((e) => e.id == eventId);
  }

  /// Check if user is event photographer
  bool isEventPhotographer(String eventId) {
    return _userPhotographerEvents.any((e) => e.id == eventId);
  }

  @override
  void onClose() {
    _clearAllEvents();
    super.onClose();
  }
}
