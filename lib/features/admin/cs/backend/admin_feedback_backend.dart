import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk FeedbackAdminScreen (admin_feedback_screen.dart)
/// Mengelola ulasan pengguna, penilaian bintang, dan balasan resmi admin CS
/// Terkoneksi ke `public.parking_reviews` atau fallback di Supabase
class AdminFeedbackBackend extends ChangeNotifier {
  AdminFeedbackBackend._();
  static final AdminFeedbackBackend instance = AdminFeedbackBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _defaultFeedbacks = [
    {
      'id': 'FDB-001',
      'user': 'Rafi Maulana',
      'avatar': 'R',
      'rating': 5,
      'location': 'Central Park Mall (B2)',
      'date': 'Hari ini, 11:20',
      'comment': 'Sensor gate dan QR ticket sangat cepat! Tidak perlu antre lama di pos keluar.',
      'adminReply': 'Terima kasih atas apresiasinya Kak Rafi! Kami terus berupaya menjaga kecepatan sistem.',
      'isResolved': true,
    },
    {
      'id': 'FDB-002',
      'user': 'Hana Aulia',
      'avatar': 'H',
      'rating': 2,
      'location': 'Grand Indonesia',
      'date': 'Kemarin, 19:45',
      'comment': 'Marka slot nomor C-05 agak pudar jadi sempat salah parkir di slot booking orang lain.',
      'adminReply': null,
      'isResolved': false,
    },
    {
      'id': 'FDB-003',
      'user': 'Budi Santoso',
      'avatar': 'B',
      'rating': 4,
      'location': 'Malioboro Mall',
      'date': '2 hari lalu',
      'comment': 'Fitur perpanjang timer tiket parkir sangat membantu pas lagi meeting mendadak.',
      'adminReply': 'Senang mendengar fitur extend timer bermanfaat untuk Kak Budi!',
      'isResolved': true,
    },
    {
      'id': 'FDB-004',
      'user': 'Dewi Lestari',
      'avatar': 'D',
      'rating': 5,
      'location': 'Pacific Place SCBD',
      'date': '3 hari lalu',
      'comment': 'Slot EV Fast Charger berfungsi sangat baik, daya masuk stabil 22 kW.',
      'adminReply': null,
      'isResolved': true,
    },
    {
      'id': 'FDB-005',
      'user': 'Joko Widarto',
      'avatar': 'J',
      'rating': 1,
      'location': 'Central Park Mall',
      'date': '1 minggu lalu',
      'comment': 'Barrier gate sempat macet 5 menit sebelum sensor terbuka otomatis.',
      'adminReply': 'Mohon maaf atas kendalanya. Kami telah melakukan kompensasi saldo dompet Rp 50.000 ke akun Bapak.',
      'isResolved': true,
    },
  ];

  late List<Map<String, dynamic>> feedbacks = List.from(_defaultFeedbacks);

  /// Mengambil data ulasan dari Supabase
  Future<void> fetchFeedbacks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_reviews')
          .select('id, rating, comment, reply, created_at')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        feedbacks = res.map<Map<String, dynamic>>((row) {
          final reply = row['reply']?.toString();
          return {
            'id': row['id']?.toString() ?? 'FDB-000',
            'user': 'Pelanggan ParkSmart',
            'avatar': 'P',
            'rating': (row['rating'] as num?)?.toInt() ?? 5,
            'location': 'Central Park Mall',
            'date': row['created_at']?.toString().split('T')[0] ?? 'Hari ini',
            'comment': row['comment']?.toString() ?? 'Layanan parkir sangat baik.',
            'adminReply': reply,
            'isResolved': reply != null && reply.isNotEmpty,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminFeedbackBackend] fetchFeedbacks error: $e');
      _errorMessage = e.toString();
      if (feedbacks.isEmpty) {
        feedbacks = List.from(_defaultFeedbacks);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengirimkan balasan resmi admin CS
  Future<void> submitReply(String id, String reply) async {
    final idx = feedbacks.indexWhere((f) => f['id'] == id);
    if (idx != -1) {
      feedbacks[idx]['adminReply'] = reply;
      feedbacks[idx]['isResolved'] = true;
      notifyListeners();
    }

    try {
      await _client.from('parking_reviews').update({
        'reply': reply,
      }).eq('id', id);
    } catch (_) {}
  }
}
