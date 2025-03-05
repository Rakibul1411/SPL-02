import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'authProvider.dart';

class ProfileProvider extends StateNotifier<ProfileState> {
  final AuthProvider _authProvider;

  ProfileProvider(this._authProvider) : super(ProfileState());

  // Fetch user profile data
  Future<void> fetchUserProfile(String userEmail) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final url = Uri.parse('http://192.168.0.101:3005/profile/getProfile/$userEmail');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = state.copyWith(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          isVerified: data['isVerified'] ?? false,
          companyId: data['companyId'] ?? '',
          isLoading: false,
        );
      } else {
        final errorData = json.decode(response.body);
        state = state.copyWith(
          errorMessage: errorData['message'] ?? 'Failed to fetch user profile',
          isLoading: false,
        );
      }
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Failed to connect to server: ${error.toString()}',
        isLoading: false,
      );
      print('Connection error: ${error.toString()}');
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
}

// State class to hold profile data
class ProfileState {
  final String? name;
  final String? email;
  final String? role;
  final bool? isVerified;
  final String? companyId;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.name,
    this.email,
    this.role,
    this.isVerified,
    this.companyId,
    this.isLoading = false,
    this.errorMessage,
  });

  // Convenience method to create a copy with updated values
  ProfileState copyWith({
    String? name,
    String? email,
    String? role,
    bool? isVerified,
    String? companyId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      companyId: companyId ?? this.companyId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Getter for user profile
  Map<String, dynamic>? get userProfile {
    if (name == null && email == null && role == null) return null;

    return {
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'companyId': companyId,
    };
  }
}

// Riverpod Provider with dependency injection
final authProvider = Provider<AuthProvider>((ref) => AuthProvider());

final profileProvider = StateNotifierProvider<ProfileProvider, ProfileState>((ref) {
  final authProviderInstance = ref.read(authProvider);
  return ProfileProvider(authProviderInstance);
});