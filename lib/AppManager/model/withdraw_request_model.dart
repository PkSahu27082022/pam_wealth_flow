import 'package:cloud_firestore/cloud_firestore.dart';

enum WithdrawStatus { pending, approved, declined }

class WithdrawRequestModel {
  final String id;
  final String uid;
  final String userName;
  final double amount;
  final String paymentDetails; // Wallet address or bank info
  final WithdrawStatus status;
  final DateTime timestamp;

  WithdrawRequestModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.amount,
    required this.paymentDetails,
    required this.status,
    required this.timestamp,
  });

  factory WithdrawRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return WithdrawRequestModel(
      id: id,
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentDetails: map['paymentDetails'] ?? '',
      status: WithdrawStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => WithdrawStatus.pending,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'amount': amount,
      'paymentDetails': paymentDetails,
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
