import 'dart:convert';
import 'package:http/http.dart' as http;

enum TaskStatus { CREATED, ASSIGNED, IN_PROGRESS, COMPLETED, REJECTED }

enum NotificationType {
  TASK_CREATED,
  TASK_ASSIGNED,
  TASK_COMPLETED,
  PAYMENT_PROCESSED,
  SYSTEM_UPDATE
}

class Task {
  String id;
  String companyId;
  String title;
  String description;
  String location;
  double incentive;
  DateTime deadline;
  TaskStatus status;
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.location,
    required this.incentive,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      companyId: json['companyId'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      incentive: json['incentive'],
      deadline: DateTime.parse(json['deadline']),
      status: TaskStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'title': title,
      'description': description,
      'location': location,
      'incentive': incentive,
      'deadline': deadline.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TaskService {
  final String baseUrl = 'http://10.0.2.2:3000'; // Adjust for your server

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<void> assignTask(String taskId, String workerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/assign'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'taskId': taskId, 'workerId': workerId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign task');
    }
  }
}
