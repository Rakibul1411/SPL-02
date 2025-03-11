import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/worker_model.dart';
import './baseUrl.dart';

class WorkerState {
  final List<Worker> workers;
  final bool isLoading;
  final String? errorMessage;

  WorkerState({
    this.workers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  WorkerState copyWith({
    List<Worker>? workers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WorkerState(
      workers: workers ?? this.workers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WorkerNotifier extends StateNotifier<List<Worker>> {
  WorkerNotifier() : super([]);
  bool isLoading = false;
  String? errorMessage;

  // Fetch all workers
  Future<void> fetchWorkers() async {
    isLoading = true;
    errorMessage = null;

    try {
      // Assuming the API endpoint for getting all workers with role 'Gig Worker'
      final url = Uri.parse('$baseUrl/profile/getUserByRole?role=Gig%20Worker');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final workers = data.map((item) => Worker.fromJson(item)).toList();

        state = workers;
      } else {
        errorMessage = 'Failed to fetch workers: ${response.body}';
      }
    } catch (error) {
      errorMessage = 'Error connecting to server: $error';
    } finally {
      isLoading = false;
    }
  }

  // Get worker by ID
  Future<Worker?> getWorkerById(String workerId) async {
    isLoading = true;
    errorMessage = null;

    try {
      final url = Uri.parse('$baseUrl/profile/getUser/$workerId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Worker.fromJson(data);
      } else {
        errorMessage = 'Failed to fetch worker: ${response.body}';
        return null;
      }
    } catch (error) {
      errorMessage = 'Error connecting to server: $error';
      return null;
    } finally {
      isLoading = false;
    }
  }
}

// Define the provider
final workerProvider = StateNotifierProvider<WorkerNotifier, List<Worker>>((ref) {
  return WorkerNotifier();
});