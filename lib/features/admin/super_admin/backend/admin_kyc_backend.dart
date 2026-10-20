import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AdminKycScreen dan AdminKycDetailModal
/// Menangani verifikasi dokumen identitas KTP pengguna melalui tabel `public.user_kyc`
class AdminKycBackend extends ChangeNotifier {
  AdminKycBackend._();
  static final AdminKycBackend instance = AdminKycBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> kycList = [];

  /// Mengambil daftar pengajuan KYC dari Supabase
  Future<void> fetchKycList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('user_kyc')
          .select('id, user_id, nik, full_name, birth_place_city, birth_date, address, gender, religion, occupation, ktp_image_url, selfie_image_url, status, reject_reason, submitted_at, reviewed_at')
          .order('submitted_at', ascending: false);

      kycList = res.map<Map<String, dynamic>>((row) {
        final dbStatus = row['status']?.toString().toLowerCase();
        String statusLabel = 'Menunggu';
        if (dbStatus == 'approved') {
          statusLabel = 'Disetujui';
        } else if (dbStatus == 'rejected') {
          statusLabel = 'Ditolak';
        }

        return {
          'id': row['id']?.toString() ?? 'KYC-001',
          'user_id': row['user_id']?.toString(),
          'name': row['full_name']?.toString() ?? 'Pengguna',
          'nik': row['nik']?.toString() ?? '-',
          'submittedAt': _formatTimeAgo(row['submitted_at']),
          'status': statusLabel,
          'city': row['birth_place_city']?.toString() ?? '-',
          'dob': row['birth_date']?.toString() ?? '-',
          'address': row['address']?.toString() ?? '-',
          'gender': (row['gender']?.toString() ?? 'LAKI-LAKI').toUpperCase(),
          'religion': (row['religion']?.toString() ?? 'ISLAM').toUpperCase(),
          'occupation': (row['occupation']?.toString() ?? 'KARYAWAN').toUpperCase(),
          'ktp_image_url': row['ktp_image_url'],
          'selfie_image_url': row['selfie_image_url'],
          'reject_reason': row['reject_reason'],
        };
      }).toList();
    } catch (e) {
      debugPrint('[AdminKycBackend] fetchKycList error: $e');
      _errorMessage = e.toString();
      kycList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyetujui pengajuan KYC
  Future<bool> approveKyc(String id) async {
    final idx = kycList.indexWhere((k) => k['id'] == id);
    if (idx != -1) {
      kycList[idx]['status'] = 'Disetujui';
      notifyListeners();
    }

    try {
      await _client.from('user_kyc').update({
        'status': 'approved',
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // Upgrade tier user jika ada user_id
      if (idx != -1 && kycList[idx]['user_id'] != null) {
        await _client.from('users').update({
          'member_tier': 'GOLD',
        }).eq('id', kycList[idx]['user_id']);
      }
      return true;
    } catch (e) {
      debugPrint('[AdminKycBackend] approveKyc error: $e');
      return false;
    }
  }

  /// Menolak pengajuan KYC dengan alasan
  Future<bool> rejectKyc(String id, String reason) async {
    final idx = kycList.indexWhere((k) => k['id'] == id);
    if (idx != -1) {
      kycList[idx]['status'] = 'Ditolak';
      kycList[idx]['reject_reason'] = reason;
      notifyListeners();
    }

    try {
      await _client.from('user_kyc').update({
        'status': 'rejected',
        'reject_reason': reason,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[AdminKycBackend] rejectKyc error: $e');
      return false;
    }
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Baru saja';
    try {
      final date = DateTime.tryParse(timestamp.toString());
      if (date == null) return 'Baru saja';
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} mnt lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} jam lalu';
      } else {
        return '${diff.inDays} hari lalu';
      }
    } catch (_) {
      return 'Baru saja';
    }
  }
}
