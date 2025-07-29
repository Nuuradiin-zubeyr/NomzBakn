import 'package:flutter/material.dart';
import 'wallet_send_screen.dart';
import 'merchant_payment_screen.dart';

class SendMoneyOptionsScreen extends StatelessWidget {
  const SendMoneyOptionsScreen({super.key});

  void _showPlaceholderDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInternalTransferDialog(BuildContext context) {
    Navigator.of(context).pop();
    // Waa in aad wacdaa internal transfer dialog-ka dashboard-ka
    // Haddii aad rabto in aad si toos ah ugu gudubto, ku dar navigation sax ah
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          children: [
            _buildSendOption(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Wallet',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WalletSendScreen(),
                  ),
                );
              },
            ),
            _buildSendOption(
              context,
              icon: Icons.store,
              label: 'Merchant',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MerchantPaymentScreen(),
                  ),
                );
              },
            ),
            _buildSendOption(
              context,
              icon: Icons.account_balance,
              label: 'Bank',
              onTap: () => _showPlaceholderDialog(context, 'Bank Transfer'),
            ),
            _buildSendOption(
              context,
              icon: Icons.send_to_mobile,
              label: 'TAAJ',
              onTap: () => _showPlaceholderDialog(context, 'TAAJ Transfer'),
            ),
            _buildSendOption(
              context,
              icon: Icons.swap_horiz,
              label: 'Inter-wallet transfer',
              onTap: () => _showInternalTransferDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOption(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
} 