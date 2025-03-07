import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/Report/report_submission_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/task_model.dart';
import '../../providers/authProvider.dart';
import '../../models/taskAssignment_model.dart';
import '../../providers/taskAssignmentProvider.dart';
import '../../providers/user_provider.dart';

class AssignedTasksScreen extends ConsumerStatefulWidget {
  final String email; // Email of logged-in user

  const AssignedTasksScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<AssignedTasksScreen> createState() => _AssignedTasksScreenState();
}

class _AssignedTasksScreenState extends ConsumerState<AssignedTasksScreen> {
  final String baseUrl = 'http://localhost:3005';
  bool isLoading = true;
  List<Map<String, dynamic>> assignedTasks = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserTasks();
  }

  Future<void> fetchUserTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Use email directly from widget
      final email = widget.email;

      if (email.isEmpty) {
        setState(() {
          errorMessage = 'No email provided';
          isLoading = false;
        });
        return;
      }

      // Step 1: Get user ID from email
      final userResponse = await http.get(
        Uri.parse('$baseUrl/profile/email/$email'),
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to fetch user data: ${userResponse.body}');
      }

      final userData = json.decode(userResponse.body);
      final userId = userData['_id'];

      // Step 2: Get task assignments for this worker
      final assignmentsResponse = await http.get(
        Uri.parse('$baseUrl/taskAssignment/getAssignedTasks/$userId'),
      );

      if (assignmentsResponse.statusCode != 200) {
        throw Exception('Failed to fetch assignments: ${assignmentsResponse.body}');
      }

      final List<dynamic> assignments = json.decode(assignmentsResponse.body);

      // Step 3: Process the response
      List<Map<String, dynamic>> tasks = [];

      for (var assignment in assignments) {
        tasks.add({
          'task': Task.fromJson(assignment['taskDetails']),
          // Use taskDetails
          'assignment': TaskAssignment.fromJson(assignment),
          // Use assignment data
        });
      }

      setState(() {
        assignedTasks = tasks;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching assigned tasks: $error';
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  void navigateToSubmitScreen(Map<String, dynamic> taskData) {
    try {
      final task = taskData['task'] as Task;
      final assignment = taskData['assignment'] as TaskAssignment;

      final String taskId = task.id ?? '';
      final String workerId = assignment.workerId;

      print('Task ID: $taskId');
      print('Worker ID: $workerId');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReportSubmissionScreen(
            taskId: taskId,
            workerId: workerId,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assigned Tasks'),
            Text(
              'For: ${widget.email}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : assignedTasks.isEmpty
          ? const Center(child: Text('No assigned tasks available.'))
          : ListView.builder(
        itemCount: assignedTasks.length,
        itemBuilder: (context, index) {
          final taskData = assignedTasks[index]['task'] as Task;
          final assignmentData = assignedTasks[index]['assignment'] as TaskAssignment;

          // Filter out completed tasks
          if (assignmentData.status == 'completed') {
            return const SizedBox.shrink();
          }

          // Check if deadline has passed
          final now = DateTime.now();
          final isDeadlinePassed = taskData.deadline.isBefore(now);

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task details section (left side)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taskData.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          taskData.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Shop: ${taskData.shopName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Incentive: \$${taskData.incentive.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Deadline: ${taskData.deadline.toString().substring(0, 16)}',
                          style: TextStyle(
                            color: isDeadlinePassed ? Colors.red : Colors.black,
                            fontWeight: isDeadlinePassed ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${taskData.status}',
                          style: TextStyle(
                            color: taskData.status == 'pending' ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verification Code: ${assignmentData.verificationCode ?? "N/A"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Submit button section (right side)
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isDeadlinePassed || taskData.status != 'pending'
                              ? null
                              : () => navigateToSubmitScreen({
                            'task': taskData,
                            'assignment': assignmentData,
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUserTasks,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}