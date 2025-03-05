import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/incentive_and_rating_table.dart';

// Provider for IncentiveAndRatingNotifier
final incentiveAndRatingProvider =
StateNotifierProvider<IncentiveAndRatingNotifier, List<IncentiveAndRating>>((ref) {
  return IncentiveAndRatingNotifier();
});

class IncentiveAndRatingNotifier extends StateNotifier<List<IncentiveAndRating>> {
  final String baseUrl = 'http://10.0.2.2:3005'; // Backend URL

  IncentiveAndRatingNotifier() : super([]);

  // ✅ Fetch ALL Incentives & Ratings from database
  Future<void> fetchAllData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incentive/all'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        // Log the first item to help with debugging
        if (dataList.isNotEmpty) {
          print('Sample data item: ${dataList[0]}');
        }

        // Process each item with error handling
        final processedItems = <IncentiveAndRating>[];

        for (var item in dataList) {
          try {
            processedItems.add(IncentiveAndRating.fromJson(item));
          } catch (e) {
            print('Error processing item: $e');
            print('Problem item: $item');
          }
        }

        state = processedItems;
      } else {
        print('Backend error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch incentives & ratings: ${response.statusCode}');
      }
    } catch (error) {
      print('⚠️ Error fetching incentives & ratings: $error');
      throw Exception('Failed to load data: $error');
    }
  }

  // Add incentive
  Future<void> addIncentive(String workerId, String taskId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incentive/issue'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'workerId': workerId,
          'taskId': taskId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 201) {
        await fetchAllData(); // Refresh the data
      } else {
        throw Exception('Failed to add incentive: ${response.body}');
      }
    } catch (error) {
      print('Error adding incentive: $error');
      throw Exception('Failed to add incentive: $error');
    }
  }

  // Add rating
  Future<void> addRating(String workerId, String taskId, int rating, String feedback, String ratedBy) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incentive/rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'workerId': workerId,
          'taskId': taskId,
          'rating': rating,
          'feedback': feedback,
          'ratedBy': ratedBy,
        }),
      );

      if (response.statusCode == 201) {
        await fetchAllData(); // Refresh the data
      } else {
        throw Exception('Failed to add rating: ${response.body}');
      }
    } catch (error) {
      print('Error adding rating: $error');
      throw Exception('Failed to add rating: $error');
    }
  }
}