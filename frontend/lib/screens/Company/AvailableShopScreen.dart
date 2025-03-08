import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

class AvailableShopScreen extends ConsumerStatefulWidget {
  final String userEmail;

  const AvailableShopScreen({super.key, required this.userEmail});

  @override
  _AvailableShopScreenState createState() => _AvailableShopScreenState();
}

class _AvailableShopScreenState extends ConsumerState<AvailableShopScreen> {
  // Define a consistent color theme
  final Color _primaryColor = const Color(0xFF2563EB); // Blue 600
  final Color _secondaryColor = const Color(0xFF7C3AED); // Purple 600
  final Color _accentColor = const Color(0xFF14B8A6); // Teal 500
  final Color _bgColor = const Color(0xFFF9FAFB); // Gray 50
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF1F2937); // Gray 800
  final Color _subtextColor = const Color(0xFF6B7280); // Gray 500

  @override
  void initState() {
    super.initState();
    // Fetch shops when the screen is initialized
    ref.read(profileProvider.notifier).fetchShops();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Shops'),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      backgroundColor: _bgColor,
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.errorMessage != null && profileState.errorMessage!.isNotEmpty
          ? Center(child: Text(profileState.errorMessage!))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: profileState.shops.length,
        itemBuilder: (context, index) {
          final shop = profileState.shops[index];
          return Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Name
                  Text(
                    shop['name'] ?? 'No Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Shop Email
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: _subtextColor),
                      const SizedBox(width: 8),
                      Text(
                        shop['email'] ?? 'No Email',
                        style: TextStyle(
                          color: _subtextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Shop Location (Latitude and Longitude)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: _subtextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude: ${shop['latitude'] ?? 'No Latitude'}',
                              style: TextStyle(
                                color: _subtextColor,
                              ),
                            ),
                            Text(
                              'Longitude: ${shop['longitude'] ?? 'No Longitude'}',
                              style: TextStyle(
                                color: _subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}