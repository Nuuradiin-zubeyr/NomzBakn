import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class WalletSendDetailsScreen extends StatefulWidget {
  final String phone;
  final String? name;
  const WalletSendDetailsScreen({super.key, required this.phone, this.name});

  @override
  State<WalletSendDetailsScreen> createState() => _WalletSendDetailsScreenState();
}

class _WalletSendDetailsScreenState extends State<WalletSendDetailsScreen> {
  String _selectedAccount = 'Nomz Plus';
  bool _showOtherAccount = false;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final double _fee = 0.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _sendMoney() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid amount'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    double balance = _selectedAccount == 'Nomz Plus'
        ? prefs.getDouble('nomz_plus') ?? 0.0
        : prefs.getDouble('nomz_balance') ?? 0.0;
    if (amount + _fee > balance) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient funds in $_selectedAccount'), backgroundColor: Colors.red),
      );
      return;
    }
    // JAR lacagta
    if (_selectedAccount == 'Nomz Plus') {
      await prefs.setDouble('nomz_plus', balance - amount - _fee);
    } else {
      await prefs.setDouble('nomz_balance', balance - amount - _fee);
    }
    // Ku dar recents
    List<String> recents = prefs.getStringList('wallet_recents') ?? [];
    final newTx = {
      'name': widget.name ?? widget.phone,
      'phone': widget.phone,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    };
    recents.insert(0, newTx.toString());
    if (recents.length > 10) recents = recents.sublist(0, 10);
    await prefs.setStringList('wallet_recents', recents);
    // Notification
    await NotificationService.addTransactionNotification(
      type: 'send',
      amount: amount,
      recipientOrSender: widget.name ?? widget.phone,
      note: _descController.text,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent \$${amount.toStringAsFixed(2)} to ${widget.name ?? widget.phone}'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account type selector
            GestureDetector(
              onTap: () => setState(() => _showOtherAccount = !_showOtherAccount),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_selectedAccount == 'Nomz Plus' ? 'EVC Plus' : 'Nomz Balance', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            if (_showOtherAccount)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _selectedAccount = _selectedAccount == 'Nomz Plus' ? 'Nomz Balance' : 'Nomz Plus';
                          _showOtherAccount = false;
                        }),
                        child: Text(_selectedAccount == 'Nomz Plus' ? 'Nomz Balance' : 'EVC Plus'),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Receiver
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name ?? widget.phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.phone, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Processing Fee'),
                Text('\$${_fee.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendMoney,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 