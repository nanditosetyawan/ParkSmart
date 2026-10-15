import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();
  ThemeService._internal();

  static const String _prefsKey = 'is_dark_mode';

  // Default false (Light Mode) when first installed
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Background colors
  Color get bg => _isDarkMode ? const Color(0xFF111418) : const Color(0xFFFCF9F2);
  Color get bgSecondary => _isDarkMode ? const Color(0xFF181C22) : const Color(0xFFFAF7F2);

  // Card / Surface colors
  Color get card => _isDarkMode ? const Color(0xFF1E232B) : Colors.white;
  Color get cardAlt => _isDarkMode ? const Color(0xFF262C36) : const Color(0xFFF9F7F2);
  Color get surfaceField => _isDarkMode ? const Color(0xFF262C36) : const Color(0xFFF1EEE7);

  // Text colors
  Color get textPrimary => _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1C1C18);
  Color get textSecondary => _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF62615B);
  Color get textMuted => _isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9E9B90);

  // Borders & Dividers
  Color get border => _isDarkMode ? const Color(0xFF2D3542) : const Color(0xFFEBE6DC);
  Color get divider => _isDarkMode ? const Color(0xFF252B35) : const Color(0xFFF1EEE7);

  // Buttons & Badges
  Color get buttonPrimary => _isDarkMode ? const Color(0xFF333C4A) : const Color(0xFF1C1C18);
  Color get buttonPrimaryText => Colors.white;
  Color get chipBg => _isDarkMode ? const Color(0xFF2B3340) : const Color(0xFFF1EEE7);
  Color get iconContainer => _isDarkMode ? const Color(0xFF2B3340) : const Color(0xFFF5F1E8);
  Color get iconColor => _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1C1C18);

  // Accent
  Color get accent => const Color(0xFFC05621);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to false (Light Mode) when first installed
    _isDarkMode = prefs.getBool(_prefsKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  Future<void> toggleTheme() async {
    await setDarkMode(!_isDarkMode);
  }
}
