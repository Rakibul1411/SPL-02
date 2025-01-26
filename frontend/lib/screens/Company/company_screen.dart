import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'create_task_screen.dart';
import 'task_list_screen.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  int _selectedIndex = 0; // Index for selected sidebar item
  bool _isSidebarExpanded = false; // Sidebar expanded state

  final List<Widget> _screens = [
    const CreateTaskScreen(), // Create Task Screen
    const TaskListScreen(), // All Tasks Screen
    const Center(child: Text('Gig Worker Report List')), // Placeholder for Gig Worker Report
    const Center(child: Text('Company Details')), // Placeholder for Company Details
    const Center(child: Text('Settings')), // Placeholder for Settings
  ];

  final List<String> _appBarTitles = [
    'Create Task',
    'All Tasks',
    'Gig Worker Report List',
    'Company Details',
    'Settings',
  ];

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
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
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Notifications'),
                    content: const Text('You have no new notifications.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: _isSidebarExpanded,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == 5) {
                _logout(context); // Logout button
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Column(
              children: [
                IconButton(
                  icon: Icon(
                    _isSidebarExpanded ? Icons.arrow_back : Icons.menu,
                  ),
                  onPressed: _toggleSidebar,
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.business, color: Colors.blue),
                ),
              ],
            ),
            labelType: _isSidebarExpanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.add_task_outlined),
                selectedIcon: Icon(Icons.add_task),
                label: Text('Create Task'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.task_outlined),
                selectedIcon: Icon(Icons.task),
                label: Text('All Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.report_outlined),
                selectedIcon: Icon(Icons.report),
                label: Text('Gig Worker Report'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('Company Details'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout),
                selectedIcon: Icon(Icons.logout),
                label: Text('Logout'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
