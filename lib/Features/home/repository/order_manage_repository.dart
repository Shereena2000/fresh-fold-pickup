import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/client_model.dart';
import '../model/shedule_model.dart';

class ShopkeeperOrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all schedules from all users (for shopkeeper)
  Future<List<ScheduleModel>> getAllOrders() async {
    try {
      List<ScheduleModel> allOrders = [];
      
      // Get all users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      
      // For each user, get their schedules
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        
        QuerySnapshot schedulesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('schedules')
            .orderBy('createdAt', descending: true)
            .get();
        
        for (var scheduleDoc in schedulesSnapshot.docs) {
          Map<String, dynamic> scheduleData = scheduleDoc.data() as Map<String, dynamic>;
          // Ensure userId is set in the schedule data
          scheduleData['userId'] = userId;
          allOrders.add(ScheduleModel.fromMap(scheduleData));
        }
      }
      
      return allOrders;
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  /// Get orders by status
  Future<List<ScheduleModel>> getOrdersByStatus(String status) async {
    try {
      List<ScheduleModel> orders = [];
      
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        
        QuerySnapshot schedulesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('schedules')
            .where('status', isEqualTo: status)
            .orderBy('createdAt', descending: true)
            .get();
        
        for (var scheduleDoc in schedulesSnapshot.docs) {
          Map<String, dynamic> scheduleData = scheduleDoc.data() as Map<String, dynamic>;
          // Ensure userId is set in the schedule data
          scheduleData['userId'] = userId;
          orders.add(ScheduleModel.fromMap(scheduleData));
        }
      }
      
      return orders;
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String userId, String scheduleId, String newStatus) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('schedules')
          .doc(scheduleId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Get specific order details
  Future<ScheduleModel?> getOrderDetails(String userId, String scheduleId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('schedules')
          .doc(scheduleId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> scheduleData = doc.data() as Map<String, dynamic>;
        // Ensure userId is set in the schedule data
        scheduleData['userId'] = userId;
        return ScheduleModel.fromMap(scheduleData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order details: $e');
    }
  }

  /// Get user details
  Future<ClientModel?> getUserDetails(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return ClientModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user details: $e');
    }
  }

  /// Stream all orders for real-time updates
  Stream<List<ScheduleModel>> streamAllOrders() {
    // Note: This is a simplified version. For production, consider using Cloud Functions
    // or a better approach for querying across subcollections
    return _firestore.collection('users').snapshots().asyncMap((usersSnapshot) async {
      List<ScheduleModel> allOrders = [];
      
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        
        QuerySnapshot schedulesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('schedules')
            .get();
        
        for (var scheduleDoc in schedulesSnapshot.docs) {
          Map<String, dynamic> scheduleData = scheduleDoc.data() as Map<String, dynamic>;
          // Ensure userId is set in the schedule data
          scheduleData['userId'] = userId;
          allOrders.add(ScheduleModel.fromMap(scheduleData));
        }
      }
      
      return allOrders;
    });
  }
}
