import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetPinScreen extends StatefulWidget {
  final bool fromSettings;
  const SetPinScreen({super.key, this.fromSettings = false});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _pinController = TextEditingController();
  String? _error;
  final String _appIconAsset = 'assets/icons/wallet-solid.png';
  final String _appName = 'Nomzbank';

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() => _error = 'PIN must be 4 digits');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin);
    setState(() => _error = null);
    if (!widget.fromSettings) {
      await prefs.setStringList('merchant_recents', []);
      await prefs.setStringList('wallet_recents', []);
      await prefs.setStringList('notifications', []);
      Navigator.of(context).pushReplacementNamed('/unlock');
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(_appIconAsset, width: 64, height: 64),
            const SizedBox(height: 16),
            Text(_appName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const Text('Set a 4-digit PIN for your account', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Enter new PIN',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _savePin(),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
} 