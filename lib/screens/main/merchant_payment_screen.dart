import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class MerchantPaymentScreen extends StatefulWidget {
  const MerchantPaymentScreen({super.key});

  @override
  State<MerchantPaymentScreen> createState() => _MerchantPaymentScreenState();
}

class _MerchantPaymentScreenState extends State<MerchantPaymentScreen> {
  final _merchantIdController = TextEditingController();
  String _selectedNetwork = 'Nomz Plus';
  List<Map<String, dynamic>> _recents = [];
  final bool _isLoading = false;
  String? _merchantNamePreview;

  final Map<String, String> _mockMerchants = {
    '626060': 'NASTEEXO RESTAURANT',
    '653144': 'SAMOW MARKET',
    '691497': 'AJMAL MINI MARKET',
    '690465': 'CARWO MARXABA',
    '663590': 'CABITAN SALUKI',
  };

  @override
  void initState() {
    super.initState();
    _loadRecents();
    _merchantIdController.addListener(_updateMerchantNamePreview);
  }

  void _updateMerchantNamePreview() {
    final id = _merchantIdController.text.trim();
    setState(() {
      if (id.isNotEmpty && _mockMerchants.containsKey(id)) {
        _merchantNamePreview = _mockMerchants[id];
      } else if (id.isNotEmpty) {
        _merchantNamePreview = 'Unknown Merchant';
      } else {
        _merchantNamePreview = null;
      }
    });
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final recents = prefs.getStringList('merchant_recents') ?? [];
    setState(() {
      _recents = recents.map((e) {
        final parts = e.split('|');
        return {
          'name': parts[0],
          'id': parts[1],
          'amount': double.tryParse(parts[2]) ?? 0.0,
        };
      }).toList();
    });
  }

  Future<void> _addRecent(String name, String id, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recents = prefs.getStringList('merchant_recents') ?? [];
    final entry = '$name|$id|$amount';
    recents.removeWhere((e) => e.contains('|$id|'));
    recents.insert(0, entry);
    if (recents.length > 10) recents = recents.sublist(0, 10);
    await prefs.setStringList('merchant_recents', recents);
    _loadRecents();
  }

  @override
  void dispose() {
    _merchantIdController.dispose();
    super.dispose();
  }

  void _onNext() async {
    final id = _merchantIdController.text.trim();
    if (id.isEmpty || id.length < 4 || int.tryParse(id) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid merchant ID (at least 4 digits)'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final merchantName = _mockMerchants[id] ?? 'Unknown Merchant';
    
    if (!mounted) return;

    // Use a Navigator.push that returns a value to check if payment was made
    final paymentMade = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MerchantPaymentDetailsScreen(
          network: _selectedNetwork,
          merchantId: id,
          merchantName: merchantName,
          // We pass the callback to be executed upon successful payment
          onPayment: (amount) async {
            await _addRecent(merchantName, id, amount);
          },
        ),
      ),
    );

