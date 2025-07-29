import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../screens/main/notifications_screen.dart';
import 'transfer_screen.dart';
import '../../services/notification_service.dart';
import '../../screens/main/add_money_screen.dart';
import '../../screens/main/merchant_payment_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'User';
  double _nomzBalance = 0.0;
  double _nomzPlus = 0.0;
  String _nomzBalanceNumber = '**** 1234';
  String _nomzPlusNumber = '**** 5678';
  bool _showNomzBalanceNumber = false;
  bool _showNomzPlusNumber = false;
  double _balance = 12500.00;
  double _monthlySpending = 3200.00;
  double _monthlyIncome = 4500.00;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationCount();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('profile_name') ?? 'User';
      _nomzBalance = prefs.getDouble('nomz_balance') ?? 0.0;
      _nomzPlus = prefs.getDouble('nomz_plus') ?? 0.0;
      _nomzBalanceNumber = prefs.getString('nomz_balance_number') ?? '**** 1234';
      _nomzPlusNumber = prefs.getString('nomz_plus_number') ?? '**** 5678';
      _balance = prefs.getDouble('user_balance') ?? 0.0;
      _monthlySpending = prefs.getDouble('monthly_spending') ?? 0.0;
      _monthlyIncome = prefs.getDouble('monthly_income') ?? 0.0;
    });
  }

  Future<void> _loadNotificationCount() async {
    final count = await NotificationService.getUnreadCount();
    setState(() {
      _unreadNotifications = count;
    });
  }

  Future<void> _updateBalance(double newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_balance', newBalance);
    setState(() {
      _balance = newBalance;
    });
  }

  Future<void> _updateSpending(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final newSpending = _monthlySpending + amount;
    await prefs.setDouble('monthly_spending', newSpending);
    setState(() {
      _monthlySpending = newSpending;
    });
  }

  Future<void> _addMoney(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final newBalance = _balance + amount;
    final newIncome = _monthlyIncome + amount;
    
    await prefs.setDouble('user_balance', newBalance);
    await prefs.setDouble('monthly_income', newIncome);
    
    setState(() {
      _balance = newBalance;
      _monthlyIncome = newIncome;
    });

    // Add notification for received money
    await NotificationService.addTransactionNotification(
      type: 'receive',
      amount: amount,
      recipientOrSender: 'Your Account',
      note: 'Money added to balance',
    );

    // Refresh notification count
    _loadNotificationCount();
  }

  void _showAddMoneyDialog() {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                await _addMoney(amount);
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added \$${amount.toStringAsFixed(2)} to your balance'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _userName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                    // Refresh notification count when returning
                    _loadNotificationCount();
                  },
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined),
                      if (_unreadNotifications > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _unreadNotifications > 99 ? '99+' : _unreadNotifications.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvailableBalanceCard(),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    
                    // Spending Analytics
                    _buildSpendingAnalytics(),
                    const SizedBox(height: 24),
                    
                    // Recent Transactions
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildAvailableBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // Empty space for symmetry
              SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nomz Balance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Text(_showNomzBalanceNumber ? _nomzBalanceNumber : '**** ****', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      IconButton(
                        icon: Icon(_showNomzBalanceNumber ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () {
                          setState(() {
                            _showNomzBalanceNumber = !_showNomzBalanceNumber;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Text('\$${_nomzBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nomz Plus', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Text(_showNomzPlusNumber ? _nomzPlusNumber : '**** ****', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      IconButton(
                        icon: Icon(_showNomzPlusNumber ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () {
                          setState(() {
                            _showNomzPlusNumber = !_showNomzPlusNumber;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Text('\$${_nomzPlus.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Send Money',
                Icons.send,
                Colors.blue,
                _showSendMoneyOptions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Add Money',
                Icons.add_circle,
                Colors.green,
                () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddMoneyScreen(),
                    ),
                  );
                  // Reload user data when returning from AddMoneyScreen
                  _loadUserData();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Bank',
                Icons.account_balance,
                Colors.orange,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bank transfer is coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Merchant',
                Icons.storefront,
                Colors.purple,
                () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MerchantPaymentScreen()),
                  );
                  // Reload user data when returning
                  _loadUserData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSendMoneyOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Money',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
                title: const Text('Send to Contact', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Transfer to another Nomzbank user'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TransferScreen(
                        onTransferComplete: (amount) async {
                          await _updateBalance(_balance - amount);
                          await _updateSpending(amount);
                          _loadNotificationCount();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Balance updated: -\$${amount.toStringAsFixed(2)}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.receipt_long_outlined, color: Theme.of(context).colorScheme.primary),
                title: const Text('Pay Bill', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pay your utility bills'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to pay bill screen
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.swap_horiz_outlined, color: Theme.of(context).colorScheme.primary),
                title: const Text('Internal Transfer', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Move money between your accounts'),
                onTap: () {
                  Navigator.pop(context); // Close this sheet first
                  _showInternalTransferDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInternalTransferDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInSheet) {
            String fromAccount = 'Nomz Balance';
            final amountController = TextEditingController();

            void swapAccounts() {
              setStateInSheet(() {
                fromAccount = fromAccount == 'Nomz Balance' ? 'Nomz Plus' : 'Nomz Balance';
              });
            }

            void handleTransfer() async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount.'), backgroundColor: Colors.red),
                );
                return;
              }

              final double fromBalance = fromAccount == 'Nomz Balance' ? _nomzBalance : _nomzPlus;

              if (amount > fromBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Insufficient funds in $fromAccount.'), backgroundColor: Colors.red),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              if (fromAccount == 'Nomz Balance') {
                await prefs.setDouble('nomz_balance', _nomzBalance - amount);
                await prefs.setDouble('nomz_plus', _nomzPlus + amount);
              } else {
                await prefs.setDouble('nomz_plus', _nomzPlus - amount);
                await prefs.setDouble('nomz_balance', _nomzBalance + amount);
              }

              await NotificationService.addTransactionNotification(
                type: 'internal',
                amount: amount,
                recipientOrSender: '$fromAccount → ${fromAccount == 'Nomz Balance' ? 'Nomz Plus' : 'Nomz Balance'}',
                note: 'Internal transfer of \$${amount.toStringAsFixed(2)}',
              );

              _loadUserData();
              _loadNotificationCount();

              if (mounted) {
                Navigator.pop(context); // Close the bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transferred \$${amount.toStringAsFixed(2)} to ${fromAccount == 'Nomz Balance' ? 'Nomz Plus' : 'Nomz Balance'}.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Internal Transfer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // From Account
                  _buildAccountCard(
                    context: context,
                    accountName: fromAccount,
                    balance: fromAccount == 'Nomz Balance' ? _nomzBalance : _nomzPlus,
                    label: 'FROM',
                  ),
                  
                  // Swap Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.swap_vert, size: 32),
                      onPressed: swapAccounts,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  // To Account
                  _buildAccountCard(
                    context: context,
                    accountName: fromAccount == 'Nomz Balance' ? 'Nomz Plus' : 'Nomz Balance',
                    balance: fromAccount == 'Nomz Balance' ? _nomzPlus : _nomzBalance,
                    label: 'TO',
                  ),

                  const SizedBox(height: 24),

                  // Amount Field
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount to Transfer',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Transfer Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleTransfer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirm Transfer'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget for the account card in the bottom sheet
  Widget _buildAccountCard({required BuildContext context, required String accountName, required double balance, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(accountName == 'Nomz Plus' ? Icons.star_border_purple500_sharp : Icons.account_balance_wallet_outlined, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(accountName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text('\$${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpendingAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This Month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_monthlySpending.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSpendingCategory('Food & Dining', 850, 0.27),
              const SizedBox(height: 12),
              _buildSpendingCategory('Transportation', 650, 0.20),
              const SizedBox(height: 12),
              _buildSpendingCategory('Shopping', 450, 0.14),
              const SizedBox(height: 12),
              _buildSpendingCategory('Entertainment', 350, 0.11),
              const SizedBox(height: 12),
              _buildSpendingCategory('Others', 900, 0.28),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingCategory(String category, double amount, double percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getCategoryColor(category),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(percentage * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return Colors.orange;
      case 'Transportation':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Entertainment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to transactions screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionItem(
          'Starbucks',
          'Food & Dining',
          -8.50,
          'assets/images/starbucks.png',
          '2 hours ago',
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          'Uber Ride',
          'Transportation',
          -12.30,
          'assets/images/uber.png',
          '4 hours ago',
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          'Salary',
          'Income',
          4500.00,
          'assets/images/salary.png',
          '2 days ago',
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String category, double amount, String icon, String time) {
    final isIncome = amount > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Income':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
} 