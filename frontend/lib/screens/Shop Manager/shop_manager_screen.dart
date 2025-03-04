import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_details_screen.dart';
import 'assign_task_survey_list_screen.dart';
import 'settings_screen.dart';
import 'previous_survey_list_screen.dart';
import '../../providers/authProvider.dart';
import '../../providers/profile_provider.dart';

class ShopManagerScreen extends StatefulWidget {
  final String userEmail;

  const ShopManagerScreen({super.key, required this.userEmail});

  @override
  _ShopManagerScreenState createState() => _ShopManagerScreenState();
}

class _ShopManagerScreenState extends State<ShopManagerScreen> {
  int _selectedIndex = 0;
  String _userName = ""; // Variable to store the user's name
  bool _isLoading = true; // Loading state

  late final List<Widget> _screens;
  late final ProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _screens = [
      ChangeNotifierProvider.value(
        value: _profileProvider,
        child: DashboardScreen(userEmail: widget.userEmail),
      ),
      const AssignSurveyListScreen(),
      const SettingsScreen(),
      const PreviousSurveyListScreen(),
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
      // Use the ProfileProvider to fetch user data
      await _profileProvider.fetchUserProfile(widget.userEmail);

      setState(() {
        // Get the user's name directly from the profile provider
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

  final List<String> _appBarTitles = [
    'Profile Details',
    'Assign Survey List',
    'Settings',
    'Previous Survey List',
  ];

  void _handleLogout(BuildContext context) async {
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
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.store,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _userName, // Now displays the user's name from database
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Profile Details'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Assign Survey'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Previous Survey List'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}