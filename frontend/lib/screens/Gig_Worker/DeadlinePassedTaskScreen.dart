import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class DeadlinePassedTasksScreen extends ConsumerWidget {
  const DeadlinePassedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    // Filter tasks where the deadline has passed and the task is not done
    final deadlinePassedTasks = tasks.where((task) {
      final now = DateTime.now();
      return task.status != 'done' && task.deadline.isBefore(now);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadline Passed Tasks'),
      ),
      body: deadlinePassedTasks.isEmpty
          ? const Center(
        child: Text('No tasks with passed deadlines available.'),
      )
          : ListView.builder(
        itemCount: deadlinePassedTasks.length,
        itemBuilder: (context, index) {
          final task = deadlinePassedTasks[index];
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