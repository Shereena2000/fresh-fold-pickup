import 'package:flutter/material.dart';
import '../../home/model/client_model.dart';
import '../../home/model/shedule_model.dart';
import '../../home/repository/order_manage_repository.dart';
import '../../home/view_model/home_view_model.dart';
import '../model/taken_order_model.dart';
import '../repository/delivery_repository.dart';

class DeliveryViewModel extends ChangeNotifier {
  final DeliveryRepository _deliveryRepository = DeliveryRepository();
  final OrderManageRepository _orderRepository = OrderManageRepository();

  String? _currentDriverId;
  List<TakenOrderModel> _takenOrders = [];
  Map<String, ScheduleModel> _schedulesCache = {};
  Map<String, ClientModel> _clientsCache = {};
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTakingOrder = false;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTakingOrder => _isTakingOrder;
  String get searchQuery => _searchQuery;

  /// Set current driver ID
  void setDriverId(String driverId) {
    _currentDriverId = driverId;
    notifyListeners();
  }

  /// Get all taken orders as OrderCardData
  List<OrderCardData> get myDeliveries {
    List<OrderCardData> deliveries = [];

    for (var takenOrder in _takenOrders) {
      final schedule = _schedulesCache[takenOrder.scheduleId];
      if (schedule != null) {
        deliveries.add(OrderCardData(
          schedule: schedule,
          client: _clientsCache[schedule.userId],
        ));
      }
    }

    return deliveries;
  }

  /// Get active deliveries (not yet delivered)
  List<OrderCardData> get activeDeliveries {
    final active = myDeliveries.where((order) {
      final status = order.schedule.status;
      return status != 'delivered' && status != 'paid';
    }).toList();
    
    return _filterDeliveries(active);
  }

  /// Get completed deliveries
  List<OrderCardData> get completedDeliveries {
    final completed = myDeliveries.where((order) {
      final status = order.schedule.status;
      return status == 'delivered' || status == 'paid';
    }).toList();
    
    return _filterDeliveries(completed);
  }
  
  /// Filter deliveries based on search query
  List<OrderCardData> _filterDeliveries(List<OrderCardData> deliveries) {
    if (_searchQuery.isEmpty) {
      return deliveries;
    }
    
    final query = _searchQuery.toLowerCase();
    
    return deliveries.where((order) {
      // Search by customer name
      final customerName = order.customerName.toLowerCase();
      if (customerName.contains(query)) return true;
      
      // Search by schedule ID
      final scheduleId = order.schedule.scheduleId.toLowerCase();
      if (scheduleId.contains(query)) return true;
      
      // Search by short schedule ID (last 8 characters)
      final shortId = order.orderId.toLowerCase();
      if (shortId.contains(query)) return true;
      
      return false;
    }).toList();
  }
  
  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Load driver's taken orders
  Future<void> loadMyDeliveries() async {
    if (_currentDriverId == null) {
      _errorMessage = 'Driver ID not set';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get list of taken order references
      _takenOrders = await _deliveryRepository.getDriverTakenOrders(_currentDriverId!);

      // Fetch actual schedule details for each taken order
      for (var takenOrder in _takenOrders) {
        if (!_schedulesCache.containsKey(takenOrder.scheduleId)) {
          try {
            final schedule = await _deliveryRepository.getScheduleDetails(
              userId: takenOrder.userId,
              scheduleId: takenOrder.scheduleId,
            );

            if (schedule != null) {
              _schedulesCache[takenOrder.scheduleId] = schedule;

              // Fetch client details
              if (!_clientsCache.containsKey(schedule.userId)) {
                final client = await _orderRepository.getUserDetails(schedule.userId);
                if (client != null) {
                  _clientsCache[schedule.userId] = client;
                }
              }
            }
          } catch (e) {
            debugPrint('Failed to fetch schedule ${takenOrder.scheduleId}: $e');
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load deliveries: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh deliveries
  Future<void> refreshDeliveries() async {
    _schedulesCache.clear();
    _clientsCache.clear();
    await loadMyDeliveries();
  }

  /// Take/Assign order to current driver
  Future<bool> takeOrder({
    required String userId,
    required String scheduleId,
  }) async {
    if (_currentDriverId == null) {
      _errorMessage = 'Driver ID not set';
      notifyListeners();
      return false;
    }

    _isTakingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if order is already taken
      final takenBy = await _deliveryRepository.isOrderTaken(userId, scheduleId);
      
      if (takenBy != null) {
        _errorMessage = takenBy == _currentDriverId 
            ? 'You have already taken this order'
            : 'This order has been taken by another driver';
        _isTakingOrder = false;
        notifyListeners();
        return false;
      }

      // Assign order to current driver
      await _deliveryRepository.assignOrderToDriver(
        driverId: _currentDriverId!,
        userId: userId,
        scheduleId: scheduleId,
      );

      // Refresh deliveries list
      await loadMyDeliveries();

      _isTakingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to take order: ${e.toString()}';
      _isTakingOrder = false;
      notifyListeners();
      return false;
    }
  }

  /// Release order from current driver
  Future<bool> releaseOrder(String scheduleId) async {
    if (_currentDriverId == null) return false;

    try {
      await _deliveryRepository.releaseOrder(
        driverId: _currentDriverId!,
        scheduleId: scheduleId,
      );

      // Refresh deliveries list
      await loadMyDeliveries();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to release order: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Check if specific order is taken
  Future<bool> isOrderTaken(String userId, String scheduleId) async {
    try {
      final takenBy = await _deliveryRepository.isOrderTaken(userId, scheduleId);
      return takenBy != null;
    } catch (e) {
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


