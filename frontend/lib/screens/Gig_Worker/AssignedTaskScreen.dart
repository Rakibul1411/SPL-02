import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class PendingTasksScreen extends ConsumerWidget {
  const PendingTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    // Filter tasks that are pending
    final pendingTasks = tasks.where((task) {
      final now = DateTime.now();
      return task.status != 'done' && task.deadline.isAfter(now);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Tasks'),
      ),
      body: pendingTasks.isEmpty
          ? const Center(
        child: Text('No pending tasks available.'),
      )
          : ListView.builder(
        itemCount: pendingTasks.length,
        itemBuilder: (context, index) {
          final task = pendingTasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Text('Deadline: ${task.deadline.toString()}'),
          );
        },
      ),
    );
  }
}