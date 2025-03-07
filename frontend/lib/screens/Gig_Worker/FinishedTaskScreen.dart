import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class FinishedTasksScreen extends ConsumerWidget {
  const FinishedTasksScreen({super.key, required String userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    // Filter tasks that are done
    final finishedTasks = tasks.where((task) => task.status == 'done').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finished Tasks'),
      ),
      body: finishedTasks.isEmpty
          ? const Center(
        child: Text('No finished tasks available.'),
      )
          : ListView.builder(
        itemCount: finishedTasks.length,
        itemBuilder: (context, index) {
          final task = finishedTasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Text('Completed on: ${task.deadline.toString()}'),
          );
        },
      ),
    );
  }
}