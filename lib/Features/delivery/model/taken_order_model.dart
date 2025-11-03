import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for storing order reference under driver
/// Stored at: drivers/{driverId}/taken_orders/{scheduleId}
class TakenOrderModel {
  final String scheduleId;
  final String userId;  // Customer userId to find the actual schedule
  final DateTime takenAt;
  final String status;  // Track status: "assigned", "picked_up", "delivered", etc.

  TakenOrderModel({
    required this.scheduleId,
    required this.userId,
    required this.takenAt,
    this.status = 'assigned',
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'scheduleId': scheduleId,
      'userId': userId,
      'takenAt': Timestamp.fromDate(takenAt),
      'status': status,
    };
  }

  // Create from Firestore document
  factory TakenOrderModel.fromMap(Map<String, dynamic> map) {
    return TakenOrderModel(
      scheduleId: map['scheduleId'] ?? '',
      userId: map['userId'] ?? '',
      takenAt: map['takenAt'] is Timestamp
          ? (map['takenAt'] as Timestamp).toDate()
          : DateTime.parse(map['takenAt']),
      status: map['status'] ?? 'assigned',
    );
  }

  // Copy with method for updates
  TakenOrderModel copyWith({
    String? scheduleId,
    String? userId,
    DateTime? takenAt,
    String? status,
  }) {
    return TakenOrderModel(
      scheduleId: scheduleId ?? this.scheduleId,
      userId: userId ?? this.userId,
      takenAt: takenAt ?? this.takenAt,
      status: status ?? this.status,
    );
  }
}


