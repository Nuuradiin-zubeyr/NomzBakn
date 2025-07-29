import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class TransferScreen extends StatefulWidget {
  final Function(double amount)? onTransferComplete;
  
  const TransferScreen({
    super.key,
    this.onTransferComplete,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedContact = '';
  bool _isLoading = false;
  bool _useCustomPhone = false;

  final List<Contact> _contacts = [
    Contact(
      id: '1',
      name: 'Ahmed Hassan',
      phone: '+252 61 1234567',
      email: 'ahmed@email.com',
      avatar: 'A',
    ),
    Contact(
      id: '2',
      name: 'Fatima Ali',
      phone: '+252 61 2345678',
      email: 'fatima@email.com',
      avatar: 'F',
    ),
    Contact(
      id: '3',
      name: 'Omar Mohamed',
      phone: '+252 61 3456789',
      email: 'omar@email.com',
      avatar: 'O',
    ),
    Contact(
      id: '4',
      name: 'Amina Yusuf',
      phone: '+252 61 4567890',
      email: 'amina@email.com',
      avatar: 'A',
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If you have a _loadRecents or _loadTransactions, call it here
    // Example: _loadRecents();
  }

  Future<void> _sendMoney() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate contact selection or custom phone number
    if (!_useCustomPhone && _selectedContact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a contact or enter a phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_useCustomPhone && _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    
    // Check if user has enough balance
    final prefs = await SharedPreferences.getInstance();
    final currentBalance = prefs.getDouble('user_balance') ?? 12500.00;
    
    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. Available: \$${currentBalance.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Load sender info right before showing dialog
    await _loadSenderInfo();

    setState(() => _isLoading = false);

    if (mounted) {
      String recipientName;
      String recipientPhone;
      
      if (_useCustomPhone) {
        recipientName = 'Unknown Contact';
        recipientPhone = _phoneController.text.trim();
      } else {
        final selectedContact = _contacts.firstWhere((c) => c.id == _selectedContact);
        recipientName = selectedContact.name;
        recipientPhone = selectedContact.phone;
      }
      
      // Automatically deduct from balance
      final newBalance = currentBalance - amount;
      await prefs.setDouble('user_balance', newBalance);
      
      // Add notification for sent money
      await NotificationService.addTransactionNotification(
        type: 'send',
        amount: amount,
        recipientOrSender: recipientName,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      
      // Call back to update balance
      widget.onTransferComplete?.call(amount);
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and app name
                    Image.asset(
                      'assets/icons/wallet-solid.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nomzbank',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Transfer Successful!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$24${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipientName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      recipientPhone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow('Sender name', _nameFromPrefs != null && _nameFromPrefs!.isNotEmpty ? _nameFromPrefs! : '---', isBold: true),
                          _detailRow('Sender number', _phoneFromPrefs != null && _phoneFromPrefs!.isNotEmpty ? _phoneFromPrefs! : '---'),
                          _detailRow('Amount', '\$${amount.toStringAsFixed(2)}'),
                          _detailRow('Charge', '\$${0.00.toStringAsFixed(2)}'),
                          const Divider(height: 24, color: Colors.white24),
                          _detailRow('Balance', '\$${(currentBalance - amount).toStringAsFixed(2)}', isBold: true),
                          const SizedBox(height: 12),
                          const Text(
                            'Description',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                          Text(
                            _noteController.text.isNotEmpty ? _noteController.text : '-',
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Contact Selection
            Row(
              children: [
                Text(
                  'Select Contact',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _useCustomPhone,
                  onChanged: (value) {
                    setState(() {
                      _useCustomPhone = value;
                      if (value) {
                        _selectedContact = '';
                      }
                    });
                  },
                ),
                Text(
                  'Custom Phone',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_useCustomPhone) ...[
              // Custom Phone Number Input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number (e.g., +252 61 1234567)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ] else ...[
              // Contact List
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final isSelected = _selectedContact == contact.id;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          contact.avatar,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        contact.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(contact.phone),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedContact = contact.id;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            const SizedBox(height: 32),
            
            // Amount Input
            Text(
              'Amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > 10000) {
                  return 'Amount cannot exceed \$10,000';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Note Input
            Text(
              'Note (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Add a note',
                border: OutlineInputBorder(),
                hintText: 'What\'s this payment for?',
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendMoney,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send Money',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Amount Buttons
            Text(
              'Quick Amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickAmountButton('10'),
                _buildQuickAmountButton('25'),
                _buildQuickAmountButton('50'),
                _buildQuickAmountButton('100'),
                _buildQuickAmountButton('200'),
                _buildQuickAmountButton('500'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          '\$$amount',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper to get sender info from prefs
  String? _nameFromPrefs;
  String? _phoneFromPrefs;

  Future<void> _loadSenderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _nameFromPrefs = prefs.getString('profile_name');
    _phoneFromPrefs = prefs.getString('profile_phone');
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatar;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatar,
  });
} 