class Task {
  final String? id; // Ensure the id field is included
  final String title;
  final String description;
  final String location;
  final double incentive;
  final DateTime deadline;
  final String status;

  Task({
    this.id, // Include the id field
    required this.title,
    required this.description,
    required this.location,
    required this.incentive,
    required this.deadline,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include the id in the JSON
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
      id: json['_id'] ?? json['id'], // Handle both '_id' and 'id'
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      incentive: (json['incentive'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
    );
  }
}