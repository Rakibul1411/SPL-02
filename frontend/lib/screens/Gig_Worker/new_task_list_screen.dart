import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import 'task_details_screen.dart';
import 'AcceptedTaskScreen.dart'; // Import the Accepted Task Screen
import 'RejectedTaskScreen.dart'; // Import the Rejected Task Screen

class NewTaskListScreen extends ConsumerStatefulWidget {
  const NewTaskListScreen({super.key});

  @override
  ConsumerState<NewTaskListScreen> createState() => _GigWorkerTaskListScreenState();
}

class _GigWorkerTaskListScreenState extends ConsumerState<NewTaskListScreen> {
  Timer? _timer; // Timer for live countdown

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).fetchTasks();
    });
    // Start the timer to update the UI every second
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Start a timer to update the UI every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Rebuild the UI every second
      }
    });
  }

  // Function to calculate remaining time
  String getRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) remaining';
    } else if (difference.inHours > 0) {
      // When less than 24 hours remain, show hours, minutes, and seconds
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);
      return '$hours hour(s), $minutes minute(s), $seconds second(s) remaining';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      final seconds = difference.inSeconds.remainder(60);
      return '$minutes minute(s), $seconds second(s) remaining';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds} second(s) remaining';
    } else {
      return 'Deadline Over';
    }
  }

  // Function to determine task status
  String getTaskStatus(Task task) {
    final now = DateTime.now();
    if (task.status == 'done') {
      return 'Done';
    } else if (task.deadline.isBefore(now)) {
      return 'Deadline Over';
    } else {
      return 'Pending';
    }
  }

  // Color based on task status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green;
      case 'Deadline Over':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Tasks',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey[800]),
            onPressed: () {
              // Future: Add task filtering functionality
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/no_tasks.png', // Add a relevant illustration
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks available',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final remainingTime = getRemainingTime(task.deadline);
          final taskStatus = getTaskStatus(task);
          final statusColor = _getStatusColor(taskStatus);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailsScreen(task: task),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            taskStatus,
                            style: GoogleFonts.poppins(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: GoogleFonts.inter(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.shopName,
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: taskStatus == 'Deadline Over'
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          remainingTime,
                          style: GoogleFonts.inter(
                            color: taskStatus == 'Deadline Over'
                                ? Colors.red
                                : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: taskStatus == 'Deadline Over'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Accept and Reject Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Redirect to Accepted Task Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AcceptedTaskScreen(task: task),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Accept',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Redirect to Rejected Task Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RejectedTaskScreen(task: task),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Reject',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}