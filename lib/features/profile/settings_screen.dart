import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'edit_profile_screen.dart';
import 'ktp_camera_screen.dart';
import 'pin_settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'Arya Raditya';
  String _userEmail = 'arya.raditya@gmail.com';
  String _userPhone = '+62 812-3456-7890';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    CurrencyService.instance.addListener(_onCurrencyChanged);
    ThemeService.instance.addListener(_onThemeChanged);
  }

  void _onCurrencyChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    CurrencyService.instance.removeListener(_onCurrencyChanged);
    ThemeService.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    bool faceEnabled = prefs.getBool('face_id_enabled') ?? false;
    final fpEnabled = prefs.getBool('fingerprint_enabled') ?? true;

    // Validasi apakah hardware perangkat benar-benar memiliki sensor Face ID terdaftar
    if (faceEnabled) {
      try {
        final auth = LocalAuthentication();
        final isSupported = await auth.isDeviceSupported();
        final canCheck = await auth.canCheckBiometrics;
        final available = await auth.getAvailableBiometrics();
        if (!isSupported || !canCheck || !available.contains(BiometricType.face)) {
          faceEnabled = false;
          await prefs.setBool('face_id_enabled', false);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_profile_name') ?? 'Arya Raditya';
        _userEmail = prefs.getString('user_profile_email') ?? 'arya.raditya@gmail.com';
        _userPhone = prefs.getString('user_profile_phone') ?? '+62 812-3456-7890';
        _faceIdEnabled = faceEnabled;
        _fingerprintEnabled = fpEnabled;
      });
    }
  }

  bool _faceIdEnabled = false;
  bool _fingerprintEnabled = true;
  bool _notifEnabled = true;
  String _cacheSize = '128.4 MB tersimpan';
  bool _isCacheCleared = false;
  String _selectedParkingPref = 'Mobil SUV';


  Future<void> _handleFaceIdToggle(bool val) async {
    if (!val) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('face_id_enabled', false);
      setState(() => _faceIdEnabled = false);
      _showSuccessToast('Face ID dinonaktifkan');
      return;
    }

    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool isSupported = await auth.isDeviceSupported();
      final bool canCheck = await auth.canCheckBiometrics;
      final List<BiometricType> available = await auth.getAvailableBiometrics();

      debugPrint('Biometrics Face check - supported: $isSupported, canCheck: $canCheck, available: $available');

      // Ketat: HANYA jika perangkat secara spesifik memiliki sensor wajah terdaftar
      final bool hasRealFace = isSupported && canCheck && available.contains(BiometricType.face);

      if (!hasRealFace) {
        _showBiometricSystemOffDialog(
          title: 'Pengaturan Face ID Sistem Mati',
          message:
              'Fitur Face ID / Pemindai Wajah tidak tersedia atau belum didaftarkan pada pengaturan keamanan sistem Android perangkat Anda.\n\nSilakan daftarkan wajah Anda terlebih dahulu di Pengaturan HP > Keamanan > Biometrik / Face Unlock.',
          icon: Icons.face_retouching_off,
        );
        setState(() => _faceIdEnabled = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('face_id_enabled', false);
        return;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Konfirmasi pemindaian wajah untuk mengaktifkan Face ID',
        biometricOnly: true,
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('face_id_enabled', true);
        setState(() => _faceIdEnabled = true);
        _showSuccessToast('Face ID sistem Android berhasil diaktifkan');
      } else {
        setState(() => _faceIdEnabled = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('face_id_enabled', false);
      }
    } on PlatformException catch (e) {
      debugPrint('Face ID error: ${e.message}');
      _showBiometricSystemOffDialog(
        title: 'Pengaturan Face ID Sistem Mati',
        message:
            'Sensor pemindai wajah tidak aktif atau belum didaftarkan pada sistem Android perangkat Anda (${e.message ?? 'Tidak aktif'}).',
        icon: Icons.face_retouching_off,
      );
      setState(() => _faceIdEnabled = false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('face_id_enabled', false);
    } catch (e) {
      _showBiometricSystemOffDialog(
        title: 'Pengaturan Face ID Sistem Mati',
        message:
            'Gagal mengakses sensor wajah perangkat. Pastikan sensor biometrik diaktifkan pada pengaturan sistem perangkat Anda.',
        icon: Icons.face_retouching_off,
      );
      setState(() => _faceIdEnabled = false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('face_id_enabled', false);
    }
  }

  Future<void> _handleFingerprintToggle(bool val) async {
    if (!val) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fingerprint_enabled', false);
      setState(() => _fingerprintEnabled = false);
      _showSuccessToast('Sidik Jari dinonaktifkan');
      return;
    }

    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool isSupported = await auth.isDeviceSupported();
      final bool canCheck = await auth.canCheckBiometrics;
      final List<BiometricType> available = await auth.getAvailableBiometrics();

      debugPrint('Biometrics FP check - supported: $isSupported, canCheck: $canCheck, available: $available');

      final bool hasFingerprint = isSupported &&
          canCheck &&
          (available.contains(BiometricType.fingerprint) ||
              available.contains(BiometricType.strong));

      if (!hasFingerprint) {
        _showBiometricSystemOffDialog(
          title: 'Pengaturan Sidik Jari Sistem Mati',
          message:
              'Fitur Sidik Jari (Fingerprint) belum diaktifkan atau belum didaftarkan pada pengaturan keamanan sistem Android perangkat Anda.\n\nSilakan daftarkan sidik jari Anda terlebih dahulu di Pengaturan HP > Keamanan > Biometrik.',
          icon: Icons.fingerprint,
        );
        setState(() => _fingerprintEnabled = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fingerprint_enabled', false);
        return;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Sentuh sensor sidik jari untuk mengaktifkan',
        biometricOnly: true,
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fingerprint_enabled', true);
        setState(() => _fingerprintEnabled = true);
        _showSuccessToast('Sidik Jari sistem Android berhasil diaktifkan');
      } else {
        setState(() => _fingerprintEnabled = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fingerprint_enabled', false);
      }
    } on PlatformException catch (e) {
      debugPrint('Fingerprint error: ${e.message}');
      _showBiometricSystemOffDialog(
        title: 'Pengaturan Sidik Jari Sistem Mati',
        message:
            'Sensor sidik jari tidak aktif atau belum didaftarkan pada sistem Android perangkat Anda (${e.message ?? 'Tidak aktif'}).',
        icon: Icons.fingerprint,
      );
      setState(() => _fingerprintEnabled = false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fingerprint_enabled', false);
    } catch (e) {
      _showBiometricSystemOffDialog(
        title: 'Pengaturan Sidik Jari Sistem Mati',
        message:
            'Gagal mengakses sensor sidik jari perangkat. Pastikan sensor biometrik diaktifkan pada pengaturan sistem perangkat Anda.',
        icon: Icons.fingerprint,
      );
      setState(() => _fingerprintEnabled = false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fingerprint_enabled', false);
    }
  }

  void _showBiometricSystemOffDialog({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ThemeService.instance.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFC05621).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: const Color(0xFFC05621)),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: ThemeService.instance.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeService.instance.isDarkMode ? const Color(0xFF333C4A) : const Color(0xFF1C1C18),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Mengerti',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1C1C18),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


  void _showCurrencySelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currencyService = CurrencyService.instance;
            final currentCode = currencyService.currentCurrency;
            const sampleAmount = 145000;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              decoration: BoxDecoration(
                color: ThemeService.instance.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThemeService.instance.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.currency_exchange,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Konversi Mata Uang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C1C18),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF15803D),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Live API Real-Time Kurs',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Refresh button
                        GestureDetector(
                          onTap: () async {
                            final success = await currencyService.fetchLatestRates();
                            setModalState(() {});
                            setState(() {});
                            _showSuccessToast(
                              success
                                  ? 'Kurs real-time berhasil diperbarui!'
                                  : 'Gagal memperbarui kurs live',
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECE7DC),
                              shape: BoxShape.circle,
                            ),
                            child: currencyService.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1C1C18),
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    size: 18,
                                    color: Color(0xFF1C1C18),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Live Preview Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E242B), Color(0xFF2C353F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SIMULASI KONVERSI HARGA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              Text(
                                currencyService.getRateString(currentCode),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFDBA74),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nominal Asal (IDR)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rp 145.000',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF94A3B8),
                                size: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Setelah Dikonversi ($currentCode)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currencyService.format(sampleAmount, includeCode: true),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF4ADE80),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Currency Options List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                      itemCount: CurrencyService.supportedCurrencies.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final code = CurrencyService.supportedCurrencies.keys.elementAt(index);
                        final info = CurrencyService.supportedCurrencies[code]!;
                        final isSelected = currentCode == code;

                        return GestureDetector(
                          onTap: () async {
                            await currencyService.setCurrency(code);
                            setModalState(() {});
                            setState(() {});
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSuccessToast(
                              'Mata uang diubah ke ${info.name}. Semua harga otomatis dikonversi!',
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : const Color(0xFFF7F5EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1C1C18)
                                    : const Color(0xFFEBE6DC),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  info.flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            info.code,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1C1C18),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECE7DC),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              info.symbol,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1C1C18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        info.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: const Color(0xFF62615B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currencyService.getRateString(code),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF9E9B90),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFF1C1C18)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF1C1C18)
                                          : const Color(0xFFCBD5E1),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showParkingPrefSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferensi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 24),
                  
                  // SUV
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedParkingPref = 'Mobil SUV');
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _selectedParkingPref == 'Mobil SUV' ? const Color(0xFFF1EEE7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _selectedParkingPref == 'Mobil SUV' ? const Color(0xFF1C1C18) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car, color: const Color(0xFF1C1C18)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text('Golongan Mobil SUV', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          ),
                          if (_selectedParkingPref == 'Mobil SUV')
                            const Icon(Icons.check_circle, color: Color(0xFF1C1C18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sedan/City
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedParkingPref = 'Mobil Sedan/City');
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _selectedParkingPref == 'Mobil Sedan/City' ? const Color(0xFFF1EEE7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _selectedParkingPref == 'Mobil Sedan/City' ? const Color(0xFF1C1C18) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car, color: const Color(0xFF1C1C18)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text('Golongan Mobil Sedan/City', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          ),
                          if (_selectedParkingPref == 'Mobil Sedan/City')
                            const Icon(Icons.check_circle, color: Color(0xFF1C1C18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Motor Roda 2
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedParkingPref = 'Motor Roda 2');
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _selectedParkingPref == 'Motor Roda 2' ? const Color(0xFFF1EEE7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _selectedParkingPref == 'Motor Roda 2' ? const Color(0xFF1C1C18) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.two_wheeler, color: const Color(0xFF1C1C18)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text('Motor Roda 2', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          ),
                          if (_selectedParkingPref == 'Motor Roda 2')
                            const Icon(Icons.check_circle, color: Color(0xFF1C1C18)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Setel Bahasa', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              const SizedBox(height: 24),
              // Indonesia
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // Optionally add setState to change active language state if it existed
                },
                child: Container(
                  height: 64, // "se jempol" height
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1A1A18), width: 1.5), // Active style
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network('https://flagcdn.com/w320/id.png', width: 32, height: 24, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('Bahasa Indonesia', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      ),
                      const Icon(Icons.check_circle, color: Color(0xFF1A1A18), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // English
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E2DB)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network('https://flagcdn.com/w320/gb.png', width: 32, height: 24, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('English', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.instance.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: ThemeService.instance.bg.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: ThemeService.instance.isDarkMode 
                        ? Colors.black.withValues(alpha: 0.3) 
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8, 
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: ThemeService.instance.chipBg, 
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back, size: 20, color: ThemeService.instance.iconColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.settings, 
                            size: 24, 
                            color: ThemeService.instance.isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF114177),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pengaturan', 
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: ThemeService.instance.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Profile Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.card, 
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeService.instance.isDarkMode 
                              ? Colors.black.withValues(alpha: 0.25) 
                              : const Color(0xFF1C1D1F).withValues(alpha: 0.06), 
                          blurRadius: 32, 
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDpCYtgl-hGVXRQdhh0hHqX3XniI-C7Lxg0yDeOLXcMqOjE46TInnh-OrhgMgEuWTCRGldtvleaFHMYyWaQJ1mquPwZd7Wml55E3cC1V_VeKZ8d3xzBuHnAybOMqARFWoTE_k9nnrnzlSBgmrSJf0f_4mfvGIQfY0UR4vW0oNI3neJvNiqlN6jEnILQFveVtdwSEsvQSXEw1pAGo4CXJcw1vAUCCtRHm53H5N4XDk72XHIaYnPJnTlD'), fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(color: const Color(0xFFBBEED4), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.check, size: 10, color: Color(0xFF1F4F3C)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _userName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeService.instance.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 16, color: Color(0xFF9A442D)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userEmail,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: ThemeService.instance.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userPhone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: ThemeService.instance.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tombol Icon Pensil Hitam Vertically Centered
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  initialName: _userName,
                                  initialEmail: _userEmail,
                                  initialPhone: _userPhone,
                                ),
                              ),
                            );
                            if (result != null && result is Map<String, String>) {
                              setState(() {
                                _userName = result['name'] ?? _userName;
                                _userEmail = result['email'] ?? _userEmail;
                                _userPhone = result['phone'] ?? _userPhone;
                              });
                            }
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: ThemeService.instance.chipBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: ThemeService.instance.iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 1: Akun & Keamanan
                  _SectionTitle(title: 'Akun & Keamanan', icon: Icons.lock),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.card, 
                      borderRadius: BorderRadius.circular(16), 
                      border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeService.instance.isDarkMode ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF1C1D1F).withValues(alpha: 0.03), 
                          blurRadius: 12, 
                          offset: const Offset(0, 4)
                        ),
                      ],
                    ),
                    child: Column(
                      children: [                          _SettingActionRow(
                            icon: Icons.badge, title: 'Verifikasi KTP', subtitle: 'Belum Terverifikasi', 
                            actionWidget: const Icon(Icons.chevron_right, color: Color(0xFF1C1C18)),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const KtpCameraScreen()));
                            },
                          ),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: ThemeService.instance.divider, height: 1)),

                        _SettingToggleRow(
                          icon: Icons.face, title: 'Face ID', subtitle: 'Login dengan pemindaian wajah',
                          value: _faceIdEnabled,
                          onChanged: (val) => _handleFaceIdToggle(val),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: ThemeService.instance.divider, height: 1)),
                        _SettingToggleRow(
                          icon: Icons.fingerprint, title: 'Fingerprint', subtitle: 'Login dengan sidik jari',
                          value: _fingerprintEnabled,
                          onChanged: (val) => _handleFingerprintToggle(val),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: ThemeService.instance.divider, height: 1)),
                        _SettingActionRow(
                          icon: Icons.pin, title: 'Transaksi PIN', subtitle: '',
                          actionWidget: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: ThemeService.instance.chipBg, shape: BoxShape.circle, border: Border.all(color: ThemeService.instance.border)),
                            child: Icon(Icons.chevron_right, size: 16, color: ThemeService.instance.iconColor),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PinSettingsScreen()));
                          }
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 2: Preferensi Aplikasi
                  _SectionTitle(title: 'Preferensi Aplikasi', icon: Icons.tune),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.card, 
                      borderRadius: BorderRadius.circular(16), 
                      border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeService.instance.isDarkMode ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF1C1D1F).withValues(alpha: 0.03), 
                          blurRadius: 12, 
                          offset: const Offset(0, 4)
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _SettingActionRow(
                          icon: Icons.language, title: 'Bahasa', subtitle: 'Bahasa Indonesia', actionWidget: const Icon(Icons.chevron_right, color: Color(0xFF1C1C18)),
                          onTap: () => _showLanguageSelection(context),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: ThemeService.instance.divider, height: 1)),
                          _SettingActionRow(
                            icon: Icons.local_parking, title: 'Preferensi Parkir', subtitle: _selectedParkingPref, actionWidget: const Icon(Icons.chevron_right, color: Color(0xFF1C1C18)),
                            onTap: () => _showParkingPrefSelection(context),
                          ),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: ThemeService.instance.divider, height: 1)),
                        _SettingActionRow(
                          icon: Icons.payments,
                          title: 'Mata Uang',
                          subtitle: '${CurrencyService.instance.currentCurrency} (${CurrencyService.instance.currentInfo.name})',
                          actionWidget: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EEE7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  CurrencyService.instance.currentCurrency,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C1C18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1C1C18)),
                            ],
                          ),
                          onTap: () => _showCurrencySelectionModal(context),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: ThemeService.instance.divider, height: 1)),
                        _SettingToggleRow(
                          icon: Icons.notifications_active, title: 'Notifikasi Sesi & Promo', subtitle: 'Pemberitahuan durasi & cashback',
                          value: _notifEnabled,
                          onChanged: (val) => setState(() => _notifEnabled = val),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: ThemeService.instance.divider, height: 1)),
                        _SettingToggleRow(
                          icon: ThemeService.instance.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          title: 'Dark Mode',
                          subtitle: ThemeService.instance.isDarkMode ? 'Tema gelap aktif' : 'Tema terang aktif (Light Mode)',
                          value: ThemeService.instance.isDarkMode,
                          onChanged: (val) {
                            ThemeService.instance.setDarkMode(val);
                            _showSuccessToast(val ? 'Dark mode diaktifkan' : 'Light mode diaktifkan');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 3: Privasi & Data
                  _SectionTitle(title: 'Privasi & Data', icon: Icons.shield),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.card, 
                      borderRadius: BorderRadius.circular(16), 
                      border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeService.instance.isDarkMode ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF1C1D1F).withValues(alpha: 0.03), 
                          blurRadius: 12, 
                          offset: const Offset(0, 4)
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        Row(
                          children: [
                            Container(width: 40, height: 40, decoration: BoxDecoration(color: ThemeService.instance.chipBg, shape: BoxShape.circle), child: Icon(Icons.cleaning_services, size: 20, color: ThemeService.instance.iconColor)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hapus Riwayat Cache', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: ThemeService.instance.textPrimary)),
                                  Text(_cacheSize, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: ThemeService.instance.textSecondary)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _isCacheCleared ? null : () {
                                setState(() {
                                  _cacheSize = '0 KB tersimpan (Bersih)';
                                  _isCacheCleared = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: ThemeService.instance.chipBg, borderRadius: BorderRadius.circular(16)),
                                child: _isCacheCleared 
                                  ? Row(children: [const Icon(Icons.done, size: 14, color: Color(0xFF45474A)), const SizedBox(width: 4), Text('Beres', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A)))])
                                  : Text('Bersihkan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  

                  
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5F8F78), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('ParkSmart v2.4.0 (Build 2026.10)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: ThemeService.instance.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.token, size: 14, color: Color(0xFF45474A)),
                            const SizedBox(width: 6),
                            Text('Blockchain Verified Network • Jakarta Smart Mobility', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: ThemeService.instance.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(), 
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: ThemeService.instance.textSecondary, 
            letterSpacing: 1.0,
          ),
        ),
        Icon(icon, size: 16, color: ThemeService.instance.textSecondary),
      ],
    );
  }
}

