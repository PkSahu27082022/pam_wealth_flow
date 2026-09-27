import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/AppManager/view/account/language_view.dart';
import 'package:pam_wealth_flow/AppManager/view/transaction/transaction_view.dart';
import '../../localization/app_language.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../service/snackbar_service.dart';

import '../transaction/add_fund_view.dart';
import '../donate/donate_view.dart';
import '../help/help_center_view.dart';
import '../team/my_team_view.dart';
import '../../service/deep_link_service.dart';
import 'referral_management_view.dart';
import '../admin/admin_dashboard_view.dart';

class AccountView extends ConsumerWidget {
  final String language;
  final VoidCallback? onLogout;
  final VoidCallback? onWithdraw;

  const AccountView({
    super.key,
    required this.language,
    this.onLogout,
    this.onWithdraw,
  });

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color borderColor = Color(0xFF50525A);
  static const Color white = Color(0xFFF2F2F2);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFE57373);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final lang = ref.watch(appLanguageProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
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
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return Center(child: Text(lang.userNotFound, style: const TextStyle(color: white)));
            }

            final String displayUserId = user.userId.isNotEmpty ? user.userId : user.uid.toUpperCase();
            final bool isAdmin = user.isAdmin;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 25),
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.admin_panel_settings, color: gold, size: 28),
                            tooltip: 'Admin Control Panel',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                              );
                            },
                          )
                        else
                          const SizedBox(width: 27),
                        Text(
                          lang.wealthCenter,
                          style: const TextStyle(
                            color: gold,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: onLogout,
                          child: const Icon(Icons.logout, color: gold, size: 27),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),

                  // PROFILE ICON
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 3),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: gold, size: 62),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // USERNAME & USER ID
                  Text(
                    user.username,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Copiable User ID
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: displayUserId));
                      Alert.show(context, message: lang.userIdCopied, type: AlertType.success);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'User ID: $displayUserId',
                            style: const TextStyle(
                              color: white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, color: gold, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // MEMBERSHIP
                  Text(
                    '${lang.membershipLevel}: ${user.activeTier}',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // BALANCE CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: borderColor, width: 1.3),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.totalBalance,
                                      style: const TextStyle(
                                        color: white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${user.balance.toStringAsFixed(2)} THB',
                                      style: const TextStyle(
                                        color: gold,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 125,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: onWithdraw,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: gold,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                  ),
                                  child: Text(
                                    lang.withdraw,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFB8B9BD), thickness: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.planProgress,
                                      style: const TextStyle(
                                        color: white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${user.tasksCompletedToday} ${lang.tasksDone}',
                                      style: const TextStyle(
                                        color: white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      lang.totalProfit,
                                      style: const TextStyle(
                                        color: white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '+${user.totalEarned.toStringAsFixed(2)} THB',
                                      style: const TextStyle(
                                        color: green,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),

                  // MENU GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                      children: [
                        _MenuItem(
                          icon: Icons.account_balance_wallet,
                          title: lang.addFunds,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFundsScreen())),
                        ),
                        _MenuItem(
                          icon: Icons.receipt_long,
                          title: lang.transactions,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen())),
                        ),
                        _MenuItem(
                          icon: Icons.people,
                          title: lang.myTeam,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTeamScreen())),
                        ),
                        _MenuItem(
                          icon: Icons.language,
                          title: lang.changeLanguage,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguagePage())),
                        ),
                        _MenuItem(
                          icon: Icons.share,
                          title: lang.registerNow,
                          onTap: () {
                            DeepLinkService.shareReferralLink(
                              referralCode: user.myReferralCode,
                              appName: "PAM Wealth Flow",
                              language: lang.languageCode,
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.shield,
                          title: lang.earnMore,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReferralManagementPage(language: lang.languageCode),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.support_agent,
                          title: lang.helpCenter,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen())),
                        ),
                        _MenuItem(
                          icon: Icons.card_giftcard,
                          title: lang.donate,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonateScreen())),
                        ),
                        // ADMIN BUTTON
                        if (isAdmin)
                          _MenuItem(
                            icon: Icons.admin_panel_settings,
                            title: 'Admin',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // LOGOUT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout, color: red, size: 20),
                        label: Text(
                          lang.logout,
                          style: const TextStyle(color: red, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF87494E), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: gold)),
          error: (e, s) => Center(child: Text(e.toString(), style: const TextStyle(color: red))),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFF171920),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF50525A), width: 1.2),
            ),
            child: Center(child: Icon(icon, color: const Color(0xFFDDB83A), size: 32)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFF2F2F2), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
