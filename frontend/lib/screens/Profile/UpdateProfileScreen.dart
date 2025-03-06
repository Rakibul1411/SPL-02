import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart'; // Correct import path

class UpdateProfileScreen extends ConsumerWidget {
  final String userEmail;

  const UpdateProfileScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the profile provider to get the profile state
    final profileState = ref.watch(profileProvider);

    // Initialize controllers with current profile data
    final nameController = TextEditingController(text: profileState.name);
    final emailController = TextEditingController(text: profileState.email);
    final latitudeController = TextEditingController(text: profileState.latitude?.toString());
    final longitudeController = TextEditingController(text: profileState.longitude?.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
              onChanged: (value) {
                ref.read(profileProvider.notifier).updateName(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              onChanged: (value) {
                ref.read(profileProvider.notifier).updateEmail(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latitudeController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'Enter your latitude',
              ),
              onChanged: (value) {
                ref.read(profileProvider.notifier).updateLatitude(double.tryParse(value) ?? 0.0);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: longitudeController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'Enter your longitude',
              ),
              onChanged: (value) {
                ref.read(profileProvider.notifier).updateLongitude(double.tryParse(value) ?? 0.0);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(profileProvider.notifier).saveProfile(userEmail);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $error')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
