import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../view-model/investment-vm/investment_tier_vm.dart';
import '../../view-model/account-vm/user_vm.dart';


class InvestmentTiersPage extends ConsumerWidget {
  final String language;

  const InvestmentTiersPage({super.key, required this.language});

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color borderColor = Color(0xFF50525A);
  static const Color white = Color(0xFFF2F2F3);

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  String tr(String english, String burmese) {
    return language == 'my' ? burmese : english;
  }

  // ===========================================================================
  // FALLBACK HARDCODED TIERS
  // ===========================================================================
  List<Map<String, String>> _fallbackTiers() {
    return [
      {'title': 'Internship', 'dailyTask': '3 Tasks', 'payPerTask': '10 THB', 'dailyRoi': '30 THB', 'investmentAmount': '0 THB'},
      {'title': 'SV1', 'dailyTask': '3 Tasks', 'payPerTask': '10 THB', 'dailyRoi': '30 THB', 'investmentAmount': '500 THB'},
      {'title': 'SV2', 'dailyTask': '3 Tasks', 'payPerTask': '12 THB', 'dailyRoi': '36 THB', 'investmentAmount': '1200 THB'},
      {'title': 'SV3', 'dailyTask': '6 Tasks', 'payPerTask': '20 THB', 'dailyRoi': '120 THB', 'investmentAmount': '3900 THB'},
      {'title': 'GV1', 'dailyTask': '12 Tasks', 'payPerTask': '30 THB', 'dailyRoi': '360 THB', 'investmentAmount': '11000 THB'},
      {'title': 'GV2', 'dailyTask': '25 Tasks', 'payPerTask': '40 THB', 'dailyRoi': '1000 THB', 'investmentAmount': '28000 THB'},
      {'title': 'GV3', 'dailyTask': '30 Tasks', 'payPerTask': '85 THB', 'dailyRoi': '2550 THB', 'investmentAmount': '70000 THB'},
      {'title': 'GO', 'dailyTask': '5 Videos', 'payPerTask': '18 THB', 'dailyRoi': '90 THB', 'investmentAmount': '3,000 THB'},
      {'title': 'PLUS', 'dailyTask': '5 Videos', 'payPerTask': '36 THB', 'dailyRoi': '180 THB', 'investmentAmount': '6,000 THB'},
      {'title': 'PRO', 'dailyTask': '5 Videos', 'payPerTask': '54 THB', 'dailyRoi': '270 THB', 'investmentAmount': '9,000 THB'},
      {'title': 'MAX', 'dailyTask': '5 Videos', 'payPerTask': '84 THB', 'dailyRoi': '420 THB', 'investmentAmount': '12,000 THB'},
      {'title': 'ULTRA', 'dailyTask': '5 Videos', 'payPerTask': '102 THB', 'dailyRoi': '510 THB', 'investmentAmount': '15,000 THB'},
      {'title': 'INFINITY', 'dailyTask': '5 Videos', 'payPerTask': '204 THB', 'dailyRoi': '1,020 THB', 'investmentAmount': '30,000 THB'},
    ];
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(investmentTiersProvider);
    final userAsync = ref.watch(userProfileProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.2,
          colors: [Color(0xFF15191F), Color(0xFF0D1117), Color(0xFF090D13)],
        ),
      ),

