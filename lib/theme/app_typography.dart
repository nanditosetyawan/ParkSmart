import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Plus Jakarta Sans — verified from Stitch HTML font-family config.
class AppTypography {
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color ?? AppColors.textPrimary,
      );

  // === Display / Headings ===
  // From login: text-[34px] font-extrabold tracking-[-0.035em]
  static TextStyle displayHero({Color? color}) => _base(
        size: 34, weight: FontWeight.w800,
        height: 38 / 34, letterSpacing: 34 * -0.035, color: color,
      );

  // From home h1: text-[34px] font-extrabold tracking-[-0.03em] leading-[1.1]
  static TextStyle displayLg({Color? color}) => _base(
        size: 34, weight: FontWeight.w800,
        height: 1.1, letterSpacing: 34 * -0.03, color: color,
      );

  // From home h2: text-[20px] font-bold tracking-tight
  static TextStyle headlineMd({Color? color}) => _base(
        size: 20, weight: FontWeight.w700,
        letterSpacing: -0.3, color: color,
      );

  // h3: text-[18px] font-bold
  static TextStyle headlineSm({Color? color}) => _base(
        size: 18, weight: FontWeight.w700, color: color,
      );

  // title-md: text-[15px] font-bold
  static TextStyle titleMd({Color? color}) => _base(
        size: 15, weight: FontWeight.w700, color: color,
      );

  // Logo name: text-[17px] font-bold tracking-tight
  static TextStyle logoTitle({Color? color}) => _base(
        size: 17, weight: FontWeight.w700,
        letterSpacing: -0.3, color: color,
      );

  // Body / Labels
  // text-[15px] font-medium — inputs, body
  static TextStyle bodyMd({Color? color}) => _base(
        size: 15, weight: FontWeight.w500, color: color,
      );

  // text-[14px] font-medium
  static TextStyle bodySm({Color? color}) => _base(
        size: 14, weight: FontWeight.w500, color: color,
      );

  // text-[13px] font-semibold — labels above inputs
  static TextStyle labelMd({Color? color}) => _base(
        size: 13, weight: FontWeight.w600,
        letterSpacing: 0.2, color: color,
      );

  // text-[13px] font-medium — tags
  static TextStyle labelSm({Color? color}) => _base(
        size: 13, weight: FontWeight.w500, color: color,
      );

  // text-[12px] font-medium — muted label
  static TextStyle caption({Color? color}) => _base(
        size: 12, weight: FontWeight.w500, color: color,
      );

  // text-[11px] uppercase tracking-wider
  static TextStyle overline({Color? color}) => _base(
        size: 11, weight: FontWeight.w600,
        letterSpacing: 11 * 0.08, color: color,
      );

  // Button: text-[16px] font-semibold
  static TextStyle buttonLg({Color? color}) => _base(
        size: 16, weight: FontWeight.w600,
        letterSpacing: -0.2, color: color,
      );

  // text-[13px] font-bold small button
  static TextStyle buttonSm({Color? color}) => _base(
        size: 13, weight: FontWeight.w700,
        letterSpacing: -0.1, color: color,
      );

  // Metric mono: text-[22px] font-extrabold font-mono
  static TextStyle monoLg({Color? color}) => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ).copyWith(color: color ?? AppColors.textPrimary);

  // Metric: text-[17px] font-bold
  static TextStyle metricMd({Color? color}) => _base(
        size: 17, weight: FontWeight.w700, color: color,
      );
}
