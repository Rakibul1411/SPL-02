import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/task_model.dart';
import '../../models/taskAssignment_model.dart';
import 'VerifyWorkerScreen.dart';
import '../../models/user_model.dart';

class AssignSurveyListScreen extends ConsumerStatefulWidget {
  final String email; // Email of logged-in user

  const AssignSurveyListScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<AssignSurveyListScreen> createState() => _AssignedTasksScreenState();
}

class _AssignedTasksScreenState extends ConsumerState<AssignSurveyListScreen> {
  final String baseUrl = 'http://10.0.2.2:3005';
  bool isLoading = true;
  List<Map<String, dynamic>> assignedTasks = [];
  String? errorMessage;
  String userRole = '';
  String userId = '';
  List<dynamic> assignments = []; // Remove 'late' and initialize as empty list

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    try {
      final email = widget.email;

      if (email.isEmpty) {
        setState(() {
          errorMessage = 'No email provided';
          isLoading = false;
        });
        return;
      }

      // Get user details to determine role
      final userResponse = await http.get(
        Uri.parse('$baseUrl/profile/email/$email'),
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to fetch user data: ${userResponse.body}');
      }

      final userData = json.decode(userResponse.body);
      final role = userData['role'] ?? '';

      setState(() {
        userRole = role;
        userId = userData['_id'];
      });

      // Now fetch the tasks based on user role
      fetchTasks();
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching user details: $error';
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (userId.isEmpty) {
        throw Exception('User ID is not available');
      }

      List<Map<String, dynamic>> tasks = [];

      // For Shop Manager, fetch tasks assigned to their shop
      final assignmentsResponse = await http.get(
        Uri.parse('$baseUrl/taskAssignment/getShopTasks/$userId'),
      );

      if (assignmentsResponse.statusCode != 200) {
        throw Exception('Failed to fetch shop tasks: ${assignmentsResponse.body}');
      }

      // Check if the response is null or empty
      final responseBody = assignmentsResponse.body;
      if (responseBody == null || responseBody.isEmpty) {
        setState(() {
          errorMessage = 'No tasks available.';
          isLoading = false;
        });
        return;
      }

      // Safely parse the JSON
      final dynamic decodedResponse = json.decode(responseBody);
      if (decodedResponse == null) {
        setState(() {
          errorMessage = 'Invalid response format.';
          isLoading = false;
        });
        return;
      }

      // Handle both array and object responses
      final List<dynamic> assignments = decodedResponse is List
          ? decodedResponse
          : decodedResponse is Map ? [decodedResponse] : [];

      // Debug the raw API response
      print('Raw API response: $responseBody');

      // Debug the parsed data
      print('Parsed assignments data: $assignments');

      if (assignments.isEmpty) {
        setState(() {
          errorMessage = 'No tasks available.';
          isLoading = false;
        });
        return;
      }

      for (var assignment in assignments) {
        // Safely handle null or invalid taskDetails
        Map<String, dynamic>? taskDetailsMap;
        if (assignment['taskDetails'] is Map<String, dynamic>) {
          taskDetailsMap = assignment['taskDetails'] as Map<String, dynamic>;
        }

        // Debug the assignment data to check ID structure
        print('Assignment ID: ${assignment['assignmentId']}');
        print('Task Details: ${assignment['taskDetails']}');
        print('Worker Details: ${assignment['workerDetails']}');

        // Only add to tasks if we have valid task details
        if (taskDetailsMap != null) {
          tasks.add({
            'task': Task.fromJson(taskDetailsMap),
            'assignment': TaskAssignment.fromJson(assignment),
            'worker': assignment['workerDetails'] ?? {},
            // Store the raw assignmentId for verification
            'rawAssignmentId': assignment['assignmentId']
          });
        }
      }

      setState(() {
        assignedTasks = tasks;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching tasks: $error';
        isLoading = false;
      });
      print(errorMessage);
    }
  }


  void navigateToVerifyWorkerScreen(Map<String, dynamic> taskData) {
    try {
      final assignment = taskData['assignment'] as TaskAssignment;

      // Use the raw assignment ID from the response data
      // This addresses the potential mismatch between model property and API data
      final String assignmentId = taskData['rawAssignmentId'] ?? assignment.assignmentId;

      print('Navigating with assignment ID: $assignmentId');

      if (assignmentId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid task assignment ID')),
        );
        return;
      }

      // Navigate to the VerifyWorkerScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyWorkerScreen(
            assignmentId: assignmentId,
            onVerificationComplete: () {
              // Refresh the task list after verification
              fetchTasks();
            },
          ),
        ),
      );
    } catch (error) {
      print('Navigation error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation to verification screen failed: $error')),
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
            const Text('Shop Tasks'),
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
          ? const Center(child: Text('No tasks available.'))
          : ListView.builder(
        itemCount: assignedTasks.length,
        itemBuilder: (context, index) {
          final taskData = assignedTasks[index]['task'] as Task;
          final assignmentData = assignedTasks[index]['assignment'] as TaskAssignment;

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
                          'Status: ${assignmentData.status}',
                          style: TextStyle(
                            color: assignmentData.status == 'assigned' ? Colors.blue : Colors.green,
                          ),
                        ),
                        // Show worker info for Shop Manager
                        if (assignedTasks[index]['worker'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Assigned to: ${assignedTasks[index]['worker']['name'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Button section (right side)
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Verify Worker button for Shop Manager
                        ElevatedButton(
                          onPressed: assignmentData.verifiedAt != null || assignmentData.status == 'finished'
                              ? null // Disable the button if already verified or finished
                              : () {
                            navigateToVerifyWorkerScreen({
                              'task': taskData,
                              'assignment': assignmentData,
                              'rawAssignmentId': assignedTasks[index]['rawAssignmentId']
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text('Verify Worker'),
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
        onPressed: fetchTasks,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}