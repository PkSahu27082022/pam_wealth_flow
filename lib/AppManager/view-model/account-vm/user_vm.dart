import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user_model.dart';

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UserModel.fromMap(snapshot.data()!);
  });
});

final userViewModelProvider = Provider((ref) => UserViewModel());

class UserViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> unlockTier(String uid, String tierTitle, double cost) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return "User profile not found.";

        final data = snapshot.data()!;
        final double currentBalance = (data['balance'] ?? 0.0).toDouble();

        if (currentBalance < cost) {
          return "Insufficient THB balance to unlock this VIP plan.";
        }

        transaction.update(docRef, {
          'balance': currentBalance - cost,
          'activeTier': tierTitle,
          'tasksCompletedToday': 0, // reset tasks for the new plan
          'lastTaskDate': FieldValue.serverTimestamp(),
        });

        return null; // Success
      });
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> completeTaskReward(String uid, double rewardAmount, int maxTasks) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);

      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return "User profile not found.";

        final data = snapshot.data()!;
        final int currentTasks = data['tasksCompletedToday'] ?? 0;
        final double currentBalance = (data['balance'] ?? 0.0).toDouble();

        if (currentTasks >= maxTasks) {
          return "Daily limit reached for your active VIP tier.";
        }

        transaction.update(docRef, {
          'balance': currentBalance + rewardAmount,
          'tasksCompletedToday': currentTasks + 1,
          'lastTaskDate': FieldValue.serverTimestamp(),
        });

        return null; // Success
      });
    } catch (e) {
      return e.toString();
    }
  }
}
