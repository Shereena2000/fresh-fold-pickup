import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String scheduleId;
  final String userId;
  final String serviceType; 
  final String washType; 
  final String pickupLocation;
  final double? latitude;
  final double? longitude;
  final DateTime pickupDate;
  final String timeSlot;
  final String status; 
  final DateTime createdAt;
  final DateTime? updatedAt;

  ScheduleModel({
    required this.scheduleId,
    required this.userId,
    required this.serviceType,
    required this.washType,
    required this.pickupLocation,
    this.latitude,
    this.longitude,
    required this.pickupDate,
    required this.timeSlot,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'scheduleId': scheduleId,
      'userId': userId,
      'serviceType': serviceType,
      'washType': washType,
      'pickupLocation': pickupLocation,
      'latitude': latitude,
      'longitude': longitude,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'timeSlot': timeSlot,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      scheduleId: map['scheduleId'] ?? '',
      userId: map['userId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      washType: map['washType'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      pickupDate: (map['pickupDate'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Copy with method for updates
  ScheduleModel copyWith({
    String? scheduleId,
    String? userId,
    String? serviceType,
    String? washType,
    String? pickupLocation,
    double? latitude,
    double? longitude,
    DateTime? pickupDate,
    String? timeSlot,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      scheduleId: scheduleId ?? this.scheduleId,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      washType: washType ?? this.washType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pickupDate: pickupDate ?? this.pickupDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}