import 'package:frontend/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/authProvider.dart';
import './Gig_Worker/gig_worker_screen.dart';
import './Company/company_screen.dart';
import './Shop Manager/shop_manager_screen.dart';
import 'otp_screen.dart';

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

  Future<void> _login() async {
    // Original login logic remains unchanged
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _authProvider.loginUser(
          _emailController.text,
          _passwordController.text,
        );

        print(response['role']);

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
            _handleUserRole(verifiedRole);
          }
        } else {
          _handleUserRole(response['user']['role']);
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $error')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleUserRole(String role) {
    // Original role handling logic remains unchanged
    switch (role) {
      case 'Gig Worker':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GigWorkerScreen()),
        );
        break;
      case 'Company':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompanyScreen()),
        );
        break;
      case 'Shop Manager':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShopManagerScreen()),
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
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700]
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Login to continue',
                style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.grey[600]
                ),
              ),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildRegistrationPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.blue[50],
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!EmailValidator.validate(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue[700],
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.blue[50],
      ),
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
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
            'Login',
            style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600
            )
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
    style: GoogleFonts.openSans(color: Colors.grey)
    ),
    GestureDetector(
    onTap: () {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );
    },
    child: Text(
    'Register',
    style: GoogleFonts.montserrat(
    color: Colors.blue[700],
    fontWeight: FontWeight.bold
    ),
    ),
    ),
    ],
    );
    }
}