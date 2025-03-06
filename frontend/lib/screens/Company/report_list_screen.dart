import 'package:flutter/material.dart';

class ReportListScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey; // Add scaffoldKey

  const ReportListScreen({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back button
          onPressed: () {
            scaffoldKey.currentState?.openDrawer(); // Open the drawer
          },
        ),
        title: const Text('Gig Worker Report List'),
      ),
      body: const Center(
        child: Text('Gig Worker Report List'),
      ),
    );
  }
}