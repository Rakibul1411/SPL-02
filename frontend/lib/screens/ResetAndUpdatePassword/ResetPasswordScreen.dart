import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/forgot_password_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Define colors to match CompanyScreen
  final Color _primaryColor = const Color(0xFF2563EB); // Blue 600
  final Color _secondaryColor = const Color(0xFF7C3AED); // Purple 600
  final Color _accentColor = const Color(0xFF14B8A6); // Teal 500
  final Color _bgColor = const Color(0xFFF9FAFB); // Gray 50
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF1F2937); // Gray 800
  final Color _subtextColor = const Color(0xFF6B7280); // Gray 500

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _bgColor,
      // Removed the default AppBar and will create a custom one
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom back button
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // Navigate back to forgot password screen
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: _subtextColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: _primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Screen title
                Text(
                  'Reset Password',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Header text
                Text(
                  'Create a new password',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your new password must be different from previous passwords',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _subtextColor,
                  ),
                ),
                const SizedBox(height: 32),

                // New password field
                Text(
                  'New Password',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    hintStyle: TextStyle(color: _subtextColor),
                    prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
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
                  obscureText: !_isNewPasswordVisible,
                  style: textTheme.bodyMedium?.copyWith(color: _textColor),
                ),
                const SizedBox(height: 24),

                // Confirm password field
                Text(
                  'Confirm New Password',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: TextStyle(color: _subtextColor),
                    prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
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
                  obscureText: !_isConfirmPasswordVisible,
                  style: textTheme.bodyMedium?.copyWith(color: _textColor),
                ),
                const SizedBox(height: 40),

                // Reset button with gradient matching company theme
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Reset Password',
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
    );
  }

  Future<void> _resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validate passwords
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields');
      return;
    }

    if (newPassword.length < 8) {
      _showMessage('Password must be at least 8 characters long');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Call resetPassword to update the password in the database
      final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);
      await forgotPasswordNotifier.resetPassword(widget.email, newPassword);

      final forgotPasswordState = ref.read(forgotPasswordProvider);

      if (forgotPasswordState.errorMessage == null) {
        _showMessage('Password reset successful');
        // Navigate back to login screen
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        _showMessage(forgotPasswordState.errorMessage ?? 'Failed to reset password');
      }
    } catch (e) {
      _showMessage('An error occurred. Please try again later.');
    } finally {
      // Hide loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('successful') ? _accentColor : _secondaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}