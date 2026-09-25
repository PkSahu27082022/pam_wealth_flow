import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../model/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const backgroundColor = Color(0xFF0F1218);
    const goldColor = Color(0xFFE5B83B);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Transactions',
            style: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: goldColor,
            labelColor: goldColor,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "My History"),
              Tab(text: "Referral History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TransactionList(provider: userTransactionsProvider, isReferral: false),
            _TransactionList(provider: referralTransactionsProvider, isReferral: true),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  final StreamProvider<List<TransactionModel>> provider;
  final bool isReferral;

  const _TransactionList({required this.provider, required this.isReferral});

  IconData _getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit: return Icons.add_circle_outline;
      case TransactionType.withdrawal: return Icons.remove_circle_outline;
      case TransactionType.planUnlock: return Icons.diamond_outlined;
      case TransactionType.taskReward: return Icons.play_circle_outline;
      case TransactionType.donationSent: return Icons.send_outlined;
      case TransactionType.donationReceived: return Icons.card_giftcard_outlined;
      case TransactionType.referralReward: return Icons.people_outline;
    }
  }

  Color _getColor(double amount) {
    return amount >= 0 ? Colors.greenAccent : Colors.redAccent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const cardBackgroundColor = Color(0xFF161B22);
    const goldColor = Color(0xFFE5B83B);
    const borderColor = Color(0xFF2A313D);

    final transactionsAsync = ref.watch(provider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 64, color: Colors.white10),
                const SizedBox(height: 16),
                Text(
                  isReferral ? "No referral activity yet." : "No transactions yet.",
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20.0),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = transactions[index];
            final isPositive = item.amount >= 0;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getColor(item.amount).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(item.type),
                      color: _getColor(item.amount),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (isReferral || item.type == TransactionType.referralReward) ...[
                              Text(
                                item.userName,
                                style: const TextStyle(
                                  color: goldColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(" • ", style: TextStyle(color: Colors.white24)),
                            ],
                            Text(
                              DateFormat('MMM dd, HH:mm').format(item.timestamp),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${isPositive ? '+' : ''}${item.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: _getColor(item.amount),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "THB",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: goldColor)),
      error: (err, stack) => Center(
        child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}
