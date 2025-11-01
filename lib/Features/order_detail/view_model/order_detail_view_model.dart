import 'package:flutter/material.dart';
import '../../home/view_model/home_view_model.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final OrderCardData orderData;
  
  OrderDetailViewModel({required this.orderData});

  // Order Information getters
  String get customerName => orderData.customerName;
  String get orderId => orderData.orderId;
  String get status => orderData.schedule.status;
  String get statusLabel => orderData.statusLabel;
  Color get statusColor => orderData.statusColor;
  String get serviceType => orderData.schedule.serviceType;
  String get washType => orderData.schedule.washType;
  String get pickupDate => orderData.pickupDate;
  String get timeSlot => orderData.schedule.timeSlot;
  String get pickupLocation => orderData.schedule.pickupLocation;
  
  // Formatted status from ScheduleModel for display
  String get formattedStatus {
    if (status.isEmpty) return 'N/A';
    // Capitalize first letter of each word
    return status.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
  
  // Pickup Information getters
  String get pickupTime => orderData.pickupTime;
  String get pickupAddress => orderData.pickupAddress;
  double? get latitude => orderData.schedule.latitude;
  double? get longitude => orderData.schedule.longitude;
  
  // Contact Information getters
  String get phoneNumber => orderData.pickupPhone;
  String get email => orderData.client?.email ?? 'N/A';
  String get alternativePhone => orderData.client?.alternativePhone ?? 'N/A';
  
  // Additional client info
  String get city => orderData.client?.city ?? 'N/A';
  String get location => orderData.client?.location ?? 'N/A';
  String get profession => orderData.client?.profession ?? 'N/A';
  
  // Status checks
  bool get isConfirmed => status == 'confirmed';
  bool get isReady => status == 'ready';
  bool get isPickedUp => status == 'picked_up';
  bool get isDelivered => status == 'delivered';
  bool get isPaid => status == 'paid';
  
  // Get formatted time slot for display
  String get formattedTimeSlot {
    // If timeSlot is already formatted like "10:00 AM - 12:00 PM", return it
    if (timeSlot.contains('-')) {
      return timeSlot;
    }
    // Otherwise return as is
    return timeSlot;
  }
  
  // Status update methods (to be implemented with repository)
  Future<void> updateStatus(String newStatus) async {
    // TODO: Implement status update with repository
    // For now, just notify listeners
    notifyListeners();
  }
  
  // Check if a status button should be enabled
  bool isStatusButtonEnabled(String targetStatus) {
    switch (targetStatus) {
      case 'picked_up':
        return isConfirmed;
      case 'delivered':
        return isPickedUp;
      case 'paid':
        return isDelivered;
      default:
        return false;
    }
  }
  
  // Check if current status matches target
  bool isCurrentStatus(String targetStatus) {
    return status.toLowerCase() == targetStatus.toLowerCase();
  }
}

