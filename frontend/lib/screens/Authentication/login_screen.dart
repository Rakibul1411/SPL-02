import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/authProvider.dart';
import '../Gig_Worker/gig_worker_screen.dart';
import '../Company/company_screen.dart';
import '../OtherScreens/user_selection_screen.dart';
import '../Shop Manager/shop_manager_screen.dart';
import '../ResetAndUpdatePassword/ForgotPasswordScreen.dart';
import '../OTP/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  final AuthProvider _authProvider = AuthProvider();

  // App theme colors
  final Color primaryColor = const Color(0xFF3E64FF);
  final Color secondaryColor = const Color(0xFFF5F7FF);
  final Color accentColor = const Color(0xFF5D7CE4);
  final Color textDarkColor = const Color(0xFF2C3E50);
  final Color textLightColor = const Color(0xFF7F8C8D);
  final Color successColor = const Color(0xFF2ECC71);
  final Color errorColor = const Color(0xFFE74C3C);

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _authProvider.loginUser(
          _emailController.text,
          _passwordController.text,
        );

        if (response['requiresOTP'] == true) {
          final role = response['role'];
          final verifiedRole = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                email: _emailController.text,
                isRegistration: false,
                role: role,
              ),
            ),
          );

          if (verifiedRole != null) {
            _handleUserRole(verifiedRole, _emailController.text);
          }
        } else {
          _handleUserRole(response['user']['role'], _emailController.text);
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $error'),
              backgroundColor: errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ));
            } finally {
            setState(() => _isLoading = false);
            }
        }
        }

  void _handleUserRole(String role, String email) {
    switch (role) {
      case 'Gig Worker':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GigWorkerScreen(userEmail: email)),
        );
        break;
      case 'Company':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CompanyScreen(userEmail: email)),
        );
        break;
      case 'Shop Manager':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShopManagerScreen(userEmail: email)),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown user role!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Login',
          style: GoogleFonts.poppins(
            color: textDarkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: textLightColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, secondaryColor],
            stops: const [0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Login header
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.login_rounded,
                          size: 48,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textLightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  _buildEmailField(),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildPasswordField(),
                  const SizedBox(height: 8),

                  // Forgot Password Prompt
                  _buildForgotPasswordPrompt(),
                  const SizedBox(height: 24),

                  // Login Button
                  _buildLoginButton(),
                  const SizedBox(height: 20),

                  // Registration Prompt
                  _buildRegistrationPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle: GoogleFonts.poppins(color: textLightColor),
          hintText: 'example@email.com',
          hintStyle: GoogleFonts.poppins(color: textLightColor.withOpacity(0.5)),
          prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(color: textDarkColor),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email address';
          }
          if (!EmailValidator.validate(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: GoogleFonts.poppins(color: textLightColor),
          hintText: 'Enter your password',
          hintStyle: GoogleFonts.poppins(color: textLightColor.withOpacity(0.5)),
          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(color: textDarkColor),
        obscureText: !_passwordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          'Login',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(color: textLightColor, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
            );
          },
          child: Text(
            'Register',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordPrompt() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
          );
        },
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}