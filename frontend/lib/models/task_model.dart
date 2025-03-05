class Task {
  final String? id; // Ensure the id field is included
  final String title;
  final String companyId; // Added companyId field
  final String description;
  final String shopName; // Added shopName field
  final double incentive;
  final DateTime deadline;
  final String status;
  final double latitude; // Added latitude field
  final double longitude; // Updated longitude to be required
  final Map<String, double> selectedWorker; // Added selectedWorker
  final Map<String, double> acceptedWorker; // Added acceptedWorker
  final Map<String, double> rejectedWorker; // Added rejectedWorker

  Task({
    this.id, // Include the id field
    required this.title,
    required this.companyId, // Added companyId
    required this.description,
    required this.shopName, // Added shopName
    required this.incentive,
    required this.deadline,
    required this.status,
    required this.latitude, // Added latitude
    required this.longitude, // Updated longitude to be required
    this.selectedWorker = const {}, // Default to empty map
    this.acceptedWorker = const {}, // Default to empty map
    this.rejectedWorker = const {}, // Default to empty map
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include the id in the JSON
      'title': title,
      'company_id': companyId, // Added companyId
      'description': description,
      'shop_name': shopName, // Added shopName
      'incentive': incentive,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'latitude': latitude, // Added latitude
      'longitude': longitude, // Added longitude
      'selectedWorker': selectedWorker, // Added selectedWorker
      'acceptedWorker': acceptedWorker, // Added acceptedWorker
      'rejectedWorker': rejectedWorker, // Added rejectedWorker
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? json['id'], // Handle both '_id' and 'id'
      title: json['title'] ?? '',
      companyId: json['company_id'] ?? '', // Added companyId
      description: json['description'] ?? '',
      shopName: json['shop_name'] ?? '', // Added shopName
      incentive: (json['incentive'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0, // Added latitude
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0, // Updated longitude to be required
      selectedWorker: Map<String, double>.from(json['selectedWorker'] ?? {}), // Added selectedWorker
      acceptedWorker: Map<String, double>.from(json['acceptedWorker'] ?? {}), // Added acceptedWorker
      rejectedWorker: Map<String, double>.from(json['rejectedWorker'] ?? {}), // Added rejectedWorker
    );
  }
}