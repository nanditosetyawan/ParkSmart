import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility untuk hashing dan verifikasi password menggunakan SHA-256
// ============================================================================
// [PETUNJUK PRESENTASI - ENKRIPSI & KEAMANAN PASSWORD (SALTED SHA-256)]
// Algoritma: SHA-256 Cryptographic Hash Algorithm dengan Custom Secret Salt
// Cara Kerja:
// 1. Password pengguna digabung dengan salt rahasia: '$_salt:$password'
// 2. String diubah ke bytes (utf8.encode), lalu di-hash oleh engine sha256 (crypto package).
// 3. Menghasilkan string heksadesimal 64-karakter ireversibel (satu arah).
// 4. Di database Supabase (`public.users`), password hanya disimpan dalam bentuk hash ini.
// ============================================================================
class HashUtil {
  /// Salt aplikasi standar untuk mengamankan digest hash
  static const String _salt = 'ParkSmart_Secure_Salt_2026';

  /// Membuat hash SHA-256 dari plaintext password dengan salt
  static String hashPassword(String password) {
    if (password.isEmpty) return '';
    final bytes = utf8.encode('$_salt:$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Memverifikasi input password terhadap password di database.
  /// Mendukung perbandingan terhadap hash (SHA-256) maupun fallback plaintext (jika belum di-hash).
  static bool verifyPassword(String inputPassword, String storedPassword) {
    if (inputPassword.isEmpty || storedPassword.isEmpty) return false;

    // 1. Cek apakah storedPassword cocok dengan hash input
    final hashedInput = hashPassword(inputPassword);
    if (hashedInput == storedPassword) {
      return true;
    }

    // 2. Fallback backward compatibility: jika di database masih berupa teks asli
    if (inputPassword == storedPassword) {
      return true;
    }

    return false;
  }
}