    // Reload recents if payment was successful
    if (paymentMade == true) {
      _loadRecents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Network', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final network = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Nomz Plus'),
                        onTap: () => Navigator.pop(context, 'Nomz Plus'),
                      ),
                      ListTile(
                        title: const Text('Nomz Wallet'),
                        onTap: () => Navigator.pop(context, 'Nomz Wallet'),
                      ),
                    ],
                  ),
                );
                if (network != null) setState(() => _selectedNetwork = network);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedNetwork, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Merchant ID', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _merchantIdController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter merchant ID or scan QR',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    // TODO: Add QR code scanner
                  },
                ),
              ],
            ),
            if (_merchantNamePreview != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  _merchantNamePreview!,
                  style: TextStyle(
                    color: _merchantNamePreview == 'Unknown Merchant' ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onNext,
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recents', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _recents.length,
                itemBuilder: (context, index) {
                  final merchant = _recents[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(merchant['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(merchant['id']),
                    trailing: Text('\$${merchant['amount'].toStringAsFixed(2)}'),
                    onTap: () {
                      _merchantIdController.text = merchant['id'];
                      setState(() {
                        _merchantNamePreview = merchant['name'];
                      });
                    },
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

class MerchantPaymentDetailsScreen extends StatefulWidget {
  final String network;
  final String merchantId;
  final String merchantName;
  final Function(double amount)? onPayment;
  const MerchantPaymentDetailsScreen({super.key, required this.network, required this.merchantId, required this.merchantName, this.onPayment});

  @override
  State<MerchantPaymentDetailsScreen> createState() => _MerchantPaymentDetailsScreenState();
}

class _MerchantPaymentDetailsScreenState extends State<MerchantPaymentDetailsScreen> {
  final _amountController = TextEditingController();
  late String _selectedWallet;
  bool _isConfirming = false;

  // Use consistent naming and structure
  final List<Map<String, dynamic>> _wallets = [
    {
      'name': 'Nomz Balance',
      'number': '**** 1234',
      'balance': 0.0,
      'currency': 'USD',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'name': 'Nomz Plus',
      'number': '**** 5678',
      'balance': 0.0,
      'currency': 'USD',
      'icon': Icons.star_border_purple500_sharp,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Respect the network chosen on the previous screen
    _selectedWallet = widget.network;
    _loadWalletBalances();
  }

  Future<void> _loadWalletBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final nomzBalance = prefs.getDouble('nomz_balance') ?? 0.0;
    final nomzPlus = prefs.getDouble('nomz_plus') ?? 0.0;
    if (mounted) {
      setState(() {
        _wallets.firstWhere((w) => w['name'] == 'Nomz Balance')['balance'] = nomzBalance;
        _wallets.firstWhere((w) => w['name'] == 'Nomz Plus')['balance'] = nomzPlus;
      });
    }
  }

  void _selectWallet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _wallets.map((w) => ListTile(
          leading: Icon(w['icon'], color: Theme.of(context).colorScheme.primary),
          title: Text(w['name']),
          subtitle: Text('${w['number']}'),
          trailing: Text('\$${w['balance'].toStringAsFixed(2)}'),
          onTap: () => Navigator.pop(context, w['name']),
        )).toList(),
      ),
    );
    if (selected != null) setState(() => _selectedWallet = selected);
  }

  Map<String, dynamic> get _currentWallet => _wallets.firstWhere((w) => w['name'] == _selectedWallet);

  void _goToConfirmScreen() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
      );
      return;
    }

    final double currentBalance = _currentWallet['balance'] as double;
    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient funds in your selected wallet'), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantPaymentConfirmScreen(
          wallet: _selectedWallet,
          merchantId: widget.merchantId,
          merchantName: widget.merchantName,
          amount: amount,
          isLoading: _isConfirming,
          onConfirm: () async {
            if (_isConfirming) return;
            setState(() => _isConfirming = true);

            // --- ACTUAL PAYMENT LOGIC ---
            final prefs = await SharedPreferences.getInstance();
            final newBalance = currentBalance - amount;
            final key = _selectedWallet == 'Nomz Plus' ? 'nomz_plus' : 'nomz_balance';
            await prefs.setDouble(key, newBalance);

            // Call the onPayment callback to add to recents
            widget.onPayment?.call(amount);

            await NotificationService.addTransactionNotification(
              type: 'merchant_payment',
              amount: amount,
              recipientOrSender: widget.merchantName,
              note: 'Paid to ${widget.merchantName}',
            );
            // --- END PAYMENT LOGIC ---

            if (mounted) {
              // Pop all the way back to dashboard and indicate success
              Navigator.of(context).popUntil((route) => route.isFirst);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Paid \$$amount to ${widget.merchantName.isNotEmpty ? widget.merchantName : widget.merchantId}'), backgroundColor: Colors.green),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = _currentWallet;
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wallet selector card
            _buildInfoCard(
              context: context,
              icon: wallet['icon'],
              title: wallet['name'],
              subtitle: wallet['number'],
              trailing: '\$${(wallet['balance'] as double).toStringAsFixed(2)}',
              onTap: _selectWallet,
            ),
            
            const SizedBox(height: 16),

            // Merchant info card
            _buildInfoCard(
              context: context,
              icon: Icons.storefront_outlined,
              title: widget.merchantName,
              subtitle: widget.merchantId,
            ),
            
            const SizedBox(height: 32),

            // Amount
            Text('Amount', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '\$ ',
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              ),
            ),
            
            const Divider(height: 24),

            // Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Processing Fee', style: TextStyle(color: Colors.grey[600])),
                const Text('\$0.00', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            
            const Spacer(),

            // Pay Button
            ElevatedButton(
              onPressed: _goToConfirmScreen,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Pay', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required BuildContext context, required IconData icon, required String title, required String subtitle, String? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (onTap != null)
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class MerchantPaymentConfirmScreen extends StatelessWidget {
  final String wallet;
  final String merchantId;
  final String merchantName;
  final double amount;
  final bool isLoading;
  final VoidCallback onConfirm;
  const MerchantPaymentConfirmScreen({
    super.key,
    required this.wallet,
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Center(child: Icon(Icons.security_outlined, size: 80, color: Colors.amber)),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'You are paying',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Center(
              child: Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                'to ${merchantName.isNotEmpty ? merchantName : merchantId}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            _detailRow('From Wallet', wallet),
            _detailRow('To Merchant ID', merchantId),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm & Pay', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
} 