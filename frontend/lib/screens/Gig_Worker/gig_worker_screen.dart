import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gig_worker_task_list_screen.dart';
import 'profile_details_screen.dart';

class GigWorkerScreen extends ConsumerStatefulWidget {
  const GigWorkerScreen({super.key});

  @override
  ConsumerState<GigWorkerScreen> createState() => _GigWorkerScreenState();
}

class _GigWorkerScreenState extends ConsumerState<GigWorkerScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = false; // Controls sidebar state

  final List<Widget> _screens = [
    const GigWorkerTaskListScreen(),
    const ProfileDetailsScreen(),
  ];

  final List<NavigationRailDestination> _sidebarDestinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.task_outlined),
      selectedIcon: Icon(Icons.task),
      label: Text('Tasks'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Profile'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.report_outlined),
      selectedIcon: Icon(Icons.report),
      label: Text('Report'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.logout),
      selectedIcon: Icon(Icons.logout),
      label: Text('Logout'),
    ),
  ];

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gig Worker Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.grey[100],
            extended: _isSidebarExpanded, // Sidebar expand/collapse
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == 4) {
                _logout(context); // Handle logout
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: _isSidebarExpanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    _isSidebarExpanded ? Icons.arrow_back : Icons.menu,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                if (_isSidebarExpanded)
                  const Text(
                    'Gig Worker',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
            destinations: _sidebarDestinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
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
