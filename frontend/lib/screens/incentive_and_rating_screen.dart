import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incentive_and_rating_provider.dart';
import '../models/incentive_and_rating_table.dart';

class IncentiveAndRatingScreen extends ConsumerStatefulWidget {
  const IncentiveAndRatingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IncentiveAndRatingScreen> createState() => _IncentiveAndRatingScreenState();
}

class _IncentiveAndRatingScreenState extends ConsumerState<IncentiveAndRatingScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch all incentives & ratings when screen loads
    Future(() async {
      try {
        await ref.read(incentiveAndRatingProvider.notifier).fetchAllData();
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load data: ${e.toString()}";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final incentivesAndRatings = ref.watch(incentiveAndRatingProvider);

    // Handle loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("All Incentives & Ratings")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Handle error state
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("All Incentives & Ratings")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  try {
                    await ref.read(incentiveAndRatingProvider.notifier).fetchAllData();
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _errorMessage = "Failed to load data: ${e.toString()}";
                      });
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Separate incentives and ratings from the combined list
    final incentives = incentivesAndRatings.where((entry) => entry.amount > 0).toList();
    final ratings = incentivesAndRatings.where((entry) => entry.rating > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("All Incentives & Ratings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: incentivesAndRatings.isEmpty
            ? const Center(child: Text("No data available."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Incentives",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            incentives.isEmpty
                ? const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text("No incentives earned yet."),
            )
                : Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: incentives.length,
                itemBuilder: (context, index) {
                  final incentive = incentives[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text("Task: ${incentive.taskId.title}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Worker: ${incentive.workerId.name}"),
                          Text("Earned: \$${incentive.amount.toStringAsFixed(2)}"),
                        ],
                      ),
                      trailing: Text("${incentive.issuedAt.toLocal().toString().split('.')[0]}"),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Ratings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ratings.isEmpty
                ? const Text("No ratings yet.")
                : Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: ratings.length,
                itemBuilder: (context, index) {
                  final rating = ratings[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text("Task: ${rating.taskId.title}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Worker: ${rating.workerId.name}"),
                          Text("Rating: ${rating.rating}/5"),
                          if (rating.feedback.isNotEmpty)
                            Text("Feedback: ${rating.feedback}"),
                          if (rating.ratedBy != null)
                            Text("Rated by: ${rating.ratedBy!.name}"),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}