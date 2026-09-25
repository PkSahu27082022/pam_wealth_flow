import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../model/user_model.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const backgroundColor = Color(0xFF0F1218);
    const cardBackgroundColor = Color(0xFF161B22);
    const goldColor = Color(0xFFE5B83B);
    const borderColor = Color(0xFF2A313D);

    final userProfile = ref.watch(userProfileProvider).value;
    final allUsersAsync = ref.watch(teamListProvider);

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
        child: allUsersAsync.when(
          data: (allUsers) {
            if (userProfile == null) return const Center(child: CircularProgressIndicator(color: goldColor));

            // Calculate Multi-level Team
            final myCode = userProfile.myReferralCode;

            // Level 1: Direct Referrals
            final level1 = allUsers.where((u) => u.referredBy == myCode).toList();
            final level1Codes = level1.map((e) => e.myReferralCode).toSet();

            // Level 2: Referrals of Level 1
            final level2 = allUsers.where((u) => level1Codes.contains(u.referredBy)).toList();
            final level2Codes = level2.map((e) => e.myReferralCode).toSet();

            // Level 3: Referrals of Level 2
            final level3 = allUsers.where((u) => level2Codes.contains(u.referredBy)).toList();

            final totalSize = level1.length + level2.length + level3.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          children: [
                            const Icon(Icons.people_alt, color: goldColor, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              '$totalSize Members',
                              style: const TextStyle(
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

                  _buildStatCard(
                    title: 'Direct Members (LV 1)',
                    value: level1.length.toString(),
                    cardColor: cardBackgroundColor,
                    borderColor: borderColor,
                    goldColor: goldColor,
                  ),
                  const SizedBox(height: 16),

                  _buildStatCard(
                    title: 'Indirect Members (LV 2)',
                    value: level2.length.toString(),
                    cardColor: cardBackgroundColor,
                    borderColor: borderColor,
                    goldColor: goldColor,
                  ),
                  const SizedBox(height: 16),

                  _buildStatCard(
                    title: 'Extended Members (LV 3)',
                    value: level3.length.toString(),
                    cardColor: cardBackgroundColor,
                    borderColor: borderColor,
                    goldColor: goldColor,
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: goldColor)),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }

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
