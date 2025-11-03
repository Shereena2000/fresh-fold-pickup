import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/order_billing_model.dart';

class OrderBillingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or update billing details under user's payment_requests subcollection
  /// Path: users/{userId}/payment_requests/{scheduleId}
  Future<void> saveBillingDetails(OrderBillingModel billing) async {
    try {
      await _firestore
          .collection('users')
          .doc(billing.userId)
          .collection('payment_requests')
          .doc(billing.scheduleId)
          .set(billing.toMap());
    } catch (e) {
      throw Exception('Failed to save billing details: $e');
    }
  }

  /// Get billing details for a specific order
  Future<OrderBillingModel?> getBillingDetails(
    String userId,
    String scheduleId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_requests')
          .doc(scheduleId)
          .get();

      if (doc.exists) {
        return OrderBillingModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get billing details: $e');
    }
  }

  /// Get latest billing for an order
  Future<OrderBillingModel?> getLatestBilling(
    String userId,
    String scheduleId,
  ) async {
    return getBillingDetails(userId, scheduleId);
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String userId,
    String scheduleId,
    String status,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_requests')
          .doc(scheduleId)
          .update({
        'paymentStatus': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Stream billing details for real-time updates
  Stream<OrderBillingModel?> streamBilling(
    String userId,
    String scheduleId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_requests')
        .doc(scheduleId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return OrderBillingModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  /// Delete billing
  Future<void> deleteBilling(
    String userId,
    String scheduleId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_requests')
          .doc(scheduleId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete billing: $e');
    }
  }
}

