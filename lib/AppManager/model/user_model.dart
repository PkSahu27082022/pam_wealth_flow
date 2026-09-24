import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String myReferralCode;
  final String referredBy;
  final String language;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.myReferralCode,
    required this.referredBy,
    required this.language,
    this.createdAt,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'myReferralCode': myReferralCode,
      'referredBy': referredBy,
      'language': language,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
