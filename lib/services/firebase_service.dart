import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool get isInitialized => Firebase.apps.isNotEmpty;

  static FirebaseAuth? get auth {
    try {
      return isInitialized ? FirebaseAuth.instance : null;
    } catch (e) {
      debugPrint('FirebaseAuth instance error: $e');
      return null;
    }
  }

  static FirebaseFirestore? get firestore {
    try {
      return isInitialized ? FirebaseFirestore.instance : null;
    } catch (e) {
      debugPrint('FirebaseFirestore instance error: $e');
      return null;
    }
  }

  /// Initialize Firebase with options
  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        debugPrint('✅ Firebase already initialized: ${Firebase.app().name}');
        return true;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      debugPrint('✅ Firebase successfully initialized for ApnaExpert (${DefaultFirebaseOptions.currentPlatform.projectId}).');
      return true;
    } catch (e) {
      debugPrint('⚠️ Firebase initialization error: $e');
      return false;
    }
  }
}
