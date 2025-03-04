import 'package:flutter/material.dart';

class GigWorkerTaskListScreen extends StatelessWidget {
  const GigWorkerTaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy task list
    final tasks = List.generate(10, (index) => 'Task #${index + 1}');

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 8, // Increase shadow elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon for the task
                Icon(
                  Icons.task_alt,
                  color: Colors.blue,
                  size: 40,
                ),
                const SizedBox(width: 16),
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tasks[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assigned to: Worker #$index',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due Date: 2025-03-10',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Task status icon (checkmark for completed tasks)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 30,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