class _SettingToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleRow({
    required this.icon, 
    required this.title, 
    required this.subtitle, 
    required this.value, 
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, 
          height: 40, 
          decoration: BoxDecoration(
            color: ThemeService.instance.chipBg, 
            shape: BoxShape.circle,
          ), 
          child: Icon(icon, size: 20, color: ThemeService.instance.iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600, 
                  color: ThemeService.instance.textPrimary,
                ),
              ),
              if (subtitle.isNotEmpty) 
                Text(
                  subtitle, 
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, 
                    color: ThemeService.instance.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: value, 
          onChanged: onChanged, 
          activeThumbColor: Colors.white, 
          activeTrackColor: ThemeService.instance.isDarkMode 
              ? const Color(0xFFC05621) 
              : const Color(0xFF020304),
        ),
      ],
    );
  }
}

class _SettingActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? actionWidget;
  final VoidCallback? onTap;

  const _SettingActionRow({
    required this.icon, 
    required this.title, 
    required this.subtitle, 
    this.actionWidget, 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 40, 
            height: 40, 
            decoration: BoxDecoration(
              color: ThemeService.instance.chipBg, 
              shape: BoxShape.circle,
            ), 
            child: Icon(icon, size: 20, color: ThemeService.instance.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: ThemeService.instance.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) 
                  Text(
                    subtitle, 
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, 
                      color: ThemeService.instance.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          ?actionWidget,
        ],
      ),
    );
  }
}


