import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/Company/company_screen.dart';
import 'package:frontend/screens/Company/create_task_screen.dart';
import 'package:frontend/screens/Company/task_list_screen.dart';
import 'package:frontend/screens/Gig_Worker/gig_worker_screen.dart';
import 'package:frontend/screens/Profile/UpdatePasswordScreen.dart';
import 'package:frontend/screens/ResetAndUpdatePassword/ResetPasswordScreen.dart';
import 'package:frontend/screens/Shop%20Manager/shop_manager_screen.dart';
import 'package:frontend/screens/OtherScreens/after_registration_screen.dart';
import 'package:frontend/screens/OtherScreens/launch_page_screen.dart';
import 'package:frontend/screens/Authentication/login_screen.dart';
import 'package:frontend/screens/Map/map_screen.dart';
import 'package:frontend/screens/Authentication/registration_screen.dart';
import 'package:frontend/screens/Report/report_submission_screen.dart';
import 'package:frontend/screens/after_registration_screen.dart';
import 'package:frontend/screens/incentive_and_rating_screen.dart';
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
      //home: const ReportSubmissionScreen(taskId: '1', workerId: '1',),
      //home: const LaunchScreen(),
      //home: const CompanyScreen(userEmail: 'bsse1408@iit.du.ac.bd'),
      //home: const CompanyScreen(userEmail: 'bsse1411@iit.du.ac.bd'),
      //home: const ShopManagerScreen(userEmail: 'natiqaqif@gmail.com'),
      //home: const GigWorkerScreen(userEmail: 'rakibulislamnatiq@gmail.com'),
      //home: const CreateTaskScreen(userEmail: 'bsse1411@iit.du.ac.bd',),
      //home: const ResetPasswordScreen(email: 'email'),
      // home: const LaunchScreen(),
      home: IncentiveAndRatingScreen(),
      // home: const ReportSubmissionScreen(taskId: '1', workerId: '1',),
      debugShowCheckedModeBanner: false, // Or your home screen
    );
  }
}