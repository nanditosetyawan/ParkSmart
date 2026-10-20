import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_backend.dart';

/// Backend khusus untuk FeedbackScreen (lib/features/profile/feedback_screen.dart)
/// Menyimpan ulasan pengguna ke tabel `public.customer_feedbacks` di Supabase
class FeedbackBackend extends ChangeNotifier {
  FeedbackBackend._();
  static final FeedbackBackend instance = FeedbackBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Mengirim ulasan pengguna ke database Supabase
  Future<bool> submitFeedback({
    required int rating,
    required String comment,
    String? locationId,
    List<String>? selectedTopics,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activeUserId = ProfileBackend.instance.userId;

      String fullComment = comment.trim();
      if (selectedTopics != null && selectedTopics.isNotEmpty) {
        fullComment = '[${selectedTopics.join(', ')}] $fullComment'.trim();
      }

      await _client.from('customer_feedbacks').insert({
        'user_id': activeUserId,
        'location_id': locationId,
        'rating': rating,
        'comment': fullComment.isNotEmpty ? fullComment : 'Ulasan pengguna ParkSmart bintang $rating',
        'is_resolved': false,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[FeedbackBackend] submitFeedback error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
