import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/maintenance_service.dart';

/// Backend khusus untuk AdminAppSettingsScreen
/// Mengatur konfigurasi pemeliharaan platform (Maintenance) & feature toggles global
/// Terkoneksi ke tabel `public.system_settings` di Supabase
class AdminAppSettingsBackend extends ChangeNotifier {
  AdminAppSettingsBackend._();
  static final AdminAppSettingsBackend instance = AdminAppSettingsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _maintenanceMode = false;
  bool get maintenanceMode => _maintenanceMode;

  String _maintenanceTitle = 'Sistem Sedang Dalam Pemeliharaan Terjadwal';
  String get maintenanceTitle => _maintenanceTitle;

  String _maintenanceMessage = 'ParkSmart sedang melakukan peningkatan server. Seluruh akses pemesanan tiket sementara ditutup demi kestabilan sistem dan keamanan data.';
  String get maintenanceMessage => _maintenanceMessage;

  String _maintenanceEta = '2 Jam (Selesai pukul 05:00 WIB)';
  String get maintenanceEta => _maintenanceEta;

  bool _showWarningOnly = false;
  bool get showWarningOnly => _showWarningOnly;

  String _warningTitle = 'Pemberitahuan Pemeliharaan Sistem';
  String get warningTitle => _warningTitle;

  String _warningMessage = 'Sistem saat ini sedang dalam pemeliharaan rutin. Seluruh layanan aplikasi tetap dapat diakses dan digunakan secara normal.';
  String get warningMessage => _warningMessage;

  final Map<String, bool> _moduleToggles = {
    'booking': false,
    'ai': false,
    'kyc': false,
    'push': false,
  };
  Map<String, bool> get moduleToggles => _moduleToggles;

  /// Memuat pengaturan dari Supabase dan sinkronisasi dengan MaintenanceService
  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ambil dari MaintenanceService local
      final local = MaintenanceService.instance;
      _maintenanceMode = local.isGlobalMaintenance;
      _maintenanceTitle = local.maintenanceTitle;
      _maintenanceMessage = local.maintenanceMessage;
      _maintenanceEta = local.maintenanceEta;
      _showWarningOnly = local.isWarningOnly;
      _warningTitle = local.warningTitle;
      _warningMessage = local.warningMessage;

      _moduleToggles['booking'] = local.isBookingMaintenance;
      _moduleToggles['ai'] = local.isAiMaintenance;
      _moduleToggles['kyc'] = local.isKycMaintenance;
      _moduleToggles['push'] = local.isPushMaintenance;

      // Sinkronisasi dari Supabase tabel system_settings
      final res = await _client
          .from('system_settings')
          .select('key, value')
          .inFilter('key', ['maintenance_mode', 'feature_toggles']);

      for (var row in res) {
        if (row['key'] == 'maintenance_mode' && row['value'] is Map) {
          final val = row['value'] as Map<String, dynamic>;
          _maintenanceMode = val['is_active'] == true;
          if (val['title'] != null) _maintenanceTitle = val['title'].toString();
          if (val['message'] != null) _maintenanceMessage = val['message'].toString();
          if (val['eta'] != null) _maintenanceEta = val['eta'].toString();
          if (val['warning_only'] != null) _showWarningOnly = val['warning_only'] == true;
          if (val['warning_title'] != null) _warningTitle = val['warning_title'].toString();
          if (val['warning_message'] != null) _warningMessage = val['warning_message'].toString();
        }
      }
    } catch (e) {
      debugPrint('[AdminAppSettingsBackend] loadSettings error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyimpan konfigurasi pemeliharaan ke MaintenanceService & Supabase
  Future<bool> saveMaintenanceSettings({
    required bool isGlobal,
    required String title,
    required String message,
    required String eta,
    required bool isWarningOnly,
    required String warningTitle,
    required String warningMessage,
  }) async {
    _maintenanceMode = isGlobal;
    _maintenanceTitle = title;
    _maintenanceMessage = message;
    _maintenanceEta = eta;
    _showWarningOnly = isWarningOnly;
    _warningTitle = warningTitle;
    _warningMessage = warningMessage;
    notifyListeners();

    // Simpan ke local service
    final local = MaintenanceService.instance;
    await local.setGlobalMaintenance(
      isGlobal,
      title: title,
      message: message,
      eta: eta,
    );
    await local.setWarningOnlySettings(
      isWarningOnly,
      title: warningTitle,
      message: warningMessage,
    );

    // Simpan ke Supabase system_settings
    try {
      await _client.from('system_settings').upsert({
        'key': 'maintenance_mode',
        'value': {
          'is_active': isGlobal,
          'title': title,
          'message': message,
          'eta': eta,
          'warning_only': isWarningOnly,
          'warning_title': warningTitle,
          'warning_message': warningMessage,
        },
        'description': 'Status darurat pemeliharaan sistem global dan banner peringatan',
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[AdminAppSettingsBackend] saveMaintenanceSettings error: $e');
      return false;
    }
  }

  /// Menyimpan toggle modular maintenance
  Future<bool> updateModuleToggle(String moduleKey, bool isActive) async {
    _moduleToggles[moduleKey] = isActive;
    notifyListeners();

    final local = MaintenanceService.instance;
    await local.setModuleMaintenance(moduleKey, isActive);

    try {
      await _client.from('system_settings').upsert({
        'key': 'modular_maintenance',
        'value': _moduleToggles,
        'description': 'Pemeliharaan modular per fitur (booking, AI, KYC, Push)',
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[AdminAppSettingsBackend] updateModuleToggle error: $e');
      return false;
    }
  }
}
