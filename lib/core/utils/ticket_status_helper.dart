import 'package:flutter/material.dart';
import '../services/language_service.dart';

/// Standardisasi status / mark tiket parkir ParkSmart:
/// 1. Belum Dibayar: tiket/booking dibuat tetapi pembayaran belum selesai
/// 2. Ready: sudah bayar namun belum dipakai / belum tap-in di gerbang masuk
/// 3. Aktif: sudah dipakai / start timer / sedang berada dalam area parkir
/// 4. Selesai: sudah checkout selesai / sesi parkir rampung
class TicketMark {
  static const String belumDibayar = 'Belum Dibayar';
  static const String ready = 'Ready';
  static const String aktif = 'Aktif';
  static const String selesai = 'Selesai';
  static const String dibatalkan = 'Dibatalkan';

  static const List<String> allMarks = [
    belumDibayar,
    ready,
    aktif,
    selesai,
  ];

  /// Nama status yang diterjemahkan di sisi antarmuka user
  static String localized(String mark) {
    return mark.tr;
  }

  /// Menentukan status tiket secara terpusat dari status pembayaran, booking, sesi, dan waktu
  static String resolve({
    String? paymentStatus,
    String? bookingStatus,
    String? sessionStatus,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? checkOutTime,
    DateTime? expectedCheckOutTime,
  }) {
    final bStatus = (bookingStatus ?? '').trim().toLowerCase();
    final pStatus = (paymentStatus ?? '').trim().toLowerCase();
    final sStatus = (sessionStatus ?? '').trim().toLowerCase();
    final now = DateTime.now();

    // 1. Selesai: jika sudah checkout selesai, check_out_time ada
    if (checkOutTime != null || sStatus == 'completed' || bStatus == 'completed') {
      return selesai;
    }

    // 2. Dibatalkan: jika dibatalkan oleh pengguna / admin
    if (bStatus == 'cancelled') {
      return dibatalkan;
    }

    // 3. Sesi aktif di gerbang atau reservasi aktif yang sudah check-in
    // Wajib diprioritaskan agar sesi yang sedang berjalan tidak salah dianggap unpaid/belum dibayar
    if (sStatus == 'active' || sStatus == 'overstay' || bStatus == 'active') {
      return aktif;
    }

    // 4. Waktu habis (selesai otomatis karena waktu telah berakhir untuk reservasi yang tidak aktif)
    if (expectedCheckOutTime != null && now.isAfter(expectedCheckOutTime)) {
      return selesai;
    }
    if (endTime != null && now.isAfter(endTime)) {
      return selesai;
    }

    // 5. Belum Dibayar: jika pembayaran belum selesai
    if (pStatus == 'unpaid' || pStatus == 'pending' || pStatus == 'belum dibayar') {
      return belumDibayar;
    }

    // 6. Sudah dibayar: tiket berstatus Ready untuk check-in.
    if (pStatus == 'paid' || pStatus == 'dibayar' || pStatus == 'success' || pStatus == 'berhasil') {
      return ready;
    }

    if (pStatus.isEmpty) {
      return belumDibayar;
    }

    return belumDibayar;
  }

  /// Warna aksen utama (teks & icon)
  static Color getColor(String mark) {
    switch (mark) {
      case ready:
        return const Color(0xFF114177); // Indigo / Navy
      case aktif:
        return const Color(0xFF17A18A); // Emerald / Teal
      case selesai:
        return const Color(0xFF76777B); // Slate Grey
      case belumDibayar:
        return const Color(0xFFD97706); // Amber Warm
      case dibatalkan:
        return const Color(0xFFD94B4B); // Crimson Red
      default:
        return const Color(0xFF76777B);
    }
  }

  /// Warna latar belakang badge (light & dark mode support)
  static Color getBgColor(String mark, {bool isDark = false}) {
    switch (mark) {
      case ready:
        return isDark
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
            : const Color(0xFFE3EEFF);
      case aktif:
        return isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
            : const Color(0xFFD1F2EB);
      case selesai:
        return isDark
            ? const Color(0xFF374151).withValues(alpha: 0.35)
            : const Color(0xFFF3F4F6);
      case belumDibayar:
        return isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.35)
            : const Color(0xFFFEF3C7);
      case dibatalkan:
        return isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
            : const Color(0xFFFDE8E4);
      default:
        return isDark
            ? const Color(0xFF374151).withValues(alpha: 0.35)
            : const Color(0xFFF3F4F6);
    }
  }

  /// Warna border badge
  static Color getBorderColor(String mark, {bool isDark = false}) {
    switch (mark) {
      case ready:
        return isDark
            ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
            : const Color(0xFFBFDBFE);
      case aktif:
        return isDark
            ? const Color(0xFF10B981).withValues(alpha: 0.4)
            : const Color(0xFFA7F3D0);
      case selesai:
        return isDark
            ? const Color(0xFF9CA3AF).withValues(alpha: 0.4)
            : const Color(0xFFE5E7EB);
      case belumDibayar:
        return isDark
            ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
            : const Color(0xFFFDE68A);
      case dibatalkan:
        return isDark
            ? const Color(0xFFEF4444).withValues(alpha: 0.4)
            : const Color(0xFFFECACA);
      default:
        return isDark
            ? const Color(0xFF9CA3AF).withValues(alpha: 0.4)
            : const Color(0xFFE5E7EB);
    }
  }

  /// Icon representatif untuk setiap mark
  static IconData getIcon(String mark) {
    switch (mark) {
      case ready:
        return Icons.confirmation_number_outlined;
      case aktif:
        return Icons.timer_outlined;
      case selesai:
        return Icons.check_circle_outline;
      case belumDibayar:
        return Icons.payment_outlined;
      case dibatalkan:
        return Icons.cancel_outlined;
      default:
        return Icons.local_parking;
    }
  }
}
