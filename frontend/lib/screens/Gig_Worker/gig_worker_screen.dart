import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'gig_worker_task_list_screen.dart';
import '../profile_details_screen.dart';
import 'settings_screen.dart';
import '../report_submission_screen.dart';
import '../../providers/profile_provider.dart';
import '../../providers/authProvider.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for controlling the Drawer

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _screens = [
      provider.ChangeNotifierProvider.value(
        value: _profileProvider,
        child: DashboardScreen(userEmail: widget.userEmail),
      ),
      const GigWorkerTaskListScreen(), // Task Screen
      const SettingsScreen(),
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

  void _logout(BuildContext context) async {
    final authProvider = AuthProvider();
    try {
      await authProvider.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Set the scaffold key
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
              _scaffoldKey.currentState?.openDrawer(); // Open Drawer
            } else {
              Navigator.of(context).pop(); // Close Drawer
            }
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
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
              leading: Icon(Icons.person_outline),
              title: Text('Profile Details'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.task_outlined),
              title: Text('Tasks'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.report_outlined),
              title: Text('Report'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
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
                      color: Colors.black.withOpacity(0.6), // Black shadow
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 4), // Shadow position
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
