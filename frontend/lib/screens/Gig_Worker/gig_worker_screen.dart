import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../OtherScreens/launch_page_screen.dart';
import 'new_task_list_screen.dart';
import '../Profile/profile_details_screen.dart';
import '../report_submission_screen.dart';
import '../../providers/profile_provider.dart';
import '../../providers/authProvider.dart';
import 'PendingTaskScreen.dart';
import 'FinishedTaskScreen.dart';
import 'DeadlinePassedTaskScreen.dart';
import 'RejectedTaskScreen.dart';
import 'AcceptedTaskScreen.dart';
import '../../models/task_model.dart';
import '../Profile/UpdatePasswordScreen.dart';
import '../Profile/UpdateProfileScreen.dart';

class GigWorkerScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const GigWorkerScreen({super.key, required this.userEmail});

  @override
  ConsumerState<GigWorkerScreen> createState() => _GigWorkerScreenState();
}

class _GigWorkerScreenState extends ConsumerState<GigWorkerScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = false;
  String _userName = "";
  bool _isLoading = true;

  late final List<Widget> _screens;
  late final ProfileProvider _profileProvider;

  final List<String> _screenTitles = [
    'Profile Details',
    'Tasks',
    'Settings',
    'Report',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _screens = [
      provider.ChangeNotifierProvider.value(
        value: _profileProvider,
        child: DashboardScreen(userEmail: widget.userEmail),
      ),
      const NewTaskListScreen(),
      _buildSettingsScreen(),
      const ReportSubmissionScreen(taskId: '1', workerId: '1'),
    ];

    // Fetch user name when the screen initializes
    _fetchUserName();
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
      print('Error fetching user name: $error');
      setState(() {
        _userName = widget.userEmail; // Fallback to email if fetching fails
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
        ExpansionTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          children: [
            ListTile(
              leading: const Icon(Icons.password),
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
              leading: const Icon(Icons.account_circle),
              title: const Text('Update Profile'),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy task for testing
    final dummyTask = Task(
      id: '1',
      title: 'Sample Task',
      description: 'This is a sample task.',
      location: 'Sample Location',
      deadline: DateTime.now().add(const Duration(days: 1)),
      status: 'pending',
      incentive: 10,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
        leading: IconButton(
          icon: Icon(
            _isSidebarExpanded ? Icons.arrow_back : Icons.menu,
          ),
          onPressed: () {
            setState(() {
              _isSidebarExpanded = !_isSidebarExpanded;
            });
            if (_isSidebarExpanded) {
              _scaffoldKey.currentState?.openDrawer();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              accountName: _isLoading
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : Text(
                _userName,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile Details'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.task_outlined),
              title: const Text('Tasks'),
              children: [
                ListTile(
                  leading: const Icon(Icons.pending_actions),
                  title: const Text('Pending Tasks'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingTasksScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.done_all),
                  title: const Text('Finished Tasks'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FinishedTasksScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer_off),
                  title: const Text('Deadline Passed Tasks'),
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
                  leading: const Icon(Icons.cancel),
                  title: const Text('Rejected Tasks'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RejectedTaskScreen(task: dummyTask),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Accepted Tasks'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcceptedTaskScreen(task: dummyTask),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_task),
                  title: const Text('New Task'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewTaskListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              children: [
                ListTile(
                  leading: const Icon(Icons.password),
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
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Update Profile'),
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
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
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