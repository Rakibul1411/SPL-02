// lib/screens/incentive_and_rating_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incentive_and_rating_provider.dart';
import '../models/incentive_and_rating_table.dart';

class IncentiveAndRatingScreen extends ConsumerWidget {
  final String workerId;

  IncentiveAndRatingScreen({required this.workerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incentives = ref.watch(incentiveProvider);
    final ratings = ref.watch(ratingProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Incentives & Ratings")),
      body: Column(
        children: [
          // Incentives Section
          Expanded(
            child: incentives.isEmpty
                ? Center(child: Text("No incentives earned yet."))
                : ListView.builder(
              itemCount: incentives.length,
              itemBuilder: (context, index) {
                final incentive = incentives[index];
                return ListTile(
                  title: Text("Task: ${incentive.taskId}"),
                  subtitle: Text("Earned: \$${incentive.amount.toStringAsFixed(2)}"),
                  trailing: Text("${incentive.issuedAt.toLocal()}"),
                );
              },
            ),
          ),
          Divider(),

          // Ratings Section
          Expanded(
            child: ratings.isEmpty
                ? Center(child: Text("No ratings yet."))
                : ListView.builder(
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return ListTile(
                  title: Text("Task: ${rating.taskId}"),
                  subtitle: Text("Rating: ${rating.rating}/5"),
                  trailing: Text("Feedback: ${rating.feedback}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
