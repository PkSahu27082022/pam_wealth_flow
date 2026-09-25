import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../view-model/investment-vm/investment_tier_vm.dart';
import '../admin/admin_dashboard_view.dart';

// ============================================================
// COLORS
// ============================================================

const Color gold = Color(0xFFDDB83A);
const Color background = Color(0xFF090D13);
const Color cardColor = Color(0xFF171920);
const Color borderColor = Color(0xFF50525A);
const Color green = Color(0xFF4CAF50);

class HomePage extends ConsumerWidget {
  final String language;

  const HomePage({
    super.key,
    required this.language,
  });

  // ============================================================
  // LANGUAGE
  // ============================================================

  bool get isBurmese => language == 'my';

  String tr(String english, String burmese) {
    return isBurmese ? burmese : english;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final profitAsync = ref.watch(profitStatsProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15),
              radius: 1.2,
              colors: [
                Color(0xFF171A1E),
                Color(0xFF0D1117),
                Color(0xFF090D13),
              ],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PAM HEADER CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 10),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.3),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/pam_logo.jpeg',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.public, size: 80, color: gold);
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PAM Wealth Flow',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gold,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Intelligent Wealth Flow',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ADMIN QUICK ACCESS BANNER
                if (userAsync.asData?.value?.isAdmin == true) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B2F00), Color(0xFF171920)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: gold, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: gold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings, color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('Admin Control Panel', 'အက်ဒမင် ထိန်းချုပ်ခန်း'),
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tr('Tap to manage users, deposits & settings', 'အသုံးပြုသူများ၊ ငွေသွင်းမှုများနှင့် ဆက်တင်များကို စီမံရန် နှိပ်ပါ'),
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: gold, size: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                // OPERATIONAL ANALYTICS
                Text(
                  tr('Operational Analytics', 'လုပ်ငန်းဆိုင်ရာ ခွဲခြမ်းစိတ်ဖြာမှု'),
                  style: const TextStyle(
                    color: gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                // PORTFOLIO PERFORMANCE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 21),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.3),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF292823),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: gold, size: 25),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('Portfolio Balance', 'ရင်းနှီးမြှုပ်နှံမှု လက်ကျန်ငွေ'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            userAsync.when(
                              data: (user) => Text(
                                '${user?.balance.toStringAsFixed(2) ?? "0.00"} THB',
                                style: const TextStyle(
                                  color: gold,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              loading: () => const SizedBox(
                                width: 15, height: 15,
                                child: CircularProgressIndicator(strokeWidth: 2, color: gold),
                              ),
                              error: (e, s) => const Text('0.00 THB', style: TextStyle(color: gold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tr('Total Profit', 'စုစုပေါင်းအမြတ်'),
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          profitAsync.when(
                            data: (stats) => Text(
                              '+${stats['total']?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(color: green, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (e, s) => const Text('+0.00', style: TextStyle(color: green)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // INCOME TIERS
                Text(
                  tr('Income Tiers', 'ဝင်ငွေအဆင့်များ'),
                  style: const TextStyle(
                    color: gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // TABLE
                const _IncomeTable(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomeTable extends ConsumerWidget {
  const _IncomeTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(investmentTiersProvider);
    final userProfile = ref.watch(userProfileProvider).value;

    return Column(
      children: [
        Container(
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFF292D37),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Row(
            children: [
              _TableHeader('Tier', 1.35),
              _TableHeader('Cost', 1.35),
              _TableHeader('Tasks', 1.0),
              _TableHeader('Daily', 1.0),
              _TableHeader('30D', 1.0),
            ],
          ),
        ),
        tiersAsync.when(
          data: (tiers) {
            final filteredTiers = tiers.where((t) => !t.title.toUpperCase().contains('GV')).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTiers.length,
              itemBuilder: (context, index) {
                final tier = filteredTiers[index];
                final isCurrent = userProfile?.activeTier == tier.title;

                final cost = tier.investmentAmount.replaceAll(RegExp(r'[^0-9]'), '');
                final daily = tier.dailyRoi.replaceAll(RegExp(r'[^0-9]'), '');
                final tasks = tier.dailyTask.replaceAll(RegExp(r'[^0-9]'), '');

                final double dailyDouble = double.tryParse(daily) ?? 0.0;
                final monthly = (dailyDouble * 30).toStringAsFixed(0);

                return _IncomeRow(
                  tier: tier.title,
                  cost: cost,
                  tasks: tasks,
                  daily: daily,
                  monthly: monthly,
                  isCurrent: isCurrent,
                );
              },
            );
          },
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: gold))),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String title;
  final double flex;
  const _TableHeader(this.title, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Color(0xFFDDB83A), fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _IncomeRow extends StatelessWidget {
  final String tier;
  final String cost;
  final String tasks;
  final String daily;
  final String monthly;
  final bool isCurrent;

  const _IncomeRow({
    required this.tier,
    required this.cost,
    required this.tasks,
    required this.daily,
    required this.monthly,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isCurrent ? gold.withOpacity(0.1) : const Color(0xFF0D1117),
        border: Border.all(
          color: isCurrent ? gold : const Color(0xFF50525A),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          _TableCell(tier, 1.35, isCurrent),
          _TableCell(cost, 1.35),
          _TableCell(tasks, 1.0),
          _TableCell(daily, 1.0),
          _TableCell(monthly, 1.0),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String value;
  final double flex;
  final bool highlight;
  const _TableCell(this.value, this.flex, [this.highlight = false]);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: highlight ? gold : Colors.white,
            fontSize: 12,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
