import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user_model.dart';
import '../../model/transaction_model.dart';
import '../investment-vm/investment_tier_vm.dart';

// Source of truth for Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// User Profile - Reacts to auth changes and fetches from Firestore
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (authUser) {
      if (authUser == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return null;
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      });
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});

// Transactions history for the current user
final userTransactionsProvider = StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (authUser) {
      if (authUser == null) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('transactions')
          .where('uid', isEqualTo: authUser.uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});

// Referral Activity (Transactions where current user is the referrer)
final referralTransactionsProvider = StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  final userProfileAsync = ref.watch(userProfileProvider);
  
  return userProfileAsync.when(
    data: (userProfile) {
      if (userProfile == null || userProfile.myReferralCode.isEmpty) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('transactions')
          .where('referrerCode', isEqualTo: userProfile.myReferralCode)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});

// Aggregated Profit Statistics
final profitStatsProvider = Provider.autoDispose<AsyncValue<Map<String, double>>>((ref) {
  final transactionsAsync = ref.watch(userTransactionsProvider);

  return transactionsAsync.whenData((transactions) {
    double today = 0;
    double yesterday = 0;
    double thisWeek = 0;
    double thisMonth = 0;
    double taskRewards = 0;
    double referralRewards = 0;
    double total = 0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    for (var tx in transactions) {
      final amount = tx.amount;
      // Only count positive earnings for profit summary
      if (amount <= 0 && tx.type != TransactionType.referralReward) continue; 

      final date = tx.timestamp;

      if (amount > 0) {
        total += amount;
        if (date.isAfter(todayStart)) {
          today += amount;
        } else if (date.isAfter(yesterdayStart)) {
          yesterday += amount;
        }
        if (date.isAfter(weekStart)) {
          thisWeek += amount;
        }
        if (date.isAfter(monthStart)) {
          thisMonth += amount;
        }
        if (tx.type == TransactionType.taskReward) {
          taskRewards += amount;
        } else if (tx.type == TransactionType.referralReward || tx.type == TransactionType.donationReceived) {
          referralRewards += amount;
        }
      }
    }

    return {
      'today': today,
      'yesterday': yesterday,
      'thisWeek': thisWeek,
      'thisMonth': thisMonth,
      'taskRewards': taskRewards,
      'referralRewards': referralRewards,
      'total': total,
    };
  });
});

