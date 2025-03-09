class IncentiveAndRating {
  final String id;
  final Worker workerId;
  final Task taskId;
  // Incentive fields
  final double amount;
  final DateTime issuedAt;
  // Rating fields
  final int rating;
  final String feedback;
  final Worker? ratedBy; // Changed to Worker type
  final DateTime createdAt;

  IncentiveAndRating({
    required this.id,
    required this.workerId,
    required this.taskId,
    // Incentive fields
    required this.amount,
    required this.issuedAt,
    // Rating fields
    required this.rating,
    required this.feedback,
    this.ratedBy, // Optional
    required this.createdAt,
  });

  factory IncentiveAndRating.fromJson(Map<String, dynamic> json) {
    return IncentiveAndRating(
      id: json['_id'] ?? '',
      workerId: json['workerId'] is Map
          ? Worker.fromJson(json['workerId'])
          : Worker(id: json['workerId'] ?? '', name: ''),
      taskId: json['taskId'] is Map
          ? Task.fromJson(json['taskId'])
          : Task(id: json['taskId'] ?? '', title: ''),
      // Incentive fields
      amount: json['amount']?.toDouble() ?? 0.0,
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'])
          : DateTime.now(),
      // Rating fields
      rating: json['rating'] ?? 0,
      feedback: json['feedback'] ?? '',
      ratedBy: json['ratedBy'] is Map
          ? Worker.fromJson(json['ratedBy'])
          : (json['ratedBy'] != null ? Worker(id: json['ratedBy'], name: '') : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

// Add these supporting classes
class Worker {
  final String id;
  final String name;

  Worker({required this.id, required this.name});

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Task {
  final String id;
  final String title;

  Task({required this.id, required this.title});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}