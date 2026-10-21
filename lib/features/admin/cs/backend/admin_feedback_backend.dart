import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk FeedbackAdminScreen (admin_feedback_screen.dart)
/// Mengelola ulasan pengguna, penilaian bintang, dan balasan resmi admin CS
/// Terkoneksi secara realtime ke tabel `public.customer_feedbacks` dan `public.parking_locations`
class AdminFeedbackBackend extends ChangeNotifier {
  AdminFeedbackBackend._();
  static final AdminFeedbackBackend instance = AdminFeedbackBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> feedbacks = [];
  double averageRating = 0.0;
  String averageRatingString = '0.0';
  int totalAllReviews = 0;

  RealtimeChannel? _realtimeChannel;

  /// Memulai langganan realtime Supabase
  void initRealtimeSubscription() {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = _client.channel('public:admin_feedback')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'customer_feedbacks',
          callback: (payload) {
            debugPrint('[AdminFeedbackBackend] Realtime update dari customer_feedbacks');
            fetchFeedbacks();
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parking_locations',
          callback: (payload) {
            debugPrint('[AdminFeedbackBackend] Realtime update dari parking_locations');
            fetchFeedbacks();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('[AdminFeedbackBackend] initRealtimeSubscription error: $e');
    }
  }

  /// Melepas langganan realtime
  void disposeRealtime() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  /// Format tanggal ulasan
  String _formatDate(dynamic dateRaw) {
    if (dateRaw == null) return 'Hari ini';
    try {
      final dt = DateTime.parse(dateRaw.toString()).toLocal();
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
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

  /// Mengambil data ulasan & agregasi kepuasan bintang dari Supabase
  Future<void> fetchFeedbacks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil data feedback ulasan dari customer_feedbacks
      final res = await _client
          .from('customer_feedbacks')
          .select('id, rating, comment, admin_reply, is_resolved, created_at, users(full_name, phone, avatar_url), parking_locations(name)')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        feedbacks = res.map<Map<String, dynamic>>((row) {
          final reply = row['admin_reply']?.toString();
          final userData = row['users'] as Map<String, dynamic>?;
          final locData = row['parking_locations'] as Map<String, dynamic>?;
          final userName = userData?['full_name'] ?? 'Pelanggan ParkSmart';
          final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'P';
          final locName = locData?['name'] ?? 'Lokasi Parkir';
          final isResolved = (row['is_resolved'] as bool?) ?? (reply != null && reply.isNotEmpty);

          return {
            'id': row['id']?.toString() ?? 'FDB-000',
            'user': userName,
            'avatar': initial,
            'avatar_url': userData?['avatar_url']?.toString(),
            'rating': (row['rating'] as num?)?.toInt() ?? 5,
            'location': locName,
            'date': row['created_at'] != null ? _formatDate(row['created_at']) : 'Hari ini',
            'comment': row['comment']?.toString() ?? '',
            'adminReply': reply,
            'isResolved': isResolved,
          };
        }).toList();
      } else {
        feedbacks = [];
      }

      // 2. Ambil semua lokasi parkir untuk rating kepuasan kumulatif
      int totalLocationReviews = 0;
      double weightedRatingSum = 0.0;
      double unweightedRatingSum = 0.0;
      int locationsWithRating = 0;

      try {
        final locRes = await _client
            .from('parking_locations')
            .select('rating, review_count');

        for (var loc in locRes) {
          final double r = (loc['rating'] as num?)?.toDouble() ?? 0.0;
          final int c = (loc['review_count'] as num?)?.toInt() ?? 0;
          totalLocationReviews += c;
          weightedRatingSum += (r * c);
          if (r > 0) {
            unweightedRatingSum += r;
            locationsWithRating++;
          }
        }
      } catch (e) {
        debugPrint('[AdminFeedbackBackend] parking_locations query error: $e');
      }

      // 3. Gabungkan ulasan dari customer_feedbacks
      int totalFeedbackReviews = feedbacks.length;
      double feedbackRatingSum = 0.0;
      for (var f in feedbacks) {
        feedbackRatingSum += ((f['rating'] as num?)?.toDouble() ?? 5.0);
      }

      totalAllReviews = totalLocationReviews + totalFeedbackReviews;

      if (totalAllReviews > 0) {
        final double totalRatingPoints = weightedRatingSum + feedbackRatingSum;
        averageRating = totalRatingPoints / totalAllReviews;
        averageRatingString = averageRating.toStringAsFixed(1);
      } else if (locationsWithRating > 0) {
        averageRating = unweightedRatingSum / locationsWithRating;
        averageRatingString = averageRating.toStringAsFixed(1);
      } else {
        averageRating = 0.0;
        averageRatingString = '0.0';
      }
    } catch (e) {
      debugPrint('[AdminFeedbackBackend] fetchFeedbacks error: $e');
      _errorMessage = e.toString();
      feedbacks = [];
      averageRating = 0.0;
      averageRatingString = '0.0';
      totalAllReviews = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengirimkan balasan resmi admin CS ke customer_feedbacks
  Future<void> submitReply(String id, String reply) async {
    final idx = feedbacks.indexWhere((f) => f['id'] == id);
    if (idx != -1) {
      feedbacks[idx]['adminReply'] = reply;
      feedbacks[idx]['isResolved'] = true;
      notifyListeners();
    }

    try {
      await _client.from('customer_feedbacks').update({
        'admin_reply': reply,
        'is_resolved': true,
        'replied_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      debugPrint('[AdminFeedbackBackend] submitReply error: $e');
    }
  }
}