      child: SafeArea(
        bottom: false,

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(28, 25, 28, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ===============================================================
              // HEADER
              // ===============================================================
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        tr('Investment Tiers', 'ရင်းနှီးမြှုပ်နှံမှုအဆင့်များ'),

                        style: const TextStyle(
                          color: gold,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ===============================================================
              // ACTIVE PORTFOLIO
              // ===============================================================
              userAsync.when(
                data: (user) => _activePortfolioCard(
                  user?.activeTier ?? 'Internship',
                  user?.balance ?? 0.0,
                ),
                loading: () => _activePortfolioCard('Loading...', 0.0),
                error: (e, s) => _activePortfolioCard('Internship', 0.0),
              ),

              const SizedBox(height: 20),

              // ===============================================================
              // TIERS LIST FROM RIVERPOD/FIREBASE
              // ===============================================================
              tiersAsync.when(
                data: (tiers) {
                  if (tiers.isEmpty) {
                    return _buildFallbackList(context, ref);
                  }
                  return Column(
                    children: tiers.map((tier) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: _tierCard(
                          context: context,
                          ref: ref,
                          title: tier.title,
                          dailyCapacity: tier.dailyTask,
                          orderRate: tier.payPerTask,
                          potentialROI: tier.dailyRoi,
                          capitalRequirement: tier.investmentAmount,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: gold),
                  ),
                ),
                error: (err, stack) => _buildFallbackList(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackList(BuildContext context, WidgetRef ref) {
    final fallbacks = _fallbackTiers();
    return Column(
      children: fallbacks.map((tier) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: _tierCard(
            context: context,
            ref: ref,
            title: tier['title']!,
            dailyCapacity: tier['dailyTask']!,
            orderRate: tier['payPerTask']!,
            potentialROI: tier['dailyRoi']!,
            capitalRequirement: tier['investmentAmount']!,
          ),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // ACTIVE PORTFOLIO CARD
  // ===========================================================================

  Widget _activePortfolioCard(String activeTier, double balance) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(17, 16, 15, 15),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: borderColor, width: 1.3),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            '${tr('Active Portfolio', 'လက်ရှိ Portfolio')}: $activeTier',

            style: const TextStyle(
              color: gold,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  '${tr('Balance', 'လက်ကျန်ငွေ')}: ${balance.toStringAsFixed(2)} THB',

                  style: const TextStyle(
                    color: white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    tr('Expiry Date', 'သက်တမ်းကုန်ဆုံးရက်'),

                    style: const TextStyle(
                      color: white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    '03-09-2029',

                    style: TextStyle(
                      color: white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TIER CARD
  // ===========================================================================

  Widget _tierCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String dailyCapacity,
    required String orderRate,
    required String potentialROI,
    required String capitalRequirement,
  }) {
    final userProfile = ref.read(userProfileProvider).value;
    final isCurrent = userProfile?.activeTier == title;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(17, 14, 17, 15),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: gold, width: 1.5) : null,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,

                style: const TextStyle(
                  color: gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tr('Active', 'အသုံးပြုနေသည်'),
                    style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    tr('Daily Task', 'နေ့စဉ်တာဝန်'),
                    dailyCapacity,
                  ),

                  const SizedBox(height: 5),

                  _infoRow(tr('Pay Per Task', 'တာဝန်တစ်ခုနှုန်း'), orderRate),

                  const SizedBox(height: 5),

                  _infoRow(
                    tr('Daily ROI', 'နေ့စဉ်ရရှိငွေ'),
                    potentialROI,
                  ),

                  const SizedBox(height: 5),

                  _infoRow(
                    tr('Investment Amount', 'ရင်းနှီးမြှုပ်နှံငွေ'),
                    capitalRequirement,
                  ),
                ],
              ),
              if (!isCurrent)
                OutlinedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return;

                    // Parse numerical value out of requirement string (e.g. "3,000 THB" -> 3000.0)
                    final costStr = capitalRequirement.replaceAll(RegExp(r'[^0-9]'), '');
                    final cost = double.tryParse(costStr) ?? 0.0;

                    final error = await ref.read(userViewModelProvider).unlockTier(uid, title, cost);
                    if (context.mounted) {
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('Plan Unlocked Successfully!', 'အစီအစဉ်ကို အောင်မြင်စွာ ဖွင့်လှစ်ပြီးပါပြီ။')),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },

                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF292823),

                    side: const BorderSide(color: gold, width: 1.7),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),

                  child: Text(
                    tr('Unlock', 'ဖွင့်ရန်'),

                    style: const TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO ROW
  // ===========================================================================

  Widget _infoRow(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title: ',

            style: const TextStyle(
              color: white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),

          TextSpan(
            text: value,

            style: const TextStyle(
              color: white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
