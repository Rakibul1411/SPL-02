import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Import DashboardScreen
import 'assign_task_survey_list_screen.dart'; // Import AssignSurveyListScreen
import 'settings_screen.dart'; // Import SettingsScreen

class ShopManagerScreen extends StatefulWidget {
  const ShopManagerScreen({super.key});

  @override
  _ShopManagerScreenState createState() => _ShopManagerScreenState();
}

class _ShopManagerScreenState extends State<ShopManagerScreen> {
  int _selectedIndex = 0; // Index for the selected sidebar item

  // List of screens corresponding to sidebar items
  final List<Widget> _screens = [
    const DashboardScreen(), // Dashboard Screen
    const AssignSurveyListScreen(), // Assign Survey List Screen
    const SettingsScreen(), // Settings Screen
  ];

  // List of app bar titles for each screen
  final List<String> _appBarTitles = [
    'Dashboard',
    'Assign Survey List',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]), // Dynamic app bar title
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
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Assign Survey'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            leading: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(
                    Icons.store,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Shop Manager',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content Area
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}