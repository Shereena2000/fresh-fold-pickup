import 'package:flutter/material.dart';
import '../model/billing_item.dart';
import '../model/order_billing_model.dart';
import '../repository/order_billing_repository.dart';
import '../../PriceList/model/price_item_model.dart';
import '../../home/view_model/home_view_model.dart';

class BillingViewModel extends ChangeNotifier {
  final OrderBillingRepository _repository = OrderBillingRepository();
  
  OrderCardData? _orderData;
  List<BillingItem> _billingItems = [];
  double _totalAmount = 0.0;
  OrderBillingModel? _currentBilling;
  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;

  OrderCardData? get orderData => _orderData;
  List<BillingItem> get billingItems => _billingItems;
  double get totalAmount => _totalAmount;
  OrderBillingModel? get currentBilling => _currentBilling;
  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Check if payment has been set
  bool get isPaymentSet => _currentBilling != null;
  
  // Get payment status
  String get paymentStatus => _currentBilling?.paymentStatus ?? 'pending';

  // Get items that have quantity > 0
  List<BillingItem> get addedItems =>
      _billingItems.where((item) => item.quantity > 0).toList();

  /// Set order data
  void setOrderData(OrderCardData orderData) {
    _orderData = orderData;
    notifyListeners();
  }

  /// Initialize billing items from price list
  void initializeBillingItems(
    List<PriceItemModel> priceItems,
    String washType,
  ) {
    _billingItems = priceItems.map((item) {
      double price = _getPriceForWashType(item, washType);
      String priceType = _getPriceTypeForWashType(washType);
      
      return BillingItem(
        priceItem: item,
        priceType: priceType,
        quantity: 0,
        unitPrice: price,
      );
    }).toList();
    
    _calculateTotal();
    notifyListeners();
  }

  /// Update quantity for a specific item
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _billingItems.length && newQuantity >= 0) {
      _billingItems[index].quantity = newQuantity;
      _calculateTotal();
      notifyListeners();
    }
  }

  /// Calculate total amount
  void _calculateTotal() {
    _totalAmount = _billingItems.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  /// Get price based on wash type
  double _getPriceForWashType(PriceItemModel item, String washType) {
    switch (washType.toLowerCase()) {
      case 'dry_clean':
        return double.tryParse(item.dryWash) ?? 0.0;
      case 'wash_press':
        return double.tryParse(item.wetWash) ?? 0.0;
      case 'press_only':
        return double.tryParse(item.steamPress) ?? 0.0;
      default:
        return 0.0;
    }
  }

  /// Get price type string
  String _getPriceTypeForWashType(String washType) {
    switch (washType.toLowerCase()) {
      case 'dry_clean':
        return 'dryWash';
      case 'wash_press':
        return 'wetWash';
      case 'press_only':
        return 'steamPress';
      default:
        return '';
    }
  }

  /// Clear all billing items
  void clearBilling() {
    for (var item in _billingItems) {
      item.quantity = 0;
    }
    _calculateTotal();
    notifyListeners();
  }

  /// Get billing summary
  Map<String, dynamic> getBillingSummary() {
    return {
      'items': addedItems.map((item) => item.toMap()).toList(),
      'totalAmount': _totalAmount,
      'itemCount': addedItems.length,
      'totalQuantity': addedItems.fold(0, (sum, item) => sum + item.quantity),
    };
  }

  /// Load existing billing details
  Future<void> loadBillingDetails(String userId, String scheduleId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentBilling = await _repository.getLatestBilling(userId, scheduleId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save billing details to Firebase
  Future<bool> saveBillingDetails({
    required String userId,
    required String scheduleId,
    required String serviceType,
    required String washType,
  }) async {
    if (addedItems.isEmpty) {
      _errorMessage = 'Please add items to the bill before saving';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert billing items to billing item data
      final billingItemsData = addedItems.map((item) {
        return BillingItemData(
          itemId: item.priceItem.itemId,
          itemName: item.priceItem.itemName,
          priceType: item.priceType,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          itemTotal: item.itemTotal,
        );
      }).toList();

      // Create billing model
      final billing = OrderBillingModel(
        billingId: DateTime.now().millisecondsSinceEpoch.toString(),
        scheduleId: scheduleId,
        userId: userId,
        serviceType: serviceType,
        washType: washType,
        items: billingItemsData,
        totalAmount: _totalAmount,
        paymentStatus: 'pay_request',
        createdAt: DateTime.now(),
      );

      // Save to Firebase
      await _repository.saveBillingDetails(billing);
      
      _currentBilling = billing;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save billing: ${e.toString()}';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(
    String userId,
    String scheduleId,
    String status,
  ) async {
    if (_currentBilling == null) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updatePaymentStatus(
        userId,
        scheduleId,
        status,
      );

      _currentBilling = _currentBilling!.copyWith(
        paymentStatus: status,
        updatedAt: DateTime.now(),
      );

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status: ${e.toString()}';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset billing state
  void resetBilling() {
    _currentBilling = null;
    _billingItems.clear();
    _totalAmount = 0.0;
    notifyListeners();
  }
}

