import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the ThemeProvider class
class ThemeProvider extends StateNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.system);

  // Method to change the theme
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

// Create a provider for ThemeProvider
final themeProvider = StateNotifierProvider<ThemeProvider, ThemeMode>((ref) {
  return ThemeProvider();
});