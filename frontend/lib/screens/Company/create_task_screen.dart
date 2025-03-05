import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart'; // Assuming you have a user provider
import 'task_list_screen.dart';
import '../Map/map_screen.dart'; // Import the map screen

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
  LatLng? _selectedLocation; // Store selected location

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
      _selectedLocation = LatLng(widget.task!.latitude, widget.task!.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.task == null ? 'Create Task' : 'Edit Task',
                    style: TextStyle(color: Colors.indigo.shade900),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
                backgroundColor: Colors.white,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
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
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        _buildInputCard(
                          child: InkWell(
                            onTap: () async {
                              final location = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapScreen(),
                                ),
                              );
                              if (location != null) {
                                setState(() {
                                  _selectedLocation = location;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      color: Colors.indigo.shade400),
                                  const SizedBox(width: 16),
                                  Text(
                                    _selectedLocation == null
                                        ? 'Select Location'
                                        : 'Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedLocation == null
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        _buildInputCard(
                          child: InkWell(
                            onTap: _selectDeadline,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.indigo.shade400),
                                  const SizedBox(width: 16),
                                  Text(
                                    _deadline == null
                                        ? 'Select Deadline'
                                        : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _deadline == null
                                          ? Colors.grey
                                          : Colors.black87,
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
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 16),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _deadline != null && _selectedLocation != null) {
      try {
        await ref.read(profileProvider.notifier).fetchUserProfile(widget.userEmail);

        // Fetch the profile state directly from the provider
        final profileState = ref.read(profileProvider);

        print('state: $profileState');

        // Retrieve the company ID from the profile state
        final companyId = profileState.id;

        print('id: $companyId');

        if (companyId == null || companyId.isEmpty) {
          // First, attempt to fetch the user profile
          await ref.read(profileProvider.notifier).fetchUserProfile(widget.userEmail);

          // Re-read the profile state after fetching
          final updatedProfileState = ref.read(profileProvider);
          print(updatedProfileState);
          final updatedCompanyId = updatedProfileState.id;

          print('companyId: $updatedCompanyId');

          if (updatedCompanyId == null || updatedCompanyId.isEmpty) {
            // Show an error dialog if no ID is found
            _showErrorDialog('Unable to retrieve your profile information. Please try again.');
            return;
          }
        }

        final newTask = Task(
          id: widget.task?.id,
          title: _titleController.text,
          description: _descriptionController.text,
          shopName: _shopNameController.text,
          incentive: double.parse(_incentiveController.text),
          deadline: _deadline!,
          status: widget.task?.status ?? 'pending',
          companyId: companyId!, // Use the retrieved company ID
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          selectedWorkers: [],
          acceptedByWorkers: [],
          rejectedByWorkers: [],
        );

        if (widget.task == null) {
          // Create a new task
          await ref.read(taskProvider.notifier).createTask(newTask);
        } else {
          // Update an existing task
          await ref.read(taskProvider.notifier).updateTask(newTask);
        }

        // Navigate to TaskListScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TaskListScreen(
                  userEmail: widget.userEmail)
          ),
        );

      } catch (error) {
        // Handle any errors during task creation
        _showErrorDialog('Failed to create/update task: $error');
      }
    } else {
      _showErrorDialog('Please fill in all required fields and select a location and deadline.');
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
          )
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