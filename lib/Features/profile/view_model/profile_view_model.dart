import 'package:flutter/material.dart';
import '../../auth/model/vendor_model.dart';
import '../../delivery/view_model/delivery_view_model.dart';

class ProfileViewModel extends ChangeNotifier {
  PickUpModel? _driverData;
  DeliveryViewModel? _deliveryViewModel;
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Set driver data from AuthViewModel
  void setDriverData(PickUpModel? driver) {
    _driverData = driver;
    notifyListeners();
  }
  
  /// Set delivery view model reference to get stats
  void setDeliveryViewModel(DeliveryViewModel deliveryViewModel) {
    _deliveryViewModel = deliveryViewModel;
    _deliveryViewModel!.addListener(notifyListeners);
  }
  
  @override
  void dispose() {
    _deliveryViewModel?.removeListener(notifyListeners);
    super.dispose();
  }
  
  /// Driver Profile Getters
  String get driverName => _driverData?.fullName ?? 'Guest Driver';
  String get driverId => _driverData?.uid ?? 'N/A';
  String get email => _driverData?.email ?? 'N/A';
  String? get profileImageUrl => _driverData?.profileImageUrl;
  String get phoneNumber => _driverData?.phoneNumber ?? 'Not provided';
  String get location => _driverData?.location ?? 'Not provided';
  String get vehicleType => _driverData?.vehicleType ?? 'Not specified';
  String get vehicleNumber => _driverData?.vehicleNumber ?? 'Not specified';
  
  /// Formatted joined date
  String get joinedDate {
    if (_driverData?.createdAt == null) return 'N/A';
    final date = _driverData!.createdAt;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }
  
  /// Get total deliveries from DeliveryViewModel
  int get totalDeliveries {
    if (_deliveryViewModel == null) return 0;
    return _deliveryViewModel!.myDeliveries.length;
  }
  
  /// Get completed deliveries count
  int get completedDeliveries {
    if (_deliveryViewModel == null) return 0;
    return _deliveryViewModel!.completedDeliveries.length;
  }
  
  /// Get active deliveries count
  int get activeDeliveries {
    if (_deliveryViewModel == null) return 0;
    return _deliveryViewModel!.activeDeliveries.length;
  }
  
  /// Mock rating (can be updated to fetch from Firebase)
  double get rating => 4.8;
  
  /// Check if profile is complete
  bool get isProfileComplete {
    if (_driverData == null) return false;
    return _driverData!.phoneNumber != null &&
        _driverData!.phoneNumber!.isNotEmpty &&
        _driverData!.location != null &&
        _driverData!.location!.isNotEmpty;
  }
  
  /// Get profile completion percentage
  double get profileCompletionPercentage {
    if (_driverData == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 7;
    
    if (_driverData!.fullName != null && _driverData!.fullName!.isNotEmpty) completedFields++;
    if (_driverData!.email != null && _driverData!.email!.isNotEmpty) completedFields++;
    if (_driverData!.phoneNumber != null && _driverData!.phoneNumber!.isNotEmpty) completedFields++;
    if (_driverData!.location != null && _driverData!.location!.isNotEmpty) completedFields++;
    if (_driverData!.vehicleType != null && _driverData!.vehicleType!.isNotEmpty) completedFields++;
    if (_driverData!.vehicleNumber != null && _driverData!.vehicleNumber!.isNotEmpty) completedFields++;
    completedFields++; // createdAt always exists
    
    return (completedFields / totalFields) * 100;
  }
  
  /// Refresh profile data
  Future<void> refreshProfile() async {
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

