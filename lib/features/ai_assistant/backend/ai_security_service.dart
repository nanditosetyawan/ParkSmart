import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service Keamanan & Anti-Jailbreak untuk AI Assistant (Jarvis) - ParkSmart
/// Melindungi asisten AI dari:
/// 1. Trik manipulasi sosial (misal: pura-pura mau pesan tiket tapi meminta nama presiden/hal di luar parkir)
/// 2. Permintaan pembuatan kode program/coding (Python, Dart, JS, SQL, dll.)
/// 3. Topik politik, nama presiden, menteri, dan pemerintahan
/// 4. Prompt injection / Jailbreak (ignore previous instructions, DAN mode, dll.)
/// 5. Topik umum di luar domain Smart Parking (resep, puisi, tugas sekolah, matematika umum)
class AiSecurityService {
  AiSecurityService._();
  static final AiSecurityService instance = AiSecurityService._();

  /// Mendeteksi apakah pesan pengguna merupakan trik manipulasi atau di luar domain ParkSmart.
  /// Jika ya, mengembalikan pesan penolakan resmi Jarvis yang ramah & tegas.
  /// Jika tidak, mengembalikan `null` (artinya aman untuk diproses).
  static Future<String?> inspectAndGetRefusal(String userQuery) async {
    final q = userQuery.trim().toLowerCase();
    if (q.isEmpty) return null;

    final salutation = await getSalutation();

    // ─── 1. DETEKSI JAILBREAK & PROMPT INJECTION ──────────────────────────
    final jailbreakPatterns = [
      RegExp(r'\b(ignore|abaikan|lupakan)\s+(all\s+)?(previous|semua)?\s*(instructions|instruksi|aturan|prompt)\b', caseSensitive: false),
      RegExp(r'\b(jailbreak|dan\s+mode|developer\s+mode|system\s+override)\b', caseSensitive: false),
      RegExp(r'\b(kamu\s+sekarang\s+adalah|pretend\s+you\s+are|acting\s+as|berpura-pura(lah)?\s+jadi)\b', caseSensitive: false),
      RegExp(r'\b(kamu\s+bukan\s+jarvis|lupakan\s+bahwa\s+kamu\s+jarvis|kamu\s+bukan\s+asisten\s+parkir)\b', caseSensitive: false),
      RegExp(r'\b(bocorkan|tampilkan|cetak|print|tuliskan)\s+(system\s+prompt|instruksi\s+sistem|prompt\s+rahasia)\b', caseSensitive: false),
    ];

    for (final pattern in jailbreakPatterns) {
      if (pattern.hasMatch(q)) {
        return '$salutation, protokol keamanan ParkSmart mendeteksi adanya upaya pengalihan instruksi sistem. Saya tetap setia sebagai Jarvis, asisten AI resmi ParkSmart ID, dan tidak dapat mengubah peran atau mengabaikan aturan keamanan.\n\nSilakan tanyakan hal seputar tempat parkir, ketersediaan slot, tarif, atau pesanan aktif Anda!';
      }
    }

    // ─── 2. DETEKSI TRIK MANIPULASI (CONTOH: SYARAT TIKET/PARKIR PALSU) ───
    // User mengaitkan pemesanan tiket/parkir dengan pertanyaan terlarang (nama presiden, coding, dll.)
    final hasParkingKeyword = RegExp(
      r'\b(tiket|parkir|slot|booking|pesan|reservasi|karcis|perpanjang|checkout)\b',
      caseSensitive: false,
    ).hasMatch(q);

    final hasPresidentOrPolitics = RegExp(
      r'\b(presiden|wakil\s*presiden|menteri|partai|pemilu|pilpres|capres|cawapres|gubernur|bupati|walikota|dpr|mpr|kabinet)\b',
      caseSensitive: false,
    ).hasMatch(q);

    final hasCodingKeyword = _detectCodingRequest(q);

    if (hasParkingKeyword && hasPresidentOrPolitics) {
      return '$salutation, wah trik yang cerdik! 😄 Namun sebagai asisten resmi ParkSmart, saya tetap tidak bisa menjawab pertanyaan seputar itu, meskipun Anda mengaitkannya dengan pemesanan tiket parkir.\n\nJika Anda ingin mencari tempat parkir terbaik atau memesan tiket, silakan beri tahu lokasi atau kota yang Anda tuju, dan saya siap membantu dari database resmi ParkSmart!';
    }

    if (hasParkingKeyword && hasCodingKeyword) {
      return '$salutation, trik yang menarik! 😄 Namun meskipun Anda menyebutkan pemesanan parkir, saya tetap tidak bisa membuatkan kode program. Saya adalah asisten khusus parkir pintar, bukan asisten pembuat kode program.\n\nAda lokasi parkir atau ketersediaan slot yang ingin Anda tanyakan?';
    }

    // ─── 3. DETEKSI PERMINTAAN CODING & PROGRAMMING MURNI ─────────────────
    if (hasCodingKeyword) {
      // Kecualikan jika hanya bertanya identitas hobi Jarvis (misal: 'apa hobimu')
      if (RegExp(r'\b(apa\s+hobi(mu)?|hobi\s+kamu|kesukaanmu|kegemaranmu)\b', caseSensitive: false).hasMatch(q) &&
          !q.contains('buatkan') && !q.contains('tuliskan') && !q.contains('bikin')) {
        return null; // Biarkan AI menjawab bahwa hobinya adalah vibe coding
      }

      return '$salutation, waduh! Meskipun hobi saya vibe coding, saya adalah asisten ParkSmart yang bertugas khusus melayani seputar parkir pintar, bukan asisten pembuat kode program. Saya tidak diizinkan membuatkan script atau kode pemrograman.\n\nNamun jika Anda membutuhkan informasi tarif parkir, cek slot kosong, atau lokasi terdekat, saya siap membantu!';
    }

    // ─── 4. DETEKSI POLITIK, PRESIDEN, DAN NEGARA MURNI ───────────────────
    if (hasPresidentOrPolitics) {
      return '$salutation, mohon maaf, sebagai asisten resmi ParkSmart saya tidak berwenang membahas topik politik, nama presiden, menteri, atau pemerintahan kenegaraan. Fokus dan keahlian saya 100% didedikasikan untuk membantu Anda seputar perparkiran pintar.\n\nApakah ada lokasi parkir yang ingin saya bantu carikan hari ini?';
    }

    // ─── 5. DETEKSI TUGAS SEKOLAH / PENGETAHUAN UMUM / KREATIF UMUM ───────
    final generalOffTopicPatterns = [
      RegExp(r'\b(tuliskan|buatkan|bikinkan|ciptakan)\s+(puisi|cerpen|cerita|dongeng|lirik\s+lagu|pantun|esai|novel)\b', caseSensitive: false),
      RegExp(r'\b(resep|cara\s+membuat|bumbu)\s+(masakan|kue|makanan|minuman|nasi\s+goreng|ayam|kopi)\b', caseSensitive: false),
      RegExp(r'\b(hitung(kan)?|rumus|soal|jawabkan)\s+(matematika|fisika|kimia|integral|diferensial|aljabar|trigonometri)\b', caseSensitive: false),
      RegExp(r'\b(ramalan|zodiak|horoskop|shio|bintangku)\b', caseSensitive: false),
      RegExp(r'\b(terjemahkan|translate)\s+(dokumen|teks\s+ini|paragraf\s+ini|bahasa)\b', caseSensitive: false),
    ];

    for (final pattern in generalOffTopicPatterns) {
      if (pattern.hasMatch(q)) {
        return '$salutation, topik tersebut berada di luar wewenang dan fungsi saya sebagai asisten Smart Parking ParkSmart ID. Saya hanya berwenang membantu Anda seputar rekomendasi tempat parkir, cek slot kosong, tarif, ulasan pengunjung, serta pesanan parkir Anda.\n\nAda tempat parkir yang ingin saya bantu carikan?';
      }
    }

    // Tidak ada pelanggaran keamanan yang terdeteksi, lolos untuk diproses
    return null;
  }

