import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forgot_password_provider.dart'; // Import the ForgotPasswordProvider
import 'otp_screen.dart'; // Import OTP screen for password reset flow

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: GoogleFonts.montserrat(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Text(
              'Enter your email to receive a password reset link.',
              style: GoogleFonts.openSans(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);

                // Call sendOtp for password reset
                try {
                  await forgotPasswordNotifier.sendPasswordResetOTP(email);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP has been sent to your email')),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OTPScreen(
                        email: email,
                        isRegistration: false,  // For forgot password, isRegistration is false
                        isForgotPassword: true,  // Pass true for forgot password flow
                      ),
                    ),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: Text(
                'Send Password Reset OTP',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
