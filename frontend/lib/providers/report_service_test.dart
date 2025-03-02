import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // Image package for resizing
import '../models/report.dart';

class ReportService {
  final String baseUrl = 'http://192.168.0.101:3005'; // Replace with your correct IP

  Future<Report> submitReport({
    required String taskId,
    required String workerId,
    required String reportText,
    File? image,
    String? fileUrl, // Add this parameter
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/report/submitReport'),
      );

      request.fields['taskId'] = taskId;
      request.fields['workerId'] = workerId;
      request.fields['reportText'] = reportText;
      request.fields['submittedAt'] = DateTime.now().toIso8601String();
      if (fileUrl != null) {
        request.fields['fileUrl'] = fileUrl; // Add fileUrl to the request
      }

      if (image != null) {
        // Compress image before uploading
        File compressedImage = await _compressImage(image);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            compressedImage.path,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 201 && decodedResponse["success"] == true) {
        return Report.fromJson({
          "reportId": decodedResponse["report"]["reportId"] ?? '',
          "taskId": decodedResponse["report"]["taskId"] ?? '',
          "workerId": decodedResponse["report"]["workerId"] ?? '',
          "reportText": decodedResponse["report"]["reportText"] ?? '',
          "imageUrl": decodedResponse["report"]["imageUrl"] ?? '',
          "fileUrl": decodedResponse["report"]["fileUrl"] ?? '', // Add this field
          "submittedAt": decodedResponse["report"]["submittedAt"] ?? '',
        });
      } else {
        throw Exception('Report submission failed. ${decodedResponse["message"] ?? "Unknown error"}');
      }
    } catch (e) {
      print('Detailed submission error: $e');
      throw Exception('Connection failed: $e');
    }
  }

  // New method for uploading general files (e.g., PDFs)
  Future<String> uploadFile(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/report/uploadFile'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 201 && decodedResponse["success"] == true) {
        return decodedResponse["fileUrl"];
      } else {
        throw Exception('File upload failed. ${decodedResponse["message"] ?? "Unknown error"}');
      }
    } catch (e) {
      print('Detailed file upload error: $e');
      throw Exception('Connection failed: $e');
    }
  }

  // Image compression function
  Future<File> _compressImage(File file) async {
    final img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) return file;

    final img.Image resized = img.copyResize(image, width: 800);

    final compressedFile = File(file.path.replaceAll('.jpg', '_compressed.jpg'))
      ..writeAsBytesSync(img.encodeJpg(resized, quality: 70));

    return compressedFile;
  }
}