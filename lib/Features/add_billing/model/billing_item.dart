import '../../PriceList/model/price_item_model.dart';

class BillingItem {
  final PriceItemModel priceItem;
  final String priceType; // 'dryWash', 'wetWash', or 'steamPress'
  int quantity;
  double unitPrice;

  BillingItem({
    required this.priceItem,
    required this.priceType,
    this.quantity = 0,
    required this.unitPrice,
  });

  double get itemTotal => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'itemId': priceItem.itemId,
      'itemName': priceItem.itemName,
      'priceType': priceType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'itemTotal': itemTotal,
    };
  }

  factory BillingItem.fromMap(Map<String, dynamic> map, PriceItemModel priceItem) {
    return BillingItem(
      priceItem: priceItem,
      priceType: map['priceType'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    );
  }

  BillingItem copyWith({
    PriceItemModel? priceItem,
    String? priceType,
    int? quantity,
    double? unitPrice,
  }) {
    return BillingItem(
      priceItem: priceItem ?? this.priceItem,
      priceType: priceType ?? this.priceType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

