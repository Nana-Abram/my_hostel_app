import 'package:flutter_riverpod/legacy.dart';

// Theme modes
enum AppTheme { light, dark }

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.light);

  void toggleTheme() {
    state = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
  }

  void setTheme(AppTheme theme) {
    state = theme;
  }

  bool get isDarkMode => state == AppTheme.dark;
}