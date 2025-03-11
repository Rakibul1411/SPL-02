import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/forgot_password_provider.dart';
import '../OTP/otp_screen.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();

    // Define colors to match CompanyScreen
    final Color _primaryColor = const Color(0xFF2563EB); // Blue 600
    final Color _secondaryColor = const Color(0xFF7C3AED); // Purple 600
    final Color _accentColor = const Color(0xFF14B8A6); // Teal 500
    final Color _bgColor = const Color(0xFFF9FAFB); // Gray 50
    final Color _cardColor = Colors.white;
    final Color _textColor = const Color(0xFF1F2937); // Gray 800
    final Color _subtextColor = const Color(0xFF6B7280); // Gray 500

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Text(
              'Forgot your password?',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Enter your email to receive a password reset OTP.',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: _subtextColor,
              ),
            ),

            const SizedBox(height: 32),

            // Email field
            Text(
              'Email',
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: _subtextColor),
                prefixIcon: Icon(Icons.email, color: _primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _subtextColor.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _subtextColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
                fillColor: _cardColor,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              style: GoogleFonts.openSans(
                fontSize: 15,
                color: _textColor,
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 40),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();

                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please enter your email'),
                        backgroundColor: _secondaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    return;
                  }

                  final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(color: _primaryColor),
                          const SizedBox(width: 16),
                          Text(
                            'Sending OTP...',
                            style: GoogleFonts.openSans(),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );

                  // Call sendOtp for password reset
                  try {
                    await forgotPasswordNotifier.sendPasswordResetOTP(email);

                    // Dismiss loading dialog
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('OTP has been sent to your email'),
                        backgroundColor: _accentColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
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
                    // Dismiss loading dialog
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                        backgroundColor: _secondaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: Text(
                  'Send Password Reset OTP',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Back to login link
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.openSans(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}