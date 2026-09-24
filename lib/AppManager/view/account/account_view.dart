import 'package:flutter/material.dart';
import 'package:pam_wealth_flow/AppManager/view/account/language_view.dart';
import 'package:pam_wealth_flow/AppManager/view/transaction/transaction_view.dart';
import '../../model/user_model.dart';
import '../../service/auth_service.dart';
import '../../service/local_storage_service.dart';

import '../transaction/add_fund_view.dart';
import '../donate/donate_view.dart';
import '../help/help_center_view.dart';
import '../team/my_team_view.dart';
import '../../service/deep_link_service.dart';


class AccountView extends StatefulWidget {
  final String language;
  final VoidCallback? onLogout;
  final VoidCallback? onWithdraw;

  const AccountView({
    super.key,
    required this.language,
    this.onLogout,
    this.onWithdraw,
  });

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  UserModel? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = await LocalStorageService.getUserUid();
    if (uid != null) {
      final profile = await AuthService().getUserProfile(uid);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  String tr(String english, String burmese) {
    return widget.language == 'my' ? burmese : english;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    String truncatedUid = _userProfile?.uid != null 
        ? (_userProfile!.uid.length > 6 
            ? '***${_userProfile!.uid.substring(_userProfile!.uid.length - 6)}' 
            : _userProfile!.uid)
        : '***751701';

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

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.only(
            bottom: 25,
          ),

          child: Column(
            children: [

              // =============================================================
              // HEADER
              // =============================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  28,
                  28,
                  28,
                  0,
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    // SPACE (REMOVED BACK BUTTON)
                    const SizedBox(width: 27),

                    // TITLE
                    Text(
                      tr(
                        'Wealth Center',
                        'Wealth Center',
                      ),

                      style: const TextStyle(
                        color: gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // LOGOUT
                    GestureDetector(
                      onTap: widget.onLogout,

                      child: const Icon(
                        Icons.logout,
                        color: gold,
                        size: 27,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              // =============================================================
              // PROFILE ICON
              // =============================================================

              Container(
                width: 82,
                height: 82,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: gold,
                    width: 3,
                  ),
                ),

                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: gold,
                    size: 62,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // =============================================================
              // USERNAME & USER ID
              // =============================================================

              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: gold),
                )
              else ...[
                Text(
                  _userProfile?.username ?? 'PAM User',
                  style: const TextStyle(
                    color: gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tr('User ID', 'အသုံးပြုသူ ID')}: $truncatedUid',
                  style: const TextStyle(
                    color: white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 3),

              // =============================================================
              // MEMBERSHIP
              // =============================================================

              Text(
                tr(
                  'Membership Level: GV1',
                  'အဖွဲ့ဝင်အဆင့်: GV1',
                ),

                style: const TextStyle(
                  color: gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              // =============================================================
              // BALANCE CARD
              // =============================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    20,
                  ),

                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.95),

                    borderRadius:
                    BorderRadius.circular(25),

                    border: Border.all(
                      color: borderColor,
                      width: 1.3,
                    ),
                  ),

                  child: Column(
                    children: [

                      // -----------------------------------------------------
                      // BALANCE
                      // -----------------------------------------------------

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Text(
                                  tr(
                                    'Total Balance',
                                    'စုစုပေါင်းလက်ကျန်',
                                  ),

                                  style:
                                  const TextStyle(
                                    color: white,
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                FittedBox(
                                  alignment:
                                  Alignment.centerLeft,

                                  child: const Text(
                                    '3,002.49 THB',

                                    style: TextStyle(
                                      color: gold,
                                      fontSize: 24,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // WITHDRAW
                          SizedBox(
                            width: 125,
                            height: 45,

                            child: ElevatedButton(
                              onPressed: widget.onWithdraw,

                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                elevation: 0,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    17,
                                  ),
                                ),
                              ),

                              child: Text(
                                tr(
                                  'Withdraw',
                                  'ငွေထုတ်ရန်',
                                ),

                                style:
                                const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // -----------------------------------------------------
                      // DIVIDER
                      // -----------------------------------------------------

                      const Divider(
                        color: Color(0xFFB8B9BD),
                        thickness: 1,
                      ),

                      const SizedBox(height: 10),

                      // -----------------------------------------------------
                      // LOCKED / PROFIT
                      // -----------------------------------------------------

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          // LOCKED
                          Flexible(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Text(
                                  tr(
                                    'Locked Assets',
                                    'သော့ခတ်ထားသော ပိုင်ဆိုင်မှု',
                                  ),

                                  style:
                                  const TextStyle(
                                    color: white,
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                const Text(
                                  '11,000.00 THB',

                                  style: TextStyle(
                                    color: white,
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // PROFIT
                          Flexible(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.end,

                              children: [

                                Text(
                                  tr(
                                    'Total Profit',
                                    'စုစုပေါင်းအမြတ်',
                                  ),

                                  style:
                                  const TextStyle(
                                    color: white,
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                const Text(
                                  '+2,878.82 THB',

                                  style: TextStyle(
                                    color: green,
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w700,
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

              // =============================================================
              // MENU GRID
              // =============================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),

                child: GridView.count(
                  crossAxisCount: 4,

                  shrinkWrap: true,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  crossAxisSpacing: 8,

                  mainAxisSpacing: 12,

                  childAspectRatio: 0.72,

                  children: [

                    _MenuItem(
                      icon:
                      Icons.account_balance_wallet,
                      title: tr(
                        'Add Funds',
                        'ငွေဖြည့်ရန်',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddFundsScreen()),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.receipt_long,
                      title: tr(
                        'Transactions',
                        'ငွေလွှဲမှတ်တမ်း',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransactionsScreen()),
                        );
                      },
                    ),

                    _MenuItem(
                      icon: Icons.people,
                      title: tr(
                        'My Team',
                        'ကျွန်ုပ်အဖွဲ့',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyTeamScreen()),
                        );
                      },
                    ),

                    _MenuItem(
                      icon: Icons.language,
                      title: tr(
                        'Change Language',
                        'ဘာသာစကားပြောင်းရန်',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LanguagePage()),
                        );
                      },
                    ),

                    _MenuItem(
                      icon: Icons.share,
                      title: tr(
                        'Register Now',
                        'ယခုစာရင်းသွင်းရန်',
                      ),
                      onTap: () {
                        if (_userProfile?.uid != null) {
                          DeepLinkService.shareReferralLink(
                            referralCode: _userProfile!.myReferralCode,
                            appName: "PAM Wealth Flow",
                            language: widget.language,
                          );
                        }
                      },
                    ),

                    _MenuItem(
                      icon: Icons.shield,
                      title: tr(
                        'Earn More',
                        'ပိုမိုရရှိရန်',
                      ),
                      onTap: () {},
                    ),

                    _MenuItem(
                      icon: Icons.support_agent,
                      title: tr(
                        'Help Center',
                        'အကူအညီ',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                        );
                      },
                    ),

                    _MenuItem(
                      icon: Icons.card_giftcard,
                      title: tr(
                        'Donate',
                        'လှူဒါန်းရန်',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DonateScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // =============================================================
              // LOGOUT
              // =============================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: OutlinedButton.icon(
                    onPressed: widget.onLogout,

                    icon: const Icon(
                      Icons.logout,
                      color: red,
                      size: 20,
                    ),

                    label: Text(
                      tr(
                        'LOGOUT',
                        'ထွက်ရန်',
                      ),

                      style: const TextStyle(
                        color: red,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    style:
                    OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF87494E),
                        width: 1.5,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================================
// MENU ITEM
// =============================================================================

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  static const Color gold = Color(0xFFDDB83A);
  static const Color white = Color(0xFFF2F2F2);

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

              borderRadius:
              BorderRadius.circular(18),

              border: Border.all(
                color: const Color(0xFF50525A),
                width: 1.2,
              ),
            ),

            child: Center(
              child: Icon(
                icon,
                color: gold,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,

            maxLines: 2,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}