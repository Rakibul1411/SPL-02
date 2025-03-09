import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';

class AssignTasksScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const AssignTasksScreen({super.key, required this.userEmail});

  @override
  _AssignTasksScreenState createState() => _AssignTasksScreenState();
}

class _AssignTasksScreenState extends ConsumerState<AssignTasksScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignableTasks();
  }

  Future<void> _loadAssignableTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(taskProvider.notifier).fetchAssignableTasks(widget.userEmail);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assignable tasks: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Tasks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text('No assignable tasks found'))
          : ListView.builder(
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