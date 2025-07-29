import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class UnlockScreen extends StatefulWidget {
  final VoidCallback? onUnlock;
  const UnlockScreen({super.key, this.onUnlock});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _pinController = TextEditingController();
  String? _userName;
  final String _appName = 'Nomzbank';
  final String _appIconAsset = 'assets/icons/wallet-solid.png';
  String? _error;
  String? _savedPin;
  bool _biometricAvailable = false;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkBiometric();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('profile_name') ?? 'User';
      _savedPin = prefs.getString('user_pin') ?? '1234';
    });
  }

  Future<void> _checkBiometric() async {
    final localAuth = LocalAuthentication();
    final available = await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();
    setState(() => _biometricAvailable = available);
  }

  Future<void> _tryBiometric() async {
    final localAuth = LocalAuthentication();
    try {
      final didAuth = await localAuth.authenticate(
        localizedReason: 'Authenticate to unlock',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (didAuth) {
        _unlock();
      } else {
        setState(() => _error = 'Biometric authentication failed');
      }
    } catch (e) {
      setState(() => _error = 'Biometric error: $e');
    }
  }

  void _unlock() {
    setState(() => _error = null);
    widget.onUnlock?.call();
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  void _tryPin() {
    if (_pinController.text == _savedPin) {
      _unlock();
    } else {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // App icon
                Image.asset(_appIconAsset, width: 64, height: 64),
                const SizedBox(height: 16),
                // App name
                Text(_appName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                // Welcome
                Text('Welcome, $_userName!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Please enter your PIN or use biometrics to unlock.'),
                const SizedBox(height: 32),
                // PIN input
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'PIN (default: 1234)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _tryPin(),
                ),
                const SizedBox(height: 12),
                // Biometric button
                if (_biometricAvailable)
                  ElevatedButton.icon(
                    onPressed: _tryBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Unlock with Biometrics'),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _tryPin,
                  child: const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 