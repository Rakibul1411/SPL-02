import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../OtherScreens/launch_page_screen.dart';
import '../Profile/profile_details_screen.dart';
import 'assign_task_survey_list_screen.dart';
import 'settings_screen.dart';
import 'previous_survey_list_screen.dart';
import '../../providers/authProvider.dart';
import '../../providers/profile_provider.dart';
import '../Profile/UpdatePasswordScreen.dart'; // Import UpdatePasswordScreen
import '../Profile/UpdateProfileScreen.dart'; // Import UpdateProfileScreen

class ShopManagerScreen extends StatefulWidget {
  final String userEmail;

  const ShopManagerScreen({super.key, required this.userEmail});

  @override
  _ShopManagerScreenState createState() => _ShopManagerScreenState();
}

class _ShopManagerScreenState extends State<ShopManagerScreen> {
  int _selectedIndex = 4; // Welcome screen is the default
  String _userName = ""; // Variable to store the user's name
  bool _isLoading = true; // Loading state

  late final List<Widget> _screens;
  late final ProfileProvider _profileProvider;

  final List<String> _appBarTitles = [
    'Profile Details',
    'Assign Survey List',
    'Settings',
    'Previous Survey List',
    'Welcome', // Added welcome screen title
  ];

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _screens = [
      ChangeNotifierProvider.value(
        value: _profileProvider,
        child: ProfileDetailsScreen(userEmail: widget.userEmail),
      ),
      const AssignSurveyListScreen(),
      _buildSettingsScreen(), // Updated to include sub-modules
      const PreviousSurveyListScreen(),
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
              Icons.store,
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

  void _handleLogout(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
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
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
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
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text(
                  'Welcome',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.white),
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
              ListTile(
                leading: const Icon(Icons.assignment, color: Colors.white),
                title: const Text(
                  'Assign Survey',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.settings, color: Colors.white),
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
                leading: const Icon(Icons.list, color: Colors.white),
                title: const Text(
                  'Previous Survey List',
                  style: TextStyle(color: Colors.white),
                ),
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
      ),
      body: _screens[_selectedIndex],
    );
  }
}