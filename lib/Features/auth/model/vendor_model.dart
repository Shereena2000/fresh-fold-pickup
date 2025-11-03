import 'package:cloud_firestore/cloud_firestore.dart';

class  PickUpModel {
  final String uid;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? location;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

   PickUpModel({
    required this.uid,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.location,
    this.vehicleType,
    this.vehicleNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory PickUpModel.fromMap(Map<String, dynamic> map) {
    return PickUpModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      location: map['location'],
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
                ? (map['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  PickUpModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? location,
    String? vehicleType,
    String? vehicleNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PickUpModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
