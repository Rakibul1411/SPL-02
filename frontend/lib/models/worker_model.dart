class Worker {
  final String id;
  final String name;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String? role;
  final bool? isVerified;

  Worker({
    required this.id,
    required this.name,
    this.email,
    this.latitude,
    this.longitude,
    this.role,
    this.isVerified,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      role: json['role'],
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'role': role,
      'isVerified': isVerified,
    };
  }
}