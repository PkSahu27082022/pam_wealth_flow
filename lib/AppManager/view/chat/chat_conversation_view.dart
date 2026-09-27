import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../localization/app_language.dart';
import '../../model/chat_message_model.dart';
import '../../model/user_model.dart';
import '../../service/chat_service.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../view-model/chat-vm/chat_vm.dart';

class ChatConversationPage extends ConsumerStatefulWidget {
  final UserModel peerUser;

  const ChatConversationPage({
    super.key,
    required this.peerUser,
  });

  @override
  ConsumerState<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends ConsumerState<ChatConversationPage> {
  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color bubbleColor = Color(0xFF171920);
  static const Color inputColor = Color(0xFF292823);
  static const Color borderColor = Color(0xFF50525A);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool _isSendingMedia = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(UserModel currentUser) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await ref.read(chatServiceProvider).sendMessage(
          senderId: currentUser.uid,
          senderName: currentUser.username,
          receiverId: widget.peerUser.uid,
          text: text,
        );

    _scrollToBottom();
  }

  Future<void> _pickAndSendMedia(UserModel currentUser, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() => _isSendingMedia = true);
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        await ref.read(chatServiceProvider).sendMessage(
              senderId: currentUser.uid,
              senderName: currentUser.username,
              receiverId: widget.peerUser.uid,
              text: '',
              mediaType: 'image',
              mediaData: base64Image,
            );

        setState(() => _isSendingMedia = false);
        _scrollToBottom();
      }
    } catch (e) {
      setState(() => _isSendingMedia = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    }
  }

  void _showImageSourcePicker(UserModel currentUser, AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171920),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang.sendPhoto,
                style: const TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: gold),
                title: Text(lang.camera, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendMedia(currentUser, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: gold),
                title: Text(lang.gallery, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendMedia(currentUser, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewFullImage(String base64Data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(base64Data),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProfileProvider).value;
    final lang = ref.watch(appLanguageProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(widget.peerUser.uid));

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    final isPeerOnline = widget.peerUser.isOnline;
    final lastSeenText = widget.peerUser.lastSeen != null
        ? '${lang.lastSeen} ${DateFormat('MMM dd, HH:mm').format(widget.peerUser.lastSeen!)}'
        : lang.offline;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF292E37),
                  child: Text(
                    widget.peerUser.username.isNotEmpty ? widget.peerUser.username[0].toUpperCase() : 'U',
                    style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isPeerOnline ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF171A21), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerUser.username,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isPeerOnline ? lang.online : lastSeenText,
                    style: TextStyle(
                      color: isPeerOnline ? Colors.greenAccent : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: Colors.white24, size: 60),
                          const SizedBox(height: 12),
                          Text(
                            lang.noMessagesYet,
                            style: const TextStyle(color: Colors.white54, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUser.uid;

                      return _ChatBubble(
                        message: msg,
                        isMe: isMe,
                        onImageTap: _viewFullImage,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: gold)),
                error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
            // if (_isSendingMedia)
            //   Container(
            //     padding: const EdgeInsets.all(8),
            //     color: const Color(0xFF171920),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: gold)),
            //         const SizedBox(width: 10),
            //         Text(lang.loading, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            //       ],
            //     ),
            //   ),
            _MessageInputBar(
              controller: _messageController,
              onSend: () => _sendMessage(currentUser),
              onMediaTap: () => _showImageSourcePicker(currentUser, lang),
              hintText: lang.typeMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final Function(String) onImageTap;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.onImageTap,
  });

  static const Color gold = Color(0xFFDDB83A);
  static const Color bubbleColor = Color(0xFF171920);

  @override
  Widget build(BuildContext context) {
    final isImage = message.mediaType == 'image' && message.mediaData != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: isImage ? const EdgeInsets.all(6) : const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: isMe ? gold : bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                ),
              ),
              child: isImage
                  ? GestureDetector(
                      onTap: () => onImageTap(message.mediaData!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          base64Decode(message.mediaData!),
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                        ),
                      ),
                    )
                  : Text(
                      message.text,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMediaTap;
  final String hintText;

  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    required this.onMediaTap,
    required this.hintText,
  });

  static const Color gold = Color(0xFFDDB83A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF171A21),
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.add_photo_alternate, color: gold, size: 28),
          //   onPressed: onMediaTap,
          // ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: gold,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFF232731),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: gold, width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
