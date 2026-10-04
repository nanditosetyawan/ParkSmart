import 'package:flutter/material.dart';

/// Shadows verified from Stitch.
class AppShadows {
  // soft: 0 8px 30px rgba(0,0,0,0.04) — cards
  static const BoxShadow soft = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 8),
    blurRadius: 30,
  );

  // float: 0 14px 40px rgba(28,29,31,0.08) — floating elements
  static const BoxShadow float = BoxShadow(
    color: Color(0x141C1D1F),
    offset: Offset(0, 14),
    blurRadius: 40,
  );

  // dock: 0 20px 40px rgba(20,20,22,0.28) — dark navigation dock
  static const BoxShadow dock = BoxShadow(
    color: Color(0x47141416),
    offset: Offset(0, 20),
    blurRadius: 40,
  );

  // login field: 0 2px 12px rgba(28,29,31,0.03)
  static const BoxShadow field = BoxShadow(
    color: Color(0x071C1D1F),
    offset: Offset(0, 2),
    blurRadius: 12,
  );

  // login submit: 0 10px 24px rgba(28,29,31,0.18)
  static const BoxShadow cta = BoxShadow(
    color: Color(0x2E1C1D1F),
    offset: Offset(0, 10),
    blurRadius: 24,
  );
}
