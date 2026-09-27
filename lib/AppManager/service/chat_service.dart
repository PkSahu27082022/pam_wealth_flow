import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/chat_message_model.dart';
import '../model/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Helper to get a deterministic chat room ID between two user IDs
  static String getChatRoomId(String uid1, String uid2) {
    if (uid1.compareTo(uid2) < 0) {
      return '${uid1}_$uid2';
    } else {
      return '${uid2}_$uid1';
    }
  }

  /// Update active user's online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error updating online status: $e");
      }
    }
  }

  /// Send a text or media message in a 1-on-1 chat
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String text,
    String? mediaType,
    String? mediaData,
  }) async {
    final chatRoomId = getChatRoomId(senderId, receiverId);
    final messagesRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages');

    final messageDoc = messagesRef.doc();
    final now = DateTime.now();

    final message = ChatMessageModel(
      id: messageDoc.id,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      text: text,
      mediaType: mediaType,
      mediaData: mediaData,
      timestamp: now,
      isRead: false,
    );

    final lastMsgText = mediaType == 'image' ? '[Photo]' : text;

    await _firestore.runTransaction((transaction) async {
      transaction.set(messageDoc, message.toMap());
      transaction.set(
        _firestore.collection('chat_rooms').doc(chatRoomId),
        {
          'participants': [senderId, receiverId],
          'lastMessage': lastMsgText,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastSenderId': senderId,
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Stream real-time messages for a 1-on-1 conversation
  Stream<List<ChatMessageModel>> getMessagesStream(String uid1, String uid2) {
    final chatRoomId = getChatRoomId(uid1, uid2);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Stream of connected referral contacts (Upline Referrer and Direct Referrals)
  Stream<List<UserModel>> getConnectedContactsStream(UserModel currentUser) {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final allUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), docId: doc.id))
          .where((u) => u.uid != currentUser.uid)
          .toList();

      final myCode = currentUser.myReferralCode;
      final referredBy = currentUser.referredBy;

      // Filter connected users (Exclude Admins from referral team list)
      final connected = allUsers.where((u) {
        if (u.isAdmin) return false; // Admin is moved to Help Center Live Chat
        final bool isUpline = referredBy.isNotEmpty && u.myReferralCode == referredBy;
        final bool isDownline = myCode.isNotEmpty && u.referredBy == myCode;

        return isUpline || isDownline;
      }).toList();

      // Sort: Online first, then by username
      connected.sort((a, b) {
        if (a.isOnline && !b.isOnline) return -1;
        if (!a.isOnline && b.isOnline) return 1;
        return a.username.compareTo(b.username);
      });

      return connected;
    });
  }
}
