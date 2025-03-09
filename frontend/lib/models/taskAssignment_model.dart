// taskAssignment_model.dart
class TaskAssignment {
  final String assignmentId;
  final String taskId;
  final String workerId;
  final String shopId;
  final DateTime assignedAt;
  final String status;
  final String? verificationCode;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? taskDetails;

  TaskAssignment({
    required this.assignmentId,
    required this.taskId,
    required this.workerId,
    required this.shopId,
    required this.assignedAt,
    required this.status,
    this.verificationCode,
    this.verifiedAt,
    this.taskDetails,
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      // Handle both API formats (camelCase and snake_case)
      assignmentId: json['assignmentId'] as String? ?? json['_id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? json['task_id'] as String? ?? '',
      workerId: json['workerId'] as String? ?? json['worker_id'] as String? ?? '',
      shopId: json['shopId'] as String? ?? json['shop_id'] as String? ?? '',
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'assigned',
      verificationCode: json['verificationCode'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      taskDetails: json['taskDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': assignmentId,
      'task_id': taskId,
      'worker_id': workerId,
      'shop_id': shopId,
      'assignedAt': assignedAt.toIso8601String(),
      'status': status,
      'verificationCode': verificationCode,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'taskDetails': taskDetails,
    };
  }
}