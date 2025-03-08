import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PreviousSurveyListScreen extends StatefulWidget {
  final String userEmail;

  const PreviousSurveyListScreen({super.key, required this.userEmail});

  @override
  State<PreviousSurveyListScreen> createState() => _PreviousSurveyListScreenState();
}

class _PreviousSurveyListScreenState extends State<PreviousSurveyListScreen> {
  final String baseUrl = 'http://10.0.2.2:3005';
  bool _isLoading = true;
  List<dynamic> _verifiedTasks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVerifiedTasks();
  }

  Future<void> _fetchVerifiedTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/taskAssignment/getVerifiedShopTasks/${widget.userEmail}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _verifiedTasks = data;
          _isLoading = false;
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage = error['error'] ?? 'Failed to fetch verified tasks';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a consistent color theme (matching the shop manager screen)
    final Color primaryColor = const Color(0xFF2563EB); // Blue 600
    final Color bgColor = const Color(0xFFF9FAFB); // Gray 50
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF1F2937); // Gray 800
    final Color subtextColor = const Color(0xFF6B7280); // Gray 500

    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: subtextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchVerifiedTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _verifiedTasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: subtextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Completed Surveys',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no verified surveys to display',
              style: TextStyle(color: subtextColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchVerifiedTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchVerifiedTasks,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Completed Surveys',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'These surveys have been completed and verified',
              style: TextStyle(
                color: subtextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ..._verifiedTasks.map((task) => _buildTaskCard(
              context,
              task,
              primaryColor,
              cardColor,
              textColor,
              subtextColor,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(
      BuildContext context,
      dynamic task,
      Color primaryColor,
      Color cardColor,
      Color textColor,
      Color subtextColor,
      ) {
    final taskDetails = task['taskDetails'] ?? {};
    final workerDetails = task['workerDetails'] ?? {};

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskDetails['title'] ?? 'Untitled Survey',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        taskDetails['shopName'] ?? 'Unknown Shop',
                        style: TextStyle(
                          fontSize: 16,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              taskDetails['description'] ?? 'No description provided',
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoTag(
                  Icons.attach_money,
                  'Incentive: \$${taskDetails['incentive'] ?? '0'}',
                  Colors.green.shade100,
                  Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                _buildInfoTag(
                  Icons.category_outlined,
                  taskDetails['category'] ?? 'General',
                  Colors.amber.shade100,
                  Colors.amber.shade700,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Text(
                          workerDetails['name']?.substring(0, 1).toUpperCase() ?? 'W',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Completed by ${workerDetails['name'] ?? 'Unknown Worker'}',
                          style: TextStyle(color: subtextColor, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Verified: ${_formatDate(task['verifiedAt'])}',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}