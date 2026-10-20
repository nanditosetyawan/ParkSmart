import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk AdminKycDetailModal
/// Menangani verifikasi detail, persetujuan (acc), dan penolakan berkas identitas KTP
/// oleh Super Admin pada tabel `public.user_kyc`.
class AdminKycDetailBackend extends ChangeNotifier {
  AdminKycDetailBackend._();
  static final AdminKycDetailBackend instance = AdminKycDetailBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Mengambil detail satu data KYC dari Supabase berdasarkan ID
  Future<Map<String, dynamic>?> fetchKycDetail(String kycId) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('user_kyc')
          .select('*')
          .eq('id', kycId)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('[AdminKycDetailBackend] fetchKycDetail error: $e');
      _errorMessage = e.toString();
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Menyetujui (ACC) berkas KYC oleh Super Admin
  Future<bool> approveKyc({
    required String kycId,
    String? adminId,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final aid = adminId ?? _client.auth.currentUser?.id;

      await _client.from('user_kyc').update({
        'status': 'approved',
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': ?aid,
      }).eq('id', kycId);

      // Invalidate cache agar data KYC di admin dan user langsung terbarui
      await DatabaseCacheBalancerService.instance.invalidatePrefix('kyc_');
      debugPrint('[AdminKycDetailBackend] KYC $kycId berhasil disetujui (ACC)');
      return true;
    } catch (e) {
      debugPrint('[AdminKycDetailBackend] approveKyc error: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Menolak berkas KYC dengan alasan wajib
  Future<bool> rejectKyc({
    required String kycId,
    required String rejectReason,
    String? adminId,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final aid = adminId ?? _client.auth.currentUser?.id;

      await _client.from('user_kyc').update({
        'status': 'rejected',
        'reject_reason': rejectReason,
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': ?aid,
      }).eq('id', kycId);

      // Invalidate cache
      await DatabaseCacheBalancerService.instance.invalidatePrefix('kyc_');
      debugPrint('[AdminKycDetailBackend] KYC $kycId berhasil ditolak dengan alasan: $rejectReason');
      return true;
    } catch (e) {
      debugPrint('[AdminKycDetailBackend] rejectKyc error: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
