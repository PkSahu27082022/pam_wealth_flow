import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/deposit_request_model.dart';
import '../model/transaction_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // PAGE 1: Statistics
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final usersSnap = await _firestore.collection('users').get();
      final List<UserModel> allUsers = usersSnap.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

      Map<String, int> planCounts = {};
      double totalBalance = 0;

      for (var user in allUsers) {
        planCounts[user.activeTier] = (planCounts[user.activeTier] ?? 0) + 1;
        totalBalance += user.balance;
      }

      // Total deposits from approved requests
      final approvedSnap = await _firestore.collection('deposit_requests')
          .where('status', isEqualTo: 'approved')
          .get();
      
      double totalDeposits = 0;
      for (var doc in approvedSnap.docs) {
        totalDeposits += (doc.data()['amount'] ?? 0.0).toDouble();
      }

      return {
        'totalUsers': allUsers.length,
        'planCounts': planCounts,
        'totalDeposits': totalDeposits,
        'totalCurrentBalance': totalBalance,
      };
    } catch (e) {
      print("Error fetching admin stats: $e");
      return {};
    }
  }

  // PAGE 2: Configuration
  Future<void> updateWalletAddress(String address) async {
    await _firestore.collection('config').doc('payment').set({
      'walletAddress': address,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getWalletAddress() async {
    final doc = await _firestore.collection('config').doc('payment').get();
    return doc.data()?['walletAddress'];
  }

  // PAGE 2: Custom Deposit (Manual Admin Action)
  Future<String?> manualDeposit(String targetUid, double amount) async {
    try {
      final docRef = _firestore.collection('users').doc(targetUid);
      
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return "User ID not found.";

        final data = snapshot.data() as Map<String, dynamic>;
        final double currentBalance = (data['balance'] ?? 0.0).toDouble();

        transaction.update(docRef, {'balance': currentBalance + amount});

        // Log transaction
        final transRef = _firestore.collection('transactions').doc();
        transaction.set(transRef, {
          'uid': targetUid,
          'userName': data['username'] ?? 'User',
          'amount': amount,
          'type': TransactionType.deposit.name,
          'description': 'Admin Manual Deposit',
          'timestamp': FieldValue.serverTimestamp(),
        });

        return null;
      });
    } catch (e) {
      return e.toString();
    }
  }

  // PAGE 3: Approval System
  Stream<List<DepositRequestModel>> getDepositRequests(DepositStatus status) {
    return _firestore
        .collection('deposit_requests')
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => DepositRequestModel.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<String?> processDepositRequest(String requestId, bool approve) async {
    try {
      final reqRef = _firestore.collection('deposit_requests').doc(requestId);
      
      return await _firestore.runTransaction((transaction) async {
        final reqSnap = await transaction.get(reqRef);
        if (!reqSnap.exists) return "Request not found.";
        
        final reqData = reqSnap.data() as Map<String, dynamic>;
        if (reqData['status'] != 'pending') return "Request already processed.";

        if (approve) {
          final uid = reqData['uid'];
          final amount = (reqData['amount'] ?? 0.0).toDouble();
          final userRef = _firestore.collection('users').doc(uid);
          final userSnap = await transaction.get(userRef);
          
          if (userSnap.exists) {
            final userData = userSnap.data() as Map<String, dynamic>;
            final double currentBalance = (userData['balance'] ?? 0.0).toDouble();
            transaction.update(userRef, {'balance': currentBalance + amount});
            
            // Log transaction
            final transRef = _firestore.collection('transactions').doc();
            transaction.set(transRef, {
              'uid': uid,
              'userName': reqData['userName'],
              'amount': amount,
              'type': TransactionType.deposit.name,
              'description': 'Approved Deposit: ${reqData['transactionHash']}',
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
          transaction.update(reqRef, {'status': 'approved'});
        } else {
          transaction.update(reqRef, {'status': 'declined'});
        }
        return null;
      });
    } catch (e) {
      return e.toString();
    }
  }
}
