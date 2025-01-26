import 'package:flutter/material.dart';
import '../providers/authProvider.dart'; // Import AuthProvider
import 'after_registration_screen.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final bool isRegistration;
  final String? role;

  const OTPScreen({
    super.key,
    required this.email,
    required this.isRegistration,
    this.role,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final AuthProvider _authProvider = AuthProvider();
  bool _isVerifyingOTP = false;

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isVerifyingOTP = true;
      });

      try {
        final response = widget.isRegistration
            ? await _authProvider.verifyRegistrationOTP(
          email: widget.email,
          otp: _otpController.text,
        )
            : await _authProvider.verifyLoginOTP(
          email: widget.email,
          otp: _otpController.text,
        );

        print(response);

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(response['message'])),
        // );

        if (widget.isRegistration) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AfterRegistrationScreen()),
          );
        } else {
            // Return the role to LoginScreen
            Navigator.pop(context, widget.role);
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
      appBar: AppBar(
        title: const Text('OTP Verification'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the OTP sent to your email',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifyingOTP ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  child: _isVerifyingOTP
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
