import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/Company/task_list_screen.dart';
import 'package:frontend/screens/after_registration_screen.dart';
import 'package:frontend/screens/launch_page_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/registration_screen.dart';
import 'package:frontend/screens/report_submission_screen.dart';
import 'package:frontend/screens/taskList_screen_test.dart';
// Adjust the import path as needed

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LaunchScreen(),
      // home: const ReportSubmissionScreen(taskId: '1', workerId: '1',),
      debugShowCheckedModeBanner: false, // Or your home screen
    );
  }
}