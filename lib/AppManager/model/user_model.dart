import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String userId; // 6-digit unique numeric User ID (e.g. "849201")
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
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.uid,
    this.userId = '',
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
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final String roleFromMap = (map['role'] ?? '').toString().trim().toLowerCase();
    final String emailFromMap = (map['email'] ?? '').toString().trim().toLowerCase();

    final bool isAdminUser = roleFromMap == 'admin' || emailFromMap == 'wealthadmin@gmail.com';

    return UserModel(
      uid: (map['uid'] != null && map['uid'].toString().isNotEmpty) ? map['uid'] : (docId ?? ''),
      userId: map['userId']?.toString() ?? '',
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
      role: isAdminUser ? 'admin' : (map['role'] ?? 'user'),
      isOnline: map['isOnline'] == true,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  bool get isAdmin => role.trim().toLowerCase() == 'admin' || email.trim().toLowerCase() == 'wealthadmin@gmail.com';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId': userId,
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
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : FieldValue.serverTimestamp(),
    };
  }
}
