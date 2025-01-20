import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  // Fetch tasks from the backend
  Future<void> fetchTasks() async {
    try {
      print('Fetching tasks...');

      final response = await http.get(
        Uri.parse(
            'http://localhost:3003/task/taskList/'), // Replace with your backend URL
      );

      if (response.statusCode == 200) {
        final List<dynamic> taskList = json.decode(response.body);
        state = taskList.map((task) => Task.fromJson(task)).toList();
        print("hello");
      } else {
        throw Exception('Failed to fetch tasks: ${response.body}');
      }
    } catch (error) {
      print('Error fetching tasks: $error');
      rethrow;
    }
  }

  Future<void> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3003/task/taskCreate/'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode(task.toJson()), // Ensure Task model has a `toJson` method
      );

      if (response.statusCode == 201) {
        state = [...state, task];
      } else {
        throw Exception('Failed to create task: ${response.body}');
      }
    } catch (error) {
      print('Error creating task: $error');
      rethrow;
    }
  }
}
