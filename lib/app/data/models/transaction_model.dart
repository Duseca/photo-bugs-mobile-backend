class Transaction {
  final String? id;
  final String sellerId;
  final String buyerId;
  final double amount;
  final String currency;
  final TransactionType type;
  final String? itemId; // Photo ID or Bundle ID
  final String? itemType; // 'photo', 'bundle', 'storage'
  final TransactionStatus status;
  final String? paymentMethod;
  final String? paymentReference;
  final double? platformFee;
  final double? sellerAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Transaction({
    this.id,
    required this.sellerId,
    required this.buyerId,
    required this.amount,
    this.currency = 'USD',
    required this.type,
    this.itemId,
    this.itemType,
    this.status = TransactionStatus.pending,
    this.paymentMethod,
    this.paymentReference,
    this.platformFee,
    this.sellerAmount,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? json['id'],
      sellerId: json['sellerId'] ?? json['seller_id'] ?? '',
      buyerId: json['buyerId'] ?? json['buyer_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      type: TransactionTypeExtension.fromString(json['type'] ?? 'purchase'),
      itemId: json['itemId'] ?? json['item_id'],
      itemType: json['itemType'] ?? json['item_type'],
      status: TransactionStatusExtension.fromString(
        json['status'] ?? 'pending',
      ),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      paymentReference: json['paymentReference'] ?? json['payment_reference'],
      platformFee:
          json['platformFee']?.toDouble() ?? json['platform_fee']?.toDouble(),
      sellerAmount:
          json['sellerAmount']?.toDouble() ?? json['seller_amount']?.toDouble(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'amount': amount,
      'currency': currency,
      'type': type.value,
      if (itemId != null) 'itemId': itemId,
      if (itemType != null) 'itemType': itemType,
      'status': status.value,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentReference != null) 'paymentReference': paymentReference,
      if (platformFee != null) 'platformFee': platformFee,
      if (sellerAmount != null) 'sellerAmount': sellerAmount,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  Transaction copyWith({
    String? id,
    String? sellerId,
    String? buyerId,
    double? amount,
    String? currency,
    TransactionType? type,
    String? itemId,
    String? itemType,
    TransactionStatus? status,
    String? paymentMethod,
    String? paymentReference,
    double? platformFee,
    double? sellerAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      platformFee: platformFee ?? this.platformFee,
      sellerAmount: sellerAmount ?? this.sellerAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, amount: $amount, type: $type, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Transaction Summary Model
class TransactionSummary {
  final double totalSales;
  final double totalPurchases;
  final double totalEarnings;
  final int totalTransactions;
  final double averageTransactionValue;
  final Map<String, double>? salesByType;

  TransactionSummary({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalEarnings,
    required this.totalTransactions,
    required this.averageTransactionValue,
    this.salesByType,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalSales: (json['totalSales'] ?? json['total_sales'] ?? 0).toDouble(),
      totalPurchases:
          (json['totalPurchases'] ?? json['total_purchases'] ?? 0).toDouble(),
      totalEarnings:
          (json['totalEarnings'] ?? json['total_earnings'] ?? 0).toDouble(),
      totalTransactions:
          json['totalTransactions'] ?? json['total_transactions'] ?? 0,
      averageTransactionValue:
          (json['averageTransactionValue'] ??
                  json['average_transaction_value'] ??
                  0)
              .toDouble(),
      salesByType:
          json['salesByType'] != null
              ? Map<String, double>.from(json['salesByType'])
              : json['sales_by_type'] != null
              ? Map<String, double>.from(json['sales_by_type'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalEarnings': totalEarnings,
      'totalTransactions': totalTransactions,
      'averageTransactionValue': averageTransactionValue,
      if (salesByType != null) 'salesByType': salesByType,
    };
  }

  @override
  String toString() {
    return 'TransactionSummary{totalSales: $totalSales, totalEarnings: $totalEarnings, totalTransactions: $totalTransactions}';
  }
}

// Transaction Type Enum
enum TransactionType { purchase, sale, refund, storage, subscription }

extension TransactionTypeExtension on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.purchase:
        return 'purchase';
      case TransactionType.sale:
        return 'sale';
      case TransactionType.refund:
        return 'refund';
      case TransactionType.storage:
        return 'storage';
      case TransactionType.subscription:
        return 'subscription';
    }
  }

  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sale':
        return TransactionType.sale;
      case 'refund':
        return TransactionType.refund;
      case 'storage':
        return TransactionType.storage;
      case 'subscription':
        return TransactionType.subscription;
      default:
        return TransactionType.purchase;
    }
  }
}

// Transaction Status Enum
enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

extension TransactionStatusExtension on TransactionStatus {
  String get value {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.processing:
        return 'processing';
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.cancelled:
        return 'cancelled';
      case TransactionStatus.refunded:
        return 'refunded';
    }
  }

  static TransactionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return TransactionStatus.processing;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'refunded':
        return TransactionStatus.refunded;
      default:
        return TransactionStatus.pending;
    }
  }
}
