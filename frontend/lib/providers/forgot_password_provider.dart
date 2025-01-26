import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordProvider extends ChangeNotifier {
  bool _isOtpSent = false;
  bool _isOtpVerified = false;

  bool get isOtpSent => _isOtpSent;
  bool get isOtpVerified => _isOtpVerified;

  Future<void> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/auth/send-otp'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        _isOtpSent = true;
        notifyListeners();
      } else {
        throw jsonDecode(response.body)['message'];
      }
    } catch (error) {
      throw 'Failed to send OTP: $error';
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/auth/verify-otp'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        _isOtpVerified = true;
        notifyListeners();
      } else {
        throw jsonDecode(response.body)['message'];
      }
    } catch (error) {
      throw 'Failed to verify OTP: $error';
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/auth/reset-password'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['message'];
      }
    } catch (error) {
      throw 'Failed to reset password: $error';
    }
  }
}
