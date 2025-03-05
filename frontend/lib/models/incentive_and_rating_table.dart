// lib/models/incentive_and_rating_table.dart

// Incentive Model
class Incentive {
  final String id;
  final String workerId;
  final String taskId;
  final double amount;
  final DateTime issuedAt;

  Incentive({
    required this.id,
    required this.workerId,
    required this.taskId,
    required this.amount,
    required this.issuedAt,
  });

  factory Incentive.fromJson(Map<String, dynamic> json) {
    return Incentive(
      id: json['_id'],
      workerId: json['workerId'],
      taskId: json['taskId'],
      amount: json['amount'].toDouble(),
      issuedAt: DateTime.parse(json['issuedAt']),
    );
  }
}

// Rating Model
class Rating {
  final String id;
  final String workerId;
  final String taskId;
  final int rating;
  final String feedback;
  final String ratedBy;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.workerId,
    required this.taskId,
    required this.rating,
    required this.feedback,
    required this.ratedBy,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'],
      workerId: json['workerId'],
      taskId: json['taskId'],
      rating: json['rating'],
      feedback: json['feedback'] ?? '',
      ratedBy: json['ratedBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
