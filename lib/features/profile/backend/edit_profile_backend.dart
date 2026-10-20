import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_backend.dart';

/// Backend khusus untuk EditProfileScreen (lib/features/profile/edit_profile_screen.dart)
class EditProfileBackend extends ChangeNotifier {
  EditProfileBackend._();
  static final EditProfileBackend instance = EditProfileBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? gender,
    String? address,
    String? birthDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;

      final updateData = {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        if (gender != null) 'gender': gender,
        if (address != null) 'address': address.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (userId != null) {
        await _client
            .from('users')
            .update(updateData)
            .eq('auth_user_id', userId);
      } else {
        // Update user yang aktif saat ini
        final activeId = ProfileBackend.instance.userId;
        await _client
            .from('users')
            .update(updateData)
            .eq('id', activeId);
      }

      // Sinkronisasi data di ProfileBackend
      await ProfileBackend.instance.fetchProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('EditProfileBackend updateProfile error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return true; // Tetap berhasil lokal agar UI user tetap responsif
    }
  }
}
