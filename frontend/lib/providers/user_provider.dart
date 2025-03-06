import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'authProvider.dart';

class ProfileProvider extends StateNotifier<ProfileState> {
  final AuthProvider _authProvider;

  // Add a method to get the current user ID
  String? get currentUserId => state.id;
  
  ProfileProvider(this._authProvider) : super(ProfileState());

  Future<void> fetchUserProfile(String userEmail) async {
    if (userEmail.isEmpty) {
      state = state.copyWith(
        errorMessage: 'User email is required',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final encodedEmail = Uri.encodeComponent(userEmail); // Encode the email
    final url = Uri.parse('http://localhost:3005/profile/getProfile/$encodedEmail');

    print('Fetching profile from URL: $url');

    try {
      final response = await http.get(url);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = state.copyWith(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          isVerified: data['isVerified'] ?? false,
          id: data['id'] ?? '',
          isLoading: false,
        );
        print('User Profile Fetched Successfully: ${state.id}');
      } else {
        // Log the response body for debugging
        print('Error response body: ${response.body}');

        // Handle non-JSON responses
        if (response.body.startsWith('<!DOCTYPE html>')) {
          state = state.copyWith(
            errorMessage: 'Server returned an HTML error page. Check the backend API.',
            isLoading: false,
          );
        } else {
          final errorData = json.decode(response.body);
          state = state.copyWith(
            errorMessage: errorData['message'] ?? 'Failed to fetch user profile',
            isLoading: false,
          );
        }
      }
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Failed to connect to server: ${error.toString()}',
        isLoading: false,
      );
      print('Connection error in user profile: ${error.toString()}');
    }
  }

  // Login User and Fetch Profile
  Future<void> loginUserAndFetchProfile(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loginResponse = await _authProvider.loginUser(email, password);

      if (loginResponse['status'] == 'success') {
        await fetchUserProfile(email);
      } else {
        state = state.copyWith(
          errorMessage: loginResponse['message'] ?? 'Login failed',
          isLoading: false,
        );
      }
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Login failed: $error',
        isLoading: false,
      );
    }
  }

  // Clear profile data on logout
  void clearProfile() {
    state = ProfileState();
  }

  // Add methods to update latitude and longitude
  void updateLatitude(double latitude) {
    state = state.copyWith(latitude: latitude);
  }

  void updateLongitude(double longitude) {
    state = state.copyWith(longitude: longitude);
  }

  // Add methods to update latitude and longitude
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  // Save profile changes
  Future<void> saveProfile(String userEmail) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final url = Uri.parse('http://localhost:3005/profile/updateProfile');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'name': state.name,
          'latitude': state.latitude,
          'longitude': state.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = state.copyWith(
          name: data['name'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          isLoading: false,
        );
      } else {
        final errorData = json.decode(response.body);
        state = state.copyWith(
          errorMessage: errorData['message'] ?? 'Failed to update profile',
          isLoading: false,
        );
      }
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Failed to connect to server: ${error.toString()}',
        isLoading: false,
      );
    }
  }
}

class ProfileState {
  final String? name;
  final String? email;
  final String? role;
  final bool? isVerified;
  final String? id;
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.name,
    this.email,
    this.role,
    this.isVerified,
    this.id,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? role,
    bool? isVerified,
    String? id,
    double? latitude,
    double? longitude,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic>? get userProfile {
    if (name == null && email == null && role == null) return null;

    return {
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// Riverpod Provider with dependency injection
final authProvider = Provider<AuthProvider>((ref) => AuthProvider());

final profileProvider = StateNotifierProvider<ProfileProvider, ProfileState>((ref) {
  final authProviderInstance = ref.read(authProvider);
  return ProfileProvider(authProviderInstance);
});