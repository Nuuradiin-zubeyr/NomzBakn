import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/email_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EmailVerificationScreen({super.key, required this.userData});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredCode = _codeController.text.trim();
    final correctCode = widget.userData['code'] as String;

    if (enteredCode != correctCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid verification code. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // If code is correct, finalize registration
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.login(
      widget.userData['email'] as String,
      widget.userData['password'] as String,
      widget.userData['name'] as String,
      phone: widget.userData['phone'] as String,
      profileImage: widget.userData['profileImage'] as File?,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/set-pin');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign up successful! Welcome to NomzBank.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    // You can add a cooldown timer here to prevent spamming
    await EmailService.sendVerificationCode(widget.userData['email'] as String);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new verification code has been sent to your email.'),
        backgroundColor: Colors.blue,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.mark_email_read_outlined, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Enter Verification Code',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'A 4-digit code has been sent to\n${widget.userData['email']}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.length != 4) {
                    return 'Please enter the 4-digit code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify Account'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code?"),
                  TextButton(
                    onPressed: _resendCode,
                    child: const Text('Resend Code'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
