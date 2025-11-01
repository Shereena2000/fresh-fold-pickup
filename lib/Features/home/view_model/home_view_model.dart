import 'package:flutter/material.dart';
import '../model/client_model.dart';
import '../model/shedule_model.dart';
import '../repository/order_manage_repository.dart';
import '../../../Settings/utils/p_colors.dart';

class OrderCardData {
  final ScheduleModel schedule;
  final ClientModel? client;

  OrderCardData({
    required this.schedule,
    this.client,
  });

  String get customerName => client?.fullName ?? 'Unknown';
  String get orderId => schedule.scheduleId;
  String get pickupDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = schedule.pickupDate.day.toString().padLeft(2, '0');
    final month = months[schedule.pickupDate.month - 1];
    final year = schedule.pickupDate.year;
    return '$day $month $year';
  }
  String get pickupTime => schedule.timeSlot;
  String get pickupAddress => schedule.pickupLocation;
  String get pickupPhone => client?.phoneNumber ?? '';
  String get statusLabel => schedule.status == 'confirmed' ? 'Pickup' : 'Deliver';
  Color get statusColor => schedule.status == 'confirmed' 
      ? PColors.primaryColor // Primary color for Pickup
      : PColors.secondoryColor; // Secondary color for Deliver

  bool get isToday {
    final now = DateTime.now();
    final orderDate = DateTime(schedule.pickupDate.year, schedule.pickupDate.month, schedule.pickupDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return orderDate == today;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final orderDate = DateTime(schedule.pickupDate.year, schedule.pickupDate.month, schedule.pickupDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return orderDate.isAfter(today);
  }
}

class HomeViewModel extends ChangeNotifier {
  final ShopkeeperOrderRepository _repository = ShopkeeperOrderRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<ScheduleModel> _allSchedules = [];
  Map<String, ClientModel> _clientsCache = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<OrderCardData> get todayPickups {
    return _getOrdersForToday().where((order) => order.schedule.status == 'confirmed').toList();
  }

  List<OrderCardData> get todayDeliveries {
    return _getOrdersForToday().where((order) => order.schedule.status == 'ready').toList();
  }

  List<OrderCardData> get todayOrders {
    return _getOrdersForToday();
  }

  List<OrderCardData> get upcomingOrders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _allSchedules
        .where((schedule) {
          final orderDate = DateTime(
            schedule.pickupDate.year,
            schedule.pickupDate.month,
            schedule.pickupDate.day,
          );
          return orderDate.isAfter(today) && 
                 (schedule.status == 'confirmed' || schedule.status == 'ready');
        })
        .map((schedule) => OrderCardData(
              schedule: schedule,
              client: _clientsCache[schedule.userId],
            ))
        .toList();
  }

  List<OrderCardData> _getOrdersForToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _allSchedules
        .where((schedule) {
          final orderDate = DateTime(
            schedule.pickupDate.year,
            schedule.pickupDate.month,
            schedule.pickupDate.day,
          );
          return orderDate == today && 
                 (schedule.status == 'confirmed' || schedule.status == 'ready');
        })
        .map((schedule) => OrderCardData(
              schedule: schedule,
              client: _clientsCache[schedule.userId],
            ))
        .toList();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allSchedules = await _repository.getAllOrders();
      
      // Fetch client details for all unique user IDs
      final Set<String> userIds = _allSchedules.map((s) => s.userId).toSet();
      
      for (String userId in userIds) {
        if (!_clientsCache.containsKey(userId)) {
          try {
            final client = await _repository.getUserDetails(userId);
            if (client != null) {
              _clientsCache[userId] = client;
            }
          } catch (e) {
            // Continue if client fetch fails
            debugPrint('Failed to fetch client $userId: $e');
          }
        }
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load orders: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> refreshOrders() async {
    _clientsCache.clear();
    await loadOrders();
  }
}