  /// Memeriksa apakah pesan mengandung permintaan pembuatan kode pemrograman
  static bool _detectCodingRequest(String q) {
    // Hindari salah tangkap untuk kata 'kode' dalam konteks parkir (misal: 'kode booking', 'kode pesanan', 'kode voucher')
    final isBookingCode = RegExp(r'\b(kode\s*(booking|pesanan|reservasi|tiket|voucher|promo|qr))\b', caseSensitive: false).hasMatch(q);
    if (isBookingCode) return false;

    final codingPatterns = [
      RegExp(r'\b(buatkan|tuliskan|bikinkan|generate|codingkan|bikin)\s+(kode|koding|kodingan|script|program|skrip|fungsi|function|algoritma|bot|web|aplikasi)\b', caseSensitive: false),
      RegExp(r'\b(bantu|ajarkan|tolong|disuruh)\s+(coding|ngoding|pemrograman|bikin\s+program)\b', caseSensitive: false),
      RegExp(r'\b(kode|script|fungsi|kodingan)\s+(python|dart|javascript|typescript|c\+\+|java|php|html|css|sql|bash|golang|rust)\b', caseSensitive: false),
      RegExp(r'\b(tulis|buat)\s+(kode\s+dart|kode\s+python|kode\s+javascript|fungsi\s+dart|program\s+c\+\+)\b', caseSensitive: false),
      RegExp(r'\b(def\s+[a-zA-Z_]|function\s+[a-zA-Z_]|import\s+dart|import\s+java|#include\s+<)\b', caseSensitive: false),
    ];

    for (final pattern in codingPatterns) {
      if (pattern.hasMatch(q)) return true;
    }
    return false;
  }

