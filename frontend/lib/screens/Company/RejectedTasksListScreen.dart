import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class RejectedTasksListScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const RejectedTasksListScreen({super.key, required this.userEmail});

  @override
  _RejectedTasksListScreenState createState() => _RejectedTasksListScreenState();
}

class _RejectedTasksListScreenState extends ConsumerState<RejectedTasksListScreen> {
  bool _isLoading = true;

  // Define a consistent color theme
  final Color _primaryColor = const Color(0xFF2563EB); // Blue 600
  final Color _secondaryColor = const Color(0xFF7C3AED); // Purple 600
  final Color _accentColor = const Color(0xFF14B8A6); // Teal 500
  final Color _bgColor = const Color(0xFFF9FAFB); // Gray 50
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF1F2937); // Gray 800
  final Color _subtextColor = const Color(0xFF6B7280); // Gray 500

  @override
  void initState() {
    super.initState();
    _loadRejectedTasks();
  }

  Future<void> _loadRejectedTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(taskProvider.notifier).fetchAcceptedOrRejectedTasksForCompany(widget.userEmail);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rejected tasks: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    // Filter only rejected tasks
    final rejectedTasks = tasks.where((task) => task.rejectedByWorkers.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Tasks'),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRejectedTasks,
          ),
        ],
      ),
      backgroundColor: _bgColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : rejectedTasks.isEmpty
          ? const Center(child: Text('No rejected tasks found'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rejectedTasks.length,
        itemBuilder: (context, index) {
          final task = rejectedTasks[index];
          return Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              subtitle: Text(
                'Shop: ${task.shopName} • Incentive: \$${task.incentive.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _subtextColor,
                ),
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
                      Text(
                        'Rejected By:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...task.rejectedByWorkers.map((worker) {
                        final selectedWorker = task.selectedWorkers.firstWhere(
                              (sw) => sw.workerId == worker.workerId,
                          orElse: () => SelectedWorker(workerId: '', email: '', distance: 0.0),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    worker.email,
                                    style: TextStyle(
                                      color: _textColor,
                                    ),
                                  ),
                                  Text(
                                    'Distance: ${selectedWorker.distance.toStringAsFixed(2)} km',
                                    style: TextStyle(
                                      color: _subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}