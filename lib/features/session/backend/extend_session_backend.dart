import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ExtendSessionScreen (lib/features/session/extend_session_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk performa optimal
class ExtendSessionBackend extends ChangeNotifier {
  ExtendSessionBackend._();
  static final ExtendSessionBackend instance = ExtendSessionBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _sessionId;
  String get slotCode => _slotCode;
  String _slotCode = 'Slot A-05';

  String get floorInfo => _floorInfo;
  String _floorInfo = 'Lantai B2 • Pilar 14';

  String get remainingTimeFormatted => _remainingTimeFormatted;
  String _remainingTimeFormatted = '01:41:19';

  String get currentDeadline => _currentDeadline;
  String _currentDeadline = '16:02 WIB';

  DateTime? _expectedCheckOut;

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

  /// Memuat sesi parkir aktif yang dapat diperpanjang
  Future<void> fetchActiveSessionForExtend() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _client
          .from('parking_sessions')
          .select('id, slot_id, expected_check_out_time, check_in_time, parking_fee')
          .eq('status', 'active')
          .order('check_in_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (session != null) {
        _sessionId = session['id']?.toString();

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
            _floorInfo = '${slot['floor_name'] ?? 'Lantai B2'} • Pilar 14';
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
    final cost = opt['amount'] as double;

    _isLoading = true;
    notifyListeners();

    try {
      final newEnd = (_expectedCheckOut ?? DateTime.now()).add(Duration(minutes: minutesToAdd));

      if (_sessionId != null) {
        // 1. Update waktu selesai sesi di parking_sessions
        await _client.from('parking_sessions').update({
          'expected_check_out_time': newEnd.toUtc().toIso8601String(),
        }).eq('id', _sessionId!);

        // 2. Buat riwayat pembayaran perpanjangan di tabel payments
        final code = 'PAY-EXT-${Random().nextInt(900000) + 100000}';
        await _client.from('payments').insert({
          'transaction_code': code,
          'session_id': _sessionId,
          'user_id': 'c0000000-0000-0000-0000-000000000001',
          'transaction_type': 'parking_payment',
          'payment_method': paymentMethod == 'ParkSmart Wallet' ? 'wallet' : 'gopay',
          'amount': cost,
          'description': 'Perpanjangan Parkir ${opt['title']}',
          'status': 'success',
        });
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
