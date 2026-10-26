import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/parking_notification_service.dart';
import '../../admin/operations/backend/admin_operations_dashboard_backend.dart';
import '../../profile/backend/profile_backend.dart';
import 'active_session_backend.dart';

/// Backend khusus untuk ExtendSessionScreen (lib/features/session/extend_session_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk performa optimal
class ExtendSessionBackend extends ChangeNotifier {
  ExtendSessionBackend._();
  static final ExtendSessionBackend instance = ExtendSessionBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _sessionId;
  bool get hasSessionToExtend => _sessionId != null;

  String get slotCode => _slotCode;
  String _slotCode = '-';

  String get floorInfo => _floorInfo;
  String _floorInfo = '-';

  String get remainingTimeFormatted => _remainingTimeFormatted;
  String _remainingTimeFormatted = '00:00:00';

  String get currentDeadline => _currentDeadline;
  String _currentDeadline = '-';

  DateTime? _expectedCheckOut;
  DateTime? get newExpectedCheckOut => _expectedCheckOut;

  final List<Map<String, dynamic>> options = [
    {
      'title': '+30 Menit',
      'cost': 'Rp 3.000',
      'amount': 3000.0,
      'minutes': 30,
      'time': 'Hingga 16:32 WIB',
      'popular': false
    },
    {
      'title': '+1 Jam',
      'cost': 'Rp 5.000',
      'amount': 5000.0,
      'minutes': 60,
      'time': 'Hingga 17:02 WIB',
      'popular': true
    },
    {
      'title': '+2 Jam',
      'cost': 'Rp 9.000',
      'amount': 9000.0,
      'minutes': 120,
      'time': 'Hingga 18:02 WIB',
      'popular': false
    },
    {
      'title': '+3 Jam',
      'cost': 'Rp 13.000',
      'amount': 13000.0,
      'minutes': 180,
      'time': 'Hingga 19:02 WIB',
      'popular': false
    },
  ];

  String _vehicleName = 'Toyota Land Cruiser';
  String get vehicleName => _vehicleName;

  String _plateNumber = 'B 1945 RI';
  String get plateNumber => _plateNumber;

  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;

