// lib/providers/incentive_and_rating_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/incentive_and_rating_table.dart';

final incentiveProvider = StateNotifierProvider<IncentiveNotifier, List<Incentive>>((ref) {
  return IncentiveNotifier();
});

final ratingProvider = StateNotifierProvider<RatingNotifier, List<Rating>>((ref) {
  return RatingNotifier();
});

class IncentiveNotifier extends StateNotifier<List<Incentive>> {
  final String baseUrl = 'http://10.0.2.2:3005'; // Backend URL

  IncentiveNotifier() : super([]);

  // Fetch all incentives for a worker
  Future<void> fetchIncentives(String workerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/incentive/worker/$workerId'));

      if (response.statusCode == 200) {
        final List<dynamic> incentiveList = json.decode(response.body);
        state = incentiveList.map((json) => Incentive.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch incentives');
      }
    } catch (error) {
      print('Error fetching incentives: $error');
      rethrow;
    }
  }
}

class RatingNotifier extends StateNotifier<List<Rating>> {
  final String baseUrl = 'http://10.0.2.2:3005';

  RatingNotifier() : super([]);

  // Fetch all ratings for a worker
  Future<void> fetchRatings(String workerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/incentive/worker/$workerId'));

      if (response.statusCode == 200) {
        final List<dynamic> ratingList = json.decode(response.body);
        state = ratingList.map((json) => Rating.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch ratings');
      }
    } catch (error) {
      print('Error fetching ratings: $error');
      rethrow;
    }
  }

  // Submit a rating
  Future<void> submitRating(Rating rating) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incentive/rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'workerId': rating.workerId,
          'taskId': rating.taskId,
          'rating': rating.rating,
          'feedback': rating.feedback,
          'ratedBy': rating.ratedBy,
        }),
      );

      if (response.statusCode == 201) {
        state = [...state, rating];
      } else {
        throw Exception('Failed to submit rating');
      }
    } catch (error) {
      print('Error submitting rating: $error');
      rethrow;
    }
  }
}
