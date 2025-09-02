import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light); //Default Light Mode

  static const String _themeKeyPrefix = 'user_theme_';

  /// Load theme for specific user
  Future<void> loadThemeForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString('$_themeKeyPrefix$userId');

    if (themeValue == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  /// Toggle and save theme for specific user

  Future<void> toggleTheme(bool isDark, String userId) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_themeKeyPrefix$userId', isDark ? 'dark' : 'light');
  }

  void clear() {
    state = ThemeMode.light;
  }
}
