import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../model/user_model.dart';
import 'local_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a unique 6-digit numeric userId
  Future<String> _generateUniqueUserId() async {
    final rnd = Random();
    while (true) {
      final candidate = (100000 + rnd.nextInt(900000)).toString();
      final query = await _firestore
          .collection('users')
          .where('userId', isEqualTo: candidate)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        return candidate;
      }
    }
  }

  /// Ensure every user doc has a 6-digit userId in Firestore
  Future<String> ensureUserId(String uid, String currentUserId) async {
    if (currentUserId.isNotEmpty) return currentUserId;
    final newUserId = await _generateUniqueUserId();
    try {
      await _firestore.collection('users').doc(uid).set({
        'userId': newUserId,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error setting userId: $e");
    }
    return newUserId;
  }

  /// Generate a unique 6-character alphanumeric referral code
  String _generateReferralCode(String username) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    String randomSuffix = String.fromCharCodes(Iterable.generate(
      4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));

    // Clean username prefix (max 3 chars, uppercase)
    String prefix = username.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    if (prefix.length > 3) prefix = prefix.substring(0, 3);
    if (prefix.isEmpty) prefix = 'USR';

    return '$prefix$randomSuffix';
  }

  /// Get Current User Model
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
        if (user.userId.isEmpty) {
          final newUserId = await ensureUserId(uid, user.userId);
          return UserModel(
            uid: user.uid,
            userId: newUserId,
            username: user.username,
            email: user.email,
            myReferralCode: user.myReferralCode,
            referredBy: user.referredBy,
            language: user.language,
            createdAt: user.createdAt,
            activeTier: user.activeTier,
            balance: user.balance,
            totalEarned: user.totalEarned,
            tasksCompletedToday: user.tasksCompletedToday,
            lastTaskDate: user.lastTaskDate,
            planActivatedAt: user.planActivatedAt,
            watchedVideoIds: user.watchedVideoIds,
            role: user.role,
          );
        }
        return user;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  /// Update User Language in Firestore
  Future<void> updateUserLanguage(String uid, String language) async {
    try {
      await _firestore.collection('users').doc(uid).update({'language': language});
    } catch (e) {
      print("Error updating language: $e");
    }
  }

  /// Login User with Email and Password
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;
      final cleanEmail = email.trim().toLowerCase();

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      UserModel user;
      if (userDoc.exists && userDoc.data() != null) {
        user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, docId: userDoc.id);
      } else {
        final bool isAdminEmail = cleanEmail == 'wealthadmin@gmail.com' || cleanEmail.contains('admin');
        user = UserModel(
          uid: uid,
          username: userCredential.user?.displayName ?? 'Pam Wealth Flow',
          email: email.trim(),
          myReferralCode: '',
          referredBy: '',
          language: 'en',
          role: isAdminEmail ? 'admin' : 'user',
        );
      }

      // Ensure 6-digit userId exists
      if (user.userId.isEmpty) {
        final newUserId = await ensureUserId(uid, user.userId);
        user = UserModel(
          uid: user.uid,
          userId: newUserId,
          username: user.username,
          email: user.email,
          myReferralCode: user.myReferralCode,
          referredBy: user.referredBy,
          language: user.language,
          createdAt: user.createdAt,
          activeTier: user.activeTier,
          balance: user.balance,
          totalEarned: user.totalEarned,
          tasksCompletedToday: user.tasksCompletedToday,
          lastTaskDate: user.lastTaskDate,
          planActivatedAt: user.planActivatedAt,
          watchedVideoIds: user.watchedVideoIds,
          role: user.role,
        );
      }

      final bool isAdmin = user.isAdmin || cleanEmail == 'wealthadmin@gmail.com';
      if (isAdmin && user.role != 'admin') {
        user = UserModel(
          uid: user.uid,
          userId: user.userId,
          username: user.username,
          email: user.email,
          myReferralCode: user.myReferralCode,
          referredBy: user.referredBy,
          language: user.language,
          createdAt: user.createdAt,
          activeTier: user.activeTier,
          balance: user.balance,
          totalEarned: user.totalEarned,
          tasksCompletedToday: user.tasksCompletedToday,
          lastTaskDate: user.lastTaskDate,
          planActivatedAt: user.planActivatedAt,
          watchedVideoIds: user.watchedVideoIds,
          role: 'admin',
        );
        await _firestore.collection('users').doc(uid).set({
          'role': 'admin',
        }, SetOptions(merge: true));
      }

      await LocalStorageService.saveUserLoginStatus(
        true,
        uid,
        email.trim(),
        user.username,
        role: user.role,
      );
      if (user.language.isNotEmpty) {
        await LocalStorageService.saveLanguage(user.language);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception("Invalid email or password. Please try again.");
      } else if (e.code == 'invalid-email') {
        throw Exception("The email address is badly formatted.");
      } else if (e.code == 'user-disabled') {
        throw Exception("This user account has been disabled.");
      } else if (e.code == 'too-many-requests') {
        throw Exception("Too many failed attempts. Please try again later.");
      }
      throw Exception(e.message ?? "Authentication failed.");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  /// Register User with Email, Password, Username, and Optional Referral Code
  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? enteredReferralCode,
  }) async {
    try {
      // 1. Validation
      if (password != confirmPassword) {
        return "Passwords do not match.";
      }
      if (username.trim().isEmpty) {
        return "Username is required.";
      }

      // 2. Validate Referral Code if provided
      String validReferralCode = '';
      if (enteredReferralCode != null && enteredReferralCode.trim().isNotEmpty) {
        String cleanCode = enteredReferralCode.trim().toUpperCase();

        var referrerQuery = await _firestore
            .collection('users')
            .where('myReferralCode', isEqualTo: cleanCode)
            .limit(1)
            .get();

        if (referrerQuery.docs.isEmpty) {
          return "Invalid referral code entered.";
        }
        validReferralCode = cleanCode;
      }

      // 3. Create Firebase Auth User
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;
      String uniqueMyCode = _generateReferralCode(username);
      String uniqueUserId = await _generateUniqueUserId();
      String currentLang = await LocalStorageService.getLanguage() ?? 'en';

      // 4. Save User Profile in Firestore - Start with 'None' plan
      UserModel newUser = UserModel(
        uid: uid,
        userId: uniqueUserId,
        username: username.trim(),
        email: email.trim(),
        myReferralCode: uniqueMyCode,
        referredBy: validReferralCode,
        language: currentLang,
        createdAt: DateTime.now(),
        activeTier: 'None',
        balance: 0.0,
        totalEarned: 0.0,
        tasksCompletedToday: 0,
        watchedVideoIds: [],
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      // 5. Store in Local Storage
      await LocalStorageService.saveUserLoginStatus(
        true,
        uid,
        email.trim(),
        username.trim(),
        role: newUser.role,
      );

      return null; // Success (No error message)
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "The email address is already in use by another account.";
      } else if (e.code == 'invalid-email') {
        return "The email address is badly formatted.";
      } else if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      }
      return e.message ?? "Registration failed.";
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    }
  }

  /// Logout User
  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
    await _auth.signOut();
    await LocalStorageService.clearUserData();
  }

  /// Send Password Reset Email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found with this email address.";
      } else if (e.code == 'invalid-email') {
        return "The email address is badly formatted.";
      }
      return e.message ?? "Failed to send reset email.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  /// Fetch the list of users who registered using [myReferralCode]
  Future<List<Map<String, dynamic>>> getMyReferredUsers(String myReferralCode) async {
    try {
      if (myReferralCode.isEmpty) return [];

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('referredBy', isEqualTo: myReferralCode)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching referrals: $e");
      return [];
    }
  }
}
