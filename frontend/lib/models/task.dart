class Task {
  // final String id;
  final String title;
  final String description;
  final String location;
  final double incentive;
  final DateTime deadline;
  final String status;

  Task({
    // required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.incentive,
    required this.deadline,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'title': title,
      'description': description,
      'location': location,
      'incentive': incentive,
      'deadline': deadline.toIso8601String(),
      'status': status,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      // id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      incentive: json['incentive'],
      deadline: DateTime.parse(json['deadline']),
      status: json['status'],
    );
  }
}
