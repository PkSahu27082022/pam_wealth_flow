import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/user_model.dart';
import '../../model/chat_message_model.dart';
import '../../service/chat_service.dart';
import '../account-vm/user_vm.dart';

final chatServiceProvider = Provider((ref) => ChatService());

/// Connected Referral Contacts Stream
final connectedContactsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final userProfileAsync = ref.watch(userProfileProvider);

  return userProfileAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ChatService().getConnectedContactsStream(user);
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});

/// 1-on-1 Messages Stream for a specific contact
final chatMessagesProvider = StreamProvider.family.autoDispose<List<ChatMessageModel>, String>((ref, peerUid) {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null) return Stream.value([]);

  return ChatService().getMessagesStream(userProfile.uid, peerUid);
});
