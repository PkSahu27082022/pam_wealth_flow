import 'package:flutter/material.dart';

class Transaction {
  final String userName;
  final String amount;
  final String subtitle;

  Transaction({
    required this.userName,
    required this.amount,
    this.subtitle = "Today's Earning",
  });
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F1218);
    const cardBackgroundColor = Color(0xFF161B22);
    const goldColor = Color(0xFFE5B83B);
    const borderColor = Color(0xFF2A313D);

    // Dummy data matching the design
    final List<Transaction> transactions = [
      Transaction(userName: 'User 1', amount: '2999 THB'),
      Transaction(userName: 'User 2', amount: '3000 THB'),
      Transaction(userName: 'User 3', amount: '4000 THB'),
      Transaction(userName: 'User 4', amount: '2000 THB'),
      Transaction(userName: 'User 5', amount: '40202 THB'),
      Transaction(userName: 'User 6', amount: '980 THB'),
    ];

    return Scaffold(
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
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
              child: Text(
                "Today's Earnings",
                style: TextStyle(
                  color: goldColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Scrollable List of Transactions
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = transactions[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Side: User Name
                        Text(
                          item.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Right Side: Amount & Subtitle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.amount,
                              style: const TextStyle(
                                color: goldColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}