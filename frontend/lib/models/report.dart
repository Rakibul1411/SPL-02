class Report {
  final String reportId;
  final String taskId;
  final String workerId;
  final String reportText;
  final List<String>? imageUrls;
  final List<String>? fileUrls;
  final DateTime submittedAt;
  final double? reportRating;

  Report({
    required this.reportId,
    required this.taskId,
    required this.workerId,
    required this.reportText,
    this.imageUrls,
    this.fileUrls,
    required this.submittedAt,
    this.reportRating,
  });

  // Map<String, dynamic> toJson() {
  //   return {
  //     'reportId': reportId,
  //     'taskId': taskId,
  //     'workerId': workerId,
  //     'reportText': reportText,
  //     'imageUrl': imageUrl,
  //     'fileUrl': fileUrl, // Add this field
  //     'submittedAt': submittedAt.toIso8601String(),
  //     'reportRating': reportRating,
  //   };
  // }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'],
      taskId: json['taskId'],
      workerId: json['workerId'],
      reportText: json['reportText'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      fileUrls: List<String>.from(json['fileUrls'] ?? []),
      submittedAt: DateTime.parse(json['submittedAt']),
      reportRating: json['reportRating']?.toDouble(),
    );
  }
}
