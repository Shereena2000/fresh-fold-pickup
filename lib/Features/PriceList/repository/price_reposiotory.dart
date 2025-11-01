import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/price_item_model.dart';

class PriceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection paths
  String _getPriceListPath(String category) => 'priceList/$category/items';

  /// Create or Update Price Item
  Future<String> savePriceItem(String category, PriceItemModel item) async {
    try {
      CollectionReference itemsRef = _firestore.collection(_getPriceListPath(category));
      
      if (item.itemId.isEmpty) {
        // Create new item
        DocumentReference docRef = itemsRef.doc();
        PriceItemModel newItem = item.copyWith(
          itemId: docRef.id,
          createdAt: DateTime.now(),
        );
        await docRef.set(newItem.toMap());
        return docRef.id;
      } else {
        // Update existing item
        await itemsRef.doc(item.itemId).update(
          item.copyWith(updatedAt: DateTime.now()).toMap(),
        );
        return item.itemId;
      }
    } catch (e) {
      throw Exception('Failed to save price item: $e');
    }
  }

  /// Get all items for a category
  Future<List<PriceItemModel>> getCategoryItems(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getPriceListPath(category))
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => PriceItemModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get price items: $e');
    }
  }

  /// Stream items for a category (real-time)
  Stream<List<PriceItemModel>> streamCategoryItems(String category) {
    return _firestore
        .collection(_getPriceListPath(category))
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceItemModel.fromMap(doc.data()))
            .toList());
  }

  /// Delete Price Item
  Future<void> deletePriceItem(String category, String itemId) async {
    try {
      await _firestore
          .collection(_getPriceListPath(category))
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete price item: $e');
    }
  }

  /// Update item order for reordering
  Future<void> updateItemOrder(String category, String itemId, int newOrder) async {
    try {
      await _firestore
          .collection(_getPriceListPath(category))
          .doc(itemId)
          .update({'order': newOrder, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  /// Batch update orders
  Future<void> batchUpdateOrders(String category, List<PriceItemModel> items) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (int i = 0; i < items.length; i++) {
        DocumentReference docRef = _firestore
            .collection(_getPriceListPath(category))
            .doc(items[i].itemId);
        
        batch.update(docRef, {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update orders: $e');
    }
  }

  /// Initialize default items for a category (one-time setup)
  Future<void> initializeDefaultItems(String category) async {
    try {
      // Check if items already exist
      QuerySnapshot existing = await _firestore
          .collection(_getPriceListPath(category))
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return; // Already initialized
      }

      // Default items
      List<Map<String, dynamic>> defaultItems = [
        {'itemName': 'Shirt', 'dryWash': '50', 'wetWash': '60', 'steamPress': '40'},
        {'itemName': 'Trousers', 'dryWash': '70', 'wetWash': '80', 'steamPress': '40'},
        {'itemName': 'Jeans', 'dryWash': '65', 'wetWash': '75', 'steamPress': '80'},
        {'itemName': 'T-Shirt', 'dryWash': '40', 'wetWash': '50', 'steamPress': '40'},
      ];

      WriteBatch batch = _firestore.batch();

      for (int i = 0; i < defaultItems.length; i++) {
        DocumentReference docRef = _firestore
            .collection(_getPriceListPath(category))
            .doc();

        PriceItemModel item = PriceItemModel(
          itemId: docRef.id,
          itemName: defaultItems[i]['itemName']!,
          dryWash: defaultItems[i]['dryWash']!,
          wetWash: defaultItems[i]['wetWash']!,
          steamPress: defaultItems[i]['steamPress']!,
          order: i,
          createdAt: DateTime.now(),
        );

        batch.set(docRef, item.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to initialize default items: $e');
    }
  }
}