import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../OtherScreens/launch_page_screen.dart';
import 'new_task_list_screen.dart';
import '../Profile/profile_details_screen.dart';
import '../Report/report_submission_screen.dart';
import '../../providers/profile_provider.dart';
import '../../providers/authProvider.dart';
import '../../providers/task_provider.dart';
import 'AssignedTaskScreen.dart';
import 'FinishedTaskScreen.dart';
import 'DeadlinePassedTaskScreen.dart';
import 'RejectedTaskScreen.dart';
import 'AcceptedTaskScreen.dart';
import '../Profile/UpdatePasswordScreen.dart';
import '../Profile/UpdateProfileScreen.dart';

class GigWorkerScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const GigWorkerScreen({super.key, required this.userEmail});

  @override
  ConsumerState<GigWorkerScreen> createState() => _GigWorkerScreenState();
}

class _GigWorkerScreenState extends ConsumerState<GigWorkerScreen> {
  int _selectedIndex = 5; // Welcome screen
  String _userName = "";
  bool _isLoading = true;

  late final List<Widget> _screens;
  late final ProfileProvider _profileProvider;

  final List<String> _screenTitles = [
    'Profile Details',
    'Tasks',
    'Settings',
    'Report',
    'Update Profile',
    'Dashboard', // Changed from 'Welcome' to 'Dashboard'
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    _profileProvider = ProfileProvider();
    _screens = [
      provider.ChangeNotifierProvider.value(
        value: _profileProvider,
        child: ProfileDetailsScreen(userEmail: widget.userEmail),
      ),
      NewTaskListScreen(userEmail: widget.userEmail),
      _buildSettingsScreen(),
      const ReportSubmissionScreen(taskId: '1', workerId: '1'),
      UpdateProfileScreen(userEmail: widget.userEmail),
      _buildWelcomeScreen(), // Added welcome screen
    ];

    // Fetch user name when the screen initializes
    _fetchUserName();
  }

  // Build welcome screen
  Widget _buildWelcomeScreen() {
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
                        Icons.person,
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
                            _userName,
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

            // Task Overview
            Text(
              'Task Overview',
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
                    'Assigned',
                    Icons.assignment_outlined,
                    Colors.blue,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignedTasksScreen(email: widget.userEmail),
                      ),
                    ),
                  ),
                  _buildTaskCard(
                    'Accepted',
                    Icons.check_circle_outline,
                    Colors.green,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcceptedTaskScreen(userEmail: widget.userEmail),
                      ),
                    ),
                  ),
                  _buildTaskCard(
                    'Completed',
                    Icons.done_all,
                    Colors.purple,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FinishedTasksScreen(userEmail: ''),
                      ),
                    ),
                  ),
                  _buildTaskCard(
                    'Rejected',
                    Icons.cancel_outlined,
                    Colors.red,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RejectedTaskScreen(userEmail: widget.userEmail),
                      ),
                    ),
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

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'New Tasks',
                    Icons.add_task,
                    _accentColor,
                        () {
                      setState(() {
                        _selectedIndex = 1; // Navigate to Tasks screen
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Profile',
                    Icons.person_outline,
                    _secondaryColor,
                        () {
                      setState(() {
                        _selectedIndex = 0; // Navigate to Profile Details
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
                    'Settings',
                    Icons.settings_outlined,
                    Colors.amber.shade700,
                        () {
                      setState(() {
                        _selectedIndex = 2; // Navigate to Settings
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Report',
                    Icons.report_outlined,
                    Colors.redAccent,
                        () {
                      setState(() {
                        _selectedIndex = 3; // Navigate to Report
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build task cards for the welcome screen
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

  // Helper method to build action buttons for the welcome screen
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

  // Method to fetch user name from database
  Future<void> _fetchUserName() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _profileProvider.fetchUserProfile(widget.userEmail);

      setState(() {
        _userName = _profileProvider.name ?? widget.userEmail;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _userName = widget.userEmail;
        _isLoading = false;
      });
    }
  }

  // Method to handle logout
  void _logout(BuildContext context) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: _subtextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = AuthProvider();
              try {
                await authProvider.logout();
                // Redirect to the LaunchScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaunchScreen(),
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $error')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Build the Settings screen with ExpansionTile
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
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.password, color: _primaryColor),
                  title: Text(
                    'Update Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Change your account password',
                    style: TextStyle(
                      color: _subtextColor,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePasswordScreen(userEmail: widget.userEmail),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: Icon(Icons.account_circle, color: _secondaryColor),
                  title: Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Edit your personal information',
                    style: TextStyle(
                      color: _subtextColor,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4; // Navigate to Update Profile screen
                    });
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: Icon(Icons.notifications_outlined, color: Colors.amber.shade700),
                  title: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Manage your notifications',
                    style: TextStyle(
                      color: _subtextColor,
                    ),
                  ),
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: _primaryColor,
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined, color: Colors.indigo.shade400),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Toggle between light and dark theme',
                    style: TextStyle(
                      color: _subtextColor,
                    ),
                  ),
                  trailing: Switch(
                    value: false,
                    onChanged: (_) {},
                    activeColor: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.help_outline, color: _accentColor),
                  title: Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.blue.shade300),
                  title: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
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
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
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
      drawer: Drawer(
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryColor, _secondaryColor],
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () {
                    setState(() {
                      _selectedIndex = 5;
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profile Details',
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    Navigator.pop(context);
                  },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.task_outlined, color: Colors.white),
                  title: const Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    _buildNestedDrawerItem(
                      icon: Icons.pending_actions,
                      title: 'Assigned Tasks',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignedTasksScreen(email: widget.userEmail),
                          ),
                        );
                      },
                    ),
                    _buildNestedDrawerItem(
                      icon: Icons.done_all,
                      title: 'Finished Tasks',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FinishedTasksScreen(userEmail: ''),
                          ),
                        );
                      },
                    ),
                    _buildNestedDrawerItem(
                      icon: Icons.timer_off,
                      title: 'Deadline Passed Tasks',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeadlinePassedTasksScreen(),
                          ),
                        );
                      },
                    ),
                    _buildNestedDrawerItem(
                      icon: Icons.cancel,
                      title: 'Rejected Tasks',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RejectedTaskScreen(userEmail: widget.userEmail),
                          ),
                        );
                      },
                    ),
                    _buildNestedDrawerItem(
                      icon: Icons.check_circle,
                      title: 'Accepted Tasks',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AcceptedTaskScreen(
                              userEmail: widget.userEmail,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildNestedDrawerItem(
                      icon: Icons.add_task,
                      title: 'New Task',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewTaskListScreen(userEmail: widget.userEmail),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.report_outlined,
                  title: 'Report',
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(
                  color: Colors.white24,
                  height: 32,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    _logout(context);
                  },
                ),
                // Add some bottom padding to ensure all items are visible
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
    );
  }

  // Helper method to build nested drawer items
  Widget _buildNestedDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 14,
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      dense: true,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
      onTap: onTap,
    );
  }
}