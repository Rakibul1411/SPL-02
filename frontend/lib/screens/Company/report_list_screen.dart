import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../providers/report_provider.dart';
import '../../providers/authProvider.dart';  // Assuming you have an auth service to get company ID
import 'report_detail_screen.dart';      // We'll create this later

class ReportListScreen extends StatefulWidget {
  final String userEmail;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ReportListScreen({
    super.key,
    required this.userEmail,
    required this.scaffoldKey,
  });
  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final ReportService _reportService = ReportService();

  List<Report> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get the company ID from your auth service
      // final String companyId = await _authService.getCurrentCompanyId();
      // final String companyId = widget.;

      // Fetch reports for this company
      final reports = await _reportService.getReportsByCompany(widget.userEmail);

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load reports: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // Changed to menu icon
          onPressed: () {
            widget.scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Gig Worker Report List',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Reports',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),

            // Show count of reports
            Text(
              '${_reports.length} reports found',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Report List
            Expanded(
              child: _buildReportList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Text(
          'No reports found',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          // Format the date
          final formattedDate = DateFormat('MMM d, yyyy').format(report.submittedAt);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              title: Text(
                'Report #${report.reportId.substring(report.reportId.length - 6)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Submitted on: $formattedDate',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Preview of report text
                  Text(
                    report.reportText.length > 50
                        ? '${report.reportText.substring(0, 50)}...'
                        : report.reportText,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Show attachments info if any
                  if (report.imageUrls.isNotEmpty || report.fileUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (report.imageUrls.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.image, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${report.imageUrls.length} Images',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          if (report.imageUrls.isNotEmpty && report.fileUrls.isNotEmpty)
                            const SizedBox(width: 16),
                          if (report.fileUrls.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${report.fileUrls.length} Files',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 18,
              ),
              onTap: () {
                // Navigate to report detail screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportDetailScreen(report: report),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}