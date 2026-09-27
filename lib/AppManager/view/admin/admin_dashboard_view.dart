import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/auth_service.dart';
import '../../service/snackbar_service.dart';
import '../../model/deposit_request_model.dart';
import '../../model/user_model.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../view-model/admin-vm/admin_vm.dart';
import '../account/login_view.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedIndex = 0;

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);

  Future<void> _logout() async {
    await AuthService().logout();

    ref.invalidate(userProfileProvider);
    ref.invalidate(adminStatsProvider);
    ref.invalidate(walletAddressProvider);
    ref.invalidate(allUsersProvider);

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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171920),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out from Admin Panel?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE57373)),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text('Admin Control Panel', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: gold),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _getAdminPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF171A21),
        selectedItemColor: gold,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Requests'),
        ],
      ),
    );
  }

  Widget _getAdminPage(int index) {
    switch (index) {
      case 0:
        return const AdminStatsPage();
      case 1:
        return const AdminUsersPage();
      case 2:
        return const AdminSettingsPage();
      case 3:
        return const AdminRequestsPage();
      default:
        return const AdminStatsPage();
    }
  }
}

// PAGE 1: Statistics
class AdminStatsPage extends ConsumerWidget {
  const AdminStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final planCounts = stats['planCounts'] as Map<String, int>? ?? {};
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatHeader('User Distribution'),
              _buildSimpleCard('Total Users', '${stats['totalUsers'] ?? 0}'),
              const SizedBox(height: 15),
              ...planCounts.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSimpleCard(e.key, '${e.value} Users'),
              )),
              const SizedBox(height: 25),
              _buildStatHeader('Financial Summary'),
              _buildSimpleCard('Total Deposits', '${(stats['totalDeposits'] ?? 0.0).toStringAsFixed(2)} THB'),
              const SizedBox(height: 10),
              _buildSimpleCard('System Liabilities', '${(stats['totalCurrentBalance'] ?? 0.0).toStringAsFixed(2)} THB'),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFDDB83A))),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(title, style: const TextStyle(color: Color(0xFFDDB83A), fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSimpleCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171920),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF50525A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// PAGE 2: User Directory & Quick Deposit
class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDepositDialog(UserModel user) {
    final amountController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF171920),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF50525A), width: 1.2),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add_card, color: Color(0xFFDDB83A)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Send Deposit',
                      style: TextStyle(color: Color(0xFFDDB83A), fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1218),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A313D)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User: ${user.username}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'User ID: ${user.userId.isNotEmpty ? user.userId : user.uid}',
                          style: const TextStyle(color: Color(0xFFDDB83A), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text('Current Balance: ${user.balance.toStringAsFixed(2)} THB', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Deposit Amount (THB)',
                      labelStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Color(0xFF0F1218),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final amountText = amountController.text.trim();
                          final amount = double.tryParse(amountText);
                          if (amount == null || amount <= 0) {
                            Alert.show(context, message: 'Please enter a valid amount', type: AlertType.warning);
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          final targetId = user.userId.isNotEmpty ? user.userId : user.uid;
                          final err = await ref.read(adminViewModelProvider).manualDeposit(targetId, amount);

                          if (mounted) {
                            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                            final currentCtx = context;
                            if (err == null) {
                              Alert.showPopup(
                                currentCtx,
                                title: 'Deposit Successful',
                                message: 'Successfully credited ${amount.toStringAsFixed(2)} THB to ${user.username} (ID: $targetId).',
                                type: AlertType.success,
                              );
                            } else {
                              Alert.showPopup(
                                currentCtx,
                                title: 'Deposit Failed',
                                message: err,
                                type: AlertType.error,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDDB83A)),
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('SUBMIT DEPOSIT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search by Name, User ID or Email...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFDDB83A)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF171920),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF50525A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDDB83A)),
              ),
            ),
          ),
        ),

        Expanded(
          child: usersAsync.when(
            data: (users) {
              final filteredList = users.where((u) {
                if (_searchQuery.isEmpty) return true;
                final nameMatches = u.username.toLowerCase().contains(_searchQuery);
                final idMatches = u.userId.toLowerCase().contains(_searchQuery) || u.uid.toLowerCase().contains(_searchQuery);
                final emailMatches = u.email.toLowerCase().contains(_searchQuery);
                return nameMatches || idMatches || emailMatches;
              }).toList();

              if (filteredList.isEmpty) {
                return const Center(
                  child: Text('No users found', style: TextStyle(color: Colors.white54)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final u = filteredList[index];
                  final displayId = u.userId.isNotEmpty ? u.userId : u.uid;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171920),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF50525A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFDDB83A),
                              radius: 20,
                              child: Text(
                                u.username.isNotEmpty
                                    ? u.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                u.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            // Small details button
                            OutlinedButton(
                              onPressed: () => _showUserDetailsDialog(u),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDDB83A),
                                side: const BorderSide(
                                  color: Color(0xFFDDB83A),
                                  width: 0.8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'VIEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        const Divider(
                          color: Color(0xFF2A313D),
                          height: 1,
                        ),

                        const SizedBox(height: 12),

                        // User ID + Plan
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'USER ID',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),

                                  Row(
                                    children: [
                                      Flexible(
                                        child: SelectableText(
                                          displayId,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Color(0xFFDDB83A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(text: displayId),
                                          );

                                          Alert.show(
                                            context,
                                            message:
                                            'User ID $displayId copied to clipboard!',
                                            type: AlertType.success,
                                          );
                                        },
                                        child: const Icon(
                                          Icons.copy,
                                          color: Color(0xFFDDB83A),
                                          size: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'PLAN',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  u.activeTier,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFDDB83A))),
            error: (e, s) => Center(child: Text('Error loading users: $e', style: const TextStyle(color: Colors.redAccent))),
          ),
        ),
      ],
    );
  }

  void _showUserDetailsDialog(UserModel u) {
    final displayId = u.userId.isNotEmpty ? u.userId : u.uid;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171920),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFF50525A),
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),

          title: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFFDDB83A),
                child: Text(
                  u.username.isNotEmpty
                      ? u.username[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      u.isAdmin ? 'ADMIN' : 'USER',
                      style: TextStyle(
                        color: u.isAdmin
                            ? const Color(0xFFDDB83A)
                            : Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _detailRow('UID', u.uid),

                  _detailRow('USER ID', u.userId.isEmpty?u.uid:u.userId),

                  _detailRow('USERNAME', u.username),

                  _detailRow('EMAIL', u.email),

                  _detailRow(
                    'MY REFERRAL CODE',
                    u.myReferralCode,
                  ),

                  _detailRow(
                    'REFERRED BY',
                    u.referredBy.isEmpty
                        ? 'None'
                        : u.referredBy,
                  ),

                  _detailRow(
                    'LANGUAGE',
                    u.language,
                  ),

                  _detailRow(
                    'ROLE',
                    u.role,
                  ),

                  _detailRow(
                    'ACTIVE PLAN',
                    u.activeTier,
                  ),

                  _detailRow(
                    'BALANCE',
                    '${u.balance.toStringAsFixed(2)} THB',
                  ),

                  _detailRow(
                    'TOTAL EARNED',
                    '${u.totalEarned.toStringAsFixed(2)} THB',
                  ),

                  _detailRow(
                    'TASKS COMPLETED TODAY',
                    u.tasksCompletedToday.toString(),
                  ),

                  _detailRow(
                    'WATCHED VIDEOS',
                    '${u.watchedVideoIds.length}',
                  ),

                  _detailRow(
                    'WATCHED VIDEO IDS',
                    u.watchedVideoIds.isEmpty
                        ? 'None'
                        : u.watchedVideoIds.join(', '),
                  ),

                  _detailRow(
                    'CREATED AT',
                    _formatDateTime(u.createdAt),
                  ),

                  _detailRow(
                    'LAST TASK DATE',
                    _formatDateTime(u.lastTaskDate),
                  ),

                  _detailRow(
                    'PLAN ACTIVATED AT',
                    _formatDateTime(u.planActivatedAt),
                  ),
                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(
                  color: Color(0xFFDDB83A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  }

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Not available';
  }

  final local = dateTime.toLocal();

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${local.day}/${local.month}/${local.year} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


// PAGE 3: Wallet & Manual Deposit
class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final walletController = TextEditingController();
  final userIdController = TextEditingController();
  final amountController = TextEditingController();

  bool _isSavingWallet = false;
  bool _isSubmittingDeposit = false;

  @override
  void dispose() {
    walletController.dispose();
    userIdController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _updateWallet() async {
    final address = walletController.text.trim();
    if (address.isEmpty) {
      Alert.showPopup(
        context,
        title: 'Validation Error',
        message: 'Please enter a valid wallet address.',
        type: AlertType.warning,
      );
      return;
    }

    setState(() => _isSavingWallet = true);

    try {
      await ref.read(adminViewModelProvider).updateWallet(address);
      if (mounted) {
        walletController.clear();
        Alert.showPopup(
          context,
          title: 'Wallet Updated',
          message: 'Deposit wallet address updated successfully!',
          type: AlertType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        Alert.showPopup(
          context,
          title: 'Update Failed',
          message: e.toString(),
          type: AlertType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingWallet = false);
    }
  }

  Future<void> _submitManualDeposit() async {
    final uid = userIdController.text.trim();
    final amountText = amountController.text.trim();

    if (uid.isEmpty || amountText.isEmpty) {
      Alert.showPopup(
        context,
        title: 'Validation Error',
        message: 'Please fill in both User ID and Amount.',
        type: AlertType.warning,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Alert.showPopup(
        context,
        title: 'Validation Error',
        message: 'Please enter a valid deposit amount greater than zero.',
        type: AlertType.warning,
      );
      return;
    }

    setState(() => _isSubmittingDeposit = true);

    try {
      final err = await ref.read(adminViewModelProvider).manualDeposit(uid, amount);
      if (mounted) {
        if (err == null) {
          userIdController.clear();
          amountController.clear();
          Alert.showPopup(
            context,
            title: 'Deposit Successful',
            message: 'Successfully credited ${amount.toStringAsFixed(2)} THB to User ID: $uid',
            type: AlertType.success,
          );
        } else {
          Alert.showPopup(
            context,
            title: 'Deposit Failed',
            message: err,
            type: AlertType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Alert.showPopup(
          context,
          title: 'Deposit Error',
          message: e.toString(),
          type: AlertType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingDeposit = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletAddressProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deposit Wallet Address', style: TextStyle(color: Color(0xFFDDB83A), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          walletAsync.when(
            data: (addr) {
              if (walletController.text.isEmpty && addr != null) walletController.text = addr;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: walletController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF171920),
                        hintText: 'Enter Wallet Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSavingWallet ? null : _updateWallet,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDDB83A)),
                      child: _isSavingWallet
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : const Text('SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(color: Color(0xFFDDB83A)),
            error: (e, s) => const Text('Error loading wallet', style: TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 40),
          const Text('Custom Deposit (Force Add Balance)', style: TextStyle(color: Color(0xFFDDB83A), fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF171920), borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                TextField(
                  controller: userIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'User ID (6-digit ID or UID)',
                    labelStyle: TextStyle(color: Colors.white54),
                    hintText: 'Enter 6-digit User ID',
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Amount (THB)', labelStyle: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmittingDeposit ? null : _submitManualDeposit,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDDB83A)),
                    child: _isSubmittingDeposit
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text('SUBMIT DEPOSIT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PAGE 4: Approvals
class AdminRequestsPage extends ConsumerWidget {
  const AdminRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Color(0xFFDDB83A),
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Declined'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _RequestList(status: DepositStatus.pending),
                _RequestList(status: DepositStatus.approved),
                _RequestList(status: DepositStatus.declined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends ConsumerStatefulWidget {
  final DepositStatus status;
  const _RequestList({required this.status});

  @override
  ConsumerState<_RequestList> createState() => _RequestListState();
}

class _RequestListState extends ConsumerState<_RequestList> {
  String? _processingActionKey;

  Future<void> _handleProcessRequest(DepositRequestModel req, bool approve) async {
    final actionKey = '${req.id}_${approve ? 'approve' : 'decline'}';
    setState(() => _processingActionKey = actionKey);

    try {
      final err = await ref.read(adminViewModelProvider).processRequest(req.id, approve);
      if (mounted) {
        if (err == null) {
          Alert.showPopup(
            context,
            title: approve ? 'Request Approved' : 'Request Declined',
            message: approve
                ? 'Deposit request of ${req.amount} THB for ${req.userName} has been approved.'
                : 'Deposit request of ${req.amount} THB for ${req.userName} has been declined.',
            type: approve ? AlertType.success : AlertType.warning,
          );
        } else {
          Alert.showPopup(
            context,
            title: 'Action Failed',
            message: err,
            type: AlertType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Alert.showPopup(
          context,
          title: 'Error',
          message: e.toString(),
          type: AlertType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _processingActionKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(depositRequestsProvider(widget.status));

    return requestsAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('No requests found', style: TextStyle(color: Colors.white54)));
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final req = list[index];
            final bool isApproving = _processingActionKey == '${req.id}_approve';
            final bool isDeclining = _processingActionKey == '${req.id}_decline';
            final bool isProcessingAny = _processingActionKey != null;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF171920),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF50525A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('User: ${req.userName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${req.amount} THB', style: const TextStyle(color: Color(0xFFDDB83A), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  SelectableText(
                    'User ID: ${req.userId.isNotEmpty ? req.userId : req.uid}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  SelectableText(
                    'Tx Hash: ${req.transactionHash}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  if (widget.status == DepositStatus.pending) ...[
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isProcessingAny ? null : () => _handleProcessRequest(req, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              disabledBackgroundColor: Colors.grey.shade800,
                            ),
                            child: isApproving
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('APPROVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isProcessingAny ? null : () => _handleProcessRequest(req, false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: isDeclining
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                                : const Text('DECLINE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFDDB83A))),
      error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
    );
  }
}
