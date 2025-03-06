import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  // Function to calculate remaining time
  String getRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) remaining';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) remaining';
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

  @override
  Widget build(BuildContext context) {
    final remainingTime = getRemainingTime(task.deadline);
    final taskStatus = getTaskStatus(task);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  task.shopName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Incentive: \$${task.incentive.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Deadline: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
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
                  style: TextStyle(
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: taskStatus == 'Done'
                    ? Colors.green.withOpacity(0.1)
                    : taskStatus == 'Deadline Over'
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                taskStatus,
                style: TextStyle(
                  color: taskStatus == 'Done'
                      ? Colors.green[700]
                      : taskStatus == 'Deadline Over'
                      ? Colors.red[700]
                      : Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}