// Daily Task Progress
final taskProgressProvider = Provider.autoDispose<AsyncValue<Map<String, int>>>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  final tiersAsync = ref.watch(investmentTiersProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return const AsyncValue.data({'completed': 0, 'total': 0, 'remaining': 0});
      
      return tiersAsync.when(
        data: (tiers) {
          final tierList = tiers.where((t) => t.title == user.activeTier).toList();
          
          if (tierList.isEmpty) {
             return AsyncValue.data({
              'completed': user.tasksCompletedToday,
              'total': 0,
              'remaining': 0,
            });
          }

          final tier = tierList.first;
          final maxTasksStr = tier.dailyTask.replaceAll(RegExp(r'[^0-9]'), '');
          final maxTasks = int.tryParse(maxTasksStr) ?? 0;

          return AsyncValue.data({
            'completed': user.tasksCompletedToday,
            'total': maxTasks,
            'remaining': (maxTasks - user.tasksCompletedToday).clamp(0, maxTasks),
          });
        },
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// Team members list
final teamListProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final userProfileAsync = ref.watch(userProfileProvider);
  
  return userProfileAsync.when(
    data: (userProfile) {
      if (userProfile == null || userProfile.myReferralCode.isEmpty) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});

final userViewModelProvider = Provider((ref) => UserViewModel());

class UserViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createDepositRequest({
    required String uid,
    required String userName,
    required double amount,
    required String transactionHash,
  }) async {
    try {
      await _firestore.collection('deposit_requests').add({
        'uid': uid,
        'userName': userName,
        'amount': amount,
        'transactionHash': transactionHash,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> addReferrer(String uid, String referralCode) async {
    try {
      final cleanCode = referralCode.trim().toUpperCase();
      
      // 1. Check if code is valid
      final referrerQuery = await _firestore
          .collection('users')
          .where('myReferralCode', isEqualTo: cleanCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) {
        return "Invalid referral code.";
      }

      final referrerDoc = referrerQuery.docs.first;
      if (referrerDoc.id == uid) {
        return "You cannot refer yourself.";
      }

      // 2. Update user profile
      await _firestore.collection('users').doc(uid).update({
        'referredBy': cleanCode,
      });

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendDonation(String senderUid, String targetEmailOrUid, double amount) async {
    try {
      if (amount <= 0) return "Amount must be greater than zero.";

      // Find member user document
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: targetEmailOrUid.trim())
          .limit(1)
          .get();

      DocumentReference targetDocRef;
      if (query.docs.isNotEmpty) {
        targetDocRef = query.docs.first.reference;
      } else {
        targetDocRef = _firestore.collection('users').doc(targetEmailOrUid.trim());
      }

      final senderDocRef = _firestore.collection('users').doc(senderUid);

      return await _firestore.runTransaction((transaction) async {
        final senderSnap = await transaction.get(senderDocRef);
        final targetSnap = await transaction.get(targetDocRef);

        if (!senderSnap.exists) return "Sender profile not found.";
        if (!targetSnap.exists) return "Target member not found in system.";

        final senderData = senderSnap.data() as Map<String, dynamic>;
        final targetData = targetSnap.data() as Map<String, dynamic>;

        final double senderBalance = (senderData['balance'] ?? 0.0).toDouble();
        final double targetBalance = (targetData['balance'] ?? 0.0).toDouble();

        if (senderBalance < amount) {
          return "Insufficient THB balance to fulfill donation.";
        }

        final String senderName = senderData['username'] ?? 'User';
        final String targetName = targetData['username'] ?? 'Member';

        transaction.update(senderDocRef, {'balance': senderBalance - amount});
        transaction.update(targetDocRef, {'balance': targetBalance + amount});

        final transId = _firestore.collection('transactions').doc().id;
        transaction.set(_firestore.collection('transactions').doc(transId), {
          'uid': senderUid,
          'userName': senderName,
          'referrerCode': senderData['referredBy'] ?? '',
          'amount': -amount,
          'type': TransactionType.donationSent.name,
          'description': 'Donated to $targetName',
          'timestamp': FieldValue.serverTimestamp(),
        });

        transaction.set(_firestore.collection('transactions').doc('${transId}_rec'), {
          'uid': targetSnap.id,
          'userName': targetName,
          'referrerCode': targetData['referredBy'] ?? '',
          'amount': amount,
          'type': TransactionType.donationReceived.name,
          'description': 'Donation from $senderName',
          'timestamp': FieldValue.serverTimestamp(),
        });

        return null;
      });
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> unlockTier(String uid, String tierTitle, double cost) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);

      final userSnap = await docRef.get();
      if (!userSnap.exists) return "User profile not found.";
      final userData = userSnap.data() as Map<String, dynamic>;
      final String referredBy = userData['referredBy'] ?? '';
      
      DocumentReference? referrerDocRef;
      if (referredBy.isNotEmpty) {
        final refQuery = await _firestore.collection('users')
            .where('myReferralCode', isEqualTo: referredBy)
            .limit(1).get();
        if (refQuery.docs.isNotEmpty) {
          referrerDocRef = refQuery.docs.first.reference;
        }
      }
      
      final DocumentReference? finalReferrerRef = referrerDocRef;

      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return "User profile not found.";

        final data = snapshot.data() as Map<String, dynamic>;
        final double currentBalance = (data['balance'] ?? 0.0).toDouble();
        final String username = data['username'] ?? 'User';

        if (currentBalance < cost) {
          return "Insufficient THB balance to unlock this VIP plan.";
        }

        // 1. Update user document
        transaction.update(docRef, {
          'balance': currentBalance - cost,
          'activeTier': tierTitle,
          'tasksCompletedToday': 0, 
          'lastTaskDate': FieldValue.serverTimestamp(),
          'planActivatedAt': FieldValue.serverTimestamp(),
        });

        // 2. Create user transaction record
        final transRef = _firestore.collection('transactions').doc();
        transaction.set(transRef, {
          'uid': uid,
          'userName': username,
          'referrerCode': referredBy,
          'amount': -cost,
          'type': TransactionType.planUnlock.name,
          'description': 'Unlocked VIP Tier: $tierTitle',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 3. Referral Commission Logic (5%)
        if (finalReferrerRef != null && cost > 0) {
          final commission = cost * 0.05;
          final referrerSnap = await transaction.get(finalReferrerRef);
          
          if (referrerSnap.exists) {
            final referrerData = referrerSnap.data() as Map<String, dynamic>;
            final double referrerBalance = (referrerData['balance'] ?? 0.0).toDouble();
            final double referrerTotalEarned = (referrerData['totalEarned'] ?? 0.0).toDouble();

            transaction.update(finalReferrerRef, {
              'balance': referrerBalance + commission,
              'totalEarned': referrerTotalEarned + commission,
            });

            final refTransRef = _firestore.collection('transactions').doc();
            transaction.set(refTransRef, {
              'uid': finalReferrerRef.id,
              'userName': referrerData['username'] ?? 'Referrer',
              'referrerCode': referrerData['referredBy'] ?? '',
              'amount': commission,
              'type': TransactionType.referralReward.name,
              'description': 'Referral Commission from $username ($tierTitle)',
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        }

        return null; // Success
      });
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> completeTaskReward(String uid, double rewardAmount, int maxTasks, String videoId, String videoTitle) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final transRef = _firestore.collection('transactions').doc();

      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return "User profile not found.";

        final data = snapshot.data() as Map<String, dynamic>;
        int currentTasks = data['tasksCompletedToday'] ?? 0;
        final double currentBalance = (data['balance'] ?? 0.0).toDouble();
        final double currentTotalEarned = (data['totalEarned'] ?? 0.0).toDouble();
        final String username = data['username'] ?? 'User';
        final String referredBy = data['referredBy'] ?? '';
        final List<String> watchedIds = List<String>.from(data['watchedVideoIds'] ?? []);

        // Daily reset logic
        final Timestamp? lastDateTs = data['lastTaskDate'] as Timestamp?;
        if (lastDateTs != null) {
          final lastDate = lastDateTs.toDate();
          final now = DateTime.now();
          if (lastDate.day != now.day || lastDate.month != now.month || lastDate.year != now.year) {
            currentTasks = 0;
          }
        }

        if (currentTasks >= maxTasks) {
          return "Daily limit reached for your active VIP tier.";
        }

        if (watchedIds.contains(videoId)) {
          return "You have already earned rewards for this video.";
        }

        watchedIds.add(videoId);

        transaction.update(docRef, {
          'balance': currentBalance + rewardAmount,
          'totalEarned': currentTotalEarned + rewardAmount,
          'tasksCompletedToday': currentTasks + 1,
          'lastTaskDate': FieldValue.serverTimestamp(),
          'watchedVideoIds': watchedIds,
        });

        transaction.set(transRef, {
          'uid': uid,
          'userName': username,
          'referrerCode': referredBy,
          'amount': rewardAmount,
          'type': TransactionType.taskReward.name,
          'description': 'Task Earned: $videoTitle',
          'timestamp': FieldValue.serverTimestamp(),
        });

        return null; // Success
      });
    } catch (e) {
      return e.toString();
    }
  }
}
