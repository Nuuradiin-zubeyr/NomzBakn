import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _senderController = TextEditingController();
  String? _selectedAccount;
  bool _isLoading = false;

  final List<String> _accounts = ['Nomz Plus', 'Nomz Balance'];

  @override
  void dispose() {
    _amountController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  Future<void> _addMoney() async {
    if (!_formKey.currentState!.validate() || _selectedAccount == null) return;
    setState(() => _isLoading = true);
    final amount = double.parse(_amountController.text);
    final sender = _senderController.text.trim();
    final accountKey = _selectedAccount == 'Nomz Plus' ? 'nomz_plus' : 'nomz_balance';
    final prefs = await SharedPreferences.getInstance();
    final oldBalance = prefs.getDouble(accountKey) ?? 0.0;
    final newBalance = oldBalance + amount;
    await prefs.setDouble(accountKey, newBalance);
    final now = DateTime.now();
    await NotificationService.addTransactionNotification(
      type: 'add',
      amount: amount,
      recipientOrSender: sender,
      note: 'Added to $_selectedAccount account',
    );
    setState(() => _isLoading = false);
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: Text('Lacag \$${amount.toStringAsFixed(2)} ayaa lagu shubay $_selectedAccount account.\nBalance cusub: \$${newBalance.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      _amountController.clear();
      _senderController.clear();
      setState(() => _selectedAccount = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Money')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter amount';
                  final v = double.tryParse(value);
                  if (v == null || v <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senderController,
                decoration: const InputDecoration(
                  labelText: 'Sender Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter sender name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Account Type:'),
              const SizedBox(height: 8),
              Row(
                children: _accounts.map((acc) => Expanded(
                  child: Card(
                    color: _selectedAccount == acc ? Theme.of(context).colorScheme.primary : Colors.white,
                    child: InkWell(
                      onTap: () => setState(() => _selectedAccount = acc),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            acc,
                            style: TextStyle(
                              color: _selectedAccount == acc ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addMoney,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Lacag ku shub', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 