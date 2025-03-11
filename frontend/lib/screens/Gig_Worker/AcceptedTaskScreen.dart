import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import 'task_details_screen.dart'; // Import the TaskDetailsScreen

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
          duration: const Duration(seconds: 3),
        ),
      );
      print('Error details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accepted Tasks',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : acceptedTasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No accepted tasks found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acceptedTasks.length,
        itemBuilder: (context, index) {
          final task = acceptedTasks[index];
          return GestureDetector(
            onTap: () {
              // Navigate to TaskDetailsScreen when the task is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailsScreen(task: task),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
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
                        Expanded(
                          child: Text(
                            task.shopName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${task.incentive.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}