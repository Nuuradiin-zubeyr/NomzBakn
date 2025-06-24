import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> initialize() async {
    await _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }
  
  Future<void> toggleTheme() async {
    try {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
    }
  }
} 