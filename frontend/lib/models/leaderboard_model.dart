class Leaderboard {
  final String userId;
  final String name;
  final String email;
  final double avgRating;
  final double totalAmount;
  final int totalTasks;
  final double latitude;
  final double longitude;

  Leaderboard({
    required this.userId,
    required this.name,
    required this.email,
    required this.avgRating,
    required this.totalAmount,
    required this.totalTasks,
    required this.latitude,
    required this.longitude,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      avgRating: json['avgRating'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      totalTasks: json['totalTasks'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class LeaderboardData {
  final List<Leaderboard> topUsers;
  final Leaderboard? currentUser;
  final int userRank;

  LeaderboardData({
    required this.topUsers,
    this.currentUser,
    required this.userRank,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      topUsers: (json['topUsers'] as List)
          .map((user) => Leaderboard.fromJson(user))
          .toList(),
      currentUser: json['currentUser'] != null
          ? Leaderboard.fromJson(json['currentUser'])
          : null,
      userRank: json['userRank'],
    );
  }
}