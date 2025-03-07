import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/report.dart';

class ReportService {
  //final String baseUrl = 'http://192.168.0.101:3005'; // Replace with actual API URL
  final String baseUrl = 'http://localhost:3005';

  Future<Report> submitReport({
    required String taskId,
    required String workerId,
    required String reportText,
    List<File>? images,
    List<File>? files,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/report/submitReport'),
      );

      request.fields['taskId'] = taskId;
      request.fields['workerId'] = workerId;
      request.fields['reportText'] = reportText;

      // Attach compressed images
      if (images != null) {
        for (var image in images) {
          File compressedImage = await _compressImage(image);
          request.files.add(
            await http.MultipartFile.fromPath('images', compressedImage.path),
          );
        }
      }

      // Attach files (PDF, DOCX, etc.)
      if (files != null) {
        for (var file in files) {
          request.files.add(
            await http.MultipartFile.fromPath('files', file.path),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 201 && decodedResponse["success"] == true) {
        return Report.fromJson(decodedResponse["report"]);
      } else {
        throw Exception('Report submission failed: ${decodedResponse["message"]}');
      }
    } catch (e) {
      print('Detailed submission error: $e');
      throw Exception('Connection failed: $e');
    }
  }

  // Method for uploading a single file (e.g., PDF, DOCX)
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
        throw Exception('File upload failed: ${decodedResponse["message"]}');
      }
    } catch (e) {
      print('Detailed file upload error: $e');
      throw Exception('Connection failed: $e');
    }
  }

  // Image compression function
  Future<File> _compressImage(File file) async {
    try {
      final img.Image? image = img.decodeImage(await file.readAsBytes());
      if (image == null) return file;

      final img.Image resized = img.copyResize(image, width: 800);
      final compressedFile = File(file.path.replaceAll('.jpg', '_compressed.jpg'))
        ..writeAsBytesSync(img.encodeJpg(resized, quality: 70));

      return compressedFile;
    } catch (e) {
      print('Image compression failed: $e');
      return file;
    }
  }
}
