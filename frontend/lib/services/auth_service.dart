import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  static Future<http.Response> register(User user) async {
    return await http.post(
      Uri.parse('http://localhost:3005/auth/registration/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': user.email,
        'password': user.password,
      }),
    );
  }

  static Future<http.Response> verifyOTP(String email, String otp) async {
    return await http.post(
      Uri.parse('http://localhost:3005/auth/verify-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );
  }
}