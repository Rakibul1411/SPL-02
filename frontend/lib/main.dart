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
      //home: const LaunchScreen(),
      //home: const CompanyScreen(userEmail: 'bsse1411@iit.du.ac.bd'),
      //home: const ShopManagerScreen(userEmail: 'natiqaqif@gmail.com'),
      home: const GigWorkerScreen(userEmail: 'mdrakibul11611@gmail.com'),
      //home: const CreateTaskScreen(userEmail: 'bsse1411@iit.du.ac.bd',),
      //home: const ResetPasswordScreen(email: 'email'),
      debugShowCheckedModeBanner: false, // Or your home screen
    );
  }
}