import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
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
import '../Profile/UpdatePasswordScreen.dart'; // Import UpdatePasswordScreen
import '../Profile/UpdateProfileScreen.dart'; // Import UpdateProfileScreen
class CompanyScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const CompanyScreen({super.key, required this.userEmail});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  int _selectedIndex = 5;
  bool _isSidebarExpanded = false;
  String _companyName = "";
  bool _isLoading = true;

  late final List<Widget> _screens;
  late final ProfileProvider _profileProvider;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _screenTitles = [
    'Create Task',
    'All Tasks',
    'Gig Worker Report List',
    'Company Details',
    'Settings',
    'Welcome',
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
      _buildSettingsScreen(), // Updated to include sub-modules
      _buildWelcomeScreen(),
    ];
    _fetchCompanyDetails();
  }

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
              Icons.business,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome Back $_companyName',
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
                  _selectedIndex = 0;
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
                'Create Your First Task',
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
        ),
      ],
    );
  }

  Future<void> _fetchCompanyDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _profileProvider.fetchUserProfile(widget.userEmail);
      setState(() {
        _companyName = _profileProvider.name ?? "Company Name";
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching company details: $error');
      setState(() {
        _companyName = "Company Name";
        _isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    final authProvider = AuthProvider();
    try {
      await authProvider.logout();
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

  @override
  Widget build(BuildContext context) {
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
        leading: _selectedIndex == 3 // Back button only for Company Details screen
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedIndex = 5; // Navigate back to Welcome screen
            });
          },
        )
            : IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
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
                  _companyName,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                accountEmail: Text(
                  widget.userEmail,
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.business,
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
              ExpansionTile(
                leading: const Icon(Icons.task_outlined, color: Colors.white),
                title: const Text(
                  'Tasks Section',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_task_outlined, color: Colors.white),
                    title: const Text(
                      'Create Task',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0; // Navigate to Create Task screen
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt_outlined, color: Colors.white),
                    title: const Text(
                      'All Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1; // Navigate to All Tasks screen
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.white),
                    title: const Text(
                      'Accepted Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcceptedTasksListScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cancel_outlined, color: Colors.white),
                    title: const Text(
                      'Rejected Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RejectedTasksListScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment_outlined, color: Colors.white),
                    title: const Text(
                      'Assign Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignTasksScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.done_all_outlined, color: Colors.white),
                    title: const Text(
                      'Finished Tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinishedTasksScreen(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Colors.white),
                title: const Text(
                  'Gig Worker Report',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 2; // Navigate to Gig Worker Report screen
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  'Company Details',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 3; // Navigate to Company Details screen
                  });
                  Navigator.pop(context);
                },
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
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}