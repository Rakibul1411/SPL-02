import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';

class AssignTasksScreen extends ConsumerWidget {
  final String userEmail;

  const AssignTasksScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Tasks'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: const Icon(Icons.assignment, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}