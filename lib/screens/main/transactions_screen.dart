import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with dynamic transactions from provider/service
    final List<Map<String, dynamic>> transactions = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No transactions yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Your transactions will appear here.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isReceive = tx['type'] == 'receive';
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isReceive
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      child: Icon(
                        tx['icon'] as IconData,
                        color: isReceive ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      tx['desc'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      tx['date'] as String,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: Text(
                      '${isReceive ? '+' : '-'}\$${(tx['amount'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isReceive ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }
} 