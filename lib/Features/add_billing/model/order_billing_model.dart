import 'package:cloud_firestore/cloud_firestore.dart';

class OrderBillingModel {
  final String billingId;
  final String scheduleId;
  final String userId;
  final String serviceType;
  final String washType;
  final List<BillingItemData> items;
  final double totalAmount;
  final String paymentStatus; // 'pending', 'pay_request', 'paid', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderBillingModel({
    required this.billingId,
    required this.scheduleId,
    required this.userId,
    required this.serviceType,
    required this.washType,
    required this.items,
    required this.totalAmount,
    this.paymentStatus = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'billingId': billingId,
      'scheduleId': scheduleId,
      'userId': userId,
      'serviceType': serviceType,
      'washType': washType,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory OrderBillingModel.fromMap(Map<String, dynamic> map) {
    return OrderBillingModel(
      billingId: map['billingId'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      userId: map['userId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      washType: map['washType'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => BillingItemData.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  OrderBillingModel copyWith({
    String? billingId,
    String? scheduleId,
    String? userId,
    String? serviceType,
    String? washType,
    List<BillingItemData>? items,
    double? totalAmount,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderBillingModel(
      billingId: billingId ?? this.billingId,
      scheduleId: scheduleId ?? this.scheduleId,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      washType: washType ?? this.washType,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BillingItemData {
  final String itemId;
  final String itemName;
  final String priceType;
  final int quantity;
  final double unitPrice;
  final double itemTotal;

  BillingItemData({
    required this.itemId,
    required this.itemName,
    required this.priceType,
    required this.quantity,
    required this.unitPrice,
    required this.itemTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'priceType': priceType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'itemTotal': itemTotal,
    };
  }

  factory BillingItemData.fromMap(Map<String, dynamic> map) {
    return BillingItemData(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      priceType: map['priceType'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      itemTotal: (map['itemTotal'] ?? 0).toDouble(),
    );
  }
}

