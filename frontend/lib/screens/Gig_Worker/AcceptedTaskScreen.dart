import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class AcceptedTaskScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const AcceptedTaskScreen({
    super.key,
    required this.userEmail,
  });

  @override
  ConsumerState<AcceptedTaskScreen> createState() => _AcceptedTaskScreenState();
}

class _AcceptedTaskScreenState extends ConsumerState<AcceptedTaskScreen> {
  List<Task> acceptedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAcceptedTasks();
  }

  Future<void> fetchAcceptedTasks() async {
    try {
      final taskNotifier = ref.read(taskProvider.notifier);
      await taskNotifier.getAcceptedTask(widget.userEmail); // Fetch accepted tasks
      setState(() {
        acceptedTasks = ref.read(taskProvider); // Update the list of accepted tasks
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch accepted tasks: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Tasks'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : acceptedTasks.isEmpty
          ? const Center(child: Text('No accepted tasks found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acceptedTasks.length,
        itemBuilder: (context, index) {
          final task = acceptedTasks[index];
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