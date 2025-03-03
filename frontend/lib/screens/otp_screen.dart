import 'package:flutter/material.dart';
import '../providers/authProvider.dart';
import '../providers/forgot_password_provider.dart'; // Import forgot password provider
import 'ResetPasswordScreen.dart';
import 'after_registration_screen.dart'; // Assuming you need to show a confirmation screen or redirect
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

class OTPScreen extends ConsumerStatefulWidget {
  final String email;
  final bool isRegistration;
  final bool isForgotPassword; // Flag to indicate Forgot Password flow
  final String? role;

  const OTPScreen({
    super.key,
    required this.email,
    required this.isRegistration,
    this.isForgotPassword = false, // Default value for non-forgot password flow
    this.role,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final AuthProvider _authProvider = AuthProvider();
  bool _isVerifyingOTP = false;

  // Method to resend OTP for forgot password flow
  Future<void> _resendOTP() async {
    try {
      if (widget.isForgotPassword) {
        // Resend OTP logic for forgot password flow
        await ref.read(forgotPasswordProvider.notifier).sendPasswordResetOTP(widget.email);
      } else {
        // Resend OTP logic for registration/login
        await _authProvider.resendOTP(widget.email);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new OTP has been sent to your email')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP: $error')),
      );
    }
  }

  // Method to verify OTP
  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isVerifyingOTP = true;
      });

      try {
        // Verify OTP for forgot password flow
        if (widget.isForgotPassword) {
          await ref.read(forgotPasswordProvider.notifier).verifyPasswordResetOTP(
            email: widget.email,
            otp: _otpController.text,
          );

          final forgotPasswordState = ref.read(forgotPasswordProvider);

          if (forgotPasswordState.isOtpVerified) {
            // OTP Verified successfully
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP Verified. You can now reset your password.')),
            );

            // Proceed to reset password
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: widget.email)), // Navigate to reset password screen
            );
          } else {
            // OTP verification failed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP verification failed: ${forgotPasswordState.errorMessage}')),
            );
          }
        } else {
          // OTP verification for registration/login
          final response = widget.isRegistration
              ? await _authProvider.verifyRegistrationOTP(
            email: widget.email,
            otp: _otpController.text,
          )
              : await _authProvider.verifyLoginOTP(
            email: widget.email,
            otp: _otpController.text,
          );

          if (response != null) {
            // Registration flow: navigate to AfterRegistrationScreen
            if (widget.isRegistration) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AfterRegistrationScreen()),
              );
            } else {
              // Login/forgot password: pop and return the role
              Navigator.pop(context, widget.role);
            }
          }
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP verification failed: $error')),
        );
      } finally {
        setState(() {
          _isVerifyingOTP = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.isForgotPassword ? 'Password Reset OTP' : 'Verification Code',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isForgotPassword
                        ? 'We sent a password reset OTP to'
                        : 'We sent a verification code to',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit code',
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: _resendOTP,
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifyingOTP ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: _isVerifyingOTP
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
