import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'AvailableShopScreen.dart';
import 'FinishedTasksScreen.dart';
import '../OtherScreens/launch_page_screen.dart';
import '../Profile/profile_details_screen.dart';
import 'AcceptedTasksListScreen.dart';
import 'AssignTasksScreen.dart';
import 'RejectedTasksListScreen.dart';
import 'create_task_screen.dart';
import 'task_list_screen.dart';
import '../../providers/profile_provider.dart';
import '../../providers/authProvider.dart';
import '../../providers/task_provider.dart'; // Import task provider
import '../Profile/UpdatePasswordScreen.dart';
import '../Profile/UpdateProfileScreen.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const CompanyScreen({super.key, required this.userEmail});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  int _selectedIndex = 5; // Dashboard screen
  String _companyName = "";
  bool _isLoading = true;

  // Add these variables to store task counts
  int _finishedTasksCount = 0;
  int _pendingTasksCount = 0;

  late final List<Widget> _screens;
  late final ProfileProvider _profileProvider;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Define a consistent color theme
  final Color _primaryColor = const Color(0xFF2563EB); // Blue 600
  final Color _secondaryColor = const Color(0xFF7C3AED); // Purple 600
  final Color _accentColor = const Color(0xFF14B8A6); // Teal 500
  final Color _bgColor = const Color(0xFFF9FAFB); // Gray 50
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF1F2937); // Gray 800
  final Color _subtextColor = const Color(0xFF6B7280); // Gray 500

  final List<String> _screenTitles = [
    'Create Task',
    'All Tasks',
    'Gig Worker Report',
    'Company Details',
    'Settings',
    'Dashboard',
  ];

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _screens = [
      CreateTaskScreen(userEmail: widget.userEmail),
      TaskListScreen(userEmail: widget.userEmail),
      const Center(child: Text('Gig Worker Report List')),
      provider.ChangeNotifierProvider.value(
        value: _profileProvider,
        child: ProfileDetailsScreen(userEmail: widget.userEmail),
      ),
      _buildSettingsScreen(),
      _buildDashboardScreen(),
    ];
    _fetchCompanyDetails();
    _fetchTaskCounts(); // Fetch task counts when the screen initializes
  }

  // Fetch task counts (finished and pending)
  Future<void> _fetchTaskCounts() async {
    try {
      // Fetch total finished tasks
      final finishedTasksCount = await ref.read(taskProvider.notifier).fetchTotalFinishedTasksByCompanyId(widget.userEmail);

      // Fetch total pending tasks
      final pendingTasksCount = await ref.read(taskProvider.notifier).fetchTotalPendingTasksByCompanyId(widget.userEmail);

      setState(() {
        _finishedTasksCount = finishedTasksCount;
        _pendingTasksCount = pendingTasksCount;
      });
    } catch (error) {
      print('Error fetching task counts: $error');
    }
  }

  Widget _buildDashboardScreen() {
    return Container(
      color: _bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: _primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.business,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _companyName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Task Analytics Section
            Text(
              'Task Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Task Analytics Cards
            Row(
              children: [
                // Finished Tasks Card
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Finished Tasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total: $_finishedTasksCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Pending Tasks Card
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Tasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total: $_pendingTasksCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Task Management Section
            Text(
              'Task Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Task Cards in a Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTaskCard(
                    'Create Task',
                    Icons.add_task,
                    _accentColor,
                        () {
                      setState(() {
                        _selectedIndex = 0; // Navigate to Create Task screen
                      });
                    },
                  ),
                  _buildTaskCard(
                    'All Tasks',
                    Icons.list_alt_outlined,
                    Colors.indigo,
                        () {
                      setState(() {
                        _selectedIndex = 1; // Navigate to All Tasks screen
                      });
                    },
                  ),
                  _buildTaskCard(
                    'Accepted',
                    Icons.check_circle_outline,
                    Colors.green,
                        () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AcceptedTasksListScreen(userEmail: widget.userEmail),
                          ),
                        ),
                  ),
                  _buildTaskCard(
                    'Rejected',
                    Icons.cancel_outlined,
                    Colors.red,
                        () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RejectedTasksListScreen(userEmail: widget.userEmail),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTaskCard(
                    'Assign Tasks',
                    Icons.assignment_turned_in_outlined,
                    Colors.amber.shade700,
                        () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AssignTasksScreen(userEmail: widget.userEmail),
                          ),
                        ),
                  ),
                  _buildTaskCard(
                    'Finished',
                    Icons.done_all,
                    Colors.purple,
                        () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FinishedTasksScreen(userEmail: widget.userEmail),
                          ),
                        ),
                  ),
                  _buildTaskCard(
                    'Shop',
                    Icons.store_outlined,
                    Colors.blue.shade400,
                        () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AvailableShopScreen(userEmail: widget.userEmail),
                          ),
                        ),
                  ),
                  _buildTaskCard(
                    'Reports',
                    Icons.assessment_outlined,
                    Colors.teal,
                        () {
                      setState(() {
                        _selectedIndex = 2; // Navigate to Gig Worker Report screen
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons in 2x2 grid
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Company Profile',
                    Icons.business_outlined,
                    _secondaryColor,
                        () {
                      setState(() {
                        _selectedIndex = 3; // Navigate to Company Details
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Settings',
                    Icons.settings_outlined,
                    Colors.amber.shade700,
                        () {
                      setState(() {
                        _selectedIndex = 4; // Navigate to Settings
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Update Password',
                    Icons.password_outlined,
                    Colors.indigo.shade400,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdatePasswordScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Update Profile',
                    Icons.edit_outlined,
                    Colors.green.shade600,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateProfileScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper method to build task cards for the dashboard
  Widget _buildTaskCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build action buttons for the dashboard
  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchCompanyDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _profileProvider.fetchUserProfile(widget.userEmail);
      setState(() {
        _companyName = _profileProvider.name ?? "Company";
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching company details: $error');
      setState(() {
        _companyName = "Company";
        _isLoading = false;
      });
    }
  }

  // Build the Settings screen
  Widget _buildSettingsScreen() {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 24),
          // ... (rest of the settings screen code)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          _screenTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          if (_selectedIndex == 5) // Only show on Dashboard
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () async {
                await _fetchTaskCounts(); // Refresh task counts
              },
            ),
        ],
        leading: _selectedIndex == 5
            ? IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        )
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedIndex = 5; // Return to Dashboard screen
            });
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
    );
  }
}