  /// Memuat sesi parkir aktif yang dapat diperpanjang
  Future<void> fetchActiveSessionForExtend({String? sessionId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final activeUserId = ProfileBackend.instance.userId.isNotEmpty
          ? ProfileBackend.instance.userId
          : (SessionService.instance.userId ?? '');

      if (activeUserId.isNotEmpty) {
        try {
          final wallet = await _client
              .from('wallets')
              .select('balance')
              .eq('user_id', activeUserId)
              .maybeSingle();
          if (wallet != null) {
            _walletBalance = (wallet['balance'] as num?)?.toDouble() ?? 0.0;
          }
        } catch (_) {}
      }
      var query = _client
          .from('parking_sessions')
          .select('id, slot_id, expected_check_out_time, check_in_time, parking_fee, total_fee, vehicle_desc, plate_number, booking_id');

      final dynamic session;
      if (sessionId != null && sessionId.isNotEmpty) {
        session = await query.eq('id', sessionId).maybeSingle();
      } else {
        session = await query
            .eq('status', 'active')
            .order('check_in_time', ascending: false)
            .limit(1)
            .maybeSingle();
      }

      if (session != null) {
        _sessionId = session['id']?.toString();

        if (session['vehicle_desc'] != null && session['vehicle_desc'].toString().isNotEmpty) {
          _vehicleName = session['vehicle_desc'].toString();
        }
        if (session['plate_number'] != null && session['plate_number'].toString().isNotEmpty) {
          _plateNumber = session['plate_number'].toString();
        }

        if (session['expected_check_out_time'] != null) {
          _expectedCheckOut = DateTime.tryParse(session['expected_check_out_time'].toString())?.toLocal();
          if (_expectedCheckOut != null) {
            final h = _expectedCheckOut!.hour.toString().padLeft(2, '0');
            final m = _expectedCheckOut!.minute.toString().padLeft(2, '0');
            _currentDeadline = '$h:$m WIB';

            final diff = _expectedCheckOut!.difference(DateTime.now()).inSeconds;
            if (diff > 0) {
              final hrs = (diff ~/ 3600).toString().padLeft(2, '0');
              final mins = ((diff % 3600) ~/ 60).toString().padLeft(2, '0');
              final secs = (diff % 60).toString().padLeft(2, '0');
              _remainingTimeFormatted = '$hrs:$mins:$secs';
            }

            // Update waktu opsi berdasarkan expectedCheckOut
            for (var opt in options) {
              final added = _expectedCheckOut!.add(Duration(minutes: opt['minutes'] as int));
              final ah = added.hour.toString().padLeft(2, '0');
              final am = added.minute.toString().padLeft(2, '0');
              opt['time'] = 'Hingga $ah:$am WIB';
            }
          }
        }

        if (session['slot_id'] != null) {
          final slot = await _client
              .from('parking_slots')
              .select('slot_code, floor_name')
              .eq('id', session['slot_id'])
              .maybeSingle();
          if (slot != null) {
            _slotCode = 'Slot ${slot['slot_code'] ?? 'A-05'}';
            _floorInfo = '${slot['floor_name'] ?? 'Lantai 1'} • Pilar 14';
          }
        }
      } else {
        // Cek juga dari tabel bookings jika sesi reservasi aktif
        final booking = await _client
            .from('bookings')
            .select('id, slot_id, location_id, vehicle_id, end_time, start_time, total_price')
            .inFilter('booking_status', ['upcoming', 'active'])
            .order('start_time', ascending: false)
            .limit(1)
            .maybeSingle();

        if (booking != null) {
          _sessionId = booking['id']?.toString();
          if (booking['vehicle_id'] != null) {
            final veh = await _client
                .from('vehicles')
                .select('brand, model, plate_number')
                .eq('id', booking['vehicle_id'])
                .maybeSingle();
            if (veh != null) {
              final b = veh['brand'] ?? '';
              final m = veh['model'] ?? '';
              _vehicleName = '$b $m'.trim();
              if (_vehicleName.isEmpty) _vehicleName = 'Toyota Land Cruiser';
              _plateNumber = veh['plate_number'] ?? _plateNumber;
            }
          }
          if (booking['end_time'] != null) {
            _expectedCheckOut = DateTime.tryParse(booking['end_time'].toString())?.toLocal();
            if (_expectedCheckOut != null) {
              final h = _expectedCheckOut!.hour.toString().padLeft(2, '0');
              final m = _expectedCheckOut!.minute.toString().padLeft(2, '0');
              _currentDeadline = '$h:$m WIB';

              final diff = _expectedCheckOut!.difference(DateTime.now()).inSeconds;
              if (diff > 0) {
                final hrs = (diff ~/ 3600).toString().padLeft(2, '0');
                final mins = ((diff % 3600) ~/ 60).toString().padLeft(2, '0');
                final secs = (diff % 60).toString().padLeft(2, '0');
                _remainingTimeFormatted = '$hrs:$mins:$secs';
              }

              for (var opt in options) {
                final added = _expectedCheckOut!.add(Duration(minutes: opt['minutes'] as int));
                final ah = added.hour.toString().padLeft(2, '0');
                final am = added.minute.toString().padLeft(2, '0');
                opt['time'] = 'Hingga $ah:$am WIB';
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ExtendSessionBackend] fetchActiveSessionForExtend error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eksekusi perpanjangan sesi di Supabase
  Future<bool> extendSession({
    required int optionIndex,
    required String paymentMethod,
  }) async {
    if (optionIndex < 0 || optionIndex >= options.length) return false;
    final opt = options[optionIndex];
    final minutesToAdd = opt['minutes'] as int;
    final cost = (opt['amount'] as num).toDouble();

    _isLoading = true;
    notifyListeners();

    try {
      if (_sessionId == null) {
        await fetchActiveSessionForExtend();
      }

      final activeUserId = ProfileBackend.instance.userId.isNotEmpty
          ? ProfileBackend.instance.userId
          : (SessionService.instance.userId ?? '');

      // Base time: jika _expectedCheckOut masih di masa depan, tambahkan dari sana; jika tidak, dari sekarang
      final now = DateTime.now();
      final baseTime = (_expectedCheckOut != null && _expectedCheckOut!.isAfter(now))
          ? _expectedCheckOut!
          : now;
      final newEnd = baseTime.add(Duration(minutes: minutesToAdd));

      // Jika bayar menggunakan wallet, pastikan saldo cukup & kurangi saldo
      if (paymentMethod.toLowerCase().contains('wallet')) {
        final walletRes = await _client
            .from('wallets')
            .select('id, balance')
            .eq('user_id', activeUserId)
            .maybeSingle();

        if (walletRes != null) {
          final currentBal = (walletRes['balance'] as num?)?.toDouble() ?? 0.0;
          if (currentBal < cost) {
            debugPrint('[ExtendSessionBackend] Saldo wallet tidak cukup: $currentBal < $cost');
            return false;
          }
          final newBal = currentBal - cost;
          await _client.from('wallets').update({
            'balance': newBal,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }).eq('id', walletRes['id']);
          _walletBalance = newBal;

          try {
            await _client.from('wallet_transactions').insert({
              'wallet_id': walletRes['id'],
              'user_id': activeUserId,
              'amount': cost,
              'type': 'expense',
              'description': 'Perpanjangan Durasi Parkir ${opt['title']}',
              'status': 'completed',
            });
          } catch (_) {}
        }
      }

      if (_sessionId != null) {
        // 1. Eksekusi RPC PostgreSQL atomik untuk memperpanjang sesi & booking
        try {
          final rpcRes = await _client.rpc('extend_parking_session', params: {
            'p_session_id': _sessionId,
            'p_additional_minutes': minutesToAdd,
            'p_cost': cost,
            'p_payment_method': paymentMethod,
          });
          debugPrint('[ExtendSessionBackend] extend_parking_session RPC result: $rpcRes');
          if (rpcRes != null && rpcRes['new_end_time'] != null) {
            final parsed = DateTime.tryParse(rpcRes['new_end_time'].toString())?.toLocal();
            if (parsed != null) {
              _expectedCheckOut = parsed;
            }
          } else {
            _expectedCheckOut = newEnd;
          }
        } catch (rpcErr) {
          debugPrint('[ExtendSessionBackend] rpc error, running direct update fallback: $rpcErr');
          // Fallback direct update jika RPC bermasalah
          try {
            final res = await _client.from('parking_sessions').update({
              'expected_check_out_time': newEnd.toUtc().toIso8601String(),
              'extended_count': 1,
              'extended_minutes': minutesToAdd,
            }).or('id.eq.$_sessionId,session_code.eq.$_sessionId').select('id, booking_id');

            if (res.isNotEmpty && res[0]['booking_id'] != null) {
              await _client.from('bookings').update({
                'end_time': newEnd.toUtc().toIso8601String(),
                'extended_count': 1,
                'extended_minutes': minutesToAdd,
              }).eq('id', res[0]['booking_id']);
            }
          } catch (_) {}

          try {
            await _client.from('bookings').update({
              'end_time': newEnd.toUtc().toIso8601String(),
              'extended_count': 1,
              'extended_minutes': minutesToAdd,
            }).or('id.eq.$_sessionId,booking_code.eq.$_sessionId');
          } catch (_) {}

          _expectedCheckOut = newEnd;
        }

        final endToDisplay = _expectedCheckOut ?? newEnd;
        _currentDeadline = '${endToDisplay.hour.toString().padLeft(2, '0')}:${endToDisplay.minute.toString().padLeft(2, '0')} WIB';

        final diff = endToDisplay.difference(DateTime.now()).inSeconds;
        if (diff > 0) {
          final hrs = (diff ~/ 3600).toString().padLeft(2, '0');
          final mins = ((diff % 3600) ~/ 60).toString().padLeft(2, '0');
          final secs = (diff % 60).toString().padLeft(2, '0');
          _remainingTimeFormatted = '$hrs:$mins:$secs';
        }

        // 2. Catat pembayaran perpanjangan jam di tabel payments
        final code = 'PAY-EXT-${Random().nextInt(900000) + 100000}';
        try {
          await _client.from('payments').insert({
            'transaction_code': code,
            'session_id': _sessionId,
            'user_id': activeUserId,
            'transaction_type': 'parking_payment',
            'payment_method': paymentMethod == 'ParkSmart Wallet' ? 'wallet' : 'gopay',
            'amount': cost,
            'description': 'Perpanjangan Durasi Parkir ${opt['title']}',
            'status': 'success',
          });
        } catch (_) {}

        // 3. Sinkronisasi ke ActiveSessionBackend (sisi user) & Admin Dashboard (sisi admin)
        await ActiveSessionBackend.instance.fetchActiveSession();
        await AdminOperationsDashboardBackend.instance.fetchDashboardData();

        // 4. Hentikan notifikasi darurat & update timer background sisi notifikasi
        final finalCheckout = _expectedCheckOut ?? newEnd;
        await ParkingNotificationService().onSessionExtended(
          newExpectedCheckout: finalCheckout,
        );
      }
      return true;
    } catch (e) {
      debugPrint('[ExtendSessionBackend] extendSession error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
