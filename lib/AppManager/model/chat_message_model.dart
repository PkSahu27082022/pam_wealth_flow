import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String text;
  final String? mediaType; // null or 'image'
  final String? mediaData; // Base64 string or image URL
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.text,
    this.mediaType,
    this.mediaData,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessageModel.fromMap(String docId, Map<String, dynamic> map) {
    return ChatMessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      mediaType: map['mediaType'],
      mediaData: map['mediaData'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'text': text,
      'mediaType': mediaType,
      'mediaData': mediaData,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
