import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class RejectedTaskScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const RejectedTaskScreen({
    super.key,
    required this.userEmail,
  });

  @override
  ConsumerState<RejectedTaskScreen> createState() => _RejectedTaskScreenState();
}

class _RejectedTaskScreenState extends ConsumerState<RejectedTaskScreen> {
  List<Task> rejectedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRejectedTasks();
  }

  Future<void> fetchRejectedTasks() async {
    try {
      final taskNotifier = ref.read(taskProvider.notifier);
      await taskNotifier.getRejectedTasks(widget.userEmail); // Fetch rejected tasks
      setState(() {
        rejectedTasks = ref.read(taskProvider); // Update the list of rejected tasks
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch rejected tasks: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Tasks'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rejectedTasks.isEmpty
          ? const Center(child: Text('No rejected tasks found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rejectedTasks.length,
        itemBuilder: (context, index) {
          final task = rejectedTasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${task.shopName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}