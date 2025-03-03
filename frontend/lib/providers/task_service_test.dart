import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model_test.dart';

class TaskService {
  static const String baseUrl = "http://localhost:5000/task_test";

  Future<List<Task>> fetchTasks(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/tasks/$userId"));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<void> verifyTask(String taskId, String verificationCode) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-task"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"taskId": taskId, "verificationCode": verificationCode}),
    );
    if (response.statusCode != 200) throw Exception("Verification failed");
  }
}
