import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFCF9F2),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFF1EEE7),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1C1C18),
        secondary: Color(0xFFC05621),
        tertiary: Color(0xFF2A9D8F),
        surface: Colors.white,
        error: Color(0xFFD94B4B),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1C1C18),
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1C1C18),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Color(0xFF76777B)),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Color(0xFF76777B)),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Color(0xFF114177)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE4DFD5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE4DFD5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF114177), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFD94B4B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFD94B4B), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE4DFD5)),
        ),
      ),
            timePickerTheme: TimePickerThemeData(
        backgroundColor: const Color(0xFF1E232B),
        dialBackgroundColor: const Color(0xFF262C36),
        dialHandColor: const Color(0xFF2DD4BF),
        dialTextColor: Colors.white,
        hourMinuteColor: const Color(0xFF262C36),
        hourMinuteTextColor: Colors.white,
        dayPeriodColor: const Color(0xFF262C36),
        dayPeriodTextColor: Colors.white,
        entryModeIconColor: Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C1C18),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  static ThemeData get dark {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111418),
        cardColor: const Color(0xFF1E232B),
        dividerColor: const Color(0xFF252B35),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF8FAFC),
          secondary: Color(0xFFE07A5F),
          tertiary: Color(0xFF2A9D8F),
          surface: Color(0xFF1E232B),
          error: Color(0xFFD94B4B),
          onPrimary: Color(0xFF111418),
          onSecondary: Colors.white,
          onSurface: Color(0xFFF8FAFC),
        ),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFF8FAFC),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E232B),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Color(0xFF94A3B8)),
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Color(0xFF64748B)),
          floatingLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Color(0xFFE07A5F)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE07A5F), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD94B4B)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD94B4B), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF334155)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF333C4A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
