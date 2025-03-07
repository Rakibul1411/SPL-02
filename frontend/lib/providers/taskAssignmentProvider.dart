import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/taskAssignment_model.dart';

final taskAssignmentProvider = StateNotifierProvider<TaskAssignmentNotifier, List<TaskAssignment>>((ref) {
  return TaskAssignmentNotifier();
});

class TaskAssignmentNotifier extends StateNotifier<List<TaskAssignment>> {
  final String baseUrl = 'http://localhost:3005'; // Replace with your backend URL

  TaskAssignmentNotifier() : super([]);

  // Fetch assigned tasks for a worker
  Future<void> fetchAssignedTasks(String workerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/taskAssignment/getAssignedTasks/$workerId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> taskAssignments = json.decode(response.body);
        state = taskAssignments.map((assignment) => TaskAssignment.fromJson(assignment)).toList();
      } else {
        throw Exception('Failed to fetch assigned tasks: ${response.body}');
      }
    } catch (error) {
      print('Error fetching assigned tasks: $error');
      rethrow;
    }
  }

  // Add this method to your TaskNotifier class in task_provider.dart
  Future<void> assignWorker(String taskId, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/taskAssignment/assignWorker/$taskId/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      print(response.statusCode);

      if (response.statusCode != 200) {
        throw Exception('Failed to assign worker: ${response.body}');
      }
    } catch (error) {
      print('Error assigning worker: $error');
      rethrow;
    }
  }

}