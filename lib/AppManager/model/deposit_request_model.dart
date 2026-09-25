import 'package:cloud_firestore/cloud_firestore.dart';

enum DepositStatus { pending, approved, declined }

class DepositRequestModel {
  final String id;
  final String uid;
  final String userName;
  final double amount;
  final String transactionHash;
  final DepositStatus status;
  final DateTime timestamp;

  DepositRequestModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.amount,
    required this.transactionHash,
    required this.status,
    required this.timestamp,
  });

  factory DepositRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return DepositRequestModel(
      id: id,
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      transactionHash: map['transactionHash'] ?? '',
      status: DepositStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DepositStatus.pending,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'amount': amount,
      'transactionHash': transactionHash,
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
