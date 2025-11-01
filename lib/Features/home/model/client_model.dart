import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String uid;
  final String phoneNumber;
  final String? fullName;
  final String? email;
  final String? location;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? profession;
  final String? city;
  final String? alternativePhone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClientModel({
    required this.uid,
    required this.phoneNumber,
    this.fullName,
    this.email,
    this.location,
    this.gender,
    this.dateOfBirth,
    this.profession,
    this.city,
    this.alternativePhone,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'email': email,
      'location': location,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profession': profession,
      'city': city,
      'alternativePhone': alternativePhone,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      fullName: map['fullName'],
      email: map['email'],
      location: map['location'],
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      profession: map['profession'],
      city: map['city'],
      alternativePhone: map['alternativePhone'],
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

  bool get isRegistered {
     return fullName != null && 
         fullName!.isNotEmpty && 
         location != null && 
         location!.isNotEmpty;
  }

  ClientModel copyWith({
    String? uid,
    String? phoneNumber,
    String? fullName,
    String? email,
    String? location,
    String? gender,
    DateTime? dateOfBirth,
    String? profession,
    String? city,
    String? alternativePhone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profession: profession ?? this.profession,
      city: city ?? this.city,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}