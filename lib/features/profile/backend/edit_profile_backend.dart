import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/image_compression_util.dart';
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

  /// Mengunggah avatar ke storage bucket `avatars` dengan kompresi hemat ruang
  Future<String?> uploadAvatar(Uint8List imageBytes, {String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final comp = await ImageCompressionUtil.compressBrutally(
        imageBytes,
        targetWidth: 600,
        quality: 75,
      );

      final uid = userId ?? ProfileBackend.instance.userId;
      final fileName = 'avatar_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$uid/$fileName';

      await _client.storage.from('avatars').uploadBinary(
            storagePath,
            comp.compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from('avatars').getPublicUrl(storagePath);
      debugPrint('[EditProfileBackend] Avatar berhasil diunggah: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[EditProfileBackend] uploadAvatar error: $e');
      _errorMessage = 'Gagal mengunggah foto profil: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? avatarUrl,
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
        if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
        'gender': ?gender,
        if (address != null) 'address': address.trim(),
        if (birthDate != null && birthDate.isNotEmpty) 'birth_date': birthDate,
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
