import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../model/user_model.dart';
import 'local_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
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
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        await LocalStorageService.saveUserLoginStatus(
          true,
          uid,
          email.trim(),
          user.username,
        );
        // Also save language from firestore to local if available
        await LocalStorageService.saveLanguage(user.language);
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Invalid email or password. Please try again.";
      } else if (e.code == 'invalid-email') {
        return "The email address is badly formatted.";
      } else if (e.code == 'user-disabled') {
        return "This user account has been disabled.";
      } else if (e.code == 'too-many-requests') {
        return "Too many failed attempts. Please try again later.";
      }
      return e.message ?? "Authentication failed.";
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
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
      String currentLang = await LocalStorageService.getLanguage() ?? 'en';

      // 4. Save User Profile in Firestore - Start with 'None' plan
      UserModel newUser = UserModel(
        uid: uid,
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
