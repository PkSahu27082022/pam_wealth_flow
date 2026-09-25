import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view-model/admin-vm/admin_vm.dart';
import '../../model/deposit_request_model.dart';
import '../../service/snackbar_service.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedIndex = 0;

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text('Admin Control Panel', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AdminStatsPage(),
          AdminSettingsPage(),
          AdminRequestsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF171A21),
        selectedItemColor: gold,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Requests'),
        ],
      ),
    );
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

// PAGE 2: Wallet & Manual Deposit
class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final walletController = TextEditingController();
  final userIdController = TextEditingController();
  final amountController = TextEditingController();

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
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(adminViewModelProvider).updateWallet(walletController.text);
                      Alert.show(context, message: 'Wallet updated', type: AlertType.success);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDDB83A)),
                    child: const Text('SAVE', style: TextStyle(color: Colors.black)),
                  )
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => const Text('Error loading wallet'),
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
                  decoration: const InputDecoration(labelText: 'User UID', labelStyle: TextStyle(color: Colors.white54)),
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
                  child: ElevatedButton(
                    onPressed: () async {
                      final uid = userIdController.text.trim();
                      final amount = double.tryParse(amountController.text) ?? 0;
                      final err = await ref.read(adminViewModelProvider).manualDeposit(uid, amount);
                      if (err == null) {
                        Alert.show(context, message: 'Deposit successful', type: AlertType.success);
                        userIdController.clear();
                        amountController.clear();
                      } else {
                        Alert.show(context, message: err, type: AlertType.error);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDDB83A)),
                    child: const Text('SUBMIT DEPOSIT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

// PAGE 3: Approvals
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

class _RequestList extends ConsumerWidget {
  final DepositStatus status;
  const _RequestList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(depositRequestsProvider(status));

    return requestsAsync.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('No requests found', style: TextStyle(color: Colors.white54)));
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final req = list[index];
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
                  SelectableText('ID: ${req.uid}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 5),
                  SelectableText('Hash: ${req.transactionHash}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  if (status == DepositStatus.pending) ...[
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(adminViewModelProvider).processRequest(req.id, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('APPROVE'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref.read(adminViewModelProvider).processRequest(req.id, false),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                            child: const Text('DECLINE', style: TextStyle(color: Colors.red)),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
