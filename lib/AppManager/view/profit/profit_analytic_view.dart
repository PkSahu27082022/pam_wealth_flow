import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view-model/account-vm/user_vm.dart';

class ProfitAnalyticsPage extends ConsumerWidget {
  final String language;

  const ProfitAnalyticsPage({
    super.key,
    required this.language,
  });

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color borderColor = Color(0xFF50525A);
  static const Color white = Color(0xFFF2F2F3);
  static const Color green = Color(0xFF50D565);

  // ===========================================================================
  // TRANSLATION
  // ===========================================================================

  String tr(String english, String burmese) {
    return language == 'my' ? burmese : english;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profitAsync = ref.watch(profitStatsProvider);
    final taskProgressAsync = ref.watch(taskProgressProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.2,
          colors: [
            Color(0xFF15191F),
            Color(0xFF0D1117),
            Color(0xFF090D13),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: profitAsync.when(
          data: (stats) {
            return taskProgressAsync.when(
              data: (progress) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 25, 28, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                tr('Profit Analytics', 'အမြတ်ခွဲခြမ်းစိတ်ဖြာမှု'),
                                style: const TextStyle(
                                  color: gold,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // EARNINGS SUMMARY
                      Text(
                        tr('Earnings Summary', 'ဝင်ငွေအကျဉ်းချုပ်'),
                        style: const TextStyle(
                          color: gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TOTAL EARNINGS CARD
                      _buildEarningsCard(stats),

                      const SizedBox(height: 10),

                      // MONTHLY DETAILS CARD
                      _buildDetailsCard(stats),

                      const SizedBox(height: 15),

                      // TASK STATISTICS
                      Text(
                        tr('Task Statistics', 'လုပ်ငန်းစာရင်းအင်း'),
                        style: const TextStyle(
                          color: gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // TASK STATISTICS CARD
                      _buildTaskStatisticsCard(
                        progress['completed'] ?? 0,
                        progress['remaining'] ?? 0,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: gold)),
              error: (e, s) => Center(child: Text(e.toString())),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: gold)),
          error: (e, s) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }

  Widget _buildEarningsCard(Map<String, double> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 15),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: green, size: 18),
              const SizedBox(width: 8),
              Text(
                tr('Total Earnings', 'စုစုပေါင်းဝင်ငွေ'),
                style: const TextStyle(
                  color: white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(
              '${stats['total']?.toStringAsFixed(2)} THB',
              style: const TextStyle(
                color: gold,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF64666C), thickness: 1.3),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _earningItem(
                title: tr('Yesterday', 'မနေ့က'),
                value: stats['yesterday']?.toStringAsFixed(2) ?? '0.00',
              ),
              _earningItem(
                title: tr('Today', 'ဒီနေ့'),
                value: stats['today']?.toStringAsFixed(2) ?? '0.00',
              ),
              _earningItem(
                title: tr('This Week', 'ဒီအပတ်'),
                value: stats['thisWeek']?.toStringAsFixed(2) ?? '0.00',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningItem({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(Map<String, double> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Column(
        children: [
          _detailRow(tr('This Month', 'ယခုလ'), '${stats['thisMonth']?.toStringAsFixed(2)} THB'),
          const SizedBox(height: 10),
          _detailRow(tr('Offer Earning', 'ကမ်းလှမ်းမှုဝင်ငွေ'), '0.00 THB'),
          const SizedBox(height: 10),
          _detailRow(tr('Referral Rewards', 'ရည်ညွှန်းဆုကြေး'), '${stats['referralRewards']?.toStringAsFixed(2)} THB'),
          const SizedBox(height: 10),
          _detailRow(tr('Task Rewards', 'လုပ်ငန်းဆုကြေး'), '${stats['taskRewards']?.toStringAsFixed(2)} THB'),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskStatisticsCard(int completed, int remaining) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$completed',
                  style: const TextStyle(
                    color: white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tr('Completed Today', 'ယနေ့ပြီးစီးမှု'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.5,
            height: 40,
            color: const Color(0xFF64666C),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$remaining',
                  style: const TextStyle(
                    color: white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tr('Remaining Today', 'ယနေ့ကျန်ရှိမှု'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
