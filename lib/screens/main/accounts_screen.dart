import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with dynamic accounts from provider/service
    final List<Map<String, dynamic>> accounts = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: accounts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No accounts yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Add an account to get started.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
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