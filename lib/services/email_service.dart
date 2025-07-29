import 'package:resend/resend.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  // TODO: Replace with your actual Resend API key
  static final resend = Resend(apiKey: 're_MZjLpVhB_EnJJS6x9GjeQzBS1guchfgjq');

  static Future<void> sendWelcomeEmail(String to) async {
    try {
      await resend.sendEmail(
        from: 'onboarding@resend.dev',
        to: [to],
        subject: 'Welcome to NomzBank!',
        html: '''
          <h1>Welcome to NomzBank!</h1>
          <p>We are excited to have you on board.</p>
          <p>You can now enjoy seamless banking services with us.</p>
          <p>If you have any questions, feel free to contact our support team.</p>
          <br>
          <p>Best regards,</p>
          <p>The NomzBank Team</p>
        '''
      );
      print('Welcome email sent successfully to $to');
    } catch (e) {
      print('Error sending welcome email: $e');
      // Handle the error accordingly, maybe log it or show a message to the user.
    }
  }

  static Future<void> sendVerificationCode(String email) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:4000/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send verification code');
    }
  }
} 