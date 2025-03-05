import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../OtherScreens/launch_page_screen.dart';
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
        child: DashboardScreen(userEmail: widget.userEmail),
      ),
      const Center(child: Text('Settings')),
      _buildWelcomeScreen(),
    ];
    _fetchCompanyDetails();
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.business,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to ${_companyName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Logged in as: ${widget.userEmail}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
            child: const Text('Create Your First Task'),
          ),
        ],
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
        title: Text(_screenTitles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
        leading: _selectedIndex == 3 // Back button only for Company Details screen
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedIndex = 5; // Navigate back to Welcome screen
            });
          },
        )
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
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
                _companyName,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.business,
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Welcome'),
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_task_outlined),
              title: const Text('Create Task'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_outlined),
              title: const Text('All Tasks'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Gig Worker Report'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Company Details'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
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
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}