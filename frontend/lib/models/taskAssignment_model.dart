class TaskAssignment {
  final String assignmentId;
  final String taskId;
  final String workerId;
  final String shopId;
  final DateTime assignedAt;
  final String status;
  final String? verificationCode;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? taskDetails; // Add taskDetails field

  TaskAssignment({
    required this.assignmentId,
    required this.taskId,
    required this.workerId,
    required this.shopId,
    required this.assignedAt,
    required this.status,
    this.verificationCode,
    this.verifiedAt,
    this.taskDetails, // Initialize taskDetails
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      assignmentId: json['_id'] as String? ?? '', // Use '_id' instead of 'assignment_id'
      taskId: json['task_id'] as String? ?? '',
      workerId: json['worker_id'] as String? ?? '',
      shopId: json['shop_id'] as String? ?? '',
      assignedAt: DateTime.parse(json['assignedAt'] as String? ?? DateTime.now().toIso8601String()),
      status: json['status'] as String? ?? 'assigned',
      verificationCode: json['verificationCode'] as String?,
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt'] as String) : null,
      taskDetails: json['taskDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': assignmentId, // Use '_id' instead of 'assignment_id'
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