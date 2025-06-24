import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        'desc': 'Received from Ahmed',
        'date': '2025-06-21 10:30 AM',
        'type': 'receive',
        'amount': 150.00,
        'icon': Icons.arrow_downward,
      },
      {
        'desc': 'Sent to Amina',
        'date': '2025-06-20 04:15 PM',
        'type': 'send',
        'amount': 75.50,
        'icon': Icons.arrow_upward,
      },
      {
        'desc': 'Received from Business',
        'date': '2025-06-19 01:00 PM',
        'type': 'receive',
        'amount': 1200.00,
        'icon': Icons.arrow_downward,
      },
      {
        'desc': 'Sent to NomzBank',
        'date': '2025-06-18 09:45 AM',
        'type': 'send',
        'amount': 300.00,
        'icon': Icons.arrow_upward,
      },
      {
        'desc': 'Received from Nira',
        'date': '2025-06-17 11:20 AM',
        'type': 'receive',
        'amount': 50.00,
        'icon': Icons.arrow_downward,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: ListView.builder(
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