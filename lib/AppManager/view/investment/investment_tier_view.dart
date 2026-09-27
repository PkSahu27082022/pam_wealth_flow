import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../localization/app_language.dart';
import '../../view-model/investment-vm/investment_tier_vm.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../service/snackbar_service.dart';

class InvestmentTiersPage extends ConsumerStatefulWidget {
  final String language;

  const InvestmentTiersPage({super.key, required this.language});

  @override
  ConsumerState<InvestmentTiersPage> createState() => _InvestmentTiersPageState();
}

class _InvestmentTiersPageState extends ConsumerState<InvestmentTiersPage> {
  String? _unlockingTierTitle;

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color borderColor = Color(0xFF50525A);
  static const Color white = Color(0xFFF2F2F3);

  void _showSuccessDialog(String title, AppLanguage lang) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    lang.planUnlocked,
                    style: const TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${lang.planUnlockedMsg} $title',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: white, fontSize: 14),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(lang.ok, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final tiersAsync = ref.watch(investmentTiersProvider);
    final userAsync = ref.watch(userProfileProvider);
    final lang = ref.watch(appLanguageProvider);

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
                        lang.investmentTiers,
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
                  user?.activeTier ?? 'None',
                  user?.balance ?? 0.0,
                  lang,
                ),
                loading: () => _activePortfolioCard('Loading...', 0.0, lang),
                error: (e, s) => _activePortfolioCard('None', 0.0, lang),
              ),

              const SizedBox(height: 20),

              // ===============================================================
              // TIERS LIST FROM RIVERPOD/FIREBASE
              // ===============================================================
              tiersAsync.when(
                data: (tiers) {
                  final filteredTiers = tiers.where((t) => !t.title.toUpperCase().contains('GV')).toList();

                  if (filteredTiers.isEmpty) {
                    return Center(
                      child: Text(
                        lang.noPlansAvailable,
                        style: const TextStyle(color: white),
                      ),
                    );
                  }
                  return Column(
                    children: filteredTiers.map((tier) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: _tierCard(
                          context: context,
                          ref: ref,
                          lang: lang,
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
                error: (err, stack) => Center(
                  child: Text(
                    lang.errorLoadingPlans,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTIVE PORTFOLIO CARD
  // ===========================================================================

  Widget _activePortfolioCard(String activeTier, double balance, AppLanguage lang) {
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
            '${lang.activePortfolio}: $activeTier',
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
                  '${lang.balance}: ${balance.toStringAsFixed(2)} THB',
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
                    lang.expiryDate,
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
    required AppLanguage lang,
    required String title,
    required String dailyCapacity,
    required String orderRate,
    required String potentialROI,
    required String capitalRequirement,
  }) {
    final userProfile = ref.read(userProfileProvider).value;
    final isCurrent = userProfile?.activeTier == title;
    final isUnlocking = _unlockingTierTitle == title;

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
                    lang.active,
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
                  _infoRow(lang.dailyTask, dailyCapacity),
                  const SizedBox(height: 5),
                  _infoRow(lang.payPerTask, orderRate),
                  const SizedBox(height: 5),
                  _infoRow(lang.dailyRoi, potentialROI),
                  const SizedBox(height: 5),
                  _infoRow(lang.investmentAmount, capitalRequirement),
                ],
              ),
              if (!isCurrent)
                SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    onPressed: isUnlocking ? null : () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;

                      setState(() => _unlockingTierTitle = title);

                      final costStr = capitalRequirement.replaceAll(RegExp(r'[^0-9]'), '');
                      final cost = double.tryParse(costStr) ?? 0.0;

                      final error = await ref.read(userViewModelProvider).unlockTier(uid, title, cost);

                      if (mounted) {
                        setState(() => _unlockingTierTitle = null);
                        if (error != null) {
                          Alert.show(context, message: error, type: AlertType.error);
                        } else {
                          _showSuccessDialog(title, lang);
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isUnlocking ? Colors.grey.shade900 : const Color(0xFF292823),
                      side: BorderSide(color: isUnlocking ? Colors.grey : gold, width: 1.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: isUnlocking
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: gold))
                        : Text(
                            lang.unlock,
                            style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w700),
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
            style: const TextStyle(color: white, fontSize: 13, fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
