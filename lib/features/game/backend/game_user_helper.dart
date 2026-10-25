import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../profile/backend/profile_backend.dart';

/// Helper terpusat untuk me-resolve user_id yang valid di Supabase
/// Digunakan oleh seluruh modul Arcade Game (Car Racing, Claws Crane, Game Lobby, Leaderboard)
class GameUserHelper {
  GameUserHelper._();

  static Future<String?> resolveUserId([String? passedUserId]) async {
    if (passedUserId != null && passedUserId.isNotEmpty) {
      return passedUserId;
    }

    // 1. Cek SessionService
    final sessionUid = SessionService.instance.userId;
    if (sessionUid != null && sessionUid.isNotEmpty) {
      return sessionUid;
    }

    // 2. Cek ProfileBackend
    final profileUid = ProfileBackend.instance.userId;
    if (profileUid.isNotEmpty) {
      return profileUid;
    }

    // 3. Cek SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final prefUid = prefs.getString('user_profile_id') ?? prefs.getString('ps_session_user_id');
    if (prefUid != null && prefUid.isNotEmpty) {
      return prefUid;
    }

    // 4. Cek Supabase Auth
    final client = Supabase.instance.client;
    final authUser = client.auth.currentUser;
    if (authUser != null) {
      try {
        final row = await client.from('users').select('id').eq('auth_user_id', authUser.id).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (e) {
        debugPrint('[GameUserHelper] Error resolving auth user: $e');
      }
    }

    // 5. Cek berdasarkan email dari session atau profile atau SharedPreferences
    final email = SessionService.instance.identifier ??
        (ProfileBackend.instance.email.isNotEmpty ? ProfileBackend.instance.email : null) ??
        prefs.getString('user_profile_email');
    if (email != null && email.isNotEmpty) {
      try {
        final row = await client.from('users').select('id').eq('email', email).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (e) {
        debugPrint('[GameUserHelper] Error resolving by email: $e');
      }
    }

    // 6. Fallback ke akun pengguna aktif utama 'user@gmail.com'
    try {
      final row = await client.from('users').select('id').eq('email', 'user@gmail.com').maybeSingle();
      if (row != null && row['id'] != null) {
        return row['id'].toString();
      }
    } catch (e) {
      debugPrint('[GameUserHelper] Error resolving fallback email: $e');
    }

    // 7. Fallback terakhir: ambil pengguna pertama di tabel users
    try {
      final row = await client.from('users').select('id').order('created_at', ascending: true).limit(1).maybeSingle();
      if (row != null && row['id'] != null) {
        return row['id'].toString();
      }
    } catch (e) {
      debugPrint('[GameUserHelper] Error resolving any user: $e');
    }

    return null;
  }
}
