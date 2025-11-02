import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:get/get.dart';
import 'package:photo_bug/app/core/common_widget/common_image_view_widget.dart';
import 'package:photo_bug/app/core/common_widget/custom_drop_down_widget.dart';
import 'package:photo_bug/app/core/common_widget/my_text_widget.dart';
import 'package:photo_bug/app/core/common_widget/simple_app_bar_widget.dart';
import 'package:photo_bug/app/core/constants/app_colors.dart';
import 'package:photo_bug/app/core/constants/app_fonts.dart';
import 'package:photo_bug/app/core/constants/app_images.dart';
import 'package:photo_bug/app/core/constants/app_sizes.dart';
import 'package:photo_bug/app/services/transaction_service/transaction_service.dart';

import 'package:photo_bug/app/data/models/transaction_model.dart';

import 'package:intl/intl.dart';

class TransactionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Services
  late final TransactionService _transactionService;

  // Tab Controller
  late TabController tabController;
  final List<String> tabs = ['Total Spent', 'Total Earned'];

  // Observable variables
  final RxString selectedPeriod = 'This Week'.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // Summary data
  final RxDouble totalSpent = 0.0.obs;
  final RxDouble totalEarned = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    _initializeTabController();
    loadTransactions();
  }

  void _initializeService() {
    try {
      _transactionService = TransactionService.instance;

      // Listen to service updates
      _transactionService.allTransactionsStream.listen((updatedTransactions) {
        transactions.value = updatedTransactions;
        _filterTransactions();
        _calculateTotals();
      });
    } catch (e) {
      print('❌ Error initializing TransactionService: $e');
      errorMessage.value = 'Failed to initialize service';
    }
  }

  void _initializeTabController() {
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      _filterTransactions();
      update();
    });
  }

  /// Load transactions from API
  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _transactionService.loadUserTransactions();

      if (_transactionService.allTransactions.isEmpty) {
        errorMessage.value = 'No transactions found';
      }
    } catch (e) {
      print('❌ Error loading transactions: $e');
      errorMessage.value = 'Failed to load transactions';
      _showError('Failed to load transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh transactions
  Future<void> refreshTransactions() async {
    try {
      isRefreshing.value = true;
      errorMessage.value = '';

      await _transactionService.refreshTransactions();

      _showSuccess('Transactions refreshed');
    } catch (e) {
      print('❌ Error refreshing transactions: $e');
      _showError('Failed to refresh transactions');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Filter transactions based on tab and period
  void _filterTransactions() {
    final allTrans = List<Transaction>.from(transactions);

    // Filter by period
    final periodFiltered = _filterByPeriod(allTrans, selectedPeriod.value);

    // Filter by tab (spent/earned)
    if (tabController.index == 0) {
      // Total Spent - show purchases
      filteredTransactions.value =
          periodFiltered
              .where(
                (t) =>
                    _transactionService.isUserBuyer(t) &&
                    t.status == TransactionStatus.completed,
              )
              .toList();
    } else {
      // Total Earned - show sales
      filteredTransactions.value =
          periodFiltered
              .where(
                (t) =>
                    _transactionService.isUserSeller(t) &&
                    t.status == TransactionStatus.completed,
              )
              .toList();
    }

    // Sort by date (newest first)
    filteredTransactions.value = _transactionService.sortByDate(
      filteredTransactions,
      descending: true,
    );
  }

  /// Filter transactions by period
  List<Transaction> _filterByPeriod(
    List<Transaction> transactions,
    String period,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        return transactions;
    }

    return _transactionService.filterByDateRange(
      startDate,
      now,
      transactions: transactions,
    );
  }

  /// Calculate totals for display
  void _calculateTotals() {
    final allTrans = transactions;

    // Calculate total spent (this week by default)
    final weekTransactions = _filterByPeriod(allTrans, selectedPeriod.value);

    totalSpent.value = weekTransactions
        .where(
          (t) =>
              _transactionService.isUserBuyer(t) &&
              t.status == TransactionStatus.completed,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    totalEarned.value = weekTransactions
        .where(
          (t) =>
              _transactionService.isUserSeller(t) &&
              t.status == TransactionStatus.completed,
        )
        .fold(0.0, (sum, t) => sum + (t.sellerAmount ?? t.amount));
  }

  /// Handle period change
  void onPeriodChanged(dynamic value) {
    if (value != null) {
      selectedPeriod.value = value;
      _filterTransactions();
      _calculateTotals();
    }
  }

  /// Get amount text based on current tab
  String get amountText {
    final amount =
        tabController.index == 0 ? totalSpent.value : totalEarned.value;
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Get amount description based on current tab
  String get amountDescription =>
      tabController.index == 0 ? 'Total amount spent' : 'Total amount earned';

  /// Check if there are any transactions
  bool get hasTransactions => filteredTransactions.isNotEmpty;

  /// Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

// Controller for individual expandable items
class ExpandableItemController extends GetxController {
  final RxBool isExpanded = false.obs;

  void toggleExpansion() {
    isExpanded.value = !isExpanded.value;
  }
}

class TransactionHistory extends StatelessWidget {
  TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());

    return Scaffold(
      appBar: simpleAppBar(title: 'Transaction History'),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTransactions,
          child: ListView(
            padding: AppSizes.DEFAULT,
            children: [
              _buildSummaryCard(controller),
              const SizedBox(height: 8),
              _buildTransactionsList(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(TransactionController controller) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: controller.tabController,
            labelPadding: const EdgeInsets.symmetric(vertical: 10),
            dividerColor: Colors.transparent,
            dividerHeight: 0,
            labelColor: kSecondaryColor,
            unselectedLabelColor: kDarkGreyColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: kTertiaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            overlayColor: WidgetStatePropertyAll(
              kSecondaryColor.withOpacity(0.1),
            ),
            splashBorderRadius: BorderRadius.circular(8),
            labelStyle: const TextStyle(
              fontSize: 14,
              color: kSecondaryColor,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.inter,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              color: kQuaternaryColor,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.inter,
            ),
            tabs: controller.tabs.map((e) => Text(e)).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MyText(
                  text: 'Amount',
                  size: 12,
                  color: kDarkGreyColor,
                  weight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 100,
                child: Obx(
                  () => CustomDropDown(
                    hint: 'This Week',
                    selectedValue: controller.selectedPeriod.value,
                    items: const ['This Week', 'This Month', 'This Year'],
                    onChanged: controller.onPeriodChanged,
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => MyText(
              text: controller.amountText,
              size: 32,
              weight: FontWeight.w700,
            ),
          ),
          GetBuilder<TransactionController>(
            builder:
                (controller) =>
                    MyText(text: controller.amountDescription, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(TransactionController controller) {
    return Obx(() {
      if (controller.filteredTransactions.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: controller.filteredTransactions.length,
        itemBuilder: (BuildContext context, int index) {
          final transaction = controller.filteredTransactions[index];
          return _CustomExpandable(transaction: transaction);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            MyText(
              text: 'No transactions yet',
              size: 18,
              weight: FontWeight.w600,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            MyText(
              text: 'Your transaction history will appear here',
              size: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({required String text, required String subText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: text,
              size: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(
            text: subText,
            size: 12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CustomExpandable extends StatelessWidget {
  final Transaction transaction;

  const _CustomExpandable({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ExpandableItemController(),
      tag: transaction.id ?? DateTime.now().toString(),
    );

    // Format date
    final dateStr =
        transaction.createdAt != null
            ? DateFormat('MM/dd/yyyy h:mm a').format(transaction.createdAt!)
            : 'N/A';

    // Determine if this is a purchase (expense) or sale (income)
    final isExpense = transaction.type == TransactionType.purchase;
    final amountText =
        '${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}';
    final amountColor = isExpense ? kRedColor : Colors.green;

    // Get item image
    final itemImage =
        transaction.metadata?['imageUrl'] ??
        transaction.metadata?['image_url'] ??
        '';

    // Get item title
    final itemTitle =
        transaction.metadata?['itemName'] ??
        transaction.metadata?['item_name'] ??
        'Transaction ${transaction.id?.substring(0, 8) ?? ''}';

    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                controller.isExpanded.value
                    ? kSecondaryColor
                    : kInputBorderColor,
          ),
        ),
        child: ExpandablePanel(
          controller: ExpandableController(initialExpanded: false),
          theme: const ExpandableThemeData(
            hasIcon: false,
            inkWellBorderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          header: GestureDetector(
            onTap: controller.toggleExpansion,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  itemImage.isNotEmpty
                      ? CommonImageView(
                        url: itemImage,
                        height: 48,
                        width: 48,
                        radius: 8,
                      )
                      : Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.receipt, color: Colors.grey[600]),
                      ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          text: itemTitle,
                          size: 13,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          paddingBottom: 2,
                        ),
                        MyText(
                          text: dateStr,
                          size: 11,
                          color: kQuaternaryColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  MyText(
                    text: amountText,
                    color: amountColor,
                    weight: FontWeight.w500,
                    paddingRight: 8,
                  ),
                  RotatedBox(
                    quarterTurns: controller.isExpanded.value ? 2 : 0,
                    child: Image.asset(
                      Assets.imagesDropDown,
                      height: 18,
                      color:
                          controller.isExpanded.value
                              ? kSecondaryColor
                              : kTertiaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          collapsed: const SizedBox(),
          expanded: _buildExpandedContent(transaction),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(Transaction transaction) {
    // Calculate breakdown
    final platformFee = transaction.platformFee ?? 0;
    final tax = transaction.metadata?['tax']?.toDouble() ?? 0;
    final serviceCharge =
        transaction.metadata?['serviceCharge']?.toDouble() ??
        transaction.metadata?['service_charge']?.toDouble() ??
        0;
    final subtotal = transaction.amount - platformFee - tax - serviceCharge;

    // Get item count
    final itemCount =
        transaction.metadata?['itemCount'] ??
        transaction.metadata?['item_count'] ??
        1;
    final bonusCount =
        transaction.metadata?['bonusCount'] ??
        transaction.metadata?['bonus_count'] ??
        0;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            height: 1,
            color: kInputBorderColor,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          _buildDetailTile(
            text: 'Transaction ID',
            subText: transaction.id?.substring(0, 12) ?? 'N/A',
          ),
          _buildDetailTile(
            text: 'Type',
            subText: _formatTransactionType(transaction.type),
          ),
          _buildDetailTile(
            text: 'Status',
            subText: _formatStatus(transaction.status),
          ),
          if (itemCount > 0)
            _buildDetailTile(
              text: 'No of items included',
              subText: 'x$itemCount',
            ),
          if (bonusCount > 0)
            _buildDetailTile(text: 'Free items', subText: 'x$bonusCount'),
          Container(
            height: 1,
            color: kInputBorderColor,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          if (transaction.paymentMethod != null)
            _buildDetailTile(
              text: 'Payment Method',
              subText: _formatPaymentMethod(transaction.paymentMethod!),
            ),
          _buildDetailTile(
            text: 'Amount',
            subText: '\$${subtotal.toStringAsFixed(2)}',
          ),
          if (tax > 0)
            _buildDetailTile(
              text: 'Tax',
              subText: '\$${tax.toStringAsFixed(2)}',
            ),
          if (serviceCharge > 0)
            _buildDetailTile(
              text: 'Service Charges',
              subText: '\$${serviceCharge.toStringAsFixed(2)}',
            ),
          if (platformFee > 0)
            _buildDetailTile(
              text: 'Platform Fee',
              subText: '\$${platformFee.toStringAsFixed(2)}',
            ),
          Container(
            height: 1,
            color: kInputBorderColor,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          Row(
            children: [
              Expanded(
                child: MyText(
                  text: 'Total',
                  size: 12,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              MyText(
                text: '\$${transaction.amount.toStringAsFixed(2)}',
                size: 12,
                weight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({required String text, required String subText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: text,
              size: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MyText(
            text: subText,
            size: 12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.storage:
        return 'Storage';
      case TransactionType.subscription:
        return 'Subscription';
    }
  }

  String _formatStatus(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      case TransactionStatus.refunded:
        return 'Refunded';
    }
  }

  String _formatPaymentMethod(String method) {
    // Hide middle digits of card number for security
    if (method.length > 8) {
      return '${method.substring(0, 4)}***${method.substring(method.length - 4)}';
    }
    return method;
  }
}
