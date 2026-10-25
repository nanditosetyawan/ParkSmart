import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _SessionTimestampEvent {
  final DateTime wibTime;
  _SessionTimestampEvent(this.wibTime);
}

/// Backend khusus untuk AdminOperationsDashboardScreen (admin_operations_dashboard_screen.dart)
/// Menyajikan metrik operasional lapangan, kapasitas lokasi, tingkat okupansi slot, overstay,
/// dan grafik kendaraan parkir 4 minggu per bulan berbasis data riil Supabase & Waktu Server Indonesia WIB.
class AdminOperationsDashboardBackend extends ChangeNotifier {
  AdminOperationsDashboardBackend._();
  static final AdminOperationsDashboardBackend instance = AdminOperationsDashboardBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // KPI Ringkasan
  int _totalLocationsCount = 0;
  int get totalLocationsCount => _totalLocationsCount;

  int _totalSlotsCount = 0;
  int get totalSlotsCount => _totalSlotsCount;

  int _occupiedSlotsCount = 0;
  int get occupiedSlotsCount => _occupiedSlotsCount;

  int _overstaySessionsCount = 0;
  int get overstaySessionsCount => _overstaySessionsCount;

  int _activeSessionsCount = 0;
  int get activeSessionsCount => _activeSessionsCount;

  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> get locations => _locations;

  List<Map<String, dynamic>> _cityDensityList = [];
  List<Map<String, dynamic>> get cityDensityList => _cityDensityList;

  List<Map<String, dynamic>> _liveSessions = [];
  List<Map<String, dynamic>> get liveSessions => _liveSessions;

  List<Map<String, dynamic>> _liveBookings = [];
  List<Map<String, dynamic>> get liveBookings => _liveBookings;

  final List<Map<String, dynamic>> _locationsSummary = [];
  List<Map<String, dynamic>> get locationsSummary => _locationsSummary;

  // 📈 Data Grafik Parkir 4 Minggu per Bulan (Maksimal 6 Bulan Terakhir dari Supabase)
  List<String> _availableMonths = [];
  List<String> get availableMonths => _availableMonths;

  final Map<String, Map<String, dynamic>> _monthlyChartData = {};
  Map<String, Map<String, dynamic>> get monthlyChartData => _monthlyChartData;

  /// Waktu saat ini dalam Waktu Indonesia Barat (WIB, UTC+7)
  DateTime get _nowWib => DateTime.now().toUtc().add(const Duration(hours: 7));

  DateTime _parseToWib(dynamic val) {
    if (val == null) return _nowWib;
    final dt = DateTime.tryParse(val.toString());
    if (dt == null) return _nowWib;
    return dt.toUtc().add(const Duration(hours: 7));
  }

