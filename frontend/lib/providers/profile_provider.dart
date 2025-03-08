import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'authProvider.dart';  // Import AuthProvider

class ProfileProvider extends ChangeNotifier {
  String? name;
  String? email;
  String? role;
  bool? isVerified;
  String? id;
  bool isLoading = false;
  String? errorMessage;
  final AuthProvider _authProvider = AuthProvider();

  // Static method to provide the provider
  static ChangeNotifierProvider<ProfileProvider> provider() {
    return ChangeNotifierProvider<ProfileProvider>(
      create: (_) => ProfileProvider(),
    );
  }

  // Provide a properly implemented userProfile getter
  Map<String, dynamic>? get userProfile {
    if (name == null && email == null && role == null) return null;

    return {
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'id': id,
    };
  }

  // Login User and Fetch Profile
  Future<void> loginUserAndFetchProfile(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Log in the user
      final loginResponse = await _authProvider.loginUser(email, password);

      if (loginResponse['status'] == 'success') {
        // Successfully logged in, now fetch the user's profile
        await fetchUserProfile(email);
      } else {
        errorMessage = loginResponse['message'] ?? 'Login failed';
      }
    } catch (error) {
      errorMessage = 'Login failed: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user profile data
  Future<void> fetchUserProfile(String userEmail) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    //final url = Uri.parse('http://192.168.0.101:3005/profile/getProfile/$userEmail'); // Adjust if needed
    final url = Uri.parse('http://10.0.2.2:3005/profile/getProfile/$userEmail');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        name = data['name'] ?? '';
        email = data['email'] ?? '';
        role = data['role'] ?? '';
        isVerified = data['isVerified'] ?? false;
        id = data['id'] ?? '';
      } else {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'Failed to fetch user profile';
      }
    } catch (error) {
      errorMessage = 'Failed to connect to server: ${error.toString()}';
      print('Connection error in profile: ${error.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Clear profile data on logout
  void clearProfile() {
    name = null;
    email = null;
    role = null;
    isVerified = null;
    id = null;
    notifyListeners();
  }
}