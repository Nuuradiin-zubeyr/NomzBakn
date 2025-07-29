import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'wallet_send_details_screen.dart';

class WalletSendScreen extends StatefulWidget {
  const WalletSendScreen({super.key});

  @override
  State<WalletSendScreen> createState() => _WalletSendScreenState();
}

class _WalletSendScreenState extends State<WalletSendScreen> {
  final _phoneController = TextEditingController();
  List<Contact> _contacts = [];
  final List<Map<String, dynamic>> _recents = [];
  bool _showContacts = false;
  String? _selectedContactName;

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecents();
  }

  Future<void> _loadContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        _showContacts = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadRecents() async {
    // TODO: Load last 10 real transactions from storage
    setState(() {});
  }

  void _selectContact(Contact contact) {
    final phone = (contact.phones.isNotEmpty) ? contact.phones.first.number : '';
    _phoneController.text = phone;
    setState(() {
      _showContacts = false;
    });
    _selectedContactName = contact.displayName;
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: 'Enter the phone number or select from contacts',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.contacts),
                  onPressed: _loadContacts,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WalletSendDetailsScreen(
                        phone: _phoneController.text,
                        name: _selectedContactName,
                      ),
                    ),
                  );
                },
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 24),
            if (_showContacts)
              Expanded(
                child: ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final name = contact.displayName;
                    final phone = (contact.phones.isNotEmpty) ? contact.phones.first.number : '';
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(name),
                      subtitle: Text(phone),
                      onTap: () => _selectContact(contact),
                    );
                  },
                ),
              )
            else ...[
              const Text('Recents', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _recents.length,
                  itemBuilder: (context, index) {
                    final recent = _recents[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(recent['name'] ?? ''),
                      subtitle: Text(recent['phone'] ?? ''),
                      trailing: Text('\$${recent['amount']?.toStringAsFixed(2) ?? ''}'),
                      onTap: () {
                        _phoneController.text = recent['phone'] ?? '';
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 