class Task {
  final String? id; // Ensure the id field is included
  final String title;
  final String companyId;
  final String description;
  final String shopName;
  final double incentive;
  final DateTime deadline;
  final String status;
  final double latitude;
  final double longitude;
  final List<SelectedWorker> selectedWorkers;
  final List<AcceptedByWorker> acceptedByWorkers;
  final List<RejectedByWorker> rejectedByWorkers;

  Task({
    this.id,
    required this.title,
    required this.companyId,
    required this.description,
    required this.shopName,
    required this.incentive,
    required this.deadline,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.selectedWorkers,
    required this.acceptedByWorkers,
    required this.rejectedByWorkers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyId': companyId,
      'description': description,
      'shopName': shopName,
      'incentive': incentive,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'selectedWorkers': selectedWorkers.map((worker) => worker.toJson()).toList(),
      'acceptedByWorkers': acceptedByWorkers.map((worker) => worker.toJson()).toList(),
      'rejectedByWorkers': rejectedByWorkers.map((worker) => worker.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      companyId: json['companyId'] ?? '',
      description: json['description'] ?? '',
      shopName: json['shopName'],
      incentive: (json['incentive'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      selectedWorkers: (json['selectedWorkers'] as List<dynamic>?)
          ?.map((worker) => SelectedWorker.fromJson(worker))
          .toList() ??
          [],
      acceptedByWorkers: (json['acceptedByWorkers'] as List<dynamic>?)
          ?.map((worker) => AcceptedByWorker.fromJson(worker))
          .toList() ??
          [],
      rejectedByWorkers: (json['rejectedByWorkers'] as List<dynamic>?)
          ?.map((worker) => RejectedByWorker.fromJson(worker))
          .toList() ??
          [],
    );
  }
}

class SelectedWorker {
  final String workerId;
  final String email;
  final double distance;

  SelectedWorker({
    required this.workerId,
    required this.email,
    required this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'email': email,
      'distance': distance,
    };
  }

  factory SelectedWorker.fromJson(Map<String, dynamic> json) {
    return SelectedWorker(
      workerId: json['workerId'] ?? '',
      email: json['email'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AcceptedByWorker {
  final String workerId;
  final String email;

  AcceptedByWorker({
    required this.workerId,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'email': email,
    };
  }

  factory AcceptedByWorker.fromJson(Map<String, dynamic> json) {
    return AcceptedByWorker(
      workerId: json['workerId'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class RejectedByWorker {
  final String workerId;
  final String email;

  RejectedByWorker({
    required this.workerId,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'email': email,
    };
  }

  factory RejectedByWorker.fromJson(Map<String, dynamic> json) {
    return RejectedByWorker(
      workerId: json['workerId'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// Add this to your task_model.dart file after the existing Worker class

class WorkerDetails {
  final String name;
  final String email;
  final double distance;

  WorkerDetails({
    required this.name,
    required this.email,
    required this.distance,
  });

  factory WorkerDetails.fromJson(Map<String, dynamic> json) {
    return WorkerDetails(
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Update the Task model to include the new worker details fields
class TaskWithWorkerDetails {
  final String taskId;
  final String title;
  final String description;
  final String shopName;
  final double incentive;
  final DateTime deadline;
  final String status;
  final double latitude;
  final double longitude;
  final List<WorkerDetails> acceptedWorkers;
  final List<WorkerDetails> rejectedWorkers;

  TaskWithWorkerDetails({
    required this.taskId,
    required this.title,
    required this.description,
    required this.shopName,
    required this.incentive,
    required this.deadline,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.acceptedWorkers,
    required this.rejectedWorkers,
  });

  factory TaskWithWorkerDetails.fromJson(Map<String, dynamic> json) {
    return TaskWithWorkerDetails(
      taskId: json['taskId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      shopName: json['shopName'] ?? '',
      incentive: (json['incentive'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      acceptedWorkers: (json['acceptedWorkers'] as List<dynamic>?)
          ?.map((worker) => WorkerDetails.fromJson(worker))
          .toList() ??
          [],
      rejectedWorkers: (json['rejectedWorkers'] as List<dynamic>?)
          ?.map((worker) => WorkerDetails.fromJson(worker))
          .toList() ??
          [],
    );
  }
}