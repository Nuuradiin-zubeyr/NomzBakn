import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = [
      {
        'name': 'Main Account',
        'number': '1234 5678 9012',
        'type': 'Savings',
        'balance': 24562.00,
        'icon': Icons.account_balance_wallet,
      },
      {
        'name': 'Nira Account',
        'number': '1234 5678 9012',
        'type': 'Savings',
        'balance': 24562.00,
        'icon': Icons.account_balance_wallet,
      },
      {
        'name': 'Nomz Account',
        'number': '1234 5678 9012',
        'type': 'Savings',
        'balance': 24562.00,
        'icon': Icons.account_balance_wallet,
      },
      {
        'name': 'Business Account',
        'number': '9876 5432 1098',
        'type': 'Current',
        'balance': 10500.50,
        'icon': Icons.business_center,
      },
      {
        'name': 'Dollar Account',
        'number': '1122 3344 5566',
        'type': 'USD',
        'balance': 3200.75,
        'icon': Icons.attach_money,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return Card(
            color: Theme.of(context).colorScheme.surface,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    account['icon'] as IconData,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  account['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No: ${account['number']}'),
                    Text('Type: ${account['type']}'),
                  ],
                ),
                trailing: Text(
                  '\$${(account['balance'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
    );
  }
} 