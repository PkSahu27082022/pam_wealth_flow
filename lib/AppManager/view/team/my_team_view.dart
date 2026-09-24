import 'package:flutter/material.dart';

class MyTeamScreen extends StatelessWidget {
  const MyTeamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F1218);
    const cardBackgroundColor = Color(0xFF161B22);
    const goldColor = Color(0xFFE5B83B);
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
          'My Team',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              const Text(
                'Team Statistics',
                style: TextStyle(
                  color: goldColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Total Team Size Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Team Size',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.people_alt,
                          color: goldColor,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '96 Members',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Direct Member Card
              _buildStatCard(
                title: 'Direct Member',
                value: '18',
                cardColor: cardBackgroundColor,
                borderColor: borderColor,
                goldColor: goldColor,
              ),
              const SizedBox(height: 16),

              // 1st Level Members Card
              _buildStatCard(
                title: '1st Level Members',
                value: '26',
                cardColor: cardBackgroundColor,
                borderColor: borderColor,
                goldColor: goldColor,
              ),
              const SizedBox(height: 16),

              // 2nd Level Members Card
              _buildStatCard(
                title: '2nd Level Members',
                value: '52',
                cardColor: cardBackgroundColor,
                borderColor: borderColor,
                goldColor: goldColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build standard stat cards
  Widget _buildStatCard({
    required String title,
    required String value,
    required Color cardColor,
    required Color borderColor,
    required Color goldColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 22.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: goldColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}