import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../game/backend/game_user_helper.dart';

/// Service penyedia konteks data database real-time untuk AI Assistant (Jarvis)
/// Mengambil data lokasi parkir, ketersediaan slot, jam buka, ulasan pengunjung,
/// serta riwayat pesanan (unpaid/active/completed) pengguna yang sedang login.
class AiContextService {
  AiContextService._();
  static final AiContextService instance = AiContextService._();

  SupabaseClient get _client => Supabase.instance.client;

  // Cache lokal dalam memori saat percakapan berlangsung
  List<Map<String, dynamic>> _cachedLocations = [];
  final Map<String, List<Map<String, dynamic>>> _cachedReviewsByLoc = {};
  List<Map<String, dynamic>> _cachedUserBookings = [];

  List<Map<String, dynamic>> get cachedLocations => _cachedLocations;
  List<Map<String, dynamic>> get cachedUserBookings => _cachedUserBookings;

  Map<String, dynamic>? getLocationById(String id) {
    try {
      final query = id.trim().toLowerCase();
      return _cachedLocations.firstWhere(
        (loc) =>
            loc['id']?.toString().toLowerCase() == query ||
            loc['code']?.toString().toLowerCase() == query ||
            loc['name']?.toString().toLowerCase() == query,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? getBookingById(String id) {
    try {
      final query = id.trim().toLowerCase();
      return _cachedUserBookings.firstWhere(
        (b) =>
            b['id']?.toString().toLowerCase() == query ||
            b['booking_code']?.toString().toLowerCase() == query,
      );
    } catch (_) {
      return null;
    }
  }

  /// Memuat data lengkap dari Supabase untuk disuntikkan ke dalam prompt AI
  Future<String> buildRealTimeContextPrompt() async {
    final buffer = StringBuffer();

    try {
      // 1. Ambil seluruh lokasi parkir aktif dari database
      final locationsRes = await _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, latitude, longitude, total_capacity, car_slots_capacity, motor_slots_capacity, ev_slots_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, operating_hours, facilities, rating, review_count, status, image_url')
          .order('name');

      final List<Map<String, dynamic>> rawLocations = List<Map<String, dynamic>>.from(locationsRes);

      // 2. Ambil data slot untuk menghitung ketersediaan riil
      final slotsRes = await _client.from('parking_slots').select('id, location_id, status');
      final Map<String, int> availableSlotsMap = {};
      final Map<String, int> totalSlotsMap = {};

      for (final s in (slotsRes as List)) {
        final locId = s['location_id']?.toString() ?? '';
        totalSlotsMap[locId] = (totalSlotsMap[locId] ?? 0) + 1;
        if (s['status'] == 'available') {
          availableSlotsMap[locId] = (availableSlotsMap[locId] ?? 0) + 1;
        }
      }

      // 3. Ambil data ulasan pengunjung dari customer_feedbacks
      final feedbacksRes = await _client
          .from('customer_feedbacks')
          .select('location_id, rating, comment, created_at')
          .order('created_at', ascending: false)
          .limit(30);

      _cachedReviewsByLoc.clear();
      for (final f in (feedbacksRes as List)) {
        final locId = f['location_id']?.toString() ?? '';
        if (locId.isNotEmpty) {
          _cachedReviewsByLoc.putIfAbsent(locId, () => []).add(Map<String, dynamic>.from(f));
        }
      }

      // Gabungkan data lokasi dengan ketersediaan & ulasan
      _cachedLocations = rawLocations.map((loc) {
        final locId = loc['id'].toString();
        final totalCap = (loc['total_capacity'] as num?)?.toInt() ?? 50;
        final actualAvail = availableSlotsMap.containsKey(locId)
            ? availableSlotsMap[locId]!
            : totalCap;

        return {
          ...loc,
          'available_slots': actualAvail,
          'reviews': _cachedReviewsByLoc[locId] ?? [],
        };
      }).toList();

      // Bangun teks ringkasan lokasi parkir untuk AI
      buffer.writeln('=== DATA DATABASE LOKASI PARKIR RESMI (REAL-TIME UPDATE DARI SUPABASE) ===');
      for (final loc in _cachedLocations) {
        final locId = loc['id'];
        final name = loc['name'];
        final city = loc['city'] ?? 'Jakarta';
        final address = loc['address'] ?? '';
        final opHours = loc['operating_hours'] ?? 'Buka 24 Jam';
        final rateMobil = loc['hourly_rate_mobil'] ?? 5000;
        final rateMotor = loc['hourly_rate_motor'] ?? 2000;
        final avail = loc['available_slots'];
        final total = loc['total_capacity'] ?? 50;
        final rating = loc['rating'] ?? 0.0;
        final status = loc['status'] ?? 'active';
        final facilities = (loc['facilities'] as List?)?.join(', ') ?? 'CCTV 24 Jam, Parkir Luas';

        final reviews = loc['reviews'] as List<Map<String, dynamic>>? ?? [];
        String reviewSummary = 'Belum ada ulasan pengguna.';
        if (reviews.isNotEmpty) {
          final reviewTexts = reviews.take(2).map((r) => '"${r['comment']}" (Rating: ${r['rating']}/5)').join('; ');
          reviewSummary = reviewTexts;
        }

        buffer.writeln(
          '- ID Lokasi: $locId | Nama: $name ($city) | Status: $status | Jam Operasional: $opHours | Tersedia: $avail/$total slot | Tarif Mobil: Rp $rateMobil/jam, Motor: Rp $rateMotor/jam | Rating: $rating/5 | Fasilitas: $facilities | Alamat: $address | Ringkasan Ulasan Pengunjung: $reviewSummary',
        );
      }
      buffer.writeln();

      // 4. Ambil data pesanan (bookings) pengguna yang sedang login
      final uid = await GameUserHelper.resolveUserId();
      if (uid != null && uid.isNotEmpty) {
        try {
          final bookingsRes = await _client
              .from('bookings')
              .select('id, booking_code, total_price, payment_status, booking_status, start_time, end_time, plate_number, vehicle_desc, parking_locations(id, name, address, city, image_url)')
              .eq('user_id', uid)
              .order('created_at', ascending: false)
              .limit(10);

          _cachedUserBookings = List<Map<String, dynamic>>.from(bookingsRes);

          buffer.writeln('=== DATA PESANAN & TRANSAKSI PENGGUNA SAAT INI (REAL-TIME DARI DATABASE) ===');
          if (_cachedUserBookings.isEmpty) {
            buffer.writeln('- Pengguna saat ini belum memiliki pesanan atau riwayat parkir.');
          } else {
            for (final b in _cachedUserBookings) {
              final bId = b['id'];
              final code = b['booking_code'];
              final locName = b['parking_locations']?['name'] ?? 'Lokasi Parkir';
              final price = b['total_price'] ?? 0;
              final payStatus = b['payment_status'] ?? 'unpaid';
              final bkgStatus = b['booking_status'] ?? 'upcoming';
              final start = b['start_time'] ?? '-';
              final end = b['end_time'] ?? '-';
              final plate = b['plate_number'] ?? '-';

              buffer.writeln(
                '- ID Pesanan: $bId | Kode: $code | Lokasi: $locName | Plat: $plate | Status Pembayaran: $payStatus | Status Parkir: $bkgStatus | Biaya: Rp $price | Waktu: $start s/d $end',
              );
            }
          }
          buffer.writeln();
        } catch (e) {
          debugPrint('[AiContextService] Error fetching user bookings: $e');
        }
      }
    } catch (e) {
      debugPrint('[AiContextService] Error building context: $e');
    }

    return buffer.toString();
  }
}
