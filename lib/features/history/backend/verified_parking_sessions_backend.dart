import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../profile/backend/profile_backend.dart';
import '../../profile/backend/vehicle_backend.dart';

class VerifiedSessionItem {
  final String id;
  final String dbId;
  final String locationName;
  final String slot;
  final String date;
  final String duration;
  final num rawAmount;
  final String amount;
  final String blockHash;
  final String timestamp;
  final String timeIn;
  final String timeOut;
  final String status;

  const VerifiedSessionItem({
    required this.id,
    this.dbId = '',
    required this.locationName,
    required this.slot,
    required this.date,
    required this.duration,
    this.rawAmount = 0,
    required this.amount,
    required this.blockHash,
    required this.timestamp,
    required this.timeIn,
    required this.timeOut,
    required this.status,
  });
}

class VerifiedParkingSessionsBackend extends ChangeNotifier {
  VerifiedParkingSessionsBackend._();
  static final VerifiedParkingSessionsBackend instance = VerifiedParkingSessionsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _vehiclePlate = '-';
  String get vehiclePlate => _vehiclePlate;

  String _vehicleInfo = 'Belum Ada Kendaraan';
  String get vehicleInfo => _vehicleInfo;

  String? _photoUrl;
  String? get photoUrl => _photoUrl;

  bool _isDefault = true;
  bool get isDefault => _isDefault;

  int _totalSessions = 0;
  int get totalSessions => _totalSessions;

  int _totalDurationHours = 0;
  int get totalDurationHours => _totalDurationHours;

  num _rawThisMonthSpending = 0;
  num get rawThisMonthSpending => _rawThisMonthSpending;

  String _thisMonthSpending = 'Rp 0';
  String get thisMonthSpending => _thisMonthSpending;

  String _selectedFilter = 'Semua Bulan';
  String get selectedFilter => _selectedFilter;

