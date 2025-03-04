import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';

class UpdateProfileScreen extends ConsumerWidget {
  const UpdateProfileScreen({super.key, required String userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProvider = ref.watch(ProfileProvider as ProviderListenable);

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
              onChanged: (value) {
                profileProvider.updateName(value);
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              onChanged: (value) {
                profileProvider.updateEmail(value);
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save profile changes
                profileProvider.saveProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated successfully!')),
                );
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}