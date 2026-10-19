import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk HistoryDetailScreen (lib/features/history/history_detail_screen.dart)
class HistoryDetailBackend extends ChangeNotifier {
  HistoryDetailBackend._();
  static final HistoryDetailBackend instance = HistoryDetailBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _transactionCode = 'PS-88210';
  String _locationName = 'Central Park Mall';
  String _locationDetail = 'South Lobby, Basement B2, Slot A-05';
  String _vehicleInfo = 'Toyota Raize (B 1234 XYZ)';
  String _checkInTime = '14:30 WIB';
  String _checkOutTime = '16:45 WIB';
  String _duration = '2 Jam 15 Menit';
  String _paymentMethod = 'ParkSmart Pay';
  int _baseFee = 16000;
  int _serviceFee = 2000;
  int _discount = 4000;
  int _totalAmount = 14000;
  String _status = 'Sukses';

  String get transactionCode => _transactionCode;
  String get locationName => _locationName;
  String get locationDetail => _locationDetail;
  String get vehicleInfo => _vehicleInfo;
  String get checkInTime => _checkInTime;
  String get checkOutTime => _checkOutTime;
  String get duration => _duration;
  String get paymentMethod => _paymentMethod;
  int get baseFee => _baseFee;
  int get serviceFee => _serviceFee;
  int get discount => _discount;
  int get totalAmount => _totalAmount;
  String get status => _status;

  Future<void> fetchDetail(String? id) async {
    if (id == null || id.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_sessions')
          .select('session_code, plate_number, vehicle_desc, check_in_time, check_out_time, total_fee, status')
          .eq('id', id)
          .maybeSingle();

      if (res != null) {
        _transactionCode = res['session_code'] ?? _transactionCode;
        _vehicleInfo = '${res['vehicle_desc'] ?? 'Mobil'} (${res['plate_number'] ?? 'B 1234 XYZ'})';
        if (res['total_fee'] != null) {
          _totalAmount = (double.tryParse(res['total_fee'].toString()) ?? _totalAmount.toDouble()).toInt();
        }
        _status = (res['status'] ?? 'completed') == 'completed' ? 'Sukses' : 'Aktif';
      }
    } catch (e) {
      debugPrint('HistoryDetailBackend fetchDetail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
