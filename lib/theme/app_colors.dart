import 'package:flutter/material.dart';
import '../core/services/theme_service.dart';

/// Design tokens dynamically adapting to ThemeService.
/// Light mode: #F6F3EC background, #FAF7F2 surface, #1C1D1F text
/// Dark mode: #111418 background, #181C22 surface, #F8FAFC text
class AppColors {
  // Surfaces
  static Color get background => ThemeService.instance.isDarkMode 
      ? const Color(0xFF111418) 
      : const Color(0xFFF6F3EC);
  static Color get surface => ThemeService.instance.isDarkMode 
      ? const Color(0xFF181C22) 
      : const Color(0xFFFAF7F2);
  static Color get surfaceCard => ThemeService.instance.isDarkMode 
      ? const Color(0xFF1E232B) 
      : const Color(0xFFFFFFFF);
  static Color get surfaceDim => ThemeService.instance.isDarkMode 
      ? const Color(0xFF262C36) 
      : const Color(0xFFEFECE5);
  static Color get surfaceField => ThemeService.instance.isDarkMode 
      ? const Color(0xFF262C36) 
      : const Color(0xFFF3EFE7);

  // Text
  static Color get textPrimary => ThemeService.instance.isDarkMode 
      ? const Color(0xFFF8FAFC) 
      : const Color(0xFF1C1D1F);
  static Color get textSecondary => ThemeService.instance.isDarkMode 
      ? const Color(0xFF94A3B8) 
      : const Color(0xFF7A7874);
  static Color get textMuted => ThemeService.instance.isDarkMode 
      ? const Color(0xFF64748B) 
      : const Color(0xFFA29F98);

  // Brand
  static const Color primary = Color(0xFF1C1D1F);
  static const Color secondary = Color(0xFFE07A5F);
  static Color get secondarySoft => ThemeService.instance.isDarkMode 
      ? const Color(0xFF3B2720) 
      : const Color(0xFFFDECE7);
  static const Color accentTeal = Color(0xFF2A9D8F);
  static Color get accentTealSoft => ThemeService.instance.isDarkMode 
      ? const Color(0xFF193834) 
      : const Color(0xFFE3F4F1);

  // Borders
  static Color get warmBorder => ThemeService.instance.isDarkMode 
      ? const Color(0xFF2D3542) 
      : const Color(0xFFEAE5DB);
  static const Color warmTerracotta = Color(0xFF9A442D);

  // Navigation
  static Color get dockBg => ThemeService.instance.isDarkMode 
      ? const Color(0xFF181C22) 
      : const Color(0xFF1C1D1F);

  // Status
  static const Color statusAvailable = Color(0xFF2A9D8F);
  static const Color statusOccupied = Color(0xFFD94B4B);
  static const Color statusWarning = Color(0xFFE07A5F);

  static const Color white = Color(0xFFFFFFFF);
}
