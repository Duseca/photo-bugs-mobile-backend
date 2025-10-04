// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:photo_bug/app/data/models/transaction_model.dart';
import 'package:photo_bug/app/data/models/api_response.dart';
import 'package:photo_bug/app/data/configs/api_configs.dart';
import '../app/app_service.dart';
import '../auth/auth_service.dart';

class TransactionService extends GetxService {
  static TransactionService get instance => Get.find<TransactionService>();

  late final AppService _appService;
  late final AuthService _authService;

  // Reactive variables
  final RxList<Transaction> _allTransactions = <Transaction>[].obs;
  final RxList<Transaction> _sellerTransactions = <Transaction>[].obs;
  final RxList<Transaction> _buyerTransactions = <Transaction>[].obs;
  final Rx<TransactionSummary?> _summary = Rx<TransactionSummary?>(null);
  final Rx<Transaction?> _selectedTransaction = Rx<Transaction?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isProcessing = false.obs;

  // Getters
  List<Transaction> get allTransactions => _allTransactions;
  List<Transaction> get sellerTransactions => _sellerTransactions;
  List<Transaction> get buyerTransactions => _buyerTransactions;
  TransactionSummary? get summary => _summary.value;
  Transaction? get selectedTransaction => _selectedTransaction.value;
  bool get isLoading => _isLoading.value;
  bool get isProcessing => _isProcessing.value;

  // Streams for reactive UI
  Stream<List<Transaction>> get allTransactionsStream =>
      _allTransactions.stream;
  Stream<List<Transaction>> get sellerTransactionsStream =>
      _sellerTransactions.stream;
  Stream<List<Transaction>> get buyerTransactionsStream =>
      _buyerTransactions.stream;
  Stream<TransactionSummary?> get summaryStream => _summary.stream;
  Stream<Transaction?> get selectedTransactionStream =>
      _selectedTransaction.stream;

  Future<TransactionService> init() async {
    await _initialize();
    return this;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    try {
      _appService = Get.find<AppService>();
      _authService = Get.find<AuthService>();

      // Load user transactions if authenticated
      if (_authService.isAuthenticated) {
        await loadUserTransactions();
      }

      // Listen to auth state changes
      _setupAuthListener();
    } catch (e) {
      print('TransactionService initialization error: $e');
    }
  }

  /// Setup authentication state listener
  void _setupAuthListener() {
    _authService.authStateStream.listen((isAuthenticated) {
      if (isAuthenticated) {
        loadUserTransactions();
      } else {
        _clearAllTransactions();
      }
    });
  }

  // ==================== TRANSACTION OPERATIONS ====================

