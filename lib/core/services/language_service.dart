import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_service.dart';

/// Layanan Pengelola Bahasa Aplikasi (Indonesian <-> English) - ParkSmart ID
/// Mengatur switch bahasa khusus di sisi pengguna (Client-side UI display).
/// Tidak mengubah data di database, melainkan mengkonversi teks hardcode & data database saat switch ke Inggris.
class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();
  LanguageService._internal();

  static const String _kPrefsLanguage = 'selected_app_language';

  // Default: 'id' (Bahasa Indonesia). Alternatif: 'en' (English).
  String _currentLanguage = 'id';

  String get currentLanguage => _currentLanguage;
  bool get isEnglish => _currentLanguage == 'en';
  bool get isIndonesian => _currentLanguage == 'id';

  /// Inisialisasi dari SharedPreferences saat aplikasi start
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_kPrefsLanguage) ?? 'id';
      notifyListeners();
    } catch (e) {
      debugPrint('[LanguageService] init error: $e');
    }
  }

  /// Mengubah bahasa ('id' atau 'en')
  Future<void> setLanguage(String langCode) async {
    if (langCode != 'id' && langCode != 'en') return;
    if (_currentLanguage == langCode) return;

    _currentLanguage = langCode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefsLanguage, langCode);
    } catch (e) {
      debugPrint('[LanguageService] setLanguage error: $e');
    }
  }

  /// Toggle antara ID dan EN
  Future<void> toggleLanguage() async {
    await setLanguage(isEnglish ? 'id' : 'en');
  }

  /// Menampilkan modal bottom sheet pemilih bahasa yang interaktif dan reaktif
  static void showLanguageSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: Listenable.merge([LanguageService.instance, ThemeService.instance]),
          builder: (context, _) {
            final theme = ThemeService.instance;
            final isDark = theme.isDarkMode;
            final service = LanguageService.instance;
            final isEn = service.isEnglish;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? theme.card : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? theme.border : const Color(0xFFE5E2DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Setel Bahasa'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A18),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Option 1: Bahasa Indonesia
                  GestureDetector(
                    onTap: () async {
                      await service.setLanguage('id');
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: !isEn
                            ? (isDark ? theme.surfaceField : const Color(0xFFF6F3EC))
                            : (isDark ? theme.card : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: !isEn
                              ? (isDark ? Colors.white : const Color(0xFF1A1A18))
                              : (isDark ? theme.border : const Color(0xFFE5E2DB)),
                          width: !isEn ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              'https://flagcdn.com/w320/id.png',
                              width: 32,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Bahasa Indonesia',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: !isEn ? FontWeight.bold : FontWeight.w600,
                                color: !isEn
                                    ? (isDark ? Colors.white : const Color(0xFF1A1A18))
                                    : (isDark ? theme.textSecondary : const Color(0xFF76777B)),
                              ),
                            ),
                          ),
                          if (!isEn)
                            Icon(
                              Icons.check_circle,
                              color: isDark ? Colors.white : const Color(0xFF1A1A18),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Option 2: English
                  GestureDetector(
                    onTap: () async {
                      await service.setLanguage('en');
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isEn
                            ? (isDark ? theme.surfaceField : const Color(0xFFF6F3EC))
                            : (isDark ? theme.card : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEn
                              ? (isDark ? Colors.white : const Color(0xFF1A1A18))
                              : (isDark ? theme.border : const Color(0xFFE5E2DB)),
                          width: isEn ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              'https://flagcdn.com/w320/gb.png',
                              width: 32,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'English (US/UK)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: isEn ? FontWeight.bold : FontWeight.w600,
                                color: isEn
                                    ? (isDark ? Colors.white : const Color(0xFF1A1A18))
                                    : (isDark ? theme.textSecondary : const Color(0xFF76777B)),
                              ),
                            ),
                          ),
                          if (isEn)
                            Icon(
                              Icons.check_circle,
                              color: isDark ? Colors.white : const Color(0xFF1A1A18),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Menerjemahkan teks dari Bahasa Indonesia ke Bahasa Inggris jika bahasa aktif adalah 'en'.
  /// Jika bahasa aktif adalah 'id', mengembalikan teks asli apa adanya.
  String tr(String? input) {
    if (input == null || input.isEmpty) return '';
    if (!isEnglish) return input;

    final trimmed = input.trim();

    // 1. Exact match dictionary
    if (_dictionary.containsKey(trimmed)) {
      return _matchCase(input, _dictionary[trimmed]!);
    }

    final lower = trimmed.toLowerCase();
    if (_dictionaryLower.containsKey(lower)) {
      return _matchCase(input, _dictionaryLower[lower]!);
    }

    // 2. Pattern matching dinamis (cth: "3 Kali", "2 Jam", "Slot A-01", "Lantai 1", "Masuk: ...")
    final dynamicMatch = _translateDynamicPatterns(trimmed);
    if (dynamicMatch != null) {
      return dynamicMatch;
    }

    return input;
  }

  /// Penyesuaian huruf besar/kecil (Capital, ALL CAPS, lowercase)
  String _matchCase(String original, String translation) {
    if (original == original.toUpperCase() && original.length > 1) {
      return translation.toUpperCase();
    }
    return translation;
  }

  /// Pola dinamis yang menggabungkan angka dan kata
  String? _translateDynamicPatterns(String text) {
    // Pola "Siap pakai di X" -> "Ready to use at X"
    if (text.startsWith('Siap pakai di ')) {
      final f = text.substring(14);
      return 'Ready to use at ${f.tr}';
    }

    // Pola "Slot Ditahan (XX:XX)" -> "Slot Held (XX:XX)"
    final slotDitahanMatch = RegExp(r'^Slot Ditahan \((.+)\)$', caseSensitive: false).firstMatch(text);
    if (slotDitahanMatch != null) {
      return 'Slot Held (${slotDitahanMatch.group(1)})';
    }

    // Pola "Selesaikan Pembayaran (XX:XX)" -> "Complete Payment (XX:XX)"
    final selesaikanMatch = RegExp(r'^Selesaikan Pembayaran \((.+)\)$', caseSensitive: false).firstMatch(text);
    if (selesaikanMatch != null) {
      return 'Complete Payment (${selesaikanMatch.group(1)})';
    }

    // Pola "Bayar Sekarang (XX:XX)" -> "Pay Now (XX:XX)"
    final bayarSekarangMatch = RegExp(r'^Bayar Sekarang \((.+)\)$', caseSensitive: false).firstMatch(text);
    if (bayarSekarangMatch != null) {
      return 'Pay Now (${bayarSekarangMatch.group(1)})';
    }

    // Pola "Belum Bayar • XX:XX" -> "Unpaid • XX:XX"
    if (text.startsWith('Belum Bayar • ')) {
      return 'Unpaid • ${text.substring(14)}';
    }

    // Pola "Tarif Parkir (X Jam • Y)" -> "Parking Rate (X Hours • Y)"
    final tarifParkirMatch = RegExp(r'^Tarif Parkir \((.+)\)$', caseSensitive: false).firstMatch(text);
    if (tarifParkirMatch != null) {
      return 'Parking Rate (${tarifParkirMatch.group(1)!.tr})';
    }

    // Pola "Belum ada slot di Zona A (X)" -> "No slots in Zone A (X) yet"
    final zoneAMatch = RegExp(r'^Belum ada slot di Zona A \((.+)\)$', caseSensitive: false).firstMatch(text);
    if (zoneAMatch != null) {
      return 'No slots in Zone A (${zoneAMatch.group(1)!.tr}) yet';
    }

    // Pola "Belum ada slot di Zona B (X)" -> "No slots in Zone B (X) yet"
    final zoneBMatch = RegExp(r'^Belum ada slot di Zona B \((.+)\)$', caseSensitive: false).firstMatch(text);
    if (zoneBMatch != null) {
      return 'No slots in Zone B (${zoneBMatch.group(1)!.tr}) yet';
    }

    // Pola "Jalur Sirkulasi X" -> "Circulation Lane X"
    if (text.startsWith('Jalur Sirkulasi ')) {
      final rest = text.substring(16);
      return 'Circulation Lane ${rest.tr}';
    }

    // Pola "X Slot" -> "X Slots"
    final xSlotMatch = RegExp(r'^(\d+)\s+Slot$', caseSensitive: false).firstMatch(text);
    if (xSlotMatch != null) {
      final num = xSlotMatch.group(1);
      return num == '1' ? '1 Slot' : '$num Slots';
    }

    // Pola "X Jam Durasi" -> "X Hours Duration"
    final xJamDurasiMatch = RegExp(r'^(\d+)\s+Jam Durasi$', caseSensitive: false).firstMatch(text);
    if (xJamDurasiMatch != null) {
      final num = xJamDurasiMatch.group(1);
      return num == '1' ? '1 Hour Duration' : '$num Hours Duration';
    }

    // Pola "Tersedia (X)" -> "Available (X)"
    if (text.startsWith('Tersedia (') && text.endsWith(')')) {
      final inner = text.substring(10, text.length - 1);
      return 'Available (${inner.tr})';
    }

    // Pola "Jadwal dialihkan ke X" -> "Schedule switched to X"
    if (text.startsWith('Jadwal dialihkan ke ')) {
      return 'Schedule switched to ${text.substring(20)}';
    }

    // Pola "Berhasil tiba di X!" -> "Successfully arrived at X!"
    if (text.startsWith('Berhasil tiba di ') && text.endsWith('!')) {
      final loc = text.substring(17, text.length - 1);
      return 'Successfully arrived at $loc!';
    }

    // Pola "Foto X" -> "Photo X"
    if (text.startsWith('Foto ') && text.length > 5) {
      return 'Photo ${text.substring(5)}';
    }

    // Pola "Kode: X" -> "Code: X"
    if (text.startsWith('Kode: ')) {
      return 'Code: ${text.substring(6)}';
    }

    // Pola "(1 Jam Pertama • X)" -> "(First 1 Hour • X)"
    if (text.startsWith('(1 Jam Pertama • ') && text.endsWith(')')) {
      final rest = text.substring(17, text.length - 1);
      return '(First 1 Hour • ${rest.tr})';
    }

    // Pola "Halo, Nama" -> "Hello, Nama"
    if (text.startsWith('Halo, ')) {
      return 'Hello, ${text.substring(6)}';
    }
    if (text.startsWith('Selamat Datang, ')) {
      return 'Welcome, ${text.substring(16)}';
    }

    // Pola "X Kali" -> "X Times"
    final kaliMatch = RegExp(r'^(\d+)\s+Kali$', caseSensitive: false).firstMatch(text);
    if (kaliMatch != null) {
      final num = kaliMatch.group(1);
      return num == '1' ? '1 Time' : '$num Times';
    }

    // Pola "X Jam" -> "X Hours"
    final jamMatch = RegExp(r'^(\d+)\s+Jam$', caseSensitive: false).firstMatch(text);
    if (jamMatch != null) {
      final num = jamMatch.group(1);
      return num == '1' ? '1 Hour' : '$num Hours';
    }

    // Pola "X Menit" -> "X Minutes"
    final menitMatch = RegExp(r'^(\d+)\s+Menit$', caseSensitive: false).firstMatch(text);
    if (menitMatch != null) {
      final num = menitMatch.group(1);
      return num == '1' ? '1 Minute' : '$num Minutes';
    }

    // Pola "X Detik" -> "X Seconds"
    final detikMatch = RegExp(r'^(\d+)\s+Detik$', caseSensitive: false).firstMatch(text);
    if (detikMatch != null) {
      final num = detikMatch.group(1);
      return num == '1' ? '1 Second' : '$num Seconds';
    }

    // Pola "X Hari" -> "X Days"
    final hariMatch = RegExp(r'^(\d+)\s+Hari$', caseSensitive: false).firstMatch(text);
    if (hariMatch != null) {
      final num = hariMatch.group(1);
      return num == '1' ? '1 Day' : '$num Days';
    }

    // Pola "Lantai X" -> "Floor X"
    final lantaiMatch = RegExp(r'^Lantai\s+(.+)$', caseSensitive: false).firstMatch(text);
    if (lantaiMatch != null) {
      return 'Floor ${lantaiMatch.group(1)}';
    }

    // Pola "Slot X" -> "Slot X"
    final slotMatch = RegExp(r'^Slot\s+(.+)$', caseSensitive: false).firstMatch(text);
    if (slotMatch != null) {
      return 'Slot ${slotMatch.group(1)}';
    }

    // Pola "Masuk: X" -> "In: X"
    if (text.startsWith('Masuk: ')) {
      return 'In: ${text.substring(7)}';
    }

    // Pola "Keluar: X" -> "Out: X"
    if (text.startsWith('Keluar: ')) {
      final rest = text.substring(8);
      if (rest.toLowerCase().contains('sedang parkir')) {
        return 'Out: Currently Parked';
      }
      return 'Out: $rest';
    }

    // Pola "Saldo: X" -> "Balance: X"
    if (text.startsWith('Saldo: ')) {
      return 'Balance: ${text.substring(7)}';
    }

    // Pola "Saldo Saat Ini: X" -> "Current Balance: X"
    if (text.startsWith('Saldo Saat Ini: ')) {
      return 'Current Balance: ${text.substring(16)}';
    }

    // Pola "... • Milik Pribadi" -> "... • Personal Vehicle"
    if (text.endsWith(' • Milik Pribadi')) {
      final prefix = text.substring(0, text.length - ' • Milik Pribadi'.length);
      return '${prefix.tr} • Personal Vehicle';
    }

    // Pola "Gol. I (XYZ)" -> "Class I (XYZ)"
    if (text.startsWith('Gol. ')) {
      return 'Class ${text.substring(5)}';
    }

    // Pola vehicle status update snackbars
    if (text.endsWith(' sekarang menjadi kendaraan utama.')) {
      final name = text.substring(0, text.length - ' sekarang menjadi kendaraan utama.'.length);
      return '$name is now the primary vehicle.';
    }
    if (text.endsWith(' berhasil dijadikan Kendaraan Utama!')) {
      final name = text.substring(0, text.length - ' berhasil dijadikan Kendaraan Utama!'.length);
      return '$name is now set as the primary vehicle!';
    }

    // Pola "Batas Selesai X" -> "Deadline X"
    if (text.startsWith('Batas Selesai ')) {
      return 'Deadline ${text.substring(14)}';
    }

    // Pola "Masuk X" -> "In X"
    if (text.startsWith('Masuk ') && !text.startsWith('Masuk Gerbang')) {
      return 'In ${text.substring(6)}';
    }

    // Pola "Durasi Paket: X Jam" -> "Package Duration: X Hours"
    final durasiMatch = RegExp(r'^Durasi Paket:\s*(\d+)\s+Jam$', caseSensitive: false).firstMatch(text);
    if (durasiMatch != null) {
      final num = durasiMatch.group(1);
      return num == '1' ? 'Package Duration: 1 Hour' : 'Package Duration: $num Hours';
    }

    // Pola "Tarif Parkir (X)" -> "Parking Fare (X)"
    final tarifMatch = RegExp(r'^Tarif Parkir \((.+)\)$', caseSensitive: false).firstMatch(text);
    if (tarifMatch != null) {
      return 'Parking Fare (${tarifMatch.group(1)!.tr})';
    }

    // Pola "Konfirmasi & Bayar X" -> "Confirm & Pay X"
    if (text.startsWith('Konfirmasi & Bayar ')) {
      return 'Confirm & Pay ${text.substring(19)}';
    }

    // Pola "Terima Kasih, X." -> "Thank You, X."
    if (text.startsWith('Terima Kasih, ')) {
      return 'Thank You, ${text.substring(14)}';
    }

    // Pola "X • Siap Keluar" -> "X • Ready to Exit"
    if (text.endsWith(' • Siap Keluar')) {
      final prefix = text.substring(0, text.length - ' • Siap Keluar'.length);
      return '$prefix • Ready to Exit';
    }

    // Pola "Hingga X" -> "Until X"
    if (text.startsWith('Hingga ')) {
      return 'Until ${text.substring(7)}';
    }

    // Pola "Sesi parkir Anda telah selesai. Palang keluar akan terbuka otomatis saat mendekati X."
    if (text.startsWith('Sesi parkir Anda telah selesai. Palang keluar akan terbuka otomatis saat mendekati ')) {
      final gate = text.substring(84, text.length - (text.endsWith('.') ? 1 : 0));
      return 'Your parking session has ended. The exit barrier will open automatically as you approach $gate.';
    }

    // Pola "Selamat Datang di\nX."
    if (text.startsWith('Selamat Datang di\n')) {
      return 'Welcome to\n${text.substring(18)}';
    }

    // Pola "Silakan maju perlahan menuju X. Navigasi slot Y telah dipandu di layar."
    final majuMatch = RegExp(r'^Silakan maju perlahan menuju (.+)\. Navigasi slot (.+) telah dipandu di layar\.$', caseSensitive: false).firstMatch(text);
    if (majuMatch != null) {
      return 'Please proceed slowly towards ${majuMatch.group(1)}. Navigation to slot ${majuMatch.group(2)} is guided on screen.';
    }

    // Pola "+X Menit" -> "+X Minutes"
    final plusMenitMatch = RegExp(r'^\+(\d+)\s+Menit$', caseSensitive: false).firstMatch(text);
    if (plusMenitMatch != null) {
      final num = plusMenitMatch.group(1);
      return num == '1' ? '+1 Minute' : '+$num Minutes';
    }

    // Pola "+X Jam" -> "+X Hours"
    final plusJamMatch = RegExp(r'^\+(\d+)\s+Jam$', caseSensitive: false).firstMatch(text);
    if (plusJamMatch != null) {
      final num = plusJamMatch.group(1);
      return num == '1' ? '+1 Hour' : '+$num Hours';
    }

    // Pola Denda overstay otomatis
    if (text.startsWith('Denda overstay otomatis ')) {
      return 'Automatic overstay fee ${text.substring(24)}';
    }

    // Pola Notifikasi Saldo Dompet Masuk & Injeksi
    final notifDompetMatch = RegExp(r'^Saldo sebesar (.+) telah ditambahkan ke dompet digital Anda oleh Admin Finansial\. Keterangan: (.*)$', caseSensitive: false).firstMatch(text);
    if (notifDompetMatch != null) {
      return 'Balance of ${notifDompetMatch.group(1)} has been added to your digital wallet by Financial Admin. Note: ${notifDompetMatch.group(2)}';
    }
    final notifDompetGeneralMatch = RegExp(r'^Saldo sebesar (.+) telah ditambahkan ke dompet digital Anda\.?(.*)$', caseSensitive: false).firstMatch(text);
    if (notifDompetGeneralMatch != null) {
      return 'Balance of ${notifDompetGeneralMatch.group(1)} has been added to your digital wallet.${notifDompetGeneralMatch.group(2)}';
    }
    final notifAdminInjeksiMatch = RegExp(r'^Berhasil menambahkan saldo (.+) ke dompet (.+)\. Keterangan: (.*)$', caseSensitive: false).firstMatch(text);
    if (notifAdminInjeksiMatch != null) {
      return 'Successfully added balance of ${notifAdminInjeksiMatch.group(1)} to ${notifAdminInjeksiMatch.group(2)}\'s wallet. Note: ${notifAdminInjeksiMatch.group(3)}';
    }

    // Pola Top Up SnackBar
    final topUpSuccessMatch = RegExp(r'^Top Up (.+) berhasil!$', caseSensitive: false).firstMatch(text);
    if (topUpSuccessMatch != null) {
      return 'Top Up of ${topUpSuccessMatch.group(1)} successful!';
    }

    // Pola Kepadatan Area Home Screen
    final macetTotalMatch = RegExp(r'^Macet Total \((\d+%)\)$', caseSensitive: false).firstMatch(text);
    if (macetTotalMatch != null) return 'Severe Congestion (${macetTotalMatch.group(1)})';

    final macetPadatMatch = RegExp(r'^Macet Padat \((\d+%)\)$', caseSensitive: false).firstMatch(text);
    if (macetPadatMatch != null) return 'Heavy Traffic (${macetPadatMatch.group(1)})';

    final padatMerayapMatch = RegExp(r'^Padat Merayap \((\d+%)\)$', caseSensitive: false).firstMatch(text);
    if (padatMerayapMatch != null) return 'Slow Moving (${padatMerayapMatch.group(1)})';

    final ramaiLancarMatch = RegExp(r'^Ramai Lancar \((\d+%)\)$', caseSensitive: false).firstMatch(text);
    if (ramaiLancarMatch != null) return 'Moderate Traffic (${ramaiLancarMatch.group(1)})';

    final lengangMatch = RegExp(r'^Tersedia Lengang \((\d+%)\)$', caseSensitive: false).firstMatch(text);
    if (lengangMatch != null) return 'Light Traffic (${lengangMatch.group(1)})';

    // Pola Explore Map Subtitle Jarak & Slot
    final distSlotMatch = RegExp(r'^(.+)\s*•\s*(\d+)\s+slot\s+tersedia$', caseSensitive: false).firstMatch(text);
    if (distSlotMatch != null) {
      final dist = distSlotMatch.group(1);
      final slots = distSlotMatch.group(2);
      return '$dist • $slots slots available';
    }
    final slotTersediaMatch = RegExp(r'^(\d+)\s+slot\s+tersedia$', caseSensitive: false).firstMatch(text);
    if (slotTersediaMatch != null) {
      return '${slotTersediaMatch.group(1)} slots available';
    }
    final ulasanCountMatch = RegExp(r'^(\d+)\s+ulasan$', caseSensitive: false).firstMatch(text);
    if (ulasanCountMatch != null) {
      return '${ulasanCountMatch.group(1)} reviews';
    }

    // Pola Turn-by-Turn Navigasi
    final navDistTurnMatch = RegExp(r'^(\d+m\s+)(.+)$', caseSensitive: false).firstMatch(text);
    if (navDistTurnMatch != null) {
      final distPrefix = navDistTurnMatch.group(1)!;
      final turnWord = navDistTurnMatch.group(2)!;
      return '$distPrefix${turnWord.tr}';
    }
    if (text.startsWith('Menuju ')) {
      return 'Towards ${text.substring(7)}';
    }

    // Pola Tarif per Jam
    if (text.endsWith(' / jam')) {
      return '${text.substring(0, text.length - 6)} / hour';
    }

    // Pola Waktu Yang Lalu
    if (text.endsWith(' hari yang lalu')) {
      final days = text.substring(0, text.length - ' hari yang lalu'.length);
      return '$days days ago';
    }
    if (text.endsWith(' jam yang lalu')) {
      final hours = text.substring(0, text.length - ' jam yang lalu'.length);
      return '$hours hours ago';
    }
    if (text.endsWith(' menit yang lalu')) {
      final mins = text.substring(0, text.length - ' menit yang lalu'.length);
      return '$mins mins ago';
    }

    // Pola gabungan bullet "Part1 • Part2"
    if (text.contains(' • ')) {
      final parts = text.split(' • ');
      final translated = parts.map((p) => p.tr).toList();
      return translated.join(' • ');
    }

    return null;
  }

  // =========================================================================
  // KAMUS KATA & FRASA LENGKAP USER APP (Hardcode & Database)
  // =========================================================================
  static final Map<String, String> _dictionary = {
    // ---------------- Notifikasi di User ----------------
    'Saldo Dompet Masuk': 'Wallet Balance Received',
    'Injeksi Saldo Dompet': 'Wallet Balance Injected',
    'Pemberitahuan Sistem (Supabase Live)': 'System Notifications (Supabase Live)',
    'Belum Ada Notifikasi': 'No Notifications Yet',
    'Pemberitahuan resmi seputar reservasi, timer parkir, dan promo akun Anda akan masuk di sini.': 'Official notifications regarding reservations, parking timers, and promos for your account will appear here.',
    'Tandai Dibaca': 'Mark as Read',

    // ---------------- Riwayat Mutasi Saldo & Top Up ----------------
    'Riwayat Mutasi Saldo': 'Balance Mutation History',
    'Aktivitas ParkSmart Pay & Parkir': 'ParkSmart Pay & Parking Activity',
    'SALDO PARKSMART PAY': 'PARKSMART PAY BALANCE',
    'Masuk': 'Income',
    'Keluar': 'Expense',
    'Semua': 'All',
    'Masuk (+)': 'Income (+)',
    'Keluar (-)': 'Expense (-)',
    'Belum ada transaksi': 'No transactions yet',
    'Riwayat mutasi pengisian saldo (Top Up) atau pembayaran parkir Anda akan otomatis tercatat di sini.': 'Your balance top up or parking payment transaction history will automatically appear here.',
    'Lihat Detail Sesi Parkir Lengkap': 'View Full Parking Session Details',
    'Isi Ulang Saldo (Top Up)': 'Balance Top Up',
    'Top Up Saldo ParkSmart Pay (bank_va)': 'ParkSmart Pay Top Up (bank_va)',
    'Top Up ParkSmart Pay': 'Top Up ParkSmart Pay',
    'Pilih nominal isi ulang saldo parkir Anda': 'Select your parking balance top up amount',
    'Konfirmasi Top Up': 'Confirm Top Up',
    'Gagal memproses Top Up. Silakan coba lagi.': 'Failed to process Top Up. Please try again.',
    'No. Referensi': 'Reference No.',
    'Waktu Transaksi': 'Transaction Time',
    'Metode/Kanal': 'Method/Channel',
    'Keterangan': 'Description',
    'Status': 'Status',
    'Tutup': 'Close',

    // ---------------- Add Vehicle ----------------
    'Add Vehicle': 'Add Vehicle',
    'Tambah Kendaraan': 'Add Vehicle',
    'Scan Plate': 'Scan Plate',
    'AI OCR': 'AI OCR',
    'Open Camera': 'Open Camera',
    'Buka Kamera': 'Open Camera',
    'Vehicle Category': 'Vehicle Category',
    'Kategori Kendaraan': 'Vehicle Category',
    'Penentu Tarif Gerbang': 'Gate Rate Decider',
    'Gate Rate Decider': 'Gate Rate Decider',
    'Mobil / SUV': 'Car / SUV',
    'Sedan / City': 'Sedan / City',
    'Motor Roda 2': '2-Wheel Motorcycle',
    'Golongan I': 'Class I',
    'Golongan II': 'Class II',
    'Nomor Polisi (TNKB)': 'License Plate (TNKB)',
    'License Plate (TNKB)': 'License Plate (TNKB)',
    'Wajib Foto (2x)': 'Photo Required (2x)',
    'Terverifikasi Foto': 'Photo Verified',
    'Gunakan tombol "Buka Kamera" di atas untuk memindai plat & STNK. Plat hitam akan terisi otomatis.': 'Use the "Open Camera" button above to scan license plate & STNK. Black plate will be filled automatically.',
    'Plat dan masa berlaku terisi dari foto (gunakan tombol "Buka Kamera" di atas jika ingin foto ulang).': 'Plate and expiry filled from photo (use "Open Camera" button above to retake photo).',
    'Detail Kendaraan': 'Vehicle Details',
    'Merek & Warna': 'Brand & Color',
    'Brand & Color': 'Brand & Color',
    'Pilihan Warna:': 'Color Choice:',
    'Putih Mutiara': 'Pearl White',
    'Hitam Solid': 'Solid Black',
    'Abu-Abu Metalik': 'Metallic Grey',
    'Merah Maroon': 'Maroon Red',
    'Silver Quartz': 'Silver Quartz',
    'Foto Fisik Kendaraan': 'Vehicle Physical Photo',
    'Opsional': 'Optional',
    'Ganti': 'Change',
    'Simpan Kendaraan': 'Save Vehicle',
    'Kendaraan berhasil disimpan!': 'Vehicle successfully saved!',
    'Wajib mengambil 2 foto: Plat Nomor & Masa Berlaku STNK terlebih dahulu!': 'Must take 2 photos: License Plate & STNK Expiry first!',

    // ---------------- Kepadatan Area Home Screen ----------------
    'KEPADATAN AREA': 'AREA DENSITY',
    'Macet': 'Congested',
    'Ramai': 'Busy',
    'Lancar': 'Clear',
    'Macet Total': 'Severe Congestion',
    'Macet Padat': 'Heavy Traffic',
    'Padat Merayap': 'Slow Moving',
    'Ramai Lancar': 'Moderate Traffic',
    'Tersedia Lengang': 'Light Traffic',
    'Live Traffic': 'Live Traffic',

    // ---------------- Explore Map & Rekomendasi Parkir ----------------
    'Cari kota di Indonesia, SPBU...': 'Search cities in Indonesia, gas stations...',
    'Terdekat': 'Nearby',
    'Mall': 'Mall',
    'Parkir EV': 'EV Parking',
    'Suasana lokal': 'Local atmosphere',
    'Cerah': 'Sunny',
    'Sebagian Cerah': 'Partly Sunny',
    'Cerah Berawan': 'Partly Cloudy',
    'Berawan': 'Cloudy',
    'Berkabut': 'Foggy',
    'Gerimis': 'Drizzle',
    'Hujan': 'Rain',
    'Salju': 'Snow',
    'Hujan Lebat': 'Heavy Rain',
    'Badai Petir': 'Thunderstorm',
    'Rekomendasi Parkir Terdekat': 'Nearby Parking Recommendations',
    'Khusus EV': 'EV Only',
    'Mobil & Motor': 'Car & Motor',
    'TARIF PARKIR': 'PARKING RATE',
    'Jelajahi': 'Explore',
    'Favorite': 'Favorite',
    'Home': 'Home',

    // ---------------- Navigasi Parkiran Turn-by-Turn ----------------
    'Mencari GPS...': 'Searching for GPS...',
    'GPS Terkunci': 'GPS Locked',
    'Belok Kiri': 'Turn Left',
    'Belok Kanan': 'Turn Right',
    'Lurus Terus': 'Continue Straight',
    'Tiba di Lokasi Tujuan': 'Arrive at Destination',
    'Masuk Bundaran': 'Enter Roundabout',
    'Lanjut lurus': 'Continue straight',
    'Panduan suara dinonaktifkan': 'Voice guidance disabled',
    'Panduan suara diaktifkan': 'Voice guidance enabled',

    // ---------------- Tab Ringkasan, Ulasan, Tentang di Explore Map ----------------
    'Ringkasan': 'Overview',
    'Ulasan': 'Reviews',
    'Tentang': 'About',
    'Rincian Parkir': 'Parking Details',
    'Tarif Resmi': 'Official Rate',
    'Kapasitas': 'Capacity',
    'Operasional': 'Operating Hours',
    'Buka • Tutup 22.00 WIB': 'Open • Closes 22:00 WIB',
    'Buka 24 Jam': 'Open 24 Hours',
    'Metode Masuk': 'Entry Method',
    'Tiket / Palang Otomatis & QRIS': 'Ticket / Automatic Gate & QRIS',
    '+ Tambah Foto': '+ Add Photo',
    'oleh Admin': 'by Admin',
    'ulasan': 'reviews',
    'Ulasan Pengunjung': 'Visitor Reviews',
    '+ Tulis Ulasan': '+ Write Review',
    'Tulis Ulasan Parkir': 'Write Parking Review',
    'Topik Masukan': 'Feedback Topic',
    'Pilih satu atau lebih': 'Choose one or more',
    'Akurasi Sensor ANPR': 'ANPR Sensor Accuracy',
    'Kemudahan Gate': 'Gate Convenience',
    'Ketersediaan Slot': 'Slot Availability',
    'Tarif & Pembayaran': 'Rates & Payment',
    'Lainnya': 'Other',
    'Tentang Parkiran': 'About Parking',
    'Fasilitas & Layanan': 'Amenities & Services',
    'CCTV 24 Jam': '24-Hour CCTV',
    'Stasiun EV': 'EV Charging Station',
    'Atap Tertutup': 'Covered Roof',
    'Palang Otomatis': 'Automatic Gate',
    'Cashless / QRIS': 'Cashless / QRIS',
    'Security 24 Jam': '24-Hour Security',
    'Penerangan LED': 'LED Lighting',

    // ---------------- Navigasi & Dock ----------------
    'Beranda': 'Home',
    'Cari': 'Search',
    'Riwayat': 'History',
    'Profil': 'Profile',
    'Sesi': 'Session',
    'Tiket': 'Ticket',
    'Pengaturan': 'Settings',
    'Pemberitahuan': 'Notifications',
    'Notifikasi': 'Notifications',
    'Favorit': 'Favorites',
    'Bantuan': 'Help',
    'Kembali': 'Back',
    'Simpan': 'Save',
    'Batal': 'Cancel',
    'Konfirmasi': 'Confirm',
    'Lanjutkan': 'Continue',
    'Selesai': 'Completed',
    'Lihat Semua': 'View All',
    'Hapus': 'Delete',
    'Ubah': 'Edit',
    'Urutkan': 'Sort',

    // ---------------- Status Tiket & Sesi Database ----------------
    'Belum Dibayar': 'Unpaid',
    'Ready': 'Ready',
    'Aktif': 'Active',
    'Dibatalkan': 'Cancelled',
    'Parkir Aktif': 'Active Parking',
    'Sedang Parkir': 'Currently Parked',
    'Overstay': 'Overstay',
    'Menunggu': 'Waiting',
    'Berhasil': 'Success',
    'Pending': 'Pending',
    'Gagal': 'Failed',
    'Tersedia': 'Available',
    'Penuh': 'Full',
    'Tutup Sementara': 'Temporarily Closed',
    'Buka': 'Open',
    'Dikonfirmasi': 'Confirmed',
    'Diproses': 'Processing',

    // ---------------- Home Screen ----------------
    'Halo,': 'Hello,',
    'Halo': 'Hello',
    'Selamat Datang,': 'Welcome,',
    'Selamat Datang': 'Welcome',
    'Selamat Pagi,': 'Good Morning,',
    'Selamat Siang,': 'Good Afternoon,',
    'Selamat Sore,': 'Good Evening,',
    'Selamat Malam,': 'Good Night,',
    'Mau parkir di mana hari ini?': 'Where would you like to park today?',
    'Temukan slot parkir nyaman hari ini': 'Find comfortable parking spots today',
    'Cari lokasi parkir, gedung, area...': 'Search parking, buildings, areas...',
    'Cari lokasi parkir...': 'Search parking location...',
    'Kategori Parkir': 'Parking Categories',
    'Paling Murah': 'Cheapest',
    'Spot Favorit': 'Favorite Spots',
    'Rekomendasi Terbaik': 'Top Recommendations',
    'Lokasi Parkir Populer': 'Popular Parking Locations',
    'Parkir Sekitar Anda': 'Parking Near You',
    'Sesi Parkir Aktif': 'Active Parking Session',
    'SESI PARKIR AKTIF': 'ACTIVE PARKING SESSION',
    'Sisa Waktu': 'Remaining Time',
    'Waktu Berakhir': 'End Time',
    'Perpanjang': 'Extend',
    'Lihat Tiket': 'View Ticket',
    'Navigasi': 'Navigate',
    'Rute': 'Route',
    'Petunjuk Arah': 'Directions',
    'Spot Parkir Terpilih': 'Selected Parking Spot',
    'Slot Tersedia': 'Slots Available',
    'Total Slot': 'Total Slots',
    'Cari gedung atau area parkir...': 'Search buildings or parking areas...',
    'Rekomendasi Lainnya': 'Other Recommendations',
    'Muat Ulang': 'Reload',
    'Buka Tiket': 'Open Ticket',
    'Belum ada rekomendasi parkir aktif': 'No active parking recommendations yet',
    'Semua tempat parkir diinput langsung oleh Admin Operasional': 'All parking spots are registered by Operations Admin',
    'Slot & Area': 'Slot & Area',
    'Unduh Rekap Parkir (PDF)': 'Download Parking Summary (PDF)',
    'Tarif': 'Rate',
    'per jam': 'per hour',
    '/ jam': '/ hour',
    '/jam': '/hour',
    'Estimasi Jarak': 'Estimated Distance',
    'Jarak': 'Distance',
    'GPS tidak aktif': 'GPS Inactive',

    // ---------------- Riwayat Transaksi & Sesi (History) ----------------
    'Riwayat Transaksi': 'Transaction History',
    'Riwayat Parkir': 'Parking History',
    'Riwayat Transaksi Parkir': 'Parking Transaction History',
    'Riwayat Sesi': 'Session History',
    'Semua Transaksi': 'All Transactions',
    'Filter Riwayat': 'History Filter',
    'Belum Ada Riwayat': 'No History Yet',
    'Belum ada riwayat parkir.': 'No parking history yet.',
    'Belum ada transaksi parkir': 'No parking transactions yet',
    'Semua riwayat parkir dan reservasi Anda akan muncul di sini.':
        'All your parking history and reservations will appear here.',
    'Detail Transaksi': 'Transaction Details',
    'Detail Tiket': 'Ticket Details',
    'Informasi Lengkap': 'Complete Information',
    'Kode Booking': 'Booking Code',
    'Kode Sesi': 'Session Code',
    'Kode Transaksi': 'Transaction Code',
    'Nomor Transaksi': 'Transaction Number',
    'Hash Blockchain': 'Blockchain Hash',
    'Hash': 'Hash',
    'Waktu Check-in': 'Check-in Time',
    'Waktu Check-out': 'Check-out Time',
    'Waktu Masuk': 'Check-in Time',
    'Waktu Keluar': 'Check-out Time',
    'Estimasi Keluar': 'Expected Check-out',
    'Durasi Parkir': 'Parking Duration',
    'Durasi': 'Duration',
    'Biaya Parkir': 'Parking Fee',
    'Biaya Layanan': 'Service Fee',
    'Potongan Diskon': 'Discount Deduction',
    'Total Pembayaran': 'Total Payment',
    'Total Biaya': 'Total Amount',
    'Total Tagihan': 'Total Bill',
    'Metode Pembayaran': 'Payment Method',
    'Status Tiket': 'Ticket Status',
    'Lokasi': 'Location',
    'Alamat Lokasi': 'Location Address',
    'Slot': 'Slot',
    'Lantai': 'Floor',
    'Dibuat': 'Created',
    'Diselesaikan': 'Completed',
    'Unduh Bukti': 'Download Receipt',
    'Bagikan': 'Share',
    'Tampilkan QR': 'Show QR',
    'Tampilkan Tiket': 'Show Ticket',

    // ---------------- Riwayat per Kendaraan (Verified Sessions) ----------------
    'Riwayat Parkir Kendaraan': 'Vehicle Parking History',
    'Total Sesi': 'Total Sessions',
    'Total Durasi': 'Total Duration',
    'Pengeluaran Bulan Ini': 'Spending This Month',
    'Bulan Ini': 'This Month',
    'Semua Bulan': 'All Months',
    'Belum Ada Sesi': 'No Sessions Yet',
    'Belum Ada Sesi Terverifikasi': 'No Verified Sessions Yet',
    'Belum ada riwayat parkir untuk kendaraan ini': 'No parking history for this vehicle yet',
    'Semua sesi parkir resmi akan diverifikasi secara otomatis':
        'All official parking sessions will be verified automatically',
    'Kendaraan Utama': 'Primary Vehicle',
    'Kendaraan Cadangan': 'Backup Vehicle',
    'Default': 'Default',
    'Sesi Parkir': 'Parking Sessions',

    // ---------------- Profil & Pengaturan (Profile & Settings) ----------------
    'Profil Pengguna': 'User Profile',
    'Informasi Akun': 'Account Information',
    'Ubah Profil': 'Edit Profile',
    'TOTAL PARKIR': 'TOTAL PARKING',
    'PENGHEMATAN': 'SAVINGS',
    'KENDARAAN TERDAFTAR': 'REGISTERED VEHICLES',
    'METODE PEMBAYARAN': 'PAYMENT METHODS',
    'BAHASA': 'LANGUAGE',
    'Setel Bahasa': 'Set Language',
    'Bahasa': 'Language',
    'Bahasa Indonesia': 'Indonesian',
    'English': 'English',
    'English (US/UK)': 'English (US/UK)',
    'Pilih Bahasa': 'Select Language',
    'Pilih Bahasa Aplikasi': 'Choose App Language',
    'Preferensi Akun': 'Account Preferences',
    'Preferensi & Tampilan': 'Preferences & Display',
    'Preferensi Parkir': 'Parking Preferences',
    'Mode Gelap': 'Dark Mode',
    'Tema Gelap': 'Dark Theme',
    'Mata Uang': 'Currency',
    'Mata Uang & Kurs Valuta': 'Currency & Exchange Rates',
    'Konversi Mata Uang': 'Currency Conversion',
    'Keamanan Akun': 'Account Security',
    'Keamanan & Autentikasi': 'Security & Authentication',
    'Kunci Aplikasi': 'App Lock',
    'Ubah PIN': 'Change PIN',
    'Biometrik & Sidik Jari': 'Biometrics & Fingerprint',
    'Bantuan & Dukungan': 'Help & Support',
    'CUSTOMER CARE': 'CUSTOMER CARE',
    'DEVELOPER OPTIONS': 'DEVELOPER OPTIONS',
    'Test Notification': 'Test Notification',
    'Pusat Bantuan': 'Help Center',
    'Syarat & Ketentuan': 'Terms & Conditions',
    'Kebijakan Privasi': 'Privacy Policy',
    'Tentang ParkSmart': 'About ParkSmart',
    'Tentang Aplikasi': 'About Application',
    'Versi Aplikasi': 'App Version',
    'Versi': 'Version',
    'KELUAR DARI AKUN': 'LOG OUT',
    'Keluar Akun': 'Log Out',
    'Apakah Anda yakin ingin keluar?': 'Are you sure you want to log out?',
    'Ya, Keluar': 'Yes, Log Out',
    'Tidak': 'No',
    'Nama Lengkap': 'Full Name',
    'Email': 'Email',
    'Nomor Telepon': 'Phone Number',
    'Nomor HP': 'Phone Number',
    'Simpan Perubahan': 'Save Changes',
    'Member Silver': 'Silver Member',
    'Member Gold': 'Gold Member',
    'Member Platinum': 'Platinum Member',
    'Member Reguler': 'Regular Member',

    // ---------------- Kendaraan (Vehicles) ----------------
    'GARASI DIGITAL': 'DIGITAL GARAGE',
    'Kendaraan Terdaftar': 'Registered Vehicles',
    'Belum Ada Kendaraan Terdaftar': 'No Registered Vehicles',
    'Tambahkan nomor plat kendaraan Anda untuk kemudahan deteksi otomatis gate ANPR dan reservasi slot parkir.':
        'Add your vehicle plate number for automatic ANPR gate detection and easy spot reservations.',
    'Daftar Kendaraan': 'Vehicle List',
    'Tambah Kendaraan Baru': 'Add New Vehicle',
    'Ubah Kendaraan': 'Edit Vehicle',
    'Hapus Kendaraan': 'Delete Vehicle',
    'Hapus Kendaraan?': 'Delete Vehicle?',
    'Apakah Anda yakin ingin menghapus kendaraan ini?':
        'Are you sure you want to delete this vehicle?',
    'Kendaraan berhasil dihapus': 'Vehicle successfully deleted',
    'Foto kendaraan berhasil diupload!': 'Vehicle photo uploaded successfully!',
    'Gagal mengupload foto kendaraan': 'Failed to upload vehicle photo',
    'Ganti Foto': 'Change Photo',
    'Tambah Foto': 'Add Photo',
    'Tap untuk tambah foto': 'Tap to add photo',
    'Live Spot Details': 'Live Spot Details',
    'Milik Pribadi': 'Personal Vehicle',
    'Golongan Tarif': 'Fare Category',
    'Masa Berlaku': 'Validity Period',
    'Aktif Selamanya': 'Always Active',
    'Jadikan Kendaraan Utama': 'Set as Default Vehicle',
    'Jadikan Utama': 'Set as Default',
    'Pilihan default otomatis untuk setiap reservasi parkir':
        'Automatic default choice for every parking reservation',
    'Hapus kendaraan ini dari daftar garasi Anda': 'Remove this vehicle from your garage',
    'Cadangan': 'Backup',
    'Nomor Plat': 'License Plate',
    'Plat Nomor': 'License Plate',
    'Merek': 'Brand',
    'Model': 'Model',
    'Warna': 'Color',
    'Tipe': 'Type',
    'Tipe Kendaraan': 'Vehicle Type',
    'Mobil': 'Car',
    'Motor': 'Motorcycle',
    'Mobil Listrik (EV)': 'Electric Vehicle (EV)',
    'Belum Ada Kendaraan': 'No Vehicles Registered',
    'Belum Terdaftar': 'Not Registered',
    'Tidak ada kendaraan aktif': 'No active vehicle',
    'Hitam Metalik': 'Metallic Black',
    'Silver Metalik': 'Metallic Silver',
    'Merah Marun': 'Maroon Red',
    'Biru Tua': 'Dark Blue',

    // ---------------- Notifikasi & Favorit ----------------
    'Sesi Berakhir Segera': 'Session Ending Soon',
    'Tidak Ada Sesi Hampir Berakhir': 'No Expiring Sessions',
    'Peringatan ini akan aktif otomatis ketika waktu sesi parkir Anda tersisa kurang dari 15 menit.':
        'This alert will activate automatically when your parking session has less than 15 minutes remaining.',
    'SISA WAKTU': 'REMAINING TIME',
    'Waktu Parkir Hampir Habis': 'Parking Time Almost Expired',
    'PILIHAN PERPANJANGAN CEPAT': 'QUICK EXTENSION OPTIONS',
    'Tarif normal': 'Normal rate',
    '+30 Menit': '+30 Minutes',
    '+1 Jam': '+1 Hour',
    '+2 Jam': '+2 Hours',
    'Rincian Parkir Aktif': 'Active Parking Details',
    'Sesi Berjalan': 'Ongoing Session',
    'Lokasi Slot': 'Slot Location',
    'Biaya Saat Ini': 'Current Fee',
    'Perpanjang Durasi Parkir': 'Extend Parking Duration',
    'Siap Check-out Sekarang': 'Ready to Check-out Now',
    'Ketuk untuk melihat detail': 'Tap to view details',
    'Favorite Parking': 'Favorite Parking',
    'Tempat Favorit': 'Favorite Spots',
    'Cari tempat favorit...': 'Search favorite spots...',
    'Belum Ada Tempat Favorit': 'No Favorite Spots Yet',
    'Simpan lokasi parkir langganan Anda dengan menekan ikon favorit pada halaman detail parkir.':
        'Save your frequent parking spots by tapping the favorite icon on the parking detail page.',
    'EV Charging': 'EV Charging',
    'Parkir Reguler': 'Regular Parking',

    // ---------------- Edit Data Diri & Feedback ----------------
    'Edit Data Diri': 'Edit Profile',
    'Ubah Foto Profil': 'Change Profile Photo',
    'Ambil Foto dari Kamera': 'Take Photo with Camera',
    'Pilih dari Galeri': 'Choose from Gallery',
    'INFORMASI PENGGUNA': 'USER INFORMATION',
    'Alamat Email': 'Email Address',
    'Nomor Telepon / WhatsApp': 'Phone Number / WhatsApp',
    'Jenis Kelamin': 'Gender',
    'Laki-laki': 'Male',
    'Perempuan': 'Female',
    'Tanggal Lahir': 'Date of Birth',
    'Alamat Tinggal / Domisili': 'Residential Address',
    'Pilih': 'Select',
    'Masukkan nama lengkap': 'Enter full name',
    'Masukkan alamat email': 'Enter email address',
    'Alamat lengkap': 'Full address',
    'Data diri berhasil diperbarui!': 'Profile successfully updated!',
    'Nama lengkap tidak boleh kosong': 'Full name cannot be empty',
    'Format email tidak valid': 'Invalid email format',
    'Nomor telepon tidak boleh kosong': 'Phone number cannot be empty',
    'PARKIR PRESISI': 'PRECISION PARKING',
    'Bagaimana Pengalaman\nParkir Anda?': 'How Was Your\nParking Experience?',
    'Bantu kami meningkatkan akurasi sensor dan kenyamanan reservasi Anda.':
        'Help us improve sensor accuracy and your reservation experience.',
    'TINGKAT KEPUASAN': 'SATISFACTION LEVEL',
    'Kirim Masukan': 'Submit Feedback',
    'Terima Kasih Banyak!': 'Thank You Very Much!',
    'Masukan berharga Anda telah tersimpan dan membantu pengguna lain menikmati parkir yang lebih mudah.':
        'Your valuable feedback has been recorded and helps other users enjoy smoother parking.',
    'Perlu Perbaikan (1/5)': 'Needs Improvement (1/5)',
    'Cukup (2/5)': 'Fair (2/5)',
    'Baik (3/5)': 'Good (3/5)',
    'Sangat Baik (4/5)': 'Very Good (4/5)',
    'Sangat Puas (5/5)': 'Very Satisfied (5/5)',
    'Ketuk bintang untuk mengubah penilaian': 'Tap stars to adjust rating',
    'Tuliskan ulasan atau masukan detail Anda di sini...': 'Write your detailed review or feedback here...',
    'Sesi hari ini • Slot B2-41': "Today's session • Slot B2-41",

    // ---------------- Metode Pembayaran ----------------
    'Saldo Aktif': 'Active Balance',
    'Top Up Saldo': 'Top Up Balance',
    'Bayar Otomatis': 'Automatic Payment',
    'Bayar otomatis & potong saldo saat waktu parkir tersisa 5 menit':
        'Auto-pay & deduct balance when 5 minutes of parking remain',
    'Bayar otomatis diaktifkan': 'Auto-pay enabled',
    'Bayar otomatis dinonaktifkan': 'Auto-pay disabled',
    'METODE TERSIMPAN': 'SAVED METHODS',
    '+ Tambah': '+ Add',
    'Tambah Metode Pembayaran Lain': 'Add Another Payment Method',
    'Tambah Metode Pembayaran': 'Add Payment Method',
    'Klik untuk memilih atau membatalkan pilihan dompet digital':
        'Click to select or deselect digital wallet',
    'UTAMA': 'DEFAULT',

    // ---------------- Checkout & Booking ----------------
    'Checkout Parkir': 'Parking Checkout',
    'Detail Reservasi': 'Reservation Details',
    'Pilih Jadwal': 'Select Schedule',
    'Waktu Mulai': 'Start Time',
    'Pilih Durasi': 'Select Duration',
    'Pilih Kendaraan': 'Select Vehicle',
    'Ringkasan Biaya': 'Cost Summary',
    'Total Bayar': 'Total Payment',
    'Bayar Sekarang': 'Pay Now',
    'Konfirmasi Booking': 'Confirm Booking',
    'Booking Berhasil': 'Booking Successful',
    'Reservasi Anda telah berhasil dibuat': 'Your reservation has been successfully created',
    'Selesaikan pembayaran dalam': 'Complete payment within',
    'Bayar Pesanan': 'Pay Order',

    // ---------------- Sesi Parkir & Checkin ----------------
    'Check-in Sekarang': 'Check-in Now',
    'Mulai Parkir': 'Start Parking',
    'Selesaikan Sesi': 'End Session',
    'Perpanjang Parkir': 'Extend Parking',
    'Waktu Habis': 'Time Expired',
    'Tiket QR Parkir': 'Parking QR Ticket',
    'Tunjukkan QR ini ke scanner gerbang masuk': 'Show this QR to the entrance gate scanner',
    'Scan QR di Gerbang': 'Scan QR at Gate',
    'SESI AKTIF': 'ACTIVE SESSION',
    'Sesi Aktif': 'Active Session',
    'Tidak Ada Sesi Parkir Aktif': 'No Active Parking Session',
    'Saat kendaraan Anda check-in di gate parkir, timer dan detail spot akan muncul secara otomatis di sini.':
        'When your vehicle checks in at the parking gate, the timer and spot details will appear here automatically.',
    'Kembali ke Beranda': 'Back to Home',
    'SISA WAKTU PARKIR': 'REMAINING PARKING TIME',
    'Batas Selesai': 'Deadline',
    'Navigasi AR': 'AR Navigation',
    'LOKASI PARKIR': 'PARKING LOCATION',
    'NOMOR SLOT': 'SLOT NUMBER',
    'Biaya Terhitung': 'Calculated Fee',
    'Lunas di Muka': 'Paid in Advance',
    'Kendaraan Aktif': 'Active Vehicle',
    'Durasi Paket': 'Package Duration',
    'Check Out Parkir': 'Check Out Parking',
    'Selesai Parkir': 'Parking Completed',
    'Tidak Ada Kendaraan di Area Parkir': 'No Vehicle in Parking Area',
    'Saat ini tidak ada sesi parkir aktif yang perlu diselesaikan checkout.':
        'There is currently no active parking session requiring checkout.',
    'Siap Keluar': 'Ready to Exit',
    'Durasi Total': 'Total Duration',
    'Waktu (WIB)': 'Time (WIB)',
    'RINCIAN TARIF': 'FARE BREAKDOWN',
    'Rincian Tarif': 'Fare Breakdown',
    'Tarif Parkir': 'Parking Fare',
    'Diskon Promo Member': 'Member Promo Discount',
    'Total Terbayar': 'Total Paid',
    'Lunas': 'Paid',
    'Gerbang Siap Terbuka • Sensor Aktif': 'Gate Ready to Open • Sensor Active',
    'Buka Palang Keluar': 'Open Exit Barrier',
    'Unduh Struk': 'Download Receipt',
    'Unduh Struk / E-Receipt': 'Download Receipt / E-Receipt',
    'Anda tidak memiliki sesi parkir aktif yang dapat diperpanjang saat ini.':
        'You do not have an active parking session that can be extended right now.',
    'Durasi Tambahan': 'Additional Duration',
    'Palang Telah Terbuka': 'Barrier Has Opened',
    'Lanjutkan Navigasi': 'Continue Navigation',
    'Belum Ada Tiket Masuk Parkir': 'No Parking Entry Ticket Yet',
    'Anda tidak memiliki reservasi aktif untuk melakukan check-in di gerbang masuk.':
        'You do not have an active reservation to check-in at the entrance gate.',
    'Sistem ANPR mendeteksi plat nomor Anda pada radius 50 meter dari Gate 01 South Entrance.':
        'The ANPR system detects your license plate within 50 meters of Gate 01 South Entrance.',
    'Terverifikasi Otomatis di Gerbang Masuk': 'Automatically Verified at Entrance Gate',
    'Jarak saat ini: ~15 meter ke portal palang': 'Current distance: ~15 meters to barrier portal',
    'KODE BOOKING': 'BOOKING CODE',
    'Valid': 'Valid',
    'Plat Nomor Kendaraan': 'Vehicle License Plate',
    'Slot Reservasi': 'Reserved Slot',
    'Dekat Lift Utama': 'Near Main Elevator',
    'Palang akan terangkat otomatis saat plat nomor terbaca. Anda juga dapat menekan tombol di bawah bila sistem palang belum terbuka.':
        'The barrier will lift automatically when the plate is scanned. You can also tap the button below if the barrier does not open.',
    'Masuk Gerbang & Buka Palang': 'Enter Gate & Open Barrier',
    'Simpan Saja': 'Save Only',
    'Perpanjang Sesi Parkir': 'Extend Parking Session',
    'Lokasi & Penempatan': 'Location & Placement',
    'Sisa Waktu Sesi Ini': 'Remaining Time This Session',
    'PILIH DURASI TAMBAHAN': 'SELECT ADDITIONAL DURATION',
    'Maks. +4 Jam': 'Max. +4 Hours',
    'POPULER': 'POPULAR',
    'WAKTU SELESAI BARU': 'NEW FINISH TIME',
    'BIAYA TAMBAHAN': 'ADDITIONAL COST',
    'Perpanjangan otomatis dikonfirmasi tanpa perlu tiket baru.':
        'Automatic extension confirmed without needing a new ticket.',
    'Pilih Metode Pembayaran': 'Select Payment Method',
    'Engine AI Assistant Sedang Maintenance': 'AI Assistant Engine Under Maintenance',
    'Fitur asisten pencarian cerdas ParkSmart sementara ditutup untuk pembaruan model. Anda tetap dapat melakukan reservasi dan jelajah peta secara normal.':
        'The ParkSmart smart assistant feature is temporarily closed for model updates. You can still make reservations and explore maps normally.',


    // ---------------- Booking Confirmation & Passes ----------------
    'Konfirmasi Kedatangan': 'Arrival Confirmation',
    'KONFIRMASI KEDATANGAN': 'ARRIVAL CONFIRMATION',
    'Slot Siap\nUntuk Anda.': 'Slot Ready\nFor You.',
    'Akses parkir tanpa sentuh aktif otomatis di gerbang masuk.': 'Touchless parking access automatically active at entrance gate.',
    'DIGITAL PARKING PASS': 'DIGITAL PARKING PASS',
    'PLAT NOMOR': 'LICENSE PLATE',
    'Kendaraan': 'Vehicle',
    'Waktu Valid': 'Valid Time',
    'Toleransi +15 mnt': 'Tolerance +15 min',
    'Tidak Ada Reservasi Aktif': 'No Active Reservations',
    'Anda belum memiliki tiket reservasi parkir yang sedang diproses.': 'You do not have a parking reservation ticket in process.',
    'Selesaikan Pembayaran': 'Complete Payment',
    'Slot parkir Anda ter-booking selama 2:59 menit. Segera selesaikan pembayaran.': 'Your parking slot is held for 2:59 minutes. Complete payment immediately.',
    'Reservasi Berhasil': 'Reservation Successful',

    // ---------------- Slot Selection ----------------
    'Pilih Slot Parkir': 'Select Parking Slot',
    'Denah Slot Parkir Belum Tersedia': 'Slot Floor Plan Not Available',
    'Lokasi parkir belum dipilih atau belum ada denah slot yang terdaftar di lokasi ini.': 'Parking location is not selected or no slot map is registered at this location.',
    'Kembali ke Peta': 'Back to Map',
    'Zona A untuk Mobil Reguler. Zona B untuk Stasiun EV Charging & Campuran.': 'Zone A for Regular Cars. Zone B for EV Charging & Mixed.',
    'Terpilih': 'Selected',
    'Zona A (Posisi Atas)': 'Zone A (Top Position)',
    'Zona B (Posisi Bawah - EV Ready)': 'Zone B (Bottom Position - EV Ready)',
    'Jalur Sirkulasi': 'Circulation Lane',
    'Satu Arah': 'One Way',
    'Terisi Mobil': 'Occupied by Car',
    'Pilihan Anda': 'Your Selection',
    'TOTAL PEMBAYARAN AWAL': 'INITIAL TOTAL PAYMENT',
    '1 Jam Pertama': 'First 1 Hour',
    'Lanjut Bayar': 'Proceed to Pay',
    'Slot Selection': 'Slot Selection',
    'Pilihan': 'Chosen',
    'Terisi': 'Occupied',
    'Reguler': 'Regular',
    'Slot Reguler': 'Regular Slot',
    'Slot Motor': 'Motorcycle Slot',
    'Slot EV': 'EV Slot',
    'Slot Difabel': 'Disabled Slot',
    'Slot VIP': 'VIP Slot',

    // ---------------- Checkout & Schedule ----------------
    'Slot Ditahan': 'Slot Held',
    'Langkah 3 dari 3': 'Step 3 of 3',
    'Konfirmasi\nReservasi': 'Confirm\nReservation',
    'Konfirmasi Reservasi': 'Confirm Reservation',
    'Tinjau detail parkir pintar Anda sebelum pembayaran otomatis diproses.': 'Review your smart parking details before automatic payment is processed.',
    'LOKASI TERPILIH': 'SELECTED LOCATION',
    'Zona Parkir': 'Parking Zone',
    'Pilih Kendaraan Anda': 'Select Your Vehicle',
    'TOTAL PEMBAYARAN': 'TOTAL PAYMENT',
    'Checkout': 'Checkout',
    'Konfirmasi Bayar Sekarang': 'Confirm & Pay Now',
    'Data booking tidak ditemukan atau sudah dibatalkan.': 'Booking data not found or already cancelled.',
    'Batas waktu pembayaran (02:59) telah habis. Slot telah dilepas.': 'Payment time limit (02:59) expired. Slot has been released.',
    'Waktu penahanan slot habis (02:59). Slot telah dilepas.': 'Slot hold time expired (02:59). Slot has been released.',
    'Slot ini sudah dibooking orang lain atau terjadi kendala. Silakan pilih jadwal/slot lain.': 'This slot was booked by someone else or an error occurred. Please select another slot.',
    'Jam masuk tidak boleh di masa lalu. Silakan atur ulang jam masuk.': 'Check-in time cannot be in the past. Please reset check-in time.',
    'Gagal membuat pesanan. Slot mungkin baru saja dibooking pengguna lain.': 'Failed to create order. Slot may have just been booked by another user.',
    'Slot Penuh pada Jam Tersebut': 'Slot is Full at that Time',
    'Status Ketersediaan Hari Ini:': "Today's Availability Status:",
    'Pilih Jadwal Jam Tersedia Hari Ini:': "Select Available Time Slot Today:",
    'Slot ini sudah penuh total untuk sisa hari ini.': 'This slot is completely full for the rest of today.',
    'Silakan kembali dan pilih slot parkir lain.': 'Please go back and select another parking slot.',
    'Pilih Slot Lain': 'Select Other Slot',
    'Atur Jam Manual': 'Set Time Manually',
    'PILIH JAM KEDATANGAN (HARI INI)': 'SELECT ARRIVAL TIME (TODAY)',
    'PILIH JAM KELUAR (HARI INI)': 'SELECT DEPARTURE TIME (TODAY)',
    'Maksimal jam kedatangan pukul 23:45 untuk pemesanan hari ini.': 'Maximum arrival time is 23:45 for today booking.',
    'JADWAL RESERVASI': 'RESERVATION SCHEDULE',
    'JAM MASUK': 'CHECK-IN TIME',
    'JAM KELUAR': 'CHECK-OUT TIME',
    'Jam Durasi': 'Hours Duration',

    // ---------------- Parking Details (PS-04) ----------------
    'Detail Tempat Parkir': 'Parking Location Details',
    'Lokasi Parkir Tidak Ditemukan': 'Parking Location Not Found',
    'Data lokasi tempat parkir belum terdaftar atau tidak ditemukan di sistem.': 'Parking location data is not registered or not found in system.',
    '24 Jam': '24 Hours',
    'Fasilitas Parkir': 'Parking Facility',
    'KAPASITAS TERSEDIA': 'AVAILABLE CAPACITY',
    'Belum ada slot yang dialokasikan': 'No slots allocated yet',
    'Zona A lebih dekat ke Lobby Tribeca & Central Park Lift.': 'Zone A is closer to Tribeca Lobby & Central Park Elevator.',
    'TARIF PARKIR BERDASARKAN TIPE': 'PARKING RATE BY TYPE',
    'FASILITAS': 'AMENITIES',
    'Disabilitas': 'Accessible',
    'Akses Lift': 'Elevator Access',
    'Ditambahkan ke parkir favorit': 'Added to favorite parking',
    'Dihapus dari parkir favorit': 'Removed from favorite parking',
    'MULAI DARI': 'STARTING FROM',
    'Pilih Slot': 'Select Slot',
    'Belum ada slot parkir yang dialokasikan di lokasi ini.': 'No parking slots allocated at this location yet.',

    // ---------------- AR Navigation & Route ----------------
    'Tujuan Parkir Belum Dipilih': 'Parking Destination Not Selected',
    'Silakan pilih tempat parkir tujuan dari peta atau beranda terlebih dahulu untuk memulai panduan rute turn-by-turn.': 'Please select destination parking from map or home first to start turn-by-turn directions.',
    'Pilih Tempat Parkir': 'Select Parking Spot',
    'Navigasi Panduan Rute': 'Route Guidance Navigation',
    'Memperbarui GPS & menghitung rute tercepat...': 'Updating GPS & calculating fastest route...',
    'Opsi Navigasi': 'Navigation Options',
    'Hitung Ulang Rute Tercepat': 'Recalculate Fastest Route',
    'Pusatkan ke Posisi GPS': 'Center to GPS Position',
    'Hentikan Navigasi': 'Stop Navigation',
    'Tiba di Lokasi': 'Arrived at Destination',

    // ---------------- Vehicle Management (Add Vehicle) ----------------
    'Pilih Foto Kendaraan (Kamera / Galeri)': 'Select Vehicle Photo (Camera / Gallery)',
    'Opsional • Kompres 70%': 'Optional • 70% Compressed',
    'Foto jernih & dikompres 70% otomatis tanpa buram': 'Clear photo & automatically compressed by 70% without blur',
    'Pindai Plat': 'Scan Plate',
    'Pilih sumber foto (otomatis dikompres 70% jernih):': 'Select photo source (automatically 70% compressed):',
    'Kamera': 'Camera',
    'Galeri': 'Gallery',
    'Foto 2x berhasil diolah!': 'Photo successfully processed!',

    // ---------------- Explore Map & Reviews ----------------
    'Pencarian Suara': 'Voice Search',
    'Atau pilih contoh suara:': 'Or choose voice sample:',
    'Explore': 'Explore',
    'Pesan Slot': 'Book Slot',
    'Galeri Foto Area Parkir': 'Parking Area Photo Gallery',
    'Kirim Ulasan': 'Submit Review',
    'Bagikan pengalaman parkir Anda untuk membantu pengguna lain.': 'Share your parking experience to help other users.',
    'Belum ada ulasan dengan topik ini.': 'No reviews with this topic yet.',
    'Layanan GPS perangkat belum aktif. Silakan aktifkan GPS.': 'Device GPS service is not active. Please activate GPS.',
    'Memperbarui cuaca lokasi...': 'Updating location weather...',

    // ---------------- AI Assistant & Chat ----------------
    'Asisten Cerdas': 'Smart Assistant',
    'Asisten ParkSmart': 'ParkSmart Assistant',
    'Tanya Jarvis...': 'Ask Jarvis...',
    'Ketik pertanyaan Anda di sini...': 'Type your question here...',
    'Rekomendasi Parkir': 'Parking Recommendations',
    'Bersihkan Percakapan': 'Clear Chat',

    // ---------------- Mini Game ----------------
    'Mulai Game': 'Start Game',
    'Skor Tertinggi': 'High Score',
    'Skor Anda': 'Your Score',
    'Main Lagi': 'Play Again',

    // ---------------- Feedback Kuliah ----------------
    'Saran & Masukan Kuliah': 'Course Feedback & Notes',
    'Masukan Mata Kuliah': 'Course Feedback',
    'Saran untuk Kuliah': 'Suggestions for Course',
    'Pesan & Kesan Kuliah': 'Impressions & Notes',
    'Simpan Masukan': 'Save Feedback',
    'Edit Masukan': 'Edit Feedback',
    'Berhasil disimpan': 'Successfully saved',

    // ---------------- Waktu & Bulan ----------------
    'Januari': 'January',
    'Februari': 'February',
    'Maret': 'March',
    'April': 'April',
    'Mei': 'May',
    'Juni': 'June',
    'Juli': 'July',
    'Agustus': 'August',
    'September': 'September',
    'Oktober': 'October',
    'November': 'November',
    'Desember': 'December',
    'Jan': 'Jan',
    'Feb': 'Feb',
    'Mar': 'Mar',
    'Apr': 'Apr',
    'May': 'May',
    'Jun': 'Jun',
    'Jul': 'Jul',
    'Agu': 'Aug',
    'Sep': 'Sep',
    'Okt': 'Oct',
    'Nov': 'Nov',
    'Des': 'Dec',
    'Hari ini': 'Today',
    'Kemarin': 'Yesterday',
    'Besok': 'Tomorrow',
    'Baru saja': 'Just now',
  };

  // Lookup map bertipe lowercase untuk perbandingan toleran huruf kecil
  static final Map<String, String> _dictionaryLower = _dictionary.map(
    (k, v) => MapEntry(k.toLowerCase(), v),
  );
}

/// Extension agar mempermudah pemanggilan `text.tr` di UI
extension TranslationExtension on String {
  String get tr => LanguageService.instance.tr(this);
}
