import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class DashboardScreen extends StatefulWidget {
  final String userEmail; // Add this to accept the user's email

  const DashboardScreen({super.key, required this.userEmail});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically fetch the user's profile data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.fetchUserProfile(widget.userEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
              profileProvider.clearProfile();
              Navigator.pop(context); // Navigate back to the login screen
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (profileProvider.errorMessage != null) {
            return Center(
              child: Text(
                profileProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (profileProvider.name != null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${profileProvider.name}'),
                  Text('Email: ${profileProvider.email}'),
                  Text('Role: ${profileProvider.role}'),
                  Text('Verified: ${profileProvider.isVerified}'),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No profile data available'));
          }
        },
      ),
    );
  }
}