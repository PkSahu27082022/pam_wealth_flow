import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { deposit, withdrawal, planUnlock, taskReward, donationSent, donationReceived, referralReward }

class TransactionModel {
  final String id;
  final String uid;
  final String userName;
  final String? referrerCode; // The referral code of the person who referred this user
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.uid,
    required this.userName,
    this.referrerCode,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? 'User',
      referrerCode: map['referrerCode'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.deposit,
      ),
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'referrerCode': referrerCode,
      'amount': amount,
      'type': type.name,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
