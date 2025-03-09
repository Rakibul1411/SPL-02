import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leaderboard_model.dart';
import '../../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  final String userEmail;

  const LeaderboardScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Debug info
    print('Building LeaderboardScreen with email: $userEmail');

    final leaderboardAsyncValue = ref.watch(leaderboardProvider(userEmail));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the leaderboard data
              ref.refresh(leaderboardProvider(userEmail));
            },
          ),
        ],
      ),
      body: leaderboardAsyncValue.when(
        data: (leaderboardData) {
          if (leaderboardData.topUsers.isEmpty) {
            return const Center(
              child: Text('No leaderboard data available'),
            );
          }

          final topUsers = leaderboardData.topUsers;
          final currentUser = leaderboardData.currentUser;
          final userRank = leaderboardData.userRank;

          return ListView(
            children: [
              if (currentUser != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Position: $userRank',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Name: ${currentUser.name}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Rating: ${currentUser.avgRating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Total Tasks: ${currentUser.totalTasks}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Total Amount: \$${currentUser.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Latitude: ${currentUser.latitude}, Longitude: ${currentUser.longitude}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Top 5 Gig Workers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topUsers.length,
                itemBuilder: (context, index) {
                  final user = topUsers[index];
                  final bool isCurrentUser = user.email == userEmail;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    color: isCurrentUser ? Colors.blue.shade50 : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRankColor(index),
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        'Rating: ${user.avgRating.toStringAsFixed(1)} | Tasks: ${user.totalTasks}',
                      ),
                      trailing: Text(
                        '\$${user.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading leaderboard data...')
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: $error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(leaderboardProvider(userEmail)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold for #1
      case 1:
        return Colors.blueGrey; // Silver for #2
      case 2:
        return Colors.brown; // Bronze for #3
      default:
        return Colors.blue; // Default for others
    }
  }
}