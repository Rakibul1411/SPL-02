import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ForgotPasswordState to manage the forgot password OTP flow state
class ForgotPasswordState {
  final bool isOtpSent;
  final bool isOtpVerified;
  final String? errorMessage;

  ForgotPasswordState({
    required this.isOtpSent,
    required this.isOtpVerified,
    this.errorMessage,
  });

  ForgotPasswordState copyWith({
    bool? isOtpSent,
    bool? isOtpVerified,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ForgotPasswordProvider class to handle forgot password logic
class ForgotPasswordProvider extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordProvider() : super(ForgotPasswordState(isOtpSent: false, isOtpVerified: false));

  final String baseUrl = 'http://localhost:3005'; // Replace with your backend URL

  // Method to send OTP for password reset
  Future<void> sendPasswordResetOTP(String email) async {
    final url = Uri.parse('$baseUrl/auth/send-password-reset-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isOtpSent: true, errorMessage: null);
      } else {
        final responseBody = jsonDecode(response.body);
        state = state.copyWith(errorMessage: responseBody['message'] ?? 'Failed to send OTP');
      }
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to send password reset OTP: $error');
    }
  }

  // Method to verify OTP for password reset
  Future<void> verifyPasswordResetOTP({required String email, required String otp}) async {
    final url = Uri.parse('$baseUrl/auth/verify-password-reset-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isOtpVerified: true, errorMessage: null);
      } else {
        final responseBody = jsonDecode(response.body);
        state = state.copyWith(errorMessage: responseBody['message'] ?? 'Failed to verify OTP');
      }
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to verify password reset OTP: $error');
    }
  }

  // Method to reset the password
  Future<void> resetPassword(String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(errorMessage: null);
      } else {
        final responseBody = jsonDecode(response.body);
        state = state.copyWith(errorMessage: responseBody['message'] ?? 'Failed to reset password');
      }
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to reset password: $error');
    }
  }

  Future<http.Response> updatePassword(String email, String currentPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/update-password');
    try {
      print("Email received in updatePassword: $email");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(errorMessage: null);
      } else {
        final responseBody = jsonDecode(response.body);
        state = state.copyWith(errorMessage: responseBody['message'] ?? 'Failed to update password');
      }

      // Return the response
      return response;
    } catch (error) {
      // Handle the error and return a custom response
      state = state.copyWith(errorMessage: 'Failed to update password: $error');
      return http.Response(
        jsonEncode({'message': 'Failed to update password: $error'}),
        500, // Internal Server Error status code
      );
    }
  }

}

// Create the StateNotifierProvider for the ForgotPasswordProvider
final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordProvider, ForgotPasswordState>((ref) {
  return ForgotPasswordProvider();
});
