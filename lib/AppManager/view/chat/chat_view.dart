import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../localization/app_language.dart';
import '../../model/user_model.dart';
import '../../service/deep_link_service.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../view-model/chat-vm/chat_vm.dart';
import '../account/referral_management_view.dart';
import '../home/home_view.dart';
import 'chat_conversation_view.dart';

class ChatPage extends ConsumerWidget {
  final String language;

  const ChatPage({
    super.key,
    required this.language,
  });

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);

  String _getReferralTag(UserModel user, UserModel currentUser, AppLanguage lang) {
    if (user.isAdmin) {
      return lang.adminSupport;
    }
    if (currentUser.referredBy.isNotEmpty && user.myReferralCode == currentUser.referredBy) {
      return lang.uplineReferrer;
    }
    return lang.downlineMember;
  }

  Color _getTagColor(UserModel user, UserModel currentUser) {
    if (user.isAdmin) {
      return Colors.redAccent;
    }
    if (currentUser.referredBy.isNotEmpty && user.myReferralCode == currentUser.referredBy) {
      return gold;
    }
    return Colors.lightBlueAccent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final currentUser = ref.watch(userProfileProvider).value;
    final contactsAsync = ref.watch(connectedContactsProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF171A21),
                border: Border(bottom: BorderSide(color: Color(0xFF20242B), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.chat,
                        style: const TextStyle(
                          color: gold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang.connectedTeam,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (currentUser != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentUser.isOnline ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: currentUser.isOnline ? Colors.greenAccent : Colors.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentUser.isOnline ? Colors.greenAccent : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentUser.isOnline ? lang.online : lang.offline,
                            style: TextStyle(
                              color: currentUser.isOnline ? Colors.greenAccent : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // CONTACTS LIST
            Expanded(
              child: contactsAsync.when(
                data: (contacts) {
                  if (contacts.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              color: gold,
                              size: 70,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              lang.noConnectedContacts,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              lang.inviteFriendsToChat,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (currentUser != null) ...[
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    DeepLinkService.shareReferralLink(
                                      referralCode: currentUser.myReferralCode,
                                      appName: "PAM Wealth Flow",
                                      language: lang.languageCode,
                                    );
                                  },
                                  icon: const Icon(Icons.share, color: Colors.black),
                                  label: Text(
                                    lang.registerNow,
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: gold,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (currentUser.referredBy.isEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReferralManagementPage(language: lang.languageCode),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.shield, color: gold),
                                    label: Text(
                                      lang.enterReferralCode,
                                      style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: gold, width: 1.3),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final tag = currentUser != null ? _getReferralTag(contact, currentUser, lang) : '';
                      final tagColor = currentUser != null ? _getTagColor(contact, currentUser) : gold;

                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF292E37),
                                child: Text(
                                  contact.username.isNotEmpty ? contact.username[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: contact.isOnline ? Colors.greenAccent : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cardColor, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  contact.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: tagColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: tagColor.withValues(alpha: 0.5), width: 1),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: tagColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              contact.isOnline
                                  ? lang.online
                                  : contact.lastSeen != null
                                      ? '${lang.lastSeen} ${DateFormat('MMM dd, HH:mm').format(contact.lastSeen!)}'
                                      : lang.offline,
                              style: TextStyle(
                                color: contact.isOnline ? Colors.greenAccent : Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: gold,
                            size: 24,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatConversationPage(peerUser: contact),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: gold)),
                error: (err, stack) => Center(
                  child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