  /// Get all transactions
  Future<ApiResponse<List<Transaction>>> getAllTransactions() async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Transaction>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.allTransactions,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Transaction.fromJson(e)).toList();
          }
          return <Transaction>[];
        },
      );

      if (response.success && response.data != null) {
        _allTransactions.value = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Transaction>>(
        success: false,
        error: 'Failed to get all transactions: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get transaction by ID
  Future<ApiResponse<Transaction>> getTransactionById(String id) async {
    try {
      _isLoading.value = true;

      // Check cache first
      final cachedTransaction = _findTransactionById(id);
      if (cachedTransaction != null) {
        _selectedTransaction.value = cachedTransaction;
        return ApiResponse<Transaction>(success: true, data: cachedTransaction);
      }

      final response = await _makeApiRequest<Transaction>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.transactionById(id),
        fromJson: (json) => Transaction.fromJson(json),
      );

      if (response.success && response.data != null) {
        _selectedTransaction.value = response.data;
        _addOrUpdateTransaction(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse<Transaction>(
        success: false,
        error: 'Failed to get transaction: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get seller transactions
  Future<ApiResponse<List<Transaction>>> getSellerTransactions(
    String sellerId,
  ) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Transaction>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.sellerTransactions(sellerId),
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Transaction.fromJson(e)).toList();
          }
          return <Transaction>[];
        },
      );

      if (response.success && response.data != null) {
        _sellerTransactions.value = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Transaction>>(
        success: false,
        error: 'Failed to get seller transactions: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get buyer transactions
  Future<ApiResponse<List<Transaction>>> getBuyerTransactions(
    String buyerId,
  ) async {
    try {
      _isLoading.value = true;

      final response = await _makeApiRequest<List<Transaction>>(
        method: 'GET',
        endpoint: ApiConfig.endpoints.buyerTransactions(buyerId),
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => Transaction.fromJson(e)).toList();
          }
          return <Transaction>[];
        },
      );

      if (response.success && response.data != null) {
        _buyerTransactions.value = response.data!;
      }

      return response;
    } catch (e) {
      return ApiResponse<List<Transaction>>(
        success: false,
        error: 'Failed to get buyer transactions: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create a new transaction
  Future<ApiResponse<Transaction>> createTransaction({
    required String sellerId,
    required String buyerId,
    required double amount,
    String currency = 'USD',
    required TransactionType type,
    String? itemId,
    String? itemType,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isProcessing.value = true;

      // Validation
      if (amount <= 0) {
        return ApiResponse<Transaction>(
          success: false,
          error: 'Transaction amount must be greater than zero',
        );
      }

      if (sellerId.isEmpty || buyerId.isEmpty) {
        return ApiResponse<Transaction>(
          success: false,
          error: 'Seller and buyer IDs are required',
        );
      }

      final transactionData = {
        'sellerId': sellerId,
        'buyerId': buyerId,
        'amount': amount,
        'currency': currency,
        'type': type.value,
        if (itemId != null) 'itemId': itemId,
        if (itemType != null) 'itemType': itemType,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _makeApiRequest<Transaction>(
        method: 'POST',
        endpoint: ApiConfig.endpoints.allTransactions,
        data: transactionData,
        fromJson: (json) => Transaction.fromJson(json),
      );

      if (response.success && response.data != null) {
        _addOrUpdateTransaction(response.data!);
        print('Transaction created successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Transaction>(
        success: false,
        error: 'Failed to create transaction: $e',
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  /// Update transaction status
  Future<ApiResponse<Transaction>> updateTransactionStatus(
    String transactionId,
    TransactionStatus status,
  ) async {
    try {
      _isProcessing.value = true;

      final response = await _makeApiRequest<Transaction>(
        method: 'PUT',
        endpoint: ApiConfig.endpoints.transactionById(transactionId),
        data: {'status': status.value},
        fromJson: (json) => Transaction.fromJson(json),
      );

      if (response.success && response.data != null) {
        _addOrUpdateTransaction(response.data!);
        print('Transaction status updated successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Transaction>(
        success: false,
        error: 'Failed to update transaction status: $e',
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  /// Process refund
  Future<ApiResponse<Transaction>> processRefund(String transactionId) async {
    try {
      _isProcessing.value = true;

      final response = await _makeApiRequest<Transaction>(
        method: 'POST',
        endpoint:
            '${ApiConfig.endpoints.transactionById(transactionId)}/refund',
        fromJson: (json) => Transaction.fromJson(json),
      );

      if (response.success && response.data != null) {
        _addOrUpdateTransaction(response.data!);
        print('Refund processed successfully');
      }

      return response;
    } catch (e) {
      return ApiResponse<Transaction>(
        success: false,
        error: 'Failed to process refund: $e',
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  // ==================== FILTERING & SORTING ====================

  /// Get transactions by status
  List<Transaction> getTransactionsByStatus(
    TransactionStatus status, {
    List<Transaction>? transactions,
  }) {
    final list = transactions ?? _allTransactions;
    return list.where((t) => t.status == status).toList();
  }

  /// Get transactions by type
  List<Transaction> getTransactionsByType(
    TransactionType type, {
    List<Transaction>? transactions,
  }) {
    final list = transactions ?? _allTransactions;
    return list.where((t) => t.type == type).toList();
  }

  /// Get pending transactions
  List<Transaction> getPendingTransactions() {
    return _allTransactions
        .where((t) => t.status == TransactionStatus.pending)
        .toList();
  }

  /// Get completed transactions
  List<Transaction> getCompletedTransactions() {
    return _allTransactions
        .where((t) => t.status == TransactionStatus.completed)
        .toList();
  }

  /// Get failed transactions
  List<Transaction> getFailedTransactions() {
    return _allTransactions
        .where((t) => t.status == TransactionStatus.failed)
        .toList();
  }

  /// Filter transactions by date range
  List<Transaction> filterByDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<Transaction>? transactions,
  }) {
    final list = transactions ?? _allTransactions;
    return list.where((t) {
      if (t.createdAt == null) return false;
      return t.createdAt!.isAfter(startDate) &&
          t.createdAt!.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filter transactions by amount range
  List<Transaction> filterByAmountRange(
    double minAmount,
    double maxAmount, {
    List<Transaction>? transactions,
  }) {
    final list = transactions ?? _allTransactions;
    return list
        .where((t) => t.amount >= minAmount && t.amount <= maxAmount)
        .toList();
  }

  /// Search transactions
  List<Transaction> searchTransactions(
    String query, {
    List<Transaction>? transactions,
  }) {
    if (query.trim().isEmpty) return transactions ?? _allTransactions;

    final list = transactions ?? _allTransactions;
    final lowerQuery = query.toLowerCase();

    return list.where((t) {
      return t.id?.toLowerCase().contains(lowerQuery) == true ||
          t.paymentReference?.toLowerCase().contains(lowerQuery) == true ||
          t.itemId?.toLowerCase().contains(lowerQuery) == true ||
          t.type.value.toLowerCase().contains(lowerQuery) ||
          t.status.value.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Sort transactions by date
  List<Transaction> sortByDate(
    List<Transaction> transactions, {
    bool descending = true,
  }) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return descending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });
    return sorted;
  }

  /// Sort transactions by amount
  List<Transaction> sortByAmount(
    List<Transaction> transactions, {
    bool descending = true,
  }) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort(
      (a, b) =>
          descending
              ? b.amount.compareTo(a.amount)
              : a.amount.compareTo(b.amount),
    );
    return sorted;
  }

  // ==================== STATISTICS & ANALYTICS ====================

  /// Calculate transaction summary
  TransactionSummary calculateSummary({List<Transaction>? transactions}) {
    final list = transactions ?? _allTransactions;
    final completedTransactions =
        list.where((t) => t.status == TransactionStatus.completed).toList();

    double totalSales = 0;
    double totalPurchases = 0;
    double totalEarnings = 0;
    final Map<String, double> salesByType = {};

    for (final transaction in completedTransactions) {
      if (transaction.type == TransactionType.sale) {
        totalSales += transaction.amount;
        totalEarnings += transaction.sellerAmount ?? transaction.amount;
      } else if (transaction.type == TransactionType.purchase) {
        totalPurchases += transaction.amount;
      }

      // Track sales by type
      final typeKey = transaction.type.value;
      salesByType[typeKey] = (salesByType[typeKey] ?? 0) + transaction.amount;
    }

    final averageValue =
        completedTransactions.isEmpty
            ? 0.0
            : completedTransactions.fold<double>(
                  0,
                  (sum, t) => sum + t.amount,
                ) /
                completedTransactions.length;

    return TransactionSummary(
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalEarnings: totalEarnings,
      totalTransactions: completedTransactions.length,
      averageTransactionValue: averageValue,
      salesByType: salesByType,
    );
  }

  /// Get total earnings
  double getTotalEarnings({List<Transaction>? transactions}) {
    final list = transactions ?? _allTransactions;
    return list
        .where(
          (t) =>
              t.status == TransactionStatus.completed &&
              t.type == TransactionType.sale,
        )
        .fold<double>(0, (sum, t) => sum + (t.sellerAmount ?? t.amount));
  }

  /// Get total spent
  double getTotalSpent({List<Transaction>? transactions}) {
    final list = transactions ?? _allTransactions;
    return list
        .where(
          (t) =>
              t.status == TransactionStatus.completed &&
              t.type == TransactionType.purchase,
        )
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Get transaction count by status
  Map<TransactionStatus, int> getCountByStatus({
    List<Transaction>? transactions,
  }) {
    final list = transactions ?? _allTransactions;
    final Map<TransactionStatus, int> counts = {};

    for (final status in TransactionStatus.values) {
      counts[status] = list.where((t) => t.status == status).length;
    }

    return counts;
  }

  /// Get transaction count by type
  Map<TransactionType, int> getCountByType({List<Transaction>? transactions}) {
    final list = transactions ?? _allTransactions;
    final Map<TransactionType, int> counts = {};

    for (final type in TransactionType.values) {
      counts[type] = list.where((t) => t.type == type).length;
    }

    return counts;
  }

  /// Get monthly transaction summary
  Map<String, double> getMonthlyTransactionSummary({
    List<Transaction>? transactions,
    int months = 12,
  }) {
    final list = transactions ?? _allTransactions;
    final Map<String, double> monthlySummary = {};
    final now = DateTime.now();

    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      final monthlyTotal = list
          .where(
            (t) =>
                t.createdAt != null &&
                t.status == TransactionStatus.completed &&
                t.createdAt!.year == month.year &&
                t.createdAt!.month == month.month,
          )
          .fold<double>(0, (sum, t) => sum + t.amount);

      monthlySummary[monthKey] = monthlyTotal;
    }

    return monthlySummary;
  }

  /// Get average transaction value
  double getAverageTransactionValue({List<Transaction>? transactions}) {
    final list = transactions ?? _allTransactions;
    final completedTransactions =
        list.where((t) => t.status == TransactionStatus.completed).toList();

    if (completedTransactions.isEmpty) return 0.0;

    return completedTransactions.fold<double>(0, (sum, t) => sum + t.amount) /
        completedTransactions.length;
  }

  /// Get highest transaction
  Transaction? getHighestTransaction({List<Transaction>? transactions}) {
    final list = transactions ?? _allTransactions;
    if (list.isEmpty) return null;

    return list.reduce(
      (current, next) => next.amount > current.amount ? next : current,
    );
  }

  /// Get platform fees collected
  double getTotalPlatformFees({List<Transaction>? transactions}) {
    final list = transactions ?? _allTransactions;
    return list
        .where((t) => t.status == TransactionStatus.completed)
        .fold<double>(0, (sum, t) => sum + (t.platformFee ?? 0));
  }

  // ==================== HELPER METHODS ====================

  /// Load user transactions (both as seller and buyer)
  Future<void> loadUserTransactions() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    await Future.wait([
      getSellerTransactions(userId),
      getBuyerTransactions(userId),
    ]);

    // Combine and deduplicate
    final combined = <String, Transaction>{};

    for (final t in _sellerTransactions) {
      if (t.id != null) combined[t.id!] = t;
    }

    for (final t in _buyerTransactions) {
      if (t.id != null) combined[t.id!] = t;
    }

    _allTransactions.value = combined.values.toList();

    // Calculate summary
    _summary.value = calculateSummary();
  }

  /// Refresh transactions
  Future<void> refreshTransactions() async {
    await loadUserTransactions();
  }

  /// Find transaction by ID
  Transaction? _findTransactionById(String id) {
    return _allTransactions.firstWhereOrNull((t) => t.id == id);
  }

  /// Add or update transaction in lists
  void _addOrUpdateTransaction(Transaction transaction) {
    if (transaction.id == null) return;

    // Update in all transactions
    final index = _allTransactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _allTransactions[index] = transaction;
    } else {
      _allTransactions.insert(0, transaction);
    }

    // Update in seller transactions if applicable
    if (transaction.sellerId == _authService.currentUser?.id) {
      final sellerIndex = _sellerTransactions.indexWhere(
        (t) => t.id == transaction.id,
      );
      if (sellerIndex != -1) {
        _sellerTransactions[sellerIndex] = transaction;
      } else {
        _sellerTransactions.insert(0, transaction);
      }
    }

    // Update in buyer transactions if applicable
    if (transaction.buyerId == _authService.currentUser?.id) {
      final buyerIndex = _buyerTransactions.indexWhere(
        (t) => t.id == transaction.id,
      );
      if (buyerIndex != -1) {
        _buyerTransactions[buyerIndex] = transaction;
      } else {
        _buyerTransactions.insert(0, transaction);
      }
    }

    // Recalculate summary
    _summary.value = calculateSummary();
  }

  /// Clear all transactions
  void _clearAllTransactions() {
    _allTransactions.clear();
    _sellerTransactions.clear();
    _buyerTransactions.clear();
    _selectedTransaction.value = null;
    _summary.value = null;
  }

  /// Set selected transaction
  void setSelectedTransaction(Transaction? transaction) {
    _selectedTransaction.value = transaction;
  }

  /// Check if user is seller in transaction
  bool isUserSeller(Transaction transaction) {
    return transaction.sellerId == _authService.currentUser?.id;
  }

  /// Check if user is buyer in transaction
  bool isUserBuyer(Transaction transaction) {
    return transaction.buyerId == _authService.currentUser?.id;
  }

  /// Get user's role in transaction
  String? getUserRole(Transaction transaction) {
    if (isUserSeller(transaction)) return 'seller';
    if (isUserBuyer(transaction)) return 'buyer';
    return null;
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
    _clearAllTransactions();
    super.onClose();
  }
}
