import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/report.dart';

class ReportService {
  final String baseUrl = 'http://localhost:3005'; // Updated base URL

  Future<Report> submitReport({
    required String taskId,
    required String workerId,
    required String reportText,
    File? image,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/report/submitReport'), // Correct endpoint
      );

      // Add form fields
      request.fields['taskId'] = taskId;
      request.fields['workerId'] = workerId;
      request.fields['reportText'] = reportText;
      request.fields['submittedAt'] = DateTime.now().toIso8601String();

      // Add image file if exists
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Must match backend field name
            image.path,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();



      if (response.statusCode == 201) {
        return Report.fromJson(jsonDecode(responseBody));
      } else {
        print('Error Response Body: $responseBody');
        throw Exception(
          'Report submission failed. Status: ${response.statusCode}. Body: $responseBody',
        );
      }
    } catch (e) {
      print('Detailed submission error: $e');
      throw Exception('Connection failed: $e');
    }
  }
}