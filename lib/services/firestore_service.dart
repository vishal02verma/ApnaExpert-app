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
      await db.collection('bookings').doc(booking.id).set(booking.toMap());

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

  static Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? workerId,
    String? workerName,
    String? workerPhone,
    DateTime? completedAt,
    String? cancellationReason,
  }) async {
    final db = _db;
    if (db == null) return false;
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (workerId != null && workerId.isNotEmpty) updateData['selectedWorkerId'] = workerId;
      if (workerName != null && workerName.isNotEmpty) updateData['selectedWorkerName'] = workerName;
      if (workerPhone != null && workerPhone.isNotEmpty) updateData['selectedWorkerPhone'] = workerPhone;
      if (completedAt != null) updateData['completedAt'] = completedAt.toIso8601String();
      if (cancellationReason != null) updateData['cancellationReason'] = cancellationReason;

      await db.collection('bookings').doc(bookingId).update(updateData);
      lastError = null;
      debugPrint('✅ [Firestore] Booking $bookingId status updated to ${status.name}');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] updateBookingStatus error: $e');
      return false;
    }
  }

  static Future<bool> updateBookingReview(String bookingId, ReviewModel review) async {
    final db = _db;
    if (db == null) return false;
    try {
      await db.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.reviewed.name,
        'review': review.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      lastError = null;
      debugPrint('✅ [Firestore] Booking $bookingId review saved to Firestore');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] updateBookingReview error: $e');
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>? streamBookings() {
    final db = _db;
    if (db == null) return null;
    return db.collection('bookings').snapshots();
  }

  static Future<bool> sendChatMessage(String bookingId, ChatMessage msg) async {
    final db = _db;
    if (db == null) return false;
    try {
      await db.collection('bookings').doc(bookingId).collection('messages').doc(msg.id).set(msg.toMap());
      return true;
    } catch (e) {
      debugPrint('⚠️ [Firestore] sendChatMessage error: $e');
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>? streamChatMessages(String bookingId) {
    final db = _db;
    if (db == null) return null;
    return db.collection('bookings').doc(bookingId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  // ---------------- WORKER OPERATIONS ----------------
  static Future<bool> saveWorker(WorkerModel worker) async {
    final db = _db;
    if (db == null) return false;
    try {
      debugPrint('🔥 [Firestore] Saving worker in "workers/${worker.id}" (isAvailable: ${worker.isAvailable})...');
      await db.collection('workers').doc(worker.id).set(worker.toMap(), SetOptions(merge: true));
      lastError = null;
      debugPrint('✅ [Firestore] Worker saved successfully: ${worker.name} (isAvailable: ${worker.isAvailable})');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] saveWorker error: $e');
      _logHelpfulHint(e.toString());
      return false;
    }
  }

  static Future<bool> updateWorkerAvailability(String workerId, bool isAvailable) async {
    final db = _db;
    if (db == null) return false;
    try {
      debugPrint('🔥 [Firestore] Updating worker "$workerId" isAvailable -> $isAvailable...');
      await db.collection('workers').doc(workerId).set({
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      lastError = null;
      debugPrint('✅ [Firestore] Worker "$workerId" availability updated to $isAvailable');
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [Firestore] updateWorkerAvailability error: $e');
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
