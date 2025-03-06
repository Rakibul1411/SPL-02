class User {
  final String name;
  final String email;
  final String password;
  final String role;
  final bool isVerified;
  final double latitude;
  final double longitude;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.isVerified,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      isVerified: json['isVerified'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}