// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/incentive_and_rating_provider.dart';
// import '../models/incentive_and_rating_table.dart';
//
// class IncentiveAndRatingScreen extends ConsumerStatefulWidget {
//   final String workerId;
//
//   IncentiveAndRatingScreen({required this.workerId});
//
//   @override
//   ConsumerState<IncentiveAndRatingScreen> createState() => _IncentiveAndRatingScreenState();
// }
//
// class _IncentiveAndRatingScreenState extends ConsumerState<IncentiveAndRatingScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch incentives and ratings when the screen loads
//     Future(() async {
//       await ref.read(incentiveAndRatingProvider.notifier).fetchIncentives(widget.workerId);
//       await ref.read(incentiveAndRatingProvider.notifier).fetchRatings(widget.workerId);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final incentivesAndRatings = ref.watch(incentiveAndRatingProvider);
//
//     // Separate incentives and ratings from the combined list
//     final incentives = incentivesAndRatings.where((entry) => entry.amount > 0).toList();
//     final ratings = incentivesAndRatings.where((entry) => entry.rating > 0).toList();
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Incentives & Ratings")),
//       body: Column(
//         children: [
//           // Incentives Section
//           Expanded(
//             child: incentives.isEmpty
//                 ? Center(child: Text("No incentives earned yet."))
//                 : ListView.builder(
//               itemCount: incentives.length,
//               itemBuilder: (context, index) {
//                 final incentive = incentives[index];
//                 return ListTile(
//                   title: Text("Task: ${incentive.taskId}"),
//                   subtitle: Text("Earned: \$${incentive.amount.toStringAsFixed(2)}"),
//                   trailing: Text("${incentive.issuedAt.toLocal()}"),
//                 );
//               },
//             ),
//           ),
//           Divider(),
//
//           // Ratings Section
//           Expanded(
//             child: ratings.isEmpty
//                 ? Center(child: Text("No ratings yet."))
//                 : ListView.builder(
//               itemCount: ratings.length,
//               itemBuilder: (context, index) {
//                 final rating = ratings[index];
//                 return ListTile(
//                   title: Text("Task: ${rating.taskId}"),
//                   subtitle: Text("Rating: ${rating.rating}/5"),
//                   trailing: Text("Feedback: ${rating.feedback}"),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }