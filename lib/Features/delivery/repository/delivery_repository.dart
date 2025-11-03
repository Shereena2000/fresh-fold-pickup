import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/taken_order_model.dart';
import '../../home/model/shedule_model.dart';

class DeliveryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Assign order to driver
  /// Stores reference at: drivers/{driverId}/taken_orders/{scheduleId}
  Future<void> assignOrderToDriver({
    required String driverId,
    required String userId,
    required String scheduleId,
  }) async {
    try {
      debugPrint('Assigning order to driver:');
      debugPrint('  driverId: $driverId');
      debugPrint('  userId: $userId');
      debugPrint('  scheduleId: $scheduleId');

      final takenOrder = TakenOrderModel(
        scheduleId: scheduleId,
        userId: userId,
        takenAt: DateTime.now(),
        status: 'assigned',
      );

      // Save order reference under driver
      await _firestore
          .collection('drivers')
          .doc(driverId)
          .collection('taken_orders')
          .doc(scheduleId)
          .set(takenOrder.toMap());

      debugPrint('Order assigned successfully');
    } catch (e) {
      debugPrint('Error assigning order: $e');
      throw Exception('Failed to assign order: $e');
    }
  }

  /// Get all taken orders for a driver (just references)
  Future<List<TakenOrderModel>> getDriverTakenOrders(String driverId) async {
    try {
      final querySnapshot = await _firestore
          .collection('drivers')
          .doc(driverId)
          .collection('taken_orders')
          .orderBy('takenAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TakenOrderModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get taken orders: $e');
    }
  }

  /// Stream driver's taken orders in real-time
  Stream<List<TakenOrderModel>> streamDriverTakenOrders(String driverId) {
    return _firestore
        .collection('drivers')
        .doc(driverId)
        .collection('taken_orders')
        .orderBy('takenAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TakenOrderModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Check if an order is already taken by any driver
  /// Returns the driverId if taken, null if available
  Future<String?> isOrderTaken(String userId, String scheduleId) async {
    try {
      // Query all drivers to see if any has this order
      final driversSnapshot = await _firestore.collection('drivers').get();

      for (var driverDoc in driversSnapshot.docs) {
        final orderDoc = await _firestore
            .collection('drivers')
            .doc(driverDoc.id)
            .collection('taken_orders')
            .doc(scheduleId)
            .get();

        if (orderDoc.exists) {
          return driverDoc.id; // Order is taken by this driver
        }
      }

      return null; // Order is available
    } catch (e) {
      debugPrint('Error checking if order is taken: $e');
      return null;
    }
  }

  /// Release/Unassign order from driver
  Future<void> releaseOrder({
    required String driverId,
    required String scheduleId,
  }) async {
    try {
      await _firestore
          .collection('drivers')
          .doc(driverId)
          .collection('taken_orders')
          .doc(scheduleId)
          .delete();

      debugPrint('Order released from driver');
    } catch (e) {
      throw Exception('Failed to release order: $e');
    }
  }

  /// Update status of taken order
  Future<void> updateTakenOrderStatus({
    required String driverId,
    required String scheduleId,
    required String newStatus,
  }) async {
    try {
      await _firestore
          .collection('drivers')
          .doc(driverId)
          .collection('taken_orders')
          .doc(scheduleId)
          .update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update taken order status: $e');
    }
  }

  /// Get specific schedule details for a taken order
  Future<ScheduleModel?> getScheduleDetails({
    required String userId,
    required String scheduleId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('schedules')
          .doc(scheduleId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['userId'] = userId; // Ensure userId is set
        return ScheduleModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get schedule details: $e');
    }
  }
  
  /// Get all driver IDs (for filtering taken orders)
  Future<List<String>> getAllDrivers() async {
    try {
      final querySnapshot = await _firestore.collection('drivers').get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting all drivers: $e');
      return [];
    }
  }
}

