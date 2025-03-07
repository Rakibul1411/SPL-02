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
    'Welcome', // Added welcome screen title
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _screens = [
      provider.ChangeNotifierProvider.value(
        value: _profileProvider,
        child: ProfileDetailsScreen(userEmail: widget.userEmail),
      ),
      NewTaskListScreen(userEmail: widget.userEmail,),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.purple.shade700],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome Back $_userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Logged in as: ${widget.userEmail}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0; // Navigate to Profile Details
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'View Profile Details',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
  }

  // Build the Settings screen with ExpansionTile
  Widget _buildSettingsScreen() {
    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: ExpansionTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.blue),
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.password, color: Colors.green),
                title: const Text('Update Password'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdatePasswordScreen(userEmail: widget.userEmail),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.orange),
                title: const Text('Update Profile'),
                onTap: () {
                  setState(() {
                    _selectedIndex = 4; // Navigate to Update Profile screen
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate leading icon
    Widget? leadingIcon;

    // If on Welcome screen, show menu icon
    if (_selectedIndex == 5) {
      leadingIcon = IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      );
    }
    // For other screens, show back button that returns to Welcome screen
    else {
      leadingIcon = IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            _selectedIndex = 5; // Return to Welcome screen
          });
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _screenTitles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        leading: leadingIcon,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.purple.shade700],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                accountName: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text(
                  _userName,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                accountEmail: Text(
                  widget.userEmail,
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined, color: Colors.white),
                title: const Text(
                  'Welcome',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 5; // Navigate to Welcome screen
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: const Text(
                  'Profile Details',
                  style: TextStyle(color: Colors.white),
                ),
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
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.pending_actions, color: Colors.white),
                    title: const Text(
                      'Assigned Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignedTasksScreen(email: widget.userEmail,),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.done_all, color: Colors.white),
                    title: const Text(
                      'Finished Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FinishedTasksScreen(userEmail: '',),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_off, color: Colors.white),
                    title: const Text(
                      'Deadline Passed Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeadlinePassedTasksScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cancel, color: Colors.white),
                    title: const Text(
                      'Rejected Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RejectedTaskScreen(userEmail: widget.userEmail,),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.white),
                    title: const Text(
                      'Accepted Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      // Get tasks from the provider
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
                  ListTile(
                    leading: const Icon(Icons.add_task, color: Colors.white),
                    title: const Text(
                      'New Task',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewTaskListScreen(userEmail: widget.userEmail,),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.white),
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.password, color: Colors.white),
                    title: const Text(
                      'Update Password',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdatePasswordScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_circle, color: Colors.white),
                    title: const Text(
                      'Update Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProfileScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Colors.white),
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 1
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: _screens[_selectedIndex],
              )
                  : _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}