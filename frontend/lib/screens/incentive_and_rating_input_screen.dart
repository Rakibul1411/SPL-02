import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incentive_and_rating_provider.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/worker_model.dart';
import '../providers/task_provider.dart';
import '../providers/worker_provider.dart';
import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
// import '../providers/user_provider.dart';

class RatingIncentiveInputScreen extends ConsumerStatefulWidget {
  final String? workerId;
  final String? taskId;

  const RatingIncentiveInputScreen({
    Key? key,
    this.workerId,
    this.taskId
  }) : super(key: key);

  @override
  ConsumerState<RatingIncentiveInputScreen> createState() => _RatingIncentiveInputScreenState();
}

class _RatingIncentiveInputScreenState extends ConsumerState<RatingIncentiveInputScreen> {
  // Form state variables
  final _formKey = GlobalKey<FormState>();
  // Worker? _selectedWorker;
  // Task? _selectedTask;
  int _rating = 3;
  String _feedback = '';
  double _incentiveAmount = 0.0;
  bool _isSubmitting = false;
  bool _showRatingSection = true;
  bool _showIncentiveSection = true;
  String? _errorMessage;

  // Controllers
  final _feedbackController = TextEditingController();
  final _incentiveController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize with passed values if available
    if (widget.workerId != null || widget.taskId != null) {
      Future.microtask(() async {
        // Load workers and tasks before setting pre-selected values
        await ref.read(workerProvider.notifier).fetchWorkers();
        await ref.read(taskProvider.notifier).fetchTasks();

        if (mounted) {
          setState(() {
            // Find worker and task in the lists if IDs were provided
            // if (widget.workerId != null) {
            //   _selectedWorker = ref.read(workerProvider)
            //       .firstWhere((w) => w.id == widget.workerId,
            //       orElse: () => Worker(id: '', name: ''));
            // }

            // if (widget.taskId != null) {
            //   _selectedTask = ref.read(taskProvider)
            //       .firstWhere((t) => t.id == widget.taskId,
            //       orElse: () => Task(
            //         id: '',
            //         title: '',
            //         companyId: '',
            //         description: '',
            //         shopName: '',
            //         incentive: 0.0,
            //         deadline: DateTime.now(),
            //         status: 'pending',
            //         latitude: 0.0,
            //         longitude: 0.0,
            //         selectedWorkers: [],
            //         acceptedByWorkers: [],
            //         rejectedByWorkers: [],
            //       ));
            // }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _incentiveController.dispose();
    super.dispose();
  }

  // Handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // if (_selectedWorker == null || _selectedTask == null) {
      //   setState(() {
      //     _errorMessage = "Please select both a worker and a task";
      //   });
      //   return;
      // }

      if (!_showRatingSection && !_showIncentiveSection) {
        setState(() {
          _errorMessage = "Please enable at least rating or incentive section";
        });
        return;
      }

      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        final currentUserId = ref.read(profileProvider).id ?? 'unknown-user';

        // Ensure _selectedTask and _selectedWorker are not null before accessing their properties
        // final taskId = _selectedTask?.id ?? '';
        // final workerId = _selectedWorker?.id ?? '';

        // if (taskId.isEmpty || workerId.isEmpty) {
        //   setState(() {
        //     _errorMessage = "Invalid worker or task selection";
        //   });
        //   return;
        // }

        if (_showRatingSection && _rating > 0) {
          await ref.read(incentiveAndRatingProvider.notifier).addRating(
              '67c6c9d48c8bda58e1fa7ac7', '67c8ab5ff85a94a6eaf9caec', _rating, _feedback, "67c6d06e8c8bda58e1fa7acc");//workerid,taskid, companyid
        }

        if (_showIncentiveSection && _incentiveAmount > 0) {
          await ref.read(incentiveAndRatingProvider.notifier).addIncentive(
              '67c6c9d48c8bda58e1fa7ac7', '67c8ab5ff85a94a6eaf9caec', _incentiveAmount);//workerid,taskid
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Successfully submitted!"),
              backgroundColor: Colors.green,
            ),
          );

          _formKey.currentState!.reset();
          setState(() {
            _rating = 3;
            _feedback = '';
            _incentiveAmount = 0.0;
            _feedbackController.clear();
            _incentiveController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to submit: ${e.toString()}";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Watch providers for workers and tasks
    final workers = ref.watch(workerProvider);
    final tasks = ref.watch(taskProvider);
    final isLoading = ref.watch(workerProvider.notifier).isLoading ||
        ref.watch(taskProvider.notifier).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Rating & Incentive"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),


              // Toggle sections
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text("Include Rating"),
                      value: _showRatingSection,
                      onChanged: (bool? value) {
                        setState(() {
                          _showRatingSection = value ?? true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text("Include Incentive"),
                      value: _showIncentiveSection,
                      onChanged: (bool? value) {
                        setState(() {
                          _showIncentiveSection = value ?? true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rating section
              if (_showRatingSection) ...[
                const Text(
                  "Rating",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Feedback text field
                TextFormField(
                  controller: _feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback (Optional)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  onSaved: (value) {
                    _feedback = value ?? '';
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Incentive section
              if (_showIncentiveSection) ...[
                const Text(
                  "Incentive",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Incentive amount field
                TextFormField(
                  controller: _incentiveController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_showIncentiveSection &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter an amount';
                    }

                    if (value != null && value.isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Please enter a valid number';
                      }
                      if (amount < 0) {
                        return 'Amount cannot be negative';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _incentiveAmount = double.tryParse(value ?? '0') ?? 0.0;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  "SUBMIT",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}