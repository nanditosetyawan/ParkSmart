import 'package:flutter/material.dart';

/// Design tokens verified directly from Stitch HTML source.
/// Login screen config: #FAF7F2 background, #1C1D1F charcoal, #9A442D terracotta
/// Home screen config: #F6F3EC background, #E07A5F secondary (terracotta), #1C1D1F dock
class AppColors {
  // Surfaces
  static const Color background = Color(0xFFF6F3EC);    // body bg home
  static const Color surface = Color(0xFFFAF7F2);       // page bg login
  static const Color surfaceCard = Color(0xFFFFFFFF);   // card bg
  static const Color surfaceDim = Color(0xFFEFECE5);    // dim bg / filter
  static const Color surfaceField = Color(0xFFF3EFE7);  // input field bg (login)

  // Text
  static const Color textPrimary = Color(0xFF1C1D1F);   // charcoal
  static const Color textSecondary = Color(0xFF7A7874); // charcoal-muted
  static const Color textMuted = Color(0xFFA29F98);     // placeholder

  // Brand
  static const Color primary = Color(0xFF1C1D1F);       // charcoal primary (buttons)
  static const Color secondary = Color(0xFFE07A5F);     // terracotta accent
  static const Color secondarySoft = Color(0xFFFDECE7); // terracotta tint
  static const Color accentTeal = Color(0xFF2A9D8F);    // teal accent
  static const Color accentTealSoft = Color(0xFFE3F4F1); // teal soft

  // Borders
  static const Color warmBorder = Color(0xFFEAE5DB);
  static const Color warmTerracotta = Color(0xFF9A442D); // logo accent, links

  // Navigation
  static const Color dockBg = Color(0xFF1C1D1F);

  // Status
  static const Color statusAvailable = Color(0xFF2A9D8F);
  static const Color statusOccupied = Color(0xFFD94B4B);
  static const Color statusWarning = Color(0xFFE07A5F);

  static const Color white = Color(0xFFFFFFFF);
}
