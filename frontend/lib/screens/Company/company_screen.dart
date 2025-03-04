import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../Profile/profile_details_screen.dart';
import 'create_task_screen.dart';
import 'task_list_screen.dart';
import '../../providers/profile_provider.dart';
import '../../providers/authProvider.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const CompanyScreen({super.key, required this.userEmail});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = false;
  String _companyName = "";
  bool _isLoading = true;

  late final List<Widget> _screens;
  late final ProfileProvider _profileProvider;

  // Create a GlobalKey for the Scaffold to control the Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _screenTitles = [
    'Create Task',
    'All Tasks',
    'Gig Worker Report List',
    'Company Details',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _screens = [
      const CreateTaskScreen(),
      const TaskListScreen(),
      const Center(child: Text('Gig Worker Report List')),
      provider.ChangeNotifierProvider.value(
        value: _profileProvider,
        child: DashboardScreen(userEmail: widget.userEmail),
      ),
      const Center(child: Text('Settings')),
    ];
    _fetchCompanyDetails();
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
      key: _scaffoldKey,  // Assign the ScaffoldKey here
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.menu), // Left-side hamburger icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer
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
                _companyName,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.business,
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_task_outlined),
              title: Text('Create Task'),
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
              title: Text('All Tasks'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.report_outlined),
              title: Text('Gig Worker Report'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                  _isSidebarExpanded = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Company Details'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
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
                  _selectedIndex = 4;
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
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
