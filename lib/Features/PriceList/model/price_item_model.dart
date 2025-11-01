import 'package:cloud_firestore/cloud_firestore.dart';

class PriceItemModel {
  final String itemId;
  final String itemName;
  final String dryWash;
  final String wetWash;
  final String steamPress;
  final int order; // For sorting
  final DateTime createdAt;
  final DateTime? updatedAt;

  PriceItemModel({
    required this.itemId,
    required this.itemName,
    required this.dryWash,
    required this.wetWash,
    required this.steamPress,
    required this.order,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'dryWash': dryWash,
      'wetWash': wetWash,
      'steamPress': steamPress,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory PriceItemModel.fromMap(Map<String, dynamic> map) {
    return PriceItemModel(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      dryWash: map['dryWash'] ?? '0',
      wetWash: map['wetWash'] ?? '0',
      steamPress: map['steamPress'] ?? '0',
      order: map['order'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  PriceItemModel copyWith({
    String? itemId,
    String? itemName,
    String? dryWash,
    String? wetWash,
    String? steamPress,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PriceItemModel(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      dryWash: dryWash ?? this.dryWash,
      wetWash: wetWash ?? this.wetWash,
      steamPress: steamPress ?? this.steamPress,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PriceListCategory {
  final String categoryId;
  final String categoryName; // "regular", "express", "premium"
  final String displayName; // "Regular (2-3 Days)", etc.
  final List<PriceItemModel> items;

  PriceListCategory({
    required this.categoryId,
    required this.categoryName,
    required this.displayName,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'displayName': displayName,
    };
  }

  factory PriceListCategory.fromMap(Map<String, dynamic> map) {
    return PriceListCategory(
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      displayName: map['displayName'] ?? '',
      items: [],
    );
  }
}