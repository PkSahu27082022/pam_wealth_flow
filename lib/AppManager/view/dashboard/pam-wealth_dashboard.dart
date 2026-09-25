import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/AppManager/view/account/language_view.dart';
import 'package:pam_wealth_flow/AppManager/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:pam_wealth_flow/AppManager/view/account/login_view.dart';
import 'package:pam_wealth_flow/AppManager/view/profit/profit_analytic_view.dart';
import 'package:pam_wealth_flow/AppManager/view/task/reel_view.dart';

import '../account/account_view.dart';
import '../chat/chat_view.dart';
import '../home/home_view.dart';
import '../investment/investment_tier_view.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../view-model/investment-vm/investment_tier_vm.dart';
import '../../view-model/task-vm/reel_vm.dart';

class WealthCenterPage extends ConsumerStatefulWidget {
  final String language;

  const WealthCenterPage({super.key, required this.language});

  @override
  ConsumerState<WealthCenterPage> createState() => _WealthCenterPageState();
}

class _WealthCenterPageState extends ConsumerState<WealthCenterPage> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color background = Color(0xFF090D13);
  static const Color gold = Color(0xFFDDB83A);

  // ===========================================================================
  // TRANSLATION
  // ===========================================================================

  String tr(String english, String burmese) {
    return widget.language == 'my' ? burmese : english;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    // 0 - HOME
    HomePage(language: widget.language),

    // 1 - CHAT
    ChatPage(language: widget.language),

    // 2 - TASK
    DailyTasksPage(language: widget.language, currentTab: _selectedIndex == 2),

    // 3 - VIP
    InvestmentTiersPage(language: widget.language),

    // 4 - PROFIT
    ProfitAnalyticsPage(language: widget.language),

    // 5 - ACCOUNT
    AccountView(
      language: widget.language,
      onLogout: _logout,
      onWithdraw: _withdraw,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background,
  
        body: SafeArea(
          bottom: false,
  
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [Color(0xFF15191F), Color(0xFF0D1117), Color(0xFF090D13)],
              ),
            ),
  
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
  
                _BottomNavigation(
                  language: widget.language,
                  selectedIndex: _selectedIndex,
                  onTap: _onBottomNavTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  void _withdraw() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Withdraw selected', 'ငွေထုတ်ရန် ရွေးချယ်ထားသည်')),
      ),
    );
  }

  void _logout() async {
    await AuthService().logout();

    // Invalidate all providers to clear in-memory cache for the next user
    ref.invalidate(userProfileProvider);
    ref.invalidate(userTransactionsProvider);
    ref.invalidate(referralTransactionsProvider);
    ref.invalidate(profitStatsProvider);
    ref.invalidate(teamListProvider);
    ref.invalidate(investmentTiersProvider);
    ref.invalidate(reelsProvider);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(language: "en"),
        ),
        (route) => false,
      );
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// ===========================================================================
// BOTTOM NAVIGATION
// ===========================================================================

class _BottomNavigation extends StatelessWidget {
  final String language;
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomNavigation({
    required this.language,
    required this.selectedIndex,
    required this.onTap,
  });

  static const Color gold = Color(0xFFDDB83A);

  String tr(String english, String burmese) {
    return language == 'my' ? burmese : english;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,

      decoration: const BoxDecoration(
        color: Color(0xFF171A21),

        border: Border(top: BorderSide(color: Color(0xFF20242B), width: 1)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _BottomItem(
            icon: Icons.home,
            title: tr('Home', 'ပင်မ'),
            selected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),

          _BottomItem(
            icon: Icons.chat,
            title: tr('Chat', 'စကားပြော'),
            selected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),

          _BottomItem(
            icon: Icons.format_list_bulleted,
            title: tr('Task', 'တာဝန်'),
            selected: selectedIndex == 2,
            onTap: () => onTap(2),
          ),

          _BottomItem(
            icon: Icons.diamond,
            title: tr('VIP', 'VIP'),
            selected: selectedIndex == 3,
            onTap: () => onTap(3),
          ),

          _BottomItem(
            icon: Icons.attach_money,
            title: tr('Profit', 'အမြတ်'),
            selected: selectedIndex == 4,
            onTap: () => onTap(4),
          ),

          _BottomItem(
            icon: Icons.account_circle,
            title: tr('Account', 'အကောင့်'),
            selected: selectedIndex == 5,
            onTap: () => onTap(5),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// BOTTOM ITEM
// ===========================================================================

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  static const Color gold = Color(0xFFDDB83A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        width: 58,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              width: selected ? 58 : 48,
              height: selected ? 44 : 44,

              decoration: BoxDecoration(
                color: selected ? const Color(0xFF292E37) : Colors.transparent,

                borderRadius: BorderRadius.circular(25),
              ),

              child: Icon(
                icon,

                color: selected ? gold : Colors.white,

                size: 28,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: selected ? gold : Colors.white,

                fontSize: 13,

                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
