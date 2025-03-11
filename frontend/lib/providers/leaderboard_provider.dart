import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/leaderboard_model.dart';

// Provider for fetching leaderboard data
final leaderboardProvider = FutureProvider.family<LeaderboardData, String>((ref, email) async {
  final leaderboardService = LeaderboardService();
  return leaderboardService.fetchLeaderboard(email);
});

// Service class to handle API calls for leaderboard
class LeaderboardService {
  final String baseUrl = 'http://10.0.2.2:3005'; // Android emulator localhost

  Future<LeaderboardData> fetchLeaderboard(String email) async {
    try {
      // For debugging
      print('Fetching leaderboard for email: $email');

      final response = await http.get(
        Uri.parse('$baseUrl/incentive/leaderboard/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Debug response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LeaderboardData.fromJson(data);
      } else {
        throw Exception('Failed to load leaderboard: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error fetching leaderboard: $error');
      throw Exception('Failed to fetch leaderboard: $error');
    }
  }
}