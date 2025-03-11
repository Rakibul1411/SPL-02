import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/authProvider.dart';
import '../../providers/forgot_password_provider.dart';
import '../ResetAndUpdatePassword/ResetPasswordScreen.dart';
import '../OtherScreens/after_registration_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String email;
  final bool isRegistration;
  final bool isForgotPassword;
  final String? role;

  const OTPScreen({
    super.key,
    required this.email,
    required this.isRegistration,
    this.isForgotPassword = false,
    this.role,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final AuthProvider _authProvider = AuthProvider();
  bool _isVerifyingOTP = false;
  bool _isHoveringVerify = false;
  bool _isHoveringResend = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.fastOutSlowIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _otpController.dispose();
    super.dispose();
  }

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
        const SnackBar(
          content: Text('A new OTP has been sent to your email'),
          backgroundColor: Color(0xFF3270FF),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP: $error'),
          backgroundColor: Colors.red,
        ),
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
              const SnackBar(
                content: Text('OTP Verified. You can now reset your password.'),
                backgroundColor: Color(0xFF3270FF),
              ),
            );

            // Proceed to reset password
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: widget.email)),
            );
          } else {
            // OTP verification failed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP verification failed: ${forgotPasswordState.errorMessage}'),
                backgroundColor: Colors.red,
              ),
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
          SnackBar(
            content: Text('OTP verification failed: $error'),
            backgroundColor: Colors.red,
          ),
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
      body: Stack(
        children: [
          // Background Color
          Container(
            color: Color(0xFF4272FF), // Apply the #4272FF color (blue)
          ),

          // Decorative Elements
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Icon Section
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Hero(
                                  tag: 'otp-icon',
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline,
                                      size: 50,
                                      color: Color(0xFF4272FF),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Title and Description
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    widget.isForgotPassword ? 'Password Reset OTP' : 'Verification Code',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.isForgotPassword
                                        ? 'We sent a password reset OTP to'
                                        : 'We sent a verification code to',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.0,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // OTP Input Field
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _otpController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter 6-digit code',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.security,
                                        color: Color(0xFF4272FF).withOpacity(0.7),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(color: Colors.red, width: 1),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 20,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      letterSpacing: 8,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4272FF),
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
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Resend OTP Section
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive the code? ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.0,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  MouseRegion(
                                    onEnter: (_) => setState(() => _isHoveringResend = true),
                                    onExit: (_) => setState(() => _isHoveringResend = false),
                                    child: GestureDetector(
                                      onTap: _resendOTP,
                                      child: Text(
                                        'Resend',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          decoration: _isHoveringResend
                                              ? TextDecoration.underline
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 48),

                            // Verify Button
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _isHoveringVerify = true),
                                  onExit: (_) => setState(() => _isHoveringVerify = false),
                                  cursor: SystemMouseCursors.click,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: _isHoveringVerify ? Colors.white.withOpacity(0.9) : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: _isHoveringVerify ? 15 : 10,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: _isVerifyingOTP ? null : _verifyOTP,
                                        splashColor: Color(0xFF4272FF).withOpacity(0.1),
                                        highlightColor: Colors.transparent,
                                        child: Center(
                                          child: _isVerifyingOTP
                                              ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF4272FF),
                                              strokeWidth: 3,
                                            ),
                                          )
                                              : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Verify',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF4272FF),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.check_circle_outline,
                                                color: Color(0xFF4272FF),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}