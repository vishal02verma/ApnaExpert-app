import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  // ==========================================
  // 👑 ADMIN EMAILS LIST
  // ==========================================
  // 👑 ADMIN EMAILS LIST
  // Add any email or name here to give it full Admin access:
  // ==========================================
  static const List<String> adminEmails = [
    'admin@apnaexpert.in',
  ];

  static bool isEmailAdmin(String email) {
    final clean = email.trim().toLowerCase();
    return adminEmails.any((e) => e.trim().toLowerCase() == clean);
  }

  AuthProvider() {
    _restoreFirebaseSession();
  }

  Future<void> _restoreFirebaseSession() async {
    try {
      final fbAuth = FirebaseService.auth;
      final fbUser = fbAuth?.currentUser;
      if (fbUser != null && fbUser.email != null) {
        final email = fbUser.email!.toLowerCase();
        debugPrint('🔥 [AuthProvider] Found active Firebase user: $email (UID: ${fbUser.uid})');

        var doc = await FirestoreService.getUser(fbUser.uid);
        UserModel? user;
        if (doc != null) {
          user = UserModel.fromMap(doc);
        } else {
          user = await FirestoreService.findUserByEmail(email);
        }

        if (user != null) {
          if (isEmailAdmin(email) && user.role != UserRole.admin) {
            user = user.copyWith(role: UserRole.admin);
          }
          _savedAddresses.clear();
          if (user.savedAddresses.isNotEmpty) {
            _savedAddresses.addAll(user.savedAddresses);
          }
          if (user.address != null && user.address!.trim().isNotEmpty) {
            if (!_savedAddresses.contains(user.address!.trim())) {
              _savedAddresses.insert(0, user.address!.trim());
            }
          }
          _currentUser = user.copyWith(savedAddresses: List.from(_savedAddresses));
          final existing = _allUsers.indexWhere((u) => u.id == user!.id || u.email.toLowerCase() == email);
          if (existing != -1) {
            _allUsers[existing] = _currentUser;
          } else {
            _allUsers.insert(0, _currentUser);
          }
          _isAuthenticated = true;
          debugPrint('🔥 [AuthProvider] Restored session with ${_savedAddresses.length} saved addresses from Firestore');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [AuthProvider] Error restoring session: $e');
    }
  }

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Authentication State
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _authError;
  String? get authError => _authError;

  void clearError() {
    _authError = null;
    notifyListeners();
  }

  // Saved addresses (dynamic user-saved addresses)
  final List<String> _savedAddresses = [];
  List<String> get savedAddresses => List.unmodifiable(_savedAddresses);

  Future<void> addSavedAddress(String address) async {
    final clean = address.trim();
    if (clean.isEmpty) return;
    if (!_savedAddresses.contains(clean)) {
      _savedAddresses.add(clean);
    }
    _currentUser = _currentUser.copyWith(
      address: _currentUser.address ?? clean,
      savedAddresses: List.from(_savedAddresses),
    );
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _allUsers[idx] = _currentUser;
    }
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirestoreService.saveUser(_currentUser);
        debugPrint('🔥 [Firestore] Address added & saved for user: ${_currentUser.id} ($clean)');
      } catch (e) {
        debugPrint('⚠️ [Firestore] Error saving user address: $e');
      }
    }
  }

  Future<void> removeSavedAddress(String address) async {
    final clean = address.trim();
    _savedAddresses.remove(clean);
    _currentUser = _currentUser.copyWith(
      savedAddresses: List.from(_savedAddresses),
      address: _currentUser.address == clean
          ? (_savedAddresses.isNotEmpty ? _savedAddresses.first : null)
          : _currentUser.address,
    );
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _allUsers[idx] = _currentUser;
    }
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirestoreService.saveUser(_currentUser);
        debugPrint('🔥 [Firestore] Address removed from Firestore for user: ${_currentUser.id}');
      } catch (e) {
        debugPrint('⚠️ [Firestore] Error updating user savedAddresses: $e');
      }
    }
  }

  Future<void> updateAddress(String address) async {
    final clean = address.trim();
    if (clean.isEmpty) return;
    if (!_savedAddresses.contains(clean)) {
      _savedAddresses.insert(0, clean);
    }
    _currentUser = _currentUser.copyWith(
      address: clean,
      savedAddresses: List.from(_savedAddresses),
    );
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _allUsers[idx] = _currentUser;
    }
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirestoreService.saveUser(_currentUser);
        debugPrint('🔥 [Firestore] User address successfully saved in Firestore: $clean');
      } catch (e) {
        debugPrint('⚠️ [Firestore] Error saving user address: $e');
      }
    }
  }

  UserModel _currentUser = UserModel(
    id: 'cust_001',
    name: 'Rahul Sharma',
    email: 'rahul.sharma@example.com',
    phone: '+91 98765 43210',
    avatarUrl: '',
    role: UserRole.customer,
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    password: 'password123',
    address: null,
  );

  UserRole? _activePortalMode;
  UserModel get currentUser => _currentUser;
  UserRole get currentRole => _activePortalMode ?? _currentUser.role;
  UserRole get baseAccountRole => _currentUser.role;
  bool get isAdmin => _currentUser.role == UserRole.admin;
  bool get isWorkerAccount => _currentUser.role == UserRole.provider;
  bool get isInCustomerModeAsWorker => _currentUser.role == UserRole.provider && currentRole == UserRole.customer;

  void switchPortalMode(UserRole mode) {
    _activePortalMode = mode;
    notifyListeners();
  }

  void switchToCustomerMode() {
    _activePortalMode = UserRole.customer;
    notifyListeners();
  }

  void switchToWorkerMode() {
    _activePortalMode = UserRole.provider;
    notifyListeners();
  }

  final List<UserModel> _allUsers = [
    UserModel(
      id: 'cust_001',
      name: 'Rahul Sharma',
      email: 'rahul.sharma@example.com',
      phone: '+91 98765 43210',
      avatarUrl: '',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      password: 'password123',
      address: null,
    ),
    UserModel(
      id: 'cust_002',
      name: 'Priya Patel',
      email: 'priya.patel@example.com',
      phone: '+91 98112 34567',
      avatarUrl: '',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      password: 'password123',
      address: 'B-12, Green Park Main, New Delhi',
    ),
    UserModel(
      id: 'wrk_001',
      name: 'Ramesh Kumar',
      email: 'ramesh.plumbing@example.com',
      phone: '+91 98991 22334',
      avatarUrl: '',
      role: UserRole.provider,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      password: 'password123',
      serviceCategory: 'cat_plumbing',
      hourlyRate: 299.0,
    ),
    UserModel(
      id: 'adm_001',
      name: 'Vikram Malhotra (Admin)',
      email: 'admin@apnaexpert.in',
      phone: '+91 1800 200 4567',
      avatarUrl: '',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      password: 'password123',
      adminPasscode: 'ADMIN2026',
    ),
  ];

  List<UserModel> get allUsers => List.unmodifiable(_allUsers);

  // Login with role validation and Firebase / Firestore sync
  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final normalizedEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();
    final bool isTargetAdmin = isEmailAdmin(normalizedEmail);

    bool isLocalDemoAccount(String em) {
      return em.endsWith('@apnaexpert.in') ||
          em == 'rahul.sharma@example.com' ||
          em == 'priya.patel@example.com' ||
          em == 'ramesh.plumbing@example.com';
    }

    bool validateRoleAndBlocked(UserModel user) {
      if (user.isBlocked) {
        _isLoading = false;
        _authError = 'This account has been suspended by the administrator.';
        notifyListeners();
        return false;
      }
      if (user.role != role && user.role != UserRole.admin && !isTargetAdmin) {
        // Allow a service worker (e.g. plumber) to log in as Customer to book another worker (e.g. electrician)
        if (user.role == UserRole.provider && role == UserRole.customer) {
          _activePortalMode = UserRole.customer;
          return true;
        }

        final actualRoleName = user.role == UserRole.customer
            ? 'Customer'
            : user.role == UserRole.provider
                ? 'Service Worker'
                : 'Admin';
        final requestedRoleName = role == UserRole.customer
            ? 'Customer'
            : role == UserRole.provider
                ? 'Service Worker'
                : 'Admin';

        _isLoading = false;
        _authError = 'This account is registered as a $actualRoleName, but you selected $requestedRoleName mode.';
        notifyListeners();
        return false;
      }
      _activePortalMode = role;
      return true;
    }

    // 1. Primary: If Firebase is initialized, authenticate securely with Firebase Auth
    if (FirebaseService.isInitialized && FirebaseService.auth != null) {
      UserCredential? credential;
      FirebaseAuthException? authException;

      try {
        debugPrint('🔥 [FirebaseAuth] Attempting remote login for: $normalizedEmail');
        try {
          credential = await FirebaseService.auth!.signInWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          // If failed with wrong password/invalid credential and password has whitespace, retry with cleanPassword
          if ((e.code == 'wrong-password' || e.code == 'invalid-credential') &&
              cleanPassword != password &&
              cleanPassword.isNotEmpty) {
            try {
              credential = await FirebaseService.auth!.signInWithEmailAndPassword(
                email: normalizedEmail,
                password: cleanPassword,
              );
            } catch (_) {
              authException = e;
            }
          } else {
            authException = e;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [FirebaseAuth] General login error: $e');
      }

      // If Firebase Auth succeeded:
      if (credential?.user != null) {
        final uid = credential!.user!.uid;
        debugPrint('🔥 [FirebaseAuth] Remote login successful. UID: $uid');

        var docData = await FirestoreService.getUser(uid);
        UserModel user;
        if (docData != null) {
          user = UserModel.fromMap(docData, defaultPassword: cleanPassword);
        } else {
          final byEmail = await FirestoreService.findUserByEmail(normalizedEmail);
          if (byEmail != null) {
            user = byEmail.copyWith(password: cleanPassword);
          } else {
            user = UserModel(
              id: uid,
              name: credential.user!.displayName?.isNotEmpty == true
                  ? credential.user!.displayName!
                  : normalizedEmail.split('@').first,
              email: normalizedEmail,
              phone: credential.user!.phoneNumber ?? '',
              avatarUrl: credential.user!.photoURL ?? '',
              role: isTargetAdmin ? UserRole.admin : role,
              createdAt: DateTime.now(),
              password: cleanPassword,
            );
            await FirestoreService.saveUser(user);
          }
        }

        if (isTargetAdmin && user.role != UserRole.admin) {
          user = user.copyWith(role: UserRole.admin);
        }

        if (!validateRoleAndBlocked(user)) {
          return false;
        }

        _savedAddresses.clear();
        if (user.savedAddresses.isNotEmpty) {
          _savedAddresses.addAll(user.savedAddresses);
        }
        if (user.address != null && user.address!.trim().isNotEmpty) {
          if (!_savedAddresses.contains(user.address!.trim())) {
            _savedAddresses.insert(0, user.address!.trim());
          }
        }
        _currentUser = user.copyWith(savedAddresses: List.from(_savedAddresses));

        final existingIdx = _allUsers.indexWhere((u) => u.email.toLowerCase() == normalizedEmail);
        if (existingIdx != -1) {
          _allUsers[existingIdx] = _currentUser;
        } else {
          _allUsers.insert(0, _currentUser);
        }

        _isAuthenticated = true;
        _isLoading = false;
        _authError = null;
        debugPrint('🔥 [AuthProvider] Remote login succeeded with ${_savedAddresses.length} saved addresses from Firestore');
        notifyListeners();
        return true;
      }

      // If Firebase Auth failed with an exception:
      if (authException != null) {
        debugPrint('⚠️ [FirebaseAuth] Login code: ${authException.code} - ${authException.message}');

        // If it is a demo account, allow logging in with local demo credentials
        if (isLocalDemoAccount(normalizedEmail)) {
          final demoMatches = _allUsers.where((u) => u.email.toLowerCase() == normalizedEmail).toList();
          if (demoMatches.isNotEmpty) {
            UserModel demoUser = demoMatches.first;
            if (demoUser.password == password || demoUser.password == cleanPassword) {
              if (isTargetAdmin && demoUser.role != UserRole.admin) {
                demoUser = demoUser.copyWith(role: UserRole.admin);
              }
              if (!validateRoleAndBlocked(demoUser)) return false;
              _savedAddresses.clear();
              if (demoUser.savedAddresses.isNotEmpty) {
                _savedAddresses.addAll(demoUser.savedAddresses);
              }
              if (demoUser.address != null && demoUser.address!.trim().isNotEmpty) {
                if (!_savedAddresses.contains(demoUser.address!.trim())) {
                  _savedAddresses.insert(0, demoUser.address!.trim());
                }
              }
              _currentUser = demoUser.copyWith(savedAddresses: List.from(_savedAddresses));
              _isAuthenticated = true;
              _isLoading = false;
              _authError = null;
              notifyListeners();
              return true;
            }
          }
        }

        if (authException.code == 'wrong-password' || authException.code == 'invalid-credential') {
          _isLoading = false;
          _authError = 'Incorrect password. Please try again.';
          notifyListeners();
          return false;
        } else if (authException.code == 'user-not-found') {
          _isLoading = false;
          _authError = 'No account found with this email ($normalizedEmail). Please check your email or sign up first.';
          notifyListeners();
          return false;
        } else if (authException.code == 'user-disabled') {
          _isLoading = false;
          _authError = 'This account has been disabled.';
          notifyListeners();
          return false;
        } else if (authException.code == 'operation-not-allowed') {
          _isLoading = false;
          _authError = 'Email/Password sign-in is disabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
          notifyListeners();
          return false;
        } else if (authException.code == 'too-many-requests') {
          _isLoading = false;
          _authError = 'Too many attempts. Please try again later.';
          notifyListeners();
          return false;
        }
      }
    }

    // 2. Offline / Demo / In-Memory Fallback
    final matchedUsers = _allUsers.where((u) => u.email.toLowerCase() == normalizedEmail).toList();
    if (matchedUsers.isNotEmpty) {
      UserModel user = matchedUsers.first;
      if (user.password == password || user.password == cleanPassword) {
        if (isTargetAdmin && user.role != UserRole.admin) {
          user = user.copyWith(role: UserRole.admin);
        }
        if (!validateRoleAndBlocked(user)) return false;
        _currentUser = user;
        _isAuthenticated = true;
        _isLoading = false;
        _authError = null;
        notifyListeners();
        return true;
      }
    }

    // 3. Fallback: Check Firestore directly by email (e.g. if created outside FirebaseAuth)
    try {
      final rawUser = await FirestoreService.findUserByEmail(normalizedEmail);
      if (rawUser != null) {
        UserModel firestoreUser = rawUser;
        if (isTargetAdmin && firestoreUser.role != UserRole.admin) {
          firestoreUser = firestoreUser.copyWith(role: UserRole.admin);
        }

        if (firestoreUser.password == password || firestoreUser.password == cleanPassword) {
          if (!validateRoleAndBlocked(firestoreUser)) return false;

          final idx = _allUsers.indexWhere((u) => u.email.toLowerCase() == normalizedEmail);
          if (idx != -1) {
            _allUsers[idx] = firestoreUser;
          } else {
            _allUsers.insert(0, firestoreUser);
          }

          _currentUser = firestoreUser;
          _isAuthenticated = true;
          _isLoading = false;
          _authError = null;
          notifyListeners();
          return true;
        } else {
          _isLoading = false;
          _authError = 'Incorrect password. Please try again.';
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore] User lookup fallback error: $e');
    }

    // 4. Truly not found anywhere
    _isLoading = false;
    _authError = 'No account found with this email ($normalizedEmail). Please check your email or sign up first.';
    notifyListeners();
    return false;
  }

  // Sign up with role support
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? address,
    String? serviceCategory,
    double? hourlyRate,
    String? adminPasscode,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (_allUsers.any((u) => u.email.toLowerCase() == normalizedEmail)) {
      _isLoading = false;
      _authError = 'An account with this email address ($normalizedEmail) already exists.';
      notifyListeners();
      return false;
    }

    // Validate admin passcode
    if (role == UserRole.admin) {
      if (adminPasscode == null || (adminPasscode != 'ADMIN2026' && adminPasscode != 'APNAEXPERT_ADMIN')) {
        _isLoading = false;
        _authError = 'Invalid Admin Passcode. Use authorization code: ADMIN2026';
        notifyListeners();
        return false;
      }
    }

    String newId = role == UserRole.customer
        ? 'cust_${DateTime.now().millisecondsSinceEpoch % 100000}'
        : role == UserRole.provider
            ? 'wrk_${DateTime.now().millisecondsSinceEpoch % 100000}'
            : 'adm_${DateTime.now().millisecondsSinceEpoch % 100000}';

    // If Firebase is configured, authenticate via FirebaseAuth
    if (FirebaseService.isInitialized) {
      try {
        final auth = FirebaseService.auth;
        if (auth != null) {
          final credential = await auth.createUserWithEmailAndPassword(
            email: normalizedEmail,
            password: cleanPassword,
          );
          if (credential.user != null) {
            newId = credential.user!.uid;
            debugPrint('🔥 [FirebaseAuth] User registered in Firebase. UID: $newId');
          }
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('⚠️ [FirebaseAuth] Register code: ${e.code}: ${e.message}');
        if (e.code == 'email-already-in-use') {
          try {
            final credential = await FirebaseService.auth?.signInWithEmailAndPassword(
              email: normalizedEmail,
              password: cleanPassword,
            );
            if (credential?.user != null) {
              newId = credential!.user!.uid;
            }
          } catch (_) {
            _isLoading = false;
            _authError = 'This email is already registered. Please log in.';
            notifyListeners();
            return false;
          }
        } else if (e.code == 'operation-not-allowed') {
          _isLoading = false;
          _authError = 'Email/Password sign-in is disabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
          notifyListeners();
          return false;
        } else if (e.code == 'weak-password') {
          _isLoading = false;
          _authError = 'Password must be at least 6 characters long.';
          notifyListeners();
          return false;
        } else if (e.code == 'invalid-email') {
          _isLoading = false;
          _authError = 'The email address is invalid.';
          notifyListeners();
          return false;
        }
      } catch (e) {
        debugPrint('⚠️ [FirebaseAuth] General register exception: $e');
      }
    }

    final newUser = UserModel(
      id: newId,
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      avatarUrl: '',
      role: role,
      createdAt: DateTime.now(),
      password: cleanPassword,
      address: address?.trim(),
      serviceCategory: serviceCategory,
      hourlyRate: hourlyRate,
      adminPasscode: adminPasscode,
    );

    _allUsers.insert(0, newUser);
    _currentUser = newUser;
    _isAuthenticated = true;
    _isLoading = false;
    _authError = null;

    if (address != null && address.trim().isNotEmpty) {
      addSavedAddress(address.trim());
    }

    // Persist to Cloud Firestore
    await FirestoreService.saveUser(newUser);

    notifyListeners();
    return true;
  }

  // Logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _activePortalMode = null;
    _authError = null;
    _savedAddresses.clear();
    _currentUser = UserModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      avatarUrl: '',
      role: UserRole.customer,
      createdAt: DateTime.now(),
      password: '',
    );
    try {
      await FirebaseService.auth?.signOut();
      debugPrint('🔥 [FirebaseAuth] User logged out successfully.');
    } catch (e) {
      debugPrint('⚠️ [FirebaseAuth] Error during sign out: $e');
    }
    notifyListeners();
  }

  void switchRole(UserRole role) {
    final matchingUser = _allUsers.firstWhere(
      (u) => u.role == role,
      orElse: () => _currentUser,
    );
    _currentUser = matchingUser;
    notifyListeners();
  }

  void toggleUserBlockStatus(String userId) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index] = _allUsers[index].copyWith(
        isBlocked: !_allUsers[index].isBlocked,
      );
      if (_currentUser.id == userId) {
        _currentUser = _allUsers[index];
      }
      notifyListeners();
    }
  }

  Future<void> updateProfilePhoto(String newAvatarUrl) async {
    _currentUser = _currentUser.copyWith(avatarUrl: newAvatarUrl);
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _allUsers[idx] = _currentUser;
    }
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirestoreService.saveUser(_currentUser);
        debugPrint('🔥 [Firestore] Profile photo saved for user: ${_currentUser.id}');
      } catch (e) {
        debugPrint('⚠️ [Firestore] Error saving profile photo: $e');
      }
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String email,
    String? avatarUrl,
    String? address,
  }) async {
    final cleanAddr = address?.trim();
    if (cleanAddr != null && cleanAddr.isNotEmpty && !_savedAddresses.contains(cleanAddr)) {
      _savedAddresses.insert(0, cleanAddr);
    }
    _currentUser = _currentUser.copyWith(
      name: name,
      phone: phone,
      email: email,
      avatarUrl: avatarUrl ?? _currentUser.avatarUrl,
      address: cleanAddr ?? _currentUser.address,
      savedAddresses: List.from(_savedAddresses),
    );
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _allUsers[idx] = _currentUser;
    }
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirestoreService.saveUser(_currentUser);
        debugPrint('🔥 [Firestore] Profile details saved for user: ${_currentUser.id}');
      } catch (e) {
        debugPrint('⚠️ [Firestore] Error saving profile details: $e');
      }
    }
  }
}