  List<VerifiedSessionItem> _allSessions = [];
  List<VerifiedSessionItem> get sessions {
    if (_selectedFilter == 'Semua Bulan') return _allSessions;
    return _allSessions.where((s) {
      if (_selectedFilter == 'Oktober 2026') {
        return s.timestamp.contains('2026-10');
      } else if (_selectedFilter == 'September 2026') {
        return s.timestamp.contains('2026-09');
      }
      return true;
    }).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  String _formatWibDate(dynamic dateRaw) {
    if (dateRaw == null) return '-';
    try {
      final dt = DateTime.parse(dateRaw.toString()).toUtc().add(const Duration(hours: 7));
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final day = dt.day;
      final month = months[dt.month - 1];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute WIB';
    } catch (_) {
      return dateRaw.toString();
    }
  }

  String _formatTimeOnly(dynamic dateRaw) {
    if (dateRaw == null) return '-';
    try {
      final dt = DateTime.parse(dateRaw.toString()).toUtc().add(const Duration(hours: 7));
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute WIB';
    } catch (_) {
      return '-';
    }
  }

  Future<String> _resolveUserIdAsync() async {
    final sessionUid = SessionService.instance.userId;
    if (sessionUid != null && sessionUid.trim().isNotEmpty) {
      return sessionUid.trim();
    }

    final profileUid = ProfileBackend.instance.userId;
    if (profileUid.trim().isNotEmpty) {
      return profileUid.trim();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('ps_session_user_id') ?? prefs.getString('user_profile_id');
      if (savedId != null && savedId.trim().isNotEmpty) {
        return savedId.trim();
      }
    } catch (_) {}

    return '';
  }

  Future<void> fetchSessions({String? vehicleId, VehicleItem? vehicleItem}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? targetVehicleId = vehicleId ?? vehicleItem?.id;
      String? targetPlate = vehicleItem?.plateNumber;

      // 1. Tentukan profil kendaraan yang diinspeksi
      if (vehicleItem != null) {
        _vehiclePlate = vehicleItem.plateNumber;
        _vehicleInfo = '${vehicleItem.displayName} • ${vehicleItem.color}'.trim();
        _photoUrl = vehicleItem.photoUrl;
        _isDefault = vehicleItem.isDefault;
        targetVehicleId = vehicleItem.id;
        targetPlate = vehicleItem.plateNumber;
      } else if (targetVehicleId != null && targetVehicleId.isNotEmpty) {
        final vRes = await _client
            .from('vehicles')
            .select('id, brand, model, plate_number, color, is_default, photo_url')
            .eq('id', targetVehicleId)
            .maybeSingle();

        if (vRes != null) {
          final item = VehicleItem.fromMap(vRes);
          _vehiclePlate = item.plateNumber;
          _vehicleInfo = '${item.displayName} • ${item.color}'.trim();
          _photoUrl = item.photoUrl;
          _isDefault = item.isDefault;
          targetPlate = item.plateNumber;
        }
      } else {
        // Fallback: Ambil kendaraan default milik user aktif
        final currentUserId = await _resolveUserIdAsync();
        dynamic vQuery = _client
            .from('vehicles')
            .select('id, brand, model, plate_number, color, is_default, photo_url');

        if (currentUserId.isNotEmpty) {
          vQuery = vQuery.eq('user_id', currentUserId);
        }
        final vRes = await vQuery.order('is_default', ascending: false).limit(1).maybeSingle();

        if (vRes != null) {
          final item = VehicleItem.fromMap(vRes);
          targetVehicleId = item.id;
          targetPlate = item.plateNumber;
          _vehiclePlate = item.plateNumber;
          _vehicleInfo = '${item.displayName} • ${item.color}'.trim();
          _photoUrl = item.photoUrl;
          _isDefault = item.isDefault;
        } else {
          _vehiclePlate = 'Belum Terdaftar';
          _vehicleInfo = 'Tidak ada kendaraan aktif';
          _photoUrl = null;
          _isDefault = true;
          _allSessions = [];
          _totalSessions = 0;
          _totalDurationHours = 0;
          _rawThisMonthSpending = 0;
          _thisMonthSpending = CurrencyService.instance.format(0);
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 2. Ambil HANYA sesi parkir yang terkait dengan kendaraan ini (melalui vehicle_id atau nomor plat)
      final List<VerifiedSessionItem> list = [];
      int totalHours = 0;
      int monthlySpending = 0;
      final nowUtc = DateTime.now().toUtc().add(const Duration(hours: 7));
      final currentMonthStr = '${nowUtc.year}-${nowUtc.month.toString().padLeft(2, '0')}';

      // 2a. Query dari parking_sessions
      dynamic sQuery = _client
          .from('parking_sessions')
          .select('''
            id,
            session_code,
            plate_number,
            check_in_time,
            check_out_time,
            expected_check_out_time,
            total_fee,
            parking_fee,
            status,
            created_at,
            booking_id,
            parking_locations(name),
            parking_slots(slot_code)
          ''');

      final hasVehicleId = targetVehicleId.isNotEmpty;
      final hasPlate = targetPlate != null && targetPlate.isNotEmpty;

      if (hasVehicleId && hasPlate) {
        sQuery = sQuery.or('vehicle_id.eq.$targetVehicleId,plate_number.eq.$targetPlate');
      } else if (hasVehicleId) {
        sQuery = sQuery.eq('vehicle_id', targetVehicleId);
      } else if (hasPlate) {
        sQuery = sQuery.eq('plate_number', targetPlate);
      }

      final sessionRes = await sQuery.order('created_at', ascending: false);

      final Set<String> processedBookingIds = {};

      if (sessionRes.isNotEmpty) {
        for (var row in sessionRes) {
          final bId = row['booking_id']?.toString();
          if (bId != null && bId.isNotEmpty) {
            processedBookingIds.add(bId);
          }

          final locData = row['parking_locations'] as Map<String, dynamic>?;
          final slotData = row['parking_slots'] as Map<String, dynamic>?;

          final locName = locData?['name']?.toString() ?? 'ParkSmart Facility';
          final slotCode = slotData?['slot_code']?.toString();
          final slotLabel = slotCode != null ? 'Slot $slotCode' : 'Slot Terverifikasi';

          final checkInRaw = row['check_in_time'] ?? row['created_at'];
          final checkOutRaw = row['check_out_time'] ?? row['expected_check_out_time'];

          final fee = (row['total_fee'] as num?)?.toInt() ??
              (row['parking_fee'] as num?)?.toInt() ??
              0;

          // Durasi
          int durationHr = 1;
          if (checkInRaw != null && checkOutRaw != null) {
            try {
              final inDt = DateTime.parse(checkInRaw.toString());
              final outDt = DateTime.parse(checkOutRaw.toString());
              final diff = outDt.difference(inDt).inHours;
              durationHr = diff > 0 ? diff : 1;
            } catch (_) {}
          }
          totalHours += durationHr;

          final createdStr = row['created_at']?.toString() ?? checkInRaw?.toString() ?? '';
          if (createdStr.contains(currentMonthStr)) {
            monthlySpending += fee;
          }

          final statusDb = (row['status'] ?? '').toString().toLowerCase();
          String statusLabel = 'Selesai';
          if (statusDb == 'active') {
            statusLabel = 'Parkir Aktif';
          } else if (statusDb == 'overstay') {
            statusLabel = 'Overstay';
          }

          final sid = row['id']?.toString() ?? '';
          final hash = '0x${sid.replaceAll('-', '').substring(0, sid.length > 8 ? 8 : sid.length)}...';

          list.add(VerifiedSessionItem(
            id: row['session_code']?.toString() ?? sid,
            dbId: sid,
            locationName: locName,
            slot: slotLabel,
            date: _formatWibDate(checkInRaw),
            duration: '$durationHr Jam',
            rawAmount: fee,
            amount: CurrencyService.instance.format(fee),
            blockHash: hash,
            timestamp: createdStr,
            timeIn: 'Masuk: ${_formatTimeOnly(checkInRaw)}',
            timeOut: 'Keluar: ${statusDb == 'active' ? 'Sedang Parkir' : _formatTimeOnly(checkOutRaw)}',
            status: statusLabel,
          ));
        }
      }

      // 2b. Query reservasi parkir dari bookings yang belum check-in
      if (hasVehicleId) {
        final bookingRes = await _client
            .from('bookings')
            .select('''
              id,
              booking_code,
              start_time,
              end_time,
              duration_hours,
              total_price,
              payment_status,
              booking_status,
              qr_code_hash,
              created_at,
              parking_locations(name),
              parking_slots(slot_code)
            ''')
            .eq('vehicle_id', targetVehicleId)
            .neq('booking_status', 'cancelled')
            .order('created_at', ascending: false);

        if (bookingRes.isNotEmpty) {
          for (var bRow in bookingRes) {
            final bId = bRow['id']?.toString() ?? '';
            if (processedBookingIds.contains(bId)) {
              continue; // Sudah masuk dari parking_sessions
            }

            final locData = bRow['parking_locations'] as Map<String, dynamic>?;
            final slotData = bRow['parking_slots'] as Map<String, dynamic>?;

            final locName = locData?['name']?.toString() ?? 'ParkSmart Facility';
            final slotCode = slotData?['slot_code']?.toString();
            final slotLabel = slotCode != null ? 'Slot $slotCode' : 'Slot Terverifikasi';

            final startRaw = bRow['start_time'] ?? bRow['created_at'];
            final endRaw = bRow['end_time'];
            final fee = (bRow['total_price'] as num?)?.toInt() ?? 0;
            final durationHr = (bRow['duration_hours'] as num?)?.toInt() ?? 1;

            totalHours += durationHr;

            final createdStr = bRow['created_at']?.toString() ?? startRaw?.toString() ?? '';
            if (createdStr.contains(currentMonthStr)) {
              monthlySpending += fee;
            }

            final bStatus = (bRow['booking_status'] ?? '').toString().toLowerCase();
            String statusLabel = 'Mendatang';
            if (bStatus == 'completed') {
              statusLabel = 'Selesai';
            }

            final rawHash = bRow['qr_code_hash']?.toString() ?? bId;
            final hash = rawHash.startsWith('0x')
                ? rawHash
                : '0x${rawHash.replaceAll('-', '').substring(0, rawHash.length > 8 ? 8 : rawHash.length)}...';

            list.add(VerifiedSessionItem(
              id: bRow['booking_code']?.toString() ?? bId,
              dbId: bId,
              locationName: locName,
              slot: slotLabel,
              date: _formatWibDate(startRaw),
              duration: '$durationHr Jam',
              rawAmount: fee,
              amount: CurrencyService.instance.format(fee),
              blockHash: hash,
              timestamp: createdStr,
              timeIn: 'Jadwal Masuk: ${_formatTimeOnly(startRaw)}',
              timeOut: 'Jadwal Selesai: ${_formatTimeOnly(endRaw)}',
              status: statusLabel,
            ));
          }
        }
      }

      _allSessions = list;
      _totalSessions = list.length;
      _totalDurationHours = totalHours;
      _rawThisMonthSpending = monthlySpending;
      _thisMonthSpending = CurrencyService.instance.format(monthlySpending);
    } catch (e) {
      debugPrint('[VerifiedParkingSessionsBackend] fetchSessions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
