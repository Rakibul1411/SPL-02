import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import 'task_list_screen.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final Task? task; // Make the task parameter optional
  final String userEmail; // Add userEmail parameter

  const CreateTaskScreen({super.key, this.task, required this.userEmail});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _incentiveController = TextEditingController();
  DateTime? _deadline;

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
    if (widget.task != null) {
      // Pre-fill the form if editing an existing task
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _shopNameController.text = widget.task!.shopName;
      _incentiveController.text = widget.task!.incentive.toString();
      _deadline = widget.task!.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Create Task' : 'Edit Task',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputCard(
                child: TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    'Task Title',
                    Icons.assignment_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: _buildInputDecoration(
                    'Description',
                    Icons.description_outlined,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task description';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                child: TextFormField(
                  controller: _shopNameController,
                  decoration: _buildInputDecoration(
                    'Shop Name',
                    Icons.store,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a shop name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      child: TextFormField(
                        controller: _incentiveController,
                        decoration: _buildInputDecoration(
                          'Incentive',
                          Icons.attach_money,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                child: InkWell(
                  onTap: _selectDeadline,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: _primaryColor),
                        const SizedBox(width: 16),
                        Text(
                          _deadline == null
                              ? 'Select Deadline'
                              : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _deadline == null ? _subtextColor : _textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(
                      widget.task == null ? 'Create Task' : 'Update Task',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: _cardColor,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _deadline != null) {
      try {
        // Fetch the user profile to get company ID
        await ref.read(profileProvider.notifier).fetchUserProfile(widget.userEmail);
        final profileState = ref.read(profileProvider);
        final companyId = profileState.id;

        if (companyId == null || companyId.isEmpty) {
          _showErrorDialog('Unable to retrieve your company ID. Please try again.');
          return;
        }

        final newTask = Task(
          id: widget.task?.id,
          title: _titleController.text,
          description: _descriptionController.text,
          shopName: _shopNameController.text,
          incentive: double.parse(_incentiveController.text),
          deadline: _deadline!,
          status: widget.task?.status ?? 'pending',
          companyId: companyId, // Use the company ID from profile
          latitude: 0.0, // Will be updated by backend from shop manager data
          longitude: 0.0, // Will be updated by backend from shop manager data
          selectedWorkers: [],
          acceptedByWorkers: [],
          rejectedByWorkers: [],
        );

        if (widget.task == null) {
          await ref.read(taskProvider.notifier).createTask(newTask);
        } else {
          await ref.read(taskProvider.notifier).updateTask(newTask);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TaskListScreen(userEmail: widget.userEmail),
          ),
        );
      } catch (error) {
        _showErrorDialog('Failed to create/update task: $error');
      }
    } else {
      _showErrorDialog('Please fill in all required fields and select a deadline.');
    }
  }

  // New helper method to show error dialogs
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }
}