  String _formatMonthYear(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  // Realtime Supabase Channel untuk Sinkronisasi Instan Lapangan
  RealtimeChannel? _realtimeChannel;

  /// Inisialisasi listener realtime Supabase untuk perubahan instan pada sesi, booking, dan slot
  void initRealtimeSubscription() {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = _client.channel('admin_operations_dashboard_realtime')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parking_sessions',
          callback: (payload) {
            debugPrint('[AdminOperationsDashboardBackend] Realtime parking_sessions change: ${payload.eventType}');
            fetchDashboardData();
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            debugPrint('[AdminOperationsDashboardBackend] Realtime bookings change: ${payload.eventType}');
            fetchDashboardData();
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parking_slots',
          callback: (payload) {
            fetchDashboardData();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('[AdminOperationsDashboardBackend] Realtime subscription error: $e');
    }
  }

  void disposeRealtime() {
    if (_realtimeChannel != null) {
      try {
        _client.removeChannel(_realtimeChannel!);
      } catch (_) {}
      _realtimeChannel = null;
    }
  }

  /// Evaluasi otomatis: Auto-cancel unpaid > 179s & Auto-complete paid lewat endTime
  Future<void> _cleanupExpiredAndCompletedBookings() async {
    try {
      // Jalankan stored procedure pembersihan di Supabase
      try {
        await _client.rpc('auto_process_expired_bookings_and_sessions');
      } catch (_) {}

      final nowUtc = DateTime.now().toUtc();

      // 1. Unpaid booking yang sudah lebih dari 2 menit 59 detik (179s) -> Cancel & bebaskan slot
      final unpaidBookings = await _client
          .from('bookings')
          .select('id, slot_id, created_at')
          .eq('payment_status', 'unpaid')
          .neq('booking_status', 'cancelled');

      for (final b in unpaidBookings) {
        final cat = DateTime.tryParse(b['created_at']?.toString() ?? '');
        if (cat != null) {
          final age = nowUtc.difference(cat.toUtc()).inSeconds;
          if (age > 179) {
            await _client.from('bookings').update({
              'booking_status': 'cancelled',
              'cancel_reason': 'Waktu pembayaran habis (Auto Cancel)',
            }).eq('id', b['id']);

            final slotId = b['slot_id']?.toString();
            if (slotId != null && slotId.isNotEmpty) {
              await _client.from('parking_slots').update({
                'status': 'available',
                'current_plate_number': null,
                'occupied_since': null,
              }).eq('id', slotId);
            }
          }
        }
      }

      // 2. Paid booking yang belum check-in tapi sudah lewat batas checkout (end_time) -> Otomatis Selesai & bebaskan slot
      final paidUpcomingBookings = await _client
          .from('bookings')
          .select('id, slot_id, end_time')
          .eq('payment_status', 'paid')
          .inFilter('booking_status', ['upcoming', 'confirmed']);

      for (final b in paidUpcomingBookings) {
        final end = DateTime.tryParse(b['end_time']?.toString() ?? '');
        if (end != null && nowUtc.isAfter(end.toUtc())) {
          await _client.from('bookings').update({
            'booking_status': 'completed',
          }).eq('id', b['id']);

          final slotId = b['slot_id']?.toString();
          if (slotId != null && slotId.isNotEmpty) {
            final activeSessionOnSlot = await _client
                .from('parking_sessions')
                .select('id')
                .eq('slot_id', slotId)
                .inFilter('status', ['active', 'overstay'])
                .maybeSingle();

            if (activeSessionOnSlot == null) {
              await _client.from('parking_slots').update({
                'status': 'available',
                'current_plate_number': null,
                'occupied_since': null,
              }).eq('id', slotId);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AdminOperationsDashboardBackend] _cleanup error: $e');
    }
  }

  /// Memuat metrik operasional & chart kendaraan dari Supabase
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 0. Jalankan evaluasi auto-cancel unpaid (>179s) & auto-selesai lewat checkout
      await _cleanupExpiredAndCompletedBookings();

      // 1. Lokasi & Kapasitas Real dari Database
      final locs = await _client
          .from('parking_locations')
          .select('id, code, name, city, province, address, total_capacity, car_slots_capacity, motor_slots_capacity, ev_slots_capacity, status')
          .order('name', ascending: true);

      // 1b. Slot & Okupansi Real dari Database (parking_slots, bookings, parking_sessions)
      final allSlots = await _client
          .from('parking_slots')
          .select('id, location_id, slot_type, status');

      final activeBookingsRes = await _client
          .from('bookings')
          .select('id, location_id, slot_id, booking_status, payment_status, vehicle_type')
          .inFilter('booking_status', ['upcoming', 'active'])
          .eq('payment_status', 'paid');

      final activeSessionsRes = await _client
          .from('parking_sessions')
          .select('id, location_id, slot_id, status, vehicle_type')
          .inFilter('status', ['active', 'overstay']);

      _totalLocationsCount = locs.length;
      int totalCap = 0;
      int totalOccupiedAcrossAll = 0;

      for (var l in locs) {
        totalCap += (l['total_capacity'] as num?)?.toInt() ?? 0;
      }
      _totalSlotsCount = totalCap;

      if (locs.isNotEmpty) {
        _locations = locs.map<Map<String, dynamic>>((row) {
          final locId = row['id']?.toString() ?? '';
          final total = (row['total_capacity'] as num?)?.toInt() ?? 0;

          final locSlots = allSlots.where((s) => s['location_id'] == locId).toList();
          final occupiedSlotIds = <String>{};
          int occupiedSlotsCount = 0;
          int occupiedMobil = 0;
          int occupiedMotor = 0;
          int occupiedEv = 0;

          for (final s in locSlots) {
            final st = (s['status']?.toString() ?? '').toLowerCase();
            final sType = (s['slot_type']?.toString() ?? '').toLowerCase();
            if (st == 'occupied' || st == 'terisi' || st == 'reserved' || st == 'booked' || st == 'dipesan') {
              occupiedSlotsCount++;
              occupiedSlotIds.add(s['id'].toString());
              if (sType.contains('ev')) {
                occupiedEv++;
              } else if (sType.contains('motor')) {
                occupiedMotor++;
              } else {
                occupiedMobil++;
              }
            }
          }

          int extraOccupancy = 0;
          for (final b in activeBookingsRes) {
            if (b['location_id'] == locId) {
              final sId = b['slot_id']?.toString();
              if (sId == null || !occupiedSlotIds.contains(sId)) {
                extraOccupancy++;
                final vt = (b['vehicle_type'] ?? '').toString().toLowerCase();
                if (vt.contains('ev') || vt.contains('electric')) {
                  occupiedEv++;
                } else if (vt.contains('motor') || vt.contains('bike')) {
                  occupiedMotor++;
                } else {
                  occupiedMobil++;
                }
              }
            }
          }
          for (final s in activeSessionsRes) {
            if (s['location_id'] == locId) {
              final sId = s['slot_id']?.toString();
              if (sId == null || !occupiedSlotIds.contains(sId)) {
                extraOccupancy++;
                final vt = (s['vehicle_type'] ?? '').toString().toLowerCase();
                if (vt.contains('ev') || vt.contains('electric')) {
                  occupiedEv++;
                } else if (vt.contains('motor') || vt.contains('bike')) {
                  occupiedMotor++;
                } else {
                  occupiedMobil++;
                }
              }
            }
          }

          final locOccupied = occupiedSlotsCount + extraOccupancy;
          totalOccupiedAcrossAll += locOccupied;

          final available = total > locOccupied ? total - locOccupied : 0;
          final ratio = total > 0 ? (locOccupied / total) : 0.0;

          final statusDb = row['status']?.toString().toLowerCase();
          String statusLabel = 'Normal';
          Color statusCol = const Color(0xFF17A18A);
          if (ratio >= 0.85 || statusDb == 'full') {
            statusLabel = 'Kritis';
            statusCol = const Color(0xFFD94B4B);
          } else if (ratio >= 0.60 || statusDb == 'crowded') {
            statusLabel = 'Padat';
            statusCol = const Color(0xFFE07A5F);
          }

          return {
            'id': row['code']?.toString() ?? row['id']?.toString() ?? 'LOC-000',
            'db_id': locId,
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'city': row['city']?.toString() ?? 'Kota',
            'province': row['province']?.toString() ?? '',
            'zone': row['address']?.toString() ?? 'Area Parkir',
            'total': total,
            'occupied': locOccupied,
            'available': available,
            'status': statusLabel,
            'statusColor': statusCol,
            'mobil': occupiedMobil,
            'motor': occupiedMotor,
            'ev': occupiedEv,
            'occupiedMobil': occupiedMobil,
            'occupiedMotor': occupiedMotor,
            'occupiedEv': occupiedEv,
          };
        }).toList();

        _occupiedSlotsCount = totalOccupiedAcrossAll;

        final Map<String, List<Map<String, dynamic>>> cityMap = {};
        for (var l in _locations) {
          final c = l['city'] as String;
          cityMap.putIfAbsent(c, () => []).add(l);
        }
        _cityDensityList = cityMap.entries.map((entry) {
          final cityName = entry.key;
          final locList = entry.value;
          int cityTotal = 0;
          int cityOccupied = 0;
          int cityMobil = 0;
          int cityMotor = 0;
          int cityEv = 0;
          for (var l in locList) {
            cityTotal += (l['total'] as int? ?? 0);
            cityOccupied += (l['occupied'] as int? ?? 0);
            cityMobil += (l['occupiedMobil'] as int? ?? 0);
            cityMotor += (l['occupiedMotor'] as int? ?? 0);
            cityEv += (l['occupiedEv'] as int? ?? 0);
          }
          final ratio = cityTotal > 0 ? (cityOccupied / cityTotal) : 0.0;
          String status = 'Normal';
          Color statusColor = const Color(0xFF17A18A);
          if (ratio >= 0.85) {
            status = 'Kritis';
            statusColor = const Color(0xFFD94B4B);
          } else if (ratio >= 0.60) {
            status = 'Padat';
            statusColor = const Color(0xFFE07A5F);
          }
          return {
            'city': cityName,
            'province': locList.first['province'] ?? '',
            'facilities': '${locList.length} Lokasi',
            'facilityCount': locList.length,
            'total': cityTotal,
            'occupied': cityOccupied,
            'status': status,
            'statusColor': statusColor,
            'mobil': cityMobil,
            'motor': cityMotor,
            'ev': cityEv,
          };
        }).toList();
      } else {
        _locations = [];
        _cityDensityList = [];
        _occupiedSlotsCount = 0;
      }

      // 2. Sesi Aktif & Overstay Real dari Database (Termasuk relasi lengkap & timer)
      final Set<String> activeSessionBookingIds = {};
      try {
        final activeSessions = await _client
            .from('parking_sessions')
            .select('''
              id,
              session_code,
              plate_number,
              vehicle_desc,
              vehicle_type,
              check_in_time,
              expected_check_out_time,
              parking_fee,
              total_fee,
              is_overstay,
              overstay_minutes,
              status,
              slot_id,
              location_id,
              booking_id,
              users(full_name, phone),
              parking_locations(name, address),
              parking_slots(slot_code, floor_name)
            ''')
            .inFilter('status', ['active', 'overstay'])
            .order('check_in_time', ascending: false);

        _activeSessionsCount = activeSessions.length;
        _overstaySessionsCount = activeSessions.where((s) => s['is_overstay'] == true).length;

        for (final s in activeSessions) {
          final bId = s['booking_id']?.toString();
          if (bId != null && bId.isNotEmpty) {
            activeSessionBookingIds.add(bId);
          }
        }

        if (activeSessions.isNotEmpty) {
          _liveSessions = activeSessions.map<Map<String, dynamic>>((row) {
            final isEv = (row['vehicle_type'] ?? '').toString().toLowerCase().contains('ev') ||
                         (row['vehicle_desc'] ?? '').toString().toLowerCase().contains('ev');
            final fee = (row['total_fee'] as num?)?.toDouble() ?? 
                        (row['parking_fee'] as num?)?.toDouble() ?? 10000;

            final userData = row['users'] is Map<String, dynamic> ? row['users'] as Map<String, dynamic> : null;
            final locData = row['parking_locations'] is Map<String, dynamic> ? row['parking_locations'] as Map<String, dynamic> : null;
            final slotData = row['parking_slots'] is Map<String, dynamic> ? row['parking_slots'] as Map<String, dynamic> : null;

            final userName = userData?['full_name']?.toString() ?? 'Pengguna ParkSmart';
            final userPhone = userData?['phone']?.toString() ?? '+62 812-xxxx-xxxx';
            final locName = locData?['name']?.toString() ?? 'Lokasi Parkir';
            final slotCode = slotData?['slot_code']?.toString() ?? 'Area Parkir';
            final floorName = slotData?['floor_name']?.toString() ?? 'Lantai 1';

            final checkInDt = DateTime.tryParse(row['check_in_time']?.toString() ?? '')?.toLocal();
            final expOutDt = DateTime.tryParse(row['expected_check_out_time']?.toString() ?? '')?.toLocal();

            String checkInStr = 'Baru saja';
            if (checkInDt != null) {
              checkInStr = '${checkInDt.hour.toString().padLeft(2, '0')}:${checkInDt.minute.toString().padLeft(2, '0')} WIB';
            }

            final now = DateTime.now();
            String durationStr = '1j';
            bool isOverstay = row['is_overstay'] == true;
            int overstayMins = (row['overstay_minutes'] as num?)?.toInt() ?? 0;

            if (expOutDt != null) {
              final diffSecs = expOutDt.difference(now).inSeconds;
              if (diffSecs > 0) {
                final h = diffSecs ~/ 3600;
                final m = (diffSecs % 3600) ~/ 60;
                final s = diffSecs % 60;
                if (h > 0) {
                  durationStr = 'Sisa ${h}j ${m}m ${s}d';
                } else {
                  durationStr = 'Sisa ${m}m ${s}d';
                }
                isOverstay = false;
              } else {
                isOverstay = true;
                overstayMins = (-diffSecs) ~/ 60;
                durationStr = 'Overstay $overstayMins mnt';
              }
            }

            final vType = (row['vehicle_type'] ?? '').toString().toLowerCase();

            return {
              'id': row['session_code']?.toString() ?? 'SES-000',
              'db_id': row['id']?.toString(),
              'slot_id': row['slot_id']?.toString(),
              'booking_id': row['booking_id']?.toString(),
              'plate': row['plate_number']?.toString() ?? 'B 1234 XYZ',
              'user': userName,
              'phone': userPhone,
              'type': isEv ? 'EV' : (vType.contains('motor') ? 'Motor' : 'Mobil'),
              'vehicle': row['vehicle_desc']?.toString() ?? 'Kendaraan',
              'location': locName,
              'slot': slotCode,
              'floor': floorName,
              'checkIn': checkInStr,
              'duration': durationStr,
              'raw_expected_check_out_time': expOutDt,
              'raw_check_in_time': checkInDt,
              'fee': 'Rp ${fee.toStringAsFixed(0)}',
              'isOverstay': isOverstay,
              'overstayDuration': '$overstayMins mnt',
              'isEv': isEv,
            };
          }).toList();
        } else {
          _liveSessions = [];
        }
      } catch (e) {
        debugPrint('[AdminOperationsDashboardBackend] liveSessions error: $e');
      }

      // 3. Reservasi Masuk Real dari Database (Hanya yang belum checkin di sesi aktif & belum expired)
      try {
        final bookingsRes = await _client
            .from('bookings')
            .select('''
              id,
              booking_code,
              booking_type,
              start_time,
              end_time,
              duration_hours,
              total_price,
              payment_status,
              booking_status,
              created_at,
              user_id,
              location_id,
              slot_id,
              vehicle_id,
              plate_number,
              vehicle_desc,
              users(full_name, phone),
              parking_locations(name),
              parking_slots(slot_code, floor_name),
              vehicles(plate_number, vehicle_type, brand, model)
            ''')
            .not('booking_status', 'in', '(cancelled,completed,expired)')
            .order('created_at', ascending: false);

        final List<Map<String, dynamic>> validIncoming = [];
        final nowUtc = DateTime.now().toUtc();

        for (final row in bookingsRes) {
          final bId = row['id']?.toString() ?? '';

          // Jika booking ini sudah check-in dan aktif di sesi lapangan, tampilkan di Kendaraan Aktif saja
          if (activeSessionBookingIds.contains(bId)) {
            continue;
          }

          final payStatus = (row['payment_status'] ?? '').toString().toLowerCase().trim();
          final isPaid = payStatus == 'paid' || payStatus == 'success' || payStatus == 'settlement';
          final bStatus = (row['booking_status'] ?? '').toString().toLowerCase().trim();

          // Filter validasi: jika unpaid tapi sudah > 179s, lewati (booking hold habis)
          if (!isPaid) {
            final cat = DateTime.tryParse(row['created_at']?.toString() ?? '');
            if (cat != null && nowUtc.difference(cat.toUtc()).inSeconds > 179) {
              continue;
            }
          }

          // Jika paid tapi sudah lewat end_time > 15 menit, lewati
          if (isPaid) {
            final end = DateTime.tryParse(row['end_time']?.toString() ?? '');
            if (end != null && nowUtc.difference(end.toUtc()).inMinutes > 15) {
              continue;
            }
          }

          final price = (row['total_price'] as num?)?.toInt() ?? 0;
          final userData = row['users'] is Map<String, dynamic> ? row['users'] as Map<String, dynamic> : null;
          final locData = row['parking_locations'] is Map<String, dynamic> ? row['parking_locations'] as Map<String, dynamic> : null;
          final slotData = row['parking_slots'] is Map<String, dynamic> ? row['parking_slots'] as Map<String, dynamic> : null;
          final vehData = row['vehicles'] is Map<String, dynamic> ? row['vehicles'] as Map<String, dynamic> : null;

          final userName = userData?['full_name']?.toString() ?? 'Pelanggan ParkSmart';
          final userPhone = userData?['phone']?.toString() ?? '-';
          final locName = locData?['name']?.toString() ?? 'Lokasi Parkir';
          final slotCode = slotData?['slot_code']?.toString() ?? '-';
          final floorName = slotData?['floor_name']?.toString() ?? 'Lantai 1';
          final plate = row['plate_number']?.toString() ?? vehData?['plate_number']?.toString() ?? '-';
          final vType = vehData?['vehicle_type']?.toString().toLowerCase() == 'motor' ? 'Motor' : 'Mobil';

          DateTime? parsedStart = DateTime.tryParse(row['start_time']?.toString() ?? '');
          String timeFormatted = '08:00';
          if (parsedStart != null) {
            final wibDt = parsedStart.toUtc().add(const Duration(hours: 7));
            timeFormatted = '${wibDt.hour.toString().padLeft(2, '0')}:${wibDt.minute.toString().padLeft(2, '0')}';
          }

          String displayStatus = 'Menunggu';
          if (isPaid) {
            if (bStatus == 'active') {
              displayStatus = 'Siap Check-In';
            } else {
              displayStatus = 'Dikonfirmasi';
            }
          }

          validIncoming.add({
            'id': row['booking_code']?.toString() ?? 'BKG-001',
            'db_id': row['id']?.toString(),
            'code': row['booking_code']?.toString() ?? 'PRK-001',
            'name': userName,
            'phone': userPhone,
            'location': locName,
            'slot': slotCode,
            'floor': floorName,
            'vehicleType': vType,
            'plate': plate,
            'time': '$timeFormatted WIB',
            'duration': '${row['duration_hours'] ?? 1} jam',
            'status': displayStatus,
            'totalPrice': 'Rp $price',
            'paymentStatus': isPaid ? 'Dibayar' : 'Belum Dibayar',
          });
        }

        _liveBookings = validIncoming;
      } catch (e) {
        debugPrint('[AdminOperationsDashboardBackend] liveBookings error: $e');
      }

      // 4. Seluruh Sesi Parkir untuk Kalkulasi Chart 4 Minggu per Bulan
      final allSessionsRes = await _client
          .from('parking_sessions')
          .select('id, check_in_time, created_at')
          .order('created_at', ascending: false);

      final List<_SessionTimestampEvent> sessionEvents = [];
      for (final s in allSessionsRes) {
        final rawTs = s['check_in_time'] ?? s['created_at'];
        if (rawTs != null) {
          sessionEvents.add(_SessionTimestampEvent(_parseToWib(rawTs)));
        }
      }

      // Ambil daftar bulan unik yang ada datanya di database
      final Set<String> distinctMonthKeys = {};
      final List<DateTime> distinctMonthDates = [];

      for (final ev in sessionEvents) {
        final key = '${ev.wibTime.year}-${ev.wibTime.month.toString().padLeft(2, '0')}';
        if (!distinctMonthKeys.contains(key)) {
          distinctMonthKeys.add(key);
          distinctMonthDates.add(DateTime(ev.wibTime.year, ev.wibTime.month, 1));
        }
      }

      // Urutkan bulan dari yang terbaru (descending)
      distinctMonthDates.sort((a, b) => b.compareTo(a));

      // Aturan pengguna: "6 bulan terakhir dihitung dari saat ini, kalau kosong muncul kosong, jika ada 3 maka 3, kalau 8 ambil 6 terakhir"
      final targetMonths = distinctMonthDates.take(6).toList();
      _availableMonths = targetMonths.map((d) => _formatMonthYear(d)).toList();

      _monthlyChartData.clear();

      final now = _nowWib;

      for (final monthDate in targetMonths) {
        final monthLabel = _formatMonthYear(monthDate);
        final year = monthDate.year;
        final month = monthDate.month;

        final sessionsInMonth = sessionEvents.where((e) =>
            e.wibTime.year == year && e.wibTime.month == month).toList();

        // Tentukan batas minggu aktif berdasarkan waktu server WIB saat ini
        int availableWeeksCount = 4;
        if (year > now.year || (year == now.year && month > now.month)) {
          availableWeeksCount = 0; // Bulan di masa depan
        } else if (year == now.year && month == now.month) {
          // Bulan sedang berlangsung
          if (now.day < 8) {
            availableWeeksCount = 1;
          } else if (now.day < 15) {
            availableWeeksCount = 2;
          } else if (now.day < 22) {
            availableWeeksCount = 3;
          } else {
            availableWeeksCount = 4;
          }
        }

        // Kalkulasi 4 minggu diskrit (mandiri)
        int w1 = 0;
        int w2 = 0;
        int w3 = 0;
        int w4 = 0;

        for (final s in sessionsInMonth) {
          final day = s.wibTime.day;
          if (day >= 1 && day <= 7) {
            w1++;
          } else if (day >= 8 && day <= 14) {
            w2++;
          } else if (day >= 15 && day <= 21) {
            w3++;
          } else if (day >= 22) {
            w4++;
          }
        }

        final rawValues = [w1, w2, w3, w4];

        // Normalisasi chart
        final int maxVal = rawValues.fold(0, (m, v) => v > m ? v : m);
        final List<double> chartData = rawValues.map((v) {
          if (maxVal <= 0 || v <= 0) return 0.05;
          return 0.15 + (v / maxVal) * 0.80;
        }).toList();

        // Hitung persentase kenaikan/penurunan vs minggu sebelumnya
        final List<double> percentages = [0.0, 0.0, 0.0, 0.0];
        for (int i = 1; i < 4; i++) {
          final prev = rawValues[i - 1];
          final cur = rawValues[i];
          if (prev == 0) {
            percentages[i] = cur > 0 ? 100.0 : 0.0;
          } else {
            percentages[i] = ((cur - prev) / prev) * 100.0;
          }
        }

        final int latestWeekIndex = (availableWeeksCount > 0 ? availableWeeksCount - 1 : 0).clamp(0, 3);

        _monthlyChartData[monthLabel] = {
          'monthLabel': monthLabel,
          'availableWeeksCount': availableWeeksCount,
          'latestWeekIndex': latestWeekIndex,
          'rawValues': rawValues,
          'chartData': chartData,
          'pointValues': rawValues.map((v) => '$v Unit').toList(),
          'pointDates': [
            'Minggu 1 (Tgl 1-7)',
            'Minggu 2 (Tgl 8-14)',
            'Minggu 3 (Tgl 15-21)',
            'Minggu 4 (Tgl 22-Akhir)',
          ],
          'xLabels': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
          'percentages': percentages,
        };
      }
    } catch (e) {
      debugPrint('[AdminOperationsDashboardBackend] fetchDashboardData error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin Force Check-In untuk reservasi status Dikonfirmasi
  Future<bool> forceCheckInBooking(String bookingIdentifier) async {
    try {
      final bRes = await _client
          .from('bookings')
          .select('''
            id, booking_code, user_id, location_id, slot_id, vehicle_id,
            plate_number, vehicle_desc, duration_hours, total_price,
            vehicles(plate_number, vehicle_type, brand, model)
          ''')
          .or('id.eq.$bookingIdentifier,booking_code.eq.$bookingIdentifier')
          .maybeSingle();

      if (bRes == null) return false;

      final bookingId = bRes['id'];
      final slotId = bRes['slot_id'];
      final vehData = bRes['vehicles'] as Map<String, dynamic>?;
      final plate = bRes['plate_number']?.toString() ?? vehData?['plate_number']?.toString() ?? '-';
      final vType = vehData?['vehicle_type']?.toString().toLowerCase() ?? 'mobil';
      final vDesc = bRes['vehicle_desc']?.toString() ??
          ((vehData != null) ? '${vehData['brand'] ?? ''} ${vehData['model'] ?? ''}'.trim() : 'Kendaraan');
      final durationHours = (bRes['duration_hours'] as num?)?.toInt() ?? 1;
      final fee = (bRes['total_price'] as num?)?.toDouble() ?? 5000.0;

      final now = DateTime.now().toUtc();
      final expEnd = now.add(Duration(hours: durationHours));

      // 1. Update status booking menjadi active
      await _client.from('bookings').update({
        'booking_status': 'active',
      }).eq('id', bookingId);

      // 2. Set slot menjadi occupied
      if (slotId != null) {
        await _client.from('parking_slots').update({
          'status': 'occupied',
          'current_plate_number': plate,
          'occupied_since': now.toIso8601String(),
        }).eq('id', slotId);
      }

      // 3. Buat sesi di parking_sessions jika belum ada, atau aktifkan jika ada
      final existingSession = await _client
          .from('parking_sessions')
          .select('id')
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (existingSession != null) {
        await _client.from('parking_sessions').update({
          'status': 'active',
          'check_in_time': now.toIso8601String(),
          'expected_check_out_time': expEnd.toIso8601String(),
        }).eq('id', existingSession['id']);
      } else {
        final sessionCode = 'SES-${Random().nextInt(900000) + 100000}';
        await _client.from('parking_sessions').insert({
          'session_code': sessionCode,
          'booking_id': bookingId,
          'user_id': bRes['user_id'],
          'location_id': bRes['location_id'],
          'slot_id': slotId,
          'vehicle_id': bRes['vehicle_id'],
          'plate_number': plate,
          'vehicle_type': vType,
          'vehicle_desc': vDesc.isEmpty ? 'Kendaraan' : vDesc,
          'check_in_time': now.toIso8601String(),
          'expected_check_out_time': expEnd.toIso8601String(),
          'parking_fee': fee,
          'total_fee': fee,
          'status': 'active',
          'gate_in_id': 'Admin Force Check-in',
        });
      }

      await fetchDashboardData();
      return true;
    } catch (e) {
      debugPrint('[AdminOperationsDashboardBackend] forceCheckInBooking error: $e');
      return false;
    }
  }

  /// Admin Force Cancel untuk reservasi belum bayar (Menunggu)
  Future<bool> forceCancelBooking(String bookingIdentifier, {String? reason}) async {
    try {
      final bRes = await _client
          .from('bookings')
          .select('id, slot_id')
          .or('id.eq.$bookingIdentifier,booking_code.eq.$bookingIdentifier')
          .maybeSingle();

      if (bRes == null) return false;

      final bookingId = bRes['id'];
      final slotId = bRes['slot_id'];

      await _client.from('bookings').update({
        'booking_status': 'cancelled',
        'cancel_reason': reason ?? 'Dibatalkan oleh Admin Operasional',
      }).eq('id', bookingId);

      if (slotId != null) {
        await _client.from('parking_slots').update({
          'status': 'available',
          'current_plate_number': null,
          'occupied_since': null,
        }).eq('id', slotId);
      }

      await fetchDashboardData();
      return true;
    } catch (e) {
      debugPrint('[AdminOperationsDashboardBackend] forceCancelBooking error: $e');
      return false;
    }
  }

  /// Admin Force Check-Out tepat pada sesi kendaraan aktif tertentu
  Future<bool> forceCheckOutSession(String sessionIdentifier) async {
    try {
      final sess = await _client
          .from('parking_sessions')
          .select('id, slot_id, booking_id')
          .or('id.eq.$sessionIdentifier,session_code.eq.$sessionIdentifier')
          .maybeSingle();

      if (sess == null) return false;

      final sId = sess['id'];
      final slotId = sess['slot_id'];
      final bookingId = sess['booking_id'];
      final now = DateTime.now().toUtc();

      // 1. Selesaikan sesi parkir ini
      await _client.from('parking_sessions').update({
        'status': 'completed',
        'check_out_time': now.toIso8601String(),
      }).eq('id', sId);

      // 2. Bebaskan slot parkir jika ada
      if (slotId != null) {
        await _client.from('parking_slots').update({
          'status': 'available',
          'current_plate_number': null,
          'occupied_since': null,
        }).eq('id', slotId);
      }

      // 3. Selesaikan status booking terkait
      if (bookingId != null) {
        await _client.from('bookings').update({
          'booking_status': 'completed',
        }).eq('id', bookingId);
      }

      await fetchDashboardData();
      return true;
    } catch (e) {
      debugPrint('[AdminOperationsDashboardBackend] forceCheckOutSession error: $e');
      return false;
    }
  }
}
