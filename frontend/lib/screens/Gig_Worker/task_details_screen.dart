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
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              text: task.shopName,
              color: Colors.grey[600]!,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.map_outlined,
              text: 'Lat: ${task.latitude.toStringAsFixed(6)}, Long: ${task.longitude.toStringAsFixed(6)}',
              color: Colors.grey[600]!,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.attach_money,
              text: 'Incentive: \$${task.incentive.toStringAsFixed(2)}',
              color: Colors.green[700]!,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.calendar_today,
              text:
              'Deadline: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
              color: Colors.grey[600]!,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.access_time,
              text: remainingTime,
              color: taskStatus == 'Deadline Over' ? Colors.red : Colors.grey[600]!,
              isUrgent: taskStatus == 'Deadline Over',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
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
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required Color color,
    bool isUrgent = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}