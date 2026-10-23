import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/booking_request.dart';
import '../models/worker_model.dart';
import '../models/payout_model.dart';

class FirestoreService {
  static String? lastError;

  static FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) {
      lastError = 'Firebase not initialized yet';
      return null;
    }
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      lastError = 'Firestore instance error: $e';
      debugPrint('⚠️ $lastError');
      return null;
    }
  }

  /// Test connection to Firestore
  static Future<String> testConnection() async {
    final db = _db;
    if (db == null) {
      return 'Firebase App not initialized';
    }
    try {
      debugPrint('🔥 [Firestore] Testing connection to ${Firebase.app().options.projectId}...');
      final testRef = db.collection('_test_ping').doc('status');
      await testRef.set({
        'status': 'online',
        'timestamp': FieldValue.serverTimestamp(),
        'app': 'ApnaExpert',
      });
      debugPrint('✅ [Firestore] Connection test SUCCESSFUL!');
      lastError = null;
      return 'SUCCESS';
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] Connection test FAILED: $e');
      _logHelpfulHint(e.toString());
      return 'FAILED: $e';
    }
  }

  // ---------------- USER OPERATIONS ----------------
  static Future<bool> saveUser(UserModel user) async {
    final db = _db;
    if (db == null) {
      debugPrint('⚠️ [Firestore] Cannot save user: Firebase not ready.');
      return false;
    }
    try {
      debugPrint('🔥 [Firestore] Saving user to "users/${user.id}" (${user.email}, ${user.role.name})...');
      await db.collection('users').doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'avatarUrl': user.avatarUrl,
        'role': user.role.name,
        'isBlocked': user.isBlocked,
        'createdAt': user.createdAt.toIso8601String(),
        'address': user.address,
        'savedAddresses': user.savedAddresses,
        'serviceCategory': user.serviceCategory,
        'hourlyRate': user.hourlyRate,
        if (user.password.isNotEmpty) 'password': user.password,
      }, SetOptions(merge: true));

      lastError = null;
      debugPrint('✅ [Firestore] User saved successfully in Firestore: ${user.name} (${user.id})');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] saveUser ERROR: $e');
      _logHelpfulHint(e.toString());
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = _db;
    if (db == null) return null;
    try {
      final doc = await db.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] getUser error: $e');
      return null;
    }
  }

  static Future<UserModel?> getUserModel(String userId) async {
    final data = await getUser(userId);
    if (data != null) {
      return UserModel.fromMap(data);
    }
    return null;
  }

  static Future<UserModel?> findUserByEmail(String email) async {
    final db = _db;
    if (db == null) return null;
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final query = await db
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [Firestore] findUserByEmail error: $e');
      return null;
    }
  }

  // ---------------- BOOKING OPERATIONS ----------------
  static Future<bool> createBooking(BookingRequest booking) async {
    final db = _db;
    if (db == null) return false;
    try {
      debugPrint('🔥 [Firestore] Creating booking in "bookings/${booking.id}"...');
      await db.collection('bookings').doc(booking.id).set({
        'id': booking.id,
        'customerId': booking.customerId,
        'customerName': booking.customerName,
        'customerPhone': booking.customerPhone,
        'categoryId': booking.categoryId,
        'categoryTitle': booking.categoryTitle,
        'problemDescription': booking.problemDescription,
        'urgency': booking.urgency,
        'address': booking.address,
        'landmark': booking.landmark,
        'selectedWorkerId': booking.selectedWorkerId,
        'selectedWorkerName': booking.selectedWorkerName,
        'selectedWorkerPhone': booking.selectedWorkerPhone,
        'estimatedCost': booking.estimatedCost,
        'discountAmount': booking.discountAmount,
        'paymentMethod': booking.paymentMethod,
        'status': booking.status.name,
        'scheduledTime': booking.scheduledTime,
        'securityOtp': booking.securityOtp,
        'createdAt': booking.createdAt.toIso8601String(),
        'completedAt': booking.completedAt?.toIso8601String(),
      });

      lastError = null;
      debugPrint('✅ [Firestore] Booking created successfully: ${booking.id}');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] createBooking error: $e');
      _logHelpfulHint(e.toString());
      return false;
    }
  }

  static Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    final db = _db;
    if (db == null) return false;
    try {
      await db.collection('bookings').doc(bookingId).update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      lastError = null;
      debugPrint('✅ [Firestore] Booking $bookingId status updated to ${status.name}');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] updateBookingStatus error: $e');
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>? streamBookings() {
    final db = _db;
    if (db == null) return null;
    return db.collection('bookings').orderBy('createdAt', descending: true).snapshots();
  }

  // ---------------- WORKER OPERATIONS ----------------
  static Future<bool> saveWorker(WorkerModel worker) async {
    final db = _db;
    if (db == null) return false;
    try {
      debugPrint('🔥 [Firestore] Saving worker in "workers/${worker.id}"...');
      await db.collection('workers').doc(worker.id).set({
        'id': worker.id,
        'userId': worker.userId,
        'name': worker.name,
        'phone': worker.phone,
        'avatarUrl': worker.avatarUrl,
        'categoryId': worker.categoryId,
        'categoryName': worker.categoryName,
        'rating': worker.rating,
        'totalReviews': worker.totalReviews,
        'hourlyRate': worker.hourlyRate,
        'distanceKm': worker.distanceKm,
        'experience': worker.experience,
        'isAvailable': worker.isAvailable,
        'isVerified': worker.isVerified,
        'bio': worker.bio,
      }, SetOptions(merge: true));

      lastError = null;
      debugPrint('✅ [Firestore] Worker saved successfully: ${worker.name}');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] saveWorker error: $e');
      _logHelpfulHint(e.toString());
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>? streamWorkers() {
    final db = _db;
    if (db == null) return null;
    return db.collection('workers').snapshots();
  }

  // ---------------- PAYOUT / WITHDRAWAL OPERATIONS ----------------
  static Future<bool> createPayoutRequest(PayoutRequestModel payout) async {
    final db = _db;
    if (db == null) return false;
    try {
      debugPrint('🔥 [Firestore] Creating payout request in "payouts/${payout.id}" (₹${payout.amount})...');
      await db.collection('payouts').doc(payout.id).set(payout.toMap());
      lastError = null;
      debugPrint('✅ [Firestore] Payout request created successfully: ${payout.id}');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] createPayoutRequest error: $e');
      _logHelpfulHint(e.toString());
      return false;
    }
  }

  static Future<bool> updatePayoutStatus(
    String payoutId,
    PayoutStatus status, {
    String? reference,
    String? adminNote,
  }) async {
    final db = _db;
    if (db == null) return false;
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'processedAt': DateTime.now().toIso8601String(),
      };
      if (reference != null) updateData['transactionReference'] = reference;
      if (adminNote != null) updateData['adminNote'] = adminNote;

      await db.collection('payouts').doc(payoutId).update(updateData);
      lastError = null;
      debugPrint('✅ [Firestore] Payout $payoutId status updated to ${status.name}');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] updatePayoutStatus error: $e');
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>? streamPayouts() {
    final db = _db;
    if (db == null) return null;
    return db.collection('payouts').orderBy('createdAt', descending: true).snapshots();
  }

  static Future<List<PayoutRequestModel>> getPayoutsForWorker(String workerId) async {
    final db = _db;
    if (db == null) return [];
    try {
      final snapshot = await db
          .collection('payouts')
          .where('workerId', isEqualTo: workerId)
          .get();
      return snapshot.docs
          .map((doc) => PayoutRequestModel.fromMap(doc.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('❌ [Firestore] getPayoutsForWorker error: $e');
      return [];
    }
  }

  static void _logHelpfulHint(String errorStr) {
    if (errorStr.toLowerCase().contains('permission-denied') || errorStr.toLowerCase().contains('permission_denied')) {
      debugPrint('💡 [Firestore HINT]: In Firebase Console > Firestore Database > Rules tab:');
      debugPrint('   allow read, write: if true;');
    } else if (errorStr.toLowerCase().contains('not-found') || errorStr.toLowerCase().contains('does not exist')) {
      debugPrint('💡 [Firestore HINT]: In Firebase Console > Build > Firestore Database, click "Create Database".');
    }
  }
}
