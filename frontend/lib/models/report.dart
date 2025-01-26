class Report {
  final String reportId;
  final String taskId;
  final String workerId;
  final String reportText;
  final String? imageUrl;
  final DateTime submittedAt;
  final double? reportRating;

  Report({
    required this.reportId,
    required this.taskId,
    required this.workerId,
    required this.reportText,
    this.imageUrl,
    required this.submittedAt,
    this.reportRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'taskId': taskId,
      'workerId': workerId,
      'reportText': reportText,
      'imageUrl': imageUrl,
      'submittedAt': submittedAt.toIso8601String(),
      'reportRating': reportRating,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'],
      taskId: json['taskId'],
      workerId: json['workerId'],
      reportText: json['reportText'],
      imageUrl: json['imageUrl'],
      submittedAt: DateTime.parse(json['submittedAt']),
      reportRating: json['reportRating']?.toDouble(),
    );
  }
}
