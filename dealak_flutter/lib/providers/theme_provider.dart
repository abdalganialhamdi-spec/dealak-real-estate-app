import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('theme_mode');
    if (savedIndex != null) {
      state = ThemeMode.values[savedIndex];
    }
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final next = ThemeMode.values[(state.index + 1) % 3];
    state = next;
    await prefs.setInt('theme_mode', next.index);
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setInt('theme_mode', mode.index);
  }
}
