import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/vendor_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register user with email (for email/password auth) - Save to drivers collection
  Future<void> registerUserWithEmail({
    required String uid,
    required String username,
    required String email,
  }) async {
    PickUpModel driver =  PickUpModel(
      uid: uid,
      fullName: username,
      email: email,
      createdAt: DateTime.now(),
    );
    await saveDriverData(driver);
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Check if user is signed in
  bool isUserSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Save driver data to drivers/ collection
  Future<void> saveDriverData(PickUpModel user) async {
    print('════════════════════════════════════════');
    print('🔹 SAVING TO FIREBASE FIRESTORE');
    print('════════════════════════════════════════');
    print('   Collection: drivers');
    print('   Document ID: ${user.uid}');
    print('   profileImageUrl from model: ${user.profileImageUrl}');
    
    final dataToSave = user.toMap();
    print('   Data to save: $dataToSave');
    print('   profileImageUrl in map: ${dataToSave['profileImageUrl']}');
    
    try {
      await _firestore
          .collection('drivers')
          .doc(user.uid)
          .set(dataToSave, SetOptions(merge: true));
      
      print('✅ Firestore set() completed!');
      
      // Wait a moment for Firestore to process
      await Future.delayed(Duration(milliseconds: 500));
      
      // Verify it was saved
      final doc = await _firestore.collection('drivers').doc(user.uid).get();
      print('════════════════════════════════════════');
      print('🔍 VERIFICATION FROM FIREBASE');
      print('════════════════════════════════════════');
      print('   Document exists: ${doc.exists}');
      
      if (doc.exists) {
        final data = doc.data();
        print('   Full document data: $data');
        print('   profileImageUrl field: ${data?['profileImageUrl']}');
        print('   Field type: ${data?['profileImageUrl'].runtimeType}');
        
        if (data?['profileImageUrl'] == null) {
          print('⚠️  WARNING: profileImageUrl is NULL in Firebase!');
          print('   This means the field was not saved properly');
        } else {
          print('✅ SUCCESS: profileImageUrl is saved correctly!');
        }
      } else {
        print('❌ ERROR: Document does not exist!');
      }
      print('════════════════════════════════════════');
    } catch (e) {
      print('❌ Firebase save error: $e');
      rethrow;
    }
  }
  
  // Keep for backward compatibility (for vendors if needed)
  Future<void> saveVendorData(PickUpModel user) async {
    await _firestore
        .collection('vendor')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get driver data from Firestore (from drivers/ collection)
  Future<PickUpModel?> getDriverData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('drivers')
          .doc(uid)
          .get();

      if (doc.exists) {
        return PickUpModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load driver data: $e');
    }
  }

  /// Stream driver data for real-time updates
  Stream<PickUpModel?> streamDriverData(String uid) {
    return _firestore
        .collection('drivers')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return PickUpModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
  
  /// Get vendor data from Firestore
  Future<PickUpModel?> getVendorData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('vendor')
          .doc(uid)
          .get();

      if (doc.exists) {
        return PickUpModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load vendor data: $e');
    }
  }

  /// Stream vendor data for real-time updates
  Stream<PickUpModel?> streamVendorData(String uid) {
    return _firestore
        .collection('vendor')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return PickUpModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}