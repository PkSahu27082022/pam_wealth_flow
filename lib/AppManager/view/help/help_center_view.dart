import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F1218);
    const cardBackgroundColor = Color(0xFF161B22);
    const goldColor = Color(0xFFE5B83B);
    const iconTileBgColor = Color(0xFF262118);
    const borderColor = Color(0xFF2A313D);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: goldColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Headset Icon
              const Icon(
                Icons.headset_mic_rounded,
                size: 80,
                color: goldColor,
              ),
              const SizedBox(height: 16),

              // Title Header
              const Text(
                'How can we help you?',
                style: TextStyle(
                  color: goldColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),

              // Live Chat Option Card
              _buildSupportOption(
                icon: Icons.chat_bubble,
                title: 'Live Chat',
                subtitle: 'Speak with our support team now',
                cardColor: cardBackgroundColor,
                iconBgColor: iconTileBgColor,
                goldColor: goldColor,
                onTap: () {
                  // Handle Live Chat click
                },
              ),
              const SizedBox(height: 16),

              // Email Support Option Card
              _buildSupportOption(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'Send us a message anytime',
                cardColor: cardBackgroundColor,
                iconBgColor: iconTileBgColor,
                goldColor: goldColor,
                onTap: () {
                  // Handle Email Support click
                },
              ),
              const SizedBox(height: 24),

              // Common Questions Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Common Questions',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionItem('• How to withdraw funds?'),
                    const SizedBox(height: 12),
                    _buildQuestionItem('• What are VIP levels?'),
                    const SizedBox(height: 12),
                    _buildQuestionItem('• How to invite friends?'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Support Card Option Item
  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color iconBgColor,
    required Color goldColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: goldColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FAQ Question Text
  Widget _buildQuestionItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}