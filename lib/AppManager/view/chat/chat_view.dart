import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String language;

  const ChatPage({
    super.key,
    required this.language,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color bubbleColor = Color(0xFF171920);
  static const Color inputColor = Color(0xFF292823);
  static const Color borderColor = Color(0xFF50525A);

  final TextEditingController messageController =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  String tr(String english, String burmese) {
    return widget.language == 'my' ? burmese : english;
  }

  // ===========================================================================
  // MESSAGES
  // ===========================================================================

  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'System',
      'message': 'Hello! Welcome to PAM Wealth Flow.',
      'time': '09:00 AM',
      'isMe': false,
    },
    {
      'sender': 'Support',
      'message': 'How are you? How can I help you today?',
      'time': '09:05 AM',
      'isMe': false,
    },
    {
      'sender': 'Me',
      'message': "I'm doing well, thank you.",
      'time': '09:10 AM',
      'isMe': true,
    },
    {
      'sender': 'Support',
      'message':
      'Would you like to know about our new investment plans?',
      'time': '09:12 AM',
      'isMe': false,
    },
    {
      'sender': 'Me',
      'message':
      "Yes, I'm interested. Please explain the details.",
      'time': '09:15 AM',
      'isMe': true,
    },
  ];

  // ===========================================================================
  // SEND MESSAGE
  // ===========================================================================

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add({
        'sender': 'Me',
        'message': text,
        'time': '09:20 AM',
        'isMe': true,
      });

      messageController.clear();
    });

    Future.delayed(
      const Duration(milliseconds: 100),
          () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [
            // ================================================================
            // TITLE
            // ================================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(
                28,
                25,
                28,
                20,
              ),

              alignment: Alignment.centerLeft,

              child: Text(
                tr(
                  'Chat',
                  'စကားပြောရန်',
                ),

                style: const TextStyle(
                  color: gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ================================================================
            // CHAT LIST
            // ================================================================

            Expanded(
              child: ListView.builder(
                controller: scrollController,

                padding: const EdgeInsets.fromLTRB(
                  28,
                  10,
                  28,
                  20,
                ),

                physics: const BouncingScrollPhysics(),

                itemCount: messages.length,

                itemBuilder: (context, index) {
                  final message = messages[index];

                  return _ChatBubble(
                    sender: message['sender'],
                    message: message['message'],
                    time: message['time'],
                    isMe: message['isMe'],
                  );
                },
              ),
            ),

            // ================================================================
            // MESSAGE INPUT
            // ================================================================

            _MessageInput(
              controller: messageController,
              onSend: sendMessage,
              hint: tr(
                'Type a message...',
                'မက်ဆေ့ချ်ရိုက်ထည့်ပါ...',
              ),
            ),

            // ================================================================
            // BOTTOM NAVIGATION
            // ================================================================


          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// CHAT BUBBLE
// ===========================================================================

class _ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final String time;
  final bool isMe;

  const _ChatBubble({
    required this.sender,
    required this.message,
    required this.time,
    required this.isMe,
  });

  static const Color gold = Color(0xFFDDB83A);
  static const Color bubbleColor = Color(0xFF171920);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),

      child: Column(
        crossAxisAlignment:
        isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,

        children: [
          // ================================================================
          // SENDER
          // ================================================================

          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 0,
              right: isMe ? 0 : 0,
            ),

            child: Text(
              sender,

              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 5),

          // ================================================================
          // MESSAGE
          // ================================================================

          Align(
            alignment:
            isMe
                ? Alignment.centerRight
                : Alignment.centerLeft,

            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                MediaQuery.of(context).size.width * 0.72,
              ),

              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),

              decoration: BoxDecoration(
                color:
                isMe
                    ? gold
                    : bubbleColor,

                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),

                  bottomLeft:
                  isMe
                      ? const Radius.circular(20)
                      : Radius.zero,

                  bottomRight:
                  isMe
                      ? Radius.zero
                      : const Radius.circular(20),
                ),
              ),

              child: Text(
                message,

                style: TextStyle(
                  color:
                  isMe
                      ? Colors.black
                      : Colors.white,

                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 7),

          // ================================================================
          // TIME
          // ================================================================

          Text(
            time,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// MESSAGE INPUT
// ===========================================================================

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hint;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.hint,
  });

  static const Color gold = Color(0xFFDDB83A);
  static const Color inputColor = Color(0xFF292823);
  static const Color borderColor = Color(0xFF50525A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        12,
      ),

      color: inputColor,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // ================================================================
          // TEXT FIELD
          // ================================================================

          Expanded(
            child: TextField(
              controller: controller,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),

              cursorColor: gold,

              minLines: 1,
              maxLines: 3,

              decoration: InputDecoration(
                hintText: hint,

                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),

                filled: true,

                fillColor: inputColor,

                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),

                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(20),

                  borderSide:
                  const BorderSide(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),

                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(35),

                  borderSide:
                  const BorderSide(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          // ================================================================
          // SEND BUTTON
          // ================================================================

          GestureDetector(
            onTap: onSend,

            child: Container(
              width: 45,
              height: 45,

              decoration: const BoxDecoration(
                color: gold,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.send,
                color: Colors.black,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
