import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/taskAssignmentProvider.dart';
import '../../providers/task_provider.dart';

class AcceptedTasksListScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const AcceptedTasksListScreen({super.key, required this.userEmail});

  @override
  _AcceptedTasksListScreenState createState() => _AcceptedTasksListScreenState();
}

class _AcceptedTasksListScreenState extends ConsumerState<AcceptedTasksListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcceptedTasks();
  }

  Future<void> _loadAcceptedTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(taskProvider.notifier).fetchAcceptedOrRejectedTasksForCompany(widget.userEmail);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading accepted tasks: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _assignWorker(String taskId, String email) async {
    try {
      // Call the API to assign the worker to the task
      await ref.read(taskAssignmentProvider.notifier).assignWorker(taskId, email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worker assigned successfully')),
      );
      await _loadAcceptedTasks(); // Refresh the task list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign worker: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    // Filter only accepted tasks
    final acceptedTasks = tasks.where((task) => task.acceptedByWorkers.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAcceptedTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : acceptedTasks.isEmpty
          ? const Center(child: Text('No accepted tasks found'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acceptedTasks.length,
        itemBuilder: (context, index) {
          final task = acceptedTasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Shop: ${task.shopName} • Incentive: \$${task.incentive.toStringAsFixed(2)}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(task.description),
                      const SizedBox(height: 16),
                      Text(
                        'Accepted By:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...task.acceptedByWorkers.map((worker) {
                        final selectedWorker = task.selectedWorkers.firstWhere(
                              (sw) => sw.workerId == worker.workerId,
                          orElse: () => SelectedWorker(workerId: '', email: '', distance: 0.0),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(worker.email),
                                  Text('Distance: ${selectedWorker.distance.toStringAsFixed(6)} km'),
                                ],
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => _assignWorker(task.id!, worker.email),
                                child: const Text('Assign Worker'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Deadline: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}