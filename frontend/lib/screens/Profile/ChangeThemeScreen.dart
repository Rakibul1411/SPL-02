import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart'; // Assuming you have a theme provider

class ChangeThemeScreen extends ConsumerWidget {
  const ChangeThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(ThemeProvider as ProviderListenable);

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Theme'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text('Light Theme'),
              trailing: Radio(
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                },
              ),
            ),
            ListTile(
              title: Text('Dark Theme'),
              trailing: Radio(
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                },
              ),
            ),
            ListTile(
              title: Text('System Default'),
              trailing: Radio(
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}