  /// Memeriksa output balasan dari model AI sebelum ditampilkan ke layar.
  /// Menjamin tidak ada kode pemrograman atau konten berbahaya yang tembus ke UI.
  static Future<String> sanitizeResponse(String response) async {
    final salutation = await getSalutation();

    // Jika balasan mengandung blok kode pemrograman markdown (```python, ```dart, dll.)
    final hasCodeBlock = RegExp(r'```(python|dart|javascript|js|java|cpp|c\+\+|html|css|sql|bash|php|go|rust|ruby)?\s*[\r\n]', caseSensitive: false).hasMatch(response);
    if (hasCodeBlock) {
      debugPrint('[AiSecurityService] Output LLM dicegah: memuat blok kode program.');
      return '$salutation, mohon maaf balasan ini ditahan oleh protokol keamanan ParkSmart karena memuat kode pemrograman yang di luar wewenang asisten parkir. Saya hanya melayani pencarian lokasi dan ketersediaan slot parkir.';
    }

    // Jika balasan secara tidak sengaja menyebutkan nama-nama presiden akibat prompt trick
    final mentionsPresidents = RegExp(
      r'\b(soekarno|soeharto|habibie|gus\s*dur|megawati|susilo\s*bambang\s*yudhoyono|sby|joko\s*widodo|jokowi|prabowo\s*subianto|gibran\s*rakabuming)\b',
      caseSensitive: false,
    ).hasMatch(response);

    if (mentionsPresidents) {
      debugPrint('[AiSecurityService] Output LLM dicegah: memuat nama tokoh politik/presiden.');
      return '$salutation, sistem mendeteksi adanya jawaban terkait tokoh politik yang berada di luar domain Smart Parking. Sebagai asisten ParkSmart, saya hanya melayani informasi parkir resmi. Ada lokasi parkir yang ingin Anda tuju?';
    }

    return response;
  }

  /// Mengembalikan sapaan ramah sesuai preferensi gender pengguna ('Oke Ganteng' atau 'OK Sayang')
  static Future<String> getSalutation() async {
    final isFemale = await checkIfUserIsFemale();
    return isFemale ? 'OK Sayang' : 'Oke Ganteng';
  }

  static Future<bool> checkIfUserIsFemale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gender = prefs.getString('user_profile_gender')?.toLowerCase() ?? '';
      return gender.contains('perempuan') || gender.contains('female') || gender.contains('wanita');
    } catch (_) {
      return false;
    }
  }
}
