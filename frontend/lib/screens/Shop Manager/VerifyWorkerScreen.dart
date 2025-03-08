import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/taskAssignment_model.dart';

class VerifyWorkerScreen extends StatefulWidget {
  final String assignmentId;
  final Function onVerificationComplete;

  const VerifyWorkerScreen({
    super.key,
    required this.assignmentId,
    required this.onVerificationComplete,
  });

  @override
  State<VerifyWorkerScreen> createState() => _VerifyWorkerScreenState();
}

class _VerifyWorkerScreenState extends State<VerifyWorkerScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String baseUrl = 'http://10.0.2.2:3005';
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> verifyWorker() async {
    // Validate input
    if (_codeController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a verification code';
      });
      return;
    }

    // Validate assignmentId
    if (widget.assignmentId.isEmpty) {
      setState(() {
        errorMessage = 'Invalid task assignment ID';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/taskAssignment/verifyWorker'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'assignmentId': widget.assignmentId,
          'verificationCode': _codeController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          successMessage = 'Worker successfully verified!';
          isLoading = false;
        });

        // Wait a moment before returning to the previous screen
        Future.delayed(const Duration(seconds: 2), () {
          widget.onVerificationComplete(); // Refresh the task list
          Navigator.pop(context); // Go back to the previous screen
        });
      } else {
        final responseData = json.decode(response.body);
        setState(() {
          errorMessage = responseData['error'] ?? 'Verification failed';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error during verification: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Worker'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the verification code that was provided to the worker:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Verification Code',
                hintText: 'Enter the 6-character code',
              ),
              maxLength: 10,
            ),
            const SizedBox(height: 24),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (successMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.green.shade100,
                child: Text(
                  successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : verifyWorker,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Verify Worker',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}