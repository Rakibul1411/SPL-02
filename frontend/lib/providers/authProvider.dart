import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider {
  final String baseUrl = 'http://10.0.2.2:3005'; // Replace with your backend URL
  //final String baseUrl = 'http://localhost:3005'; // Replace with your backend URL

  // Register User
  Future<Map<String, dynamic>> registerUser(
      String name, String email, String password, String role, double latitude, double longitude) async {
    final url = Uri.parse('$baseUrl/auth/registration/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.isEmpty ? 'dummy' : name,
          'email': email,
          'password': password.isEmpty ? 'dummy' : password,
          'role': role.isEmpty ? 'dummy' : role,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Registration failed');
      }
    } catch (error) {
      throw Exception('Failed to register user: $error');
    }
  }

  // Verify Registration OTP
  Future<Map<String, dynamic>> verifyRegistrationOTP(
      {required String email, required String otp}) async {
    final url = Uri.parse('$baseUrl/auth/verify-registration-otp/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Failed to verify registration OTP');
      }
    } catch (error) {
      throw Exception('Failed to verify registration OTP: $error');
    }
  }

  // Login User
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password.isEmpty ? 'dummy' : password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Login failed');
      }
    } catch (error) {
      throw Exception('Failed to login user: $error');
    }
  }

  // Verify Login OTP
  Future<Map<String, dynamic>> verifyLoginOTP(
      {required String email, required String otp}) async {
    final url = Uri.parse('$baseUrl/auth/verify-login-otp/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      // print('Verify Login OTP: ');
      // print(response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Failed to verify login OTP');
      }
    } catch (error) {
      throw Exception('Failed to verify login OTP: $error');
    }
  }

  Future<void> resendOTP(String email) async {
    final url = Uri.parse('$baseUrl/auth/resend-otp/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to resend OTP');
      }
    } catch (error) {
      throw Exception('Failed to resend OTP: $error');
    }
  }

  Future<void> logout() async {

  }

  final authProvider = Provider<AuthProvider>((ref) {
    return AuthProvider(); // Assuming AuthProvider is a class that handles authentication
  });

}