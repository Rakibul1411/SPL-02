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

  // Define a consistent color theme
  final Color _primaryColor = const Color(0xFF2563EB); // Blue 600
  final Color _secondaryColor = const Color(0xFF7C3AED); // Purple 600
  final Color _accentColor = const Color(0xFF14B8A6); // Teal 500
  final Color _bgColor = const Color(0xFFF9FAFB); // Gray 50
  final Color _cardColor = Colors.grey.shade200; // Grey task box
  final Color _textColor = const Color(0xFF1F2937); // Gray 800
  final Color _subtextColor = const Color(0xFF6B7280); // Gray 500

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
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAcceptedTasks,
          ),
        ],
      ),
      backgroundColor: _bgColor,
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
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: _cardColor, // Grey task box
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: const Icon(Icons.arrow_drop_down, color: Colors.black), // Toggle icon
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shop: ${task.shopName}',
                    style: TextStyle(
                      color: _subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Incentive: \$${task.incentive.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: _subtextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Deadline: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                        style: TextStyle(color: _subtextColor),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          color: _subtextColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Accepted Workers Section
                      Text(
                        'Accepted By:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...task.acceptedByWorkers.map((worker) {
                        final selectedWorker = task.selectedWorkers.firstWhere(
                              (sw) => sw.workerId == worker.workerId,
                          orElse: () => SelectedWorker(workerId: '', email: '', distance: 0.0),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      worker.email,
                                      style: TextStyle(
                                        color: _textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Text(
                                  'Distance: ${selectedWorker.distance.toStringAsFixed(6)} km',
                                  style: TextStyle(
                                    color: _subtextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _assignWorker(task.id!, worker.email),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 40), // Full-width button
                                ),
                                child: const Text(
                                  'Assign Worker',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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