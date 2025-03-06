import 'package:flutter/material.dart';

class PreviousSurveyListScreen extends StatelessWidget {
  const PreviousSurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Previous Survey List Screen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}