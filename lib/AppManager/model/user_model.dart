import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String myReferralCode;
  final String referredBy;
  final String language;
  final DateTime? createdAt;
  final String activeTier;
  final double balance;
  final double totalEarned;
  final int tasksCompletedToday;
  final DateTime? lastTaskDate;
  final DateTime? planActivatedAt;
  final List<String> watchedVideoIds;
  final String role; // 'user' or 'admin'

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.myReferralCode,
    required this.referredBy,
    required this.language,
    this.createdAt,
    this.activeTier = 'Internship',
    this.balance = 0.0,
    this.totalEarned = 0.0,
    this.tasksCompletedToday = 0,
    this.lastTaskDate,
    this.planActivatedAt,
    this.watchedVideoIds = const [],
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      myReferralCode: map['myReferralCode'] ?? '',
      referredBy: map['referredBy'] ?? '',
      language: map['language'] ?? 'en',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      activeTier: map['activeTier'] ?? 'Internship',
      balance: (map['balance'] ?? 0.0).toDouble(),
      totalEarned: (map['totalEarned'] ?? 0.0).toDouble(),
      tasksCompletedToday: map['tasksCompletedToday'] ?? 0,
      lastTaskDate: (map['lastTaskDate'] as Timestamp?)?.toDate(),
      planActivatedAt: (map['planActivatedAt'] as Timestamp?)?.toDate(),
      watchedVideoIds: List<String>.from(map['watchedVideoIds'] ?? []),
      role: map['role']?.toString().trim() ?? 'user',
    );
  }

  bool get isAdmin => role.trim().toLowerCase() == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'myReferralCode': myReferralCode,
      'referredBy': referredBy,
      'language': language,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'activeTier': activeTier,
      'balance': balance,
      'totalEarned': totalEarned,
      'tasksCompletedToday': tasksCompletedToday,
      'lastTaskDate': lastTaskDate != null ? Timestamp.fromDate(lastTaskDate!) : null,
      'planActivatedAt': planActivatedAt != null ? Timestamp.fromDate(planActivatedAt!) : null,
      'watchedVideoIds': watchedVideoIds,
      'role': role,
    };
  }
}
