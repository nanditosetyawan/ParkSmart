// PS-01 Login — Reconstructed from Stitch reference with 3-Layer scenic parallax
// Layer 1: Full-screen backgroundLogin.jpg
// Layer 2: ParkSmart logo + text directly on background (no circle)
// Layer 3: 3/4 white sheet with 2 handle indicator lines, draggable down to mentok leaving only 46px handle
// Includes persistent "Ingat saya di perangkat ini" via SharedPreferences
// Includes Secret Admin Portal on 5-second bottom hold

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/theme_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../home/home_screen.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../admin/super_admin/admin_dashboard_screen.dart';
import '../../core/services/client_info_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _obscure = true;
  bool _remember = false;
  bool _fingerprintEnabled = true;
  bool _faceIdEnabled = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Admin Portal State
  final TextEditingController _adminUsernameController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  bool _adminObscure = true;
  bool _showAdminPortal = false;
  bool _isLockedAtBottom = false;
  bool _isHoldingAtBottom = false;
  Timer? _bottomHoldTimer;

  // Jarak seret ke bawah (0.0 = posisi normal 3/4, bertambah saat diseret turun)
  double _dragOffset = 0.0;
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    // Pastikan bilah status dan navigasi sistem tetap terlihat
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
    );

    _springController.addListener(() {
      setState(() {
        _dragOffset = _springAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _bottomHoldTimer?.cancel();
    _springController.dispose();
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final bool remember = prefs.getBool('remember_me') ?? false;
    final bool fp = prefs.getBool('fingerprint_enabled') ?? true;
    final bool face = prefs.getBool('face_id_enabled') ?? false;

    if (mounted) {
      setState(() {
        _fingerprintEnabled = fp;
        _faceIdEnabled = face;
        if (remember) {
          _remember = true;
          final String? savedEmail = prefs.getString('saved_email');
          final String? savedPassword = prefs.getString('saved_password');
          if (savedEmail != null) _emailController.text = savedEmail;
          if (savedPassword != null) _passwordController.text = savedPassword;
        }
      });

      // Jika Face ID aktif, beneran memakai sistem Android untuk membuka layar
      if (_faceIdEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _authenticateWithFaceId();
        });
      }
    }
  }

  Future<void> _authenticateWithFaceId() async {
    if (!_faceIdEnabled) return;
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final List<BiometricType> available = await auth.getAvailableBiometrics();
      if (!available.contains(BiometricType.face)) {
        return;
      }
      final bool didAuth = await auth.authenticate(
        localizedReason: 'Pindai wajah untuk membuka layar',
        biometricOnly: true,
      );
      if (didAuth && mounted) {
        if (_remember) {
          await _saveCredentials();
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Face ID unlock error: $e');
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', true);
    await prefs.setString('saved_email', _emailController.text);
    await prefs.setString('saved_password', _passwordController.text);
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false);
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  void _startBottomHoldTimer() {
    if (_isHoldingAtBottom || _isLockedAtBottom) return;
    _isHoldingAtBottom = true;
    _bottomHoldTimer?.cancel();
    _bottomHoldTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _isLockedAtBottom = true;
        _showAdminPortal = true;
        _isHoldingAtBottom = false;
      });
    });
  }

  void _cancelBottomHold() {
    _bottomHoldTimer?.cancel();
    _bottomHoldTimer = null;
    _isHoldingAtBottom = false;
  }

  void _unlockAndSpringUp() {
    _cancelBottomHold();
    // Hilangkan portal admin terlebih dahulu secara cepat
    setState(() {
      _showAdminPortal = false;
      _isLockedAtBottom = false;
    });
    // Beri jeda sangat singkat agar portal admin lenyap dulu baru user sheet melompat naik
    Future.delayed(const Duration(milliseconds: 35), () {
      if (mounted) {
        _springBack();
      }
    });
  }

  void _applyDrag(double deltaDy, double maxDrag) {
    if (_springController.isAnimating) {
      _springController.stop();
    }
    setState(() {
      _dragOffset = (_dragOffset + deltaDy).clamp(0.0, maxDrag);
    });

    // Jika telah sampai di posisi mentok ujung bawah
    if (_dragOffset >= maxDrag - 1.0) {
      _startBottomHoldTimer();
    } else {
      // Jika digeser naik menjauhi batas mentok sebelum 5 detik, batalkan timer
      if (deltaDy < -1.0) {
        _cancelBottomHold();
      }
    }
  }

  void _onDragEnded() {
    if (_isLockedAtBottom) {
      // Jika sudah terkunci di bawah karena tahan 5 detik, jangan naik lagi
      return;
    }
    // Jika dilepas sebelum 5 detik, batalkan timer dan memantul naik
    _cancelBottomHold();
    _springBack();
  }

  void _springBack() {
    if (_dragOffset == 0.0) return;
    _springAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.easeOutBack,
    ));
    _springController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final mediaQuery = MediaQuery.of(context);
    final double screenH = mediaQuery.size.height;
    final double bottomInset = mediaQuery.padding.bottom;

    // Layer 3 menutupi sekitar 3/4 layar dari bawah (dimulai dari 26% dari atas)
    final double normalTop = screenH * 0.26;
    // Tinggi area pegangan alat seret (penanda 2 garis di tengah)
    const double handleVisibleHeight = 46.0;
    // Posisi top saat sheet diseret mentok ke paling bawah: menyisakan setinggi alat seret tepat di atas navigasi bawah
    final double maxTop = screenH - handleVisibleHeight - bottomInset;
    // Jarak seret maksimal dari posisi 3/4 sampai mentok di ujung bawah
    final double maxDragDown = (maxTop - normalTop).clamp(0.0, screenH);
    final double currentTop = normalTop + _dragOffset;
    final double sheetHeight = screenH - normalTop;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── LAYER 1: BACKGROUND GAMBAR FULL SCREEN ─────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundLogin.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ─── LAYER 2: BRAND LOGO & NAMA LANGSUNG DI ATAS GAMBAR ──────────
          // (Langsung tanpa circle putih, belakangnya langsung gambar layer 1)
          Positioned(
            top: mediaQuery.padding.top + 8,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTypography.logoTitle().copyWith(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w800,
                        ),
                        children: [
                          const TextSpan(text: 'Park'),
                          TextSpan(
                            text: 'Smart',
                            style: AppTypography.logoTitle(color: AppColors.warmTerracotta),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'SEAMLESS PARKING',
                      style: AppTypography.overline(color: const Color(0xFF475569)).copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── LAYER 3: SHEET PUTIH 3/4 DARI SISI BAWAH ───────────────────
          // (Dapat diseret mentok ke ujung bawah menyisakan setinggi 46px alat seret 2 garis)
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            height: sheetHeight + 150.0,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262C36) : const Color(0xFFFAF7F2), // Background yang dapat diseret lebih terang di darkmode (tidak pekat)
                borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
                border: isDark ? Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1)) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 26,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // PENANDA GARIS 2 DI TENGAH KECIL OPACITY TIPIS SUDUT BULAT
                  // Area alat seret (satu-satunya yang tetap terlihat saat diseret mentok ke paling bawah)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      if (_isLockedAtBottom) {
                        // Jika dalam mode portal admin lalu diswipe ringan naik (delta.dy < -2.0)
                        if (details.delta.dy < -2.0) {
                          _unlockAndSpringUp();
                        }
                        return;
                      }
                      _applyDrag(details.delta.dy, maxDragDown);
                    },
                    onVerticalDragEnd: (_) => _onDragEnded(),
                    onVerticalDragCancel: () => _onDragEnded(),
                    child: SizedBox(
                      width: double.infinity,
                      height: handleVisibleHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Garis atas
                          Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : const Color(0xFF1E293B).withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          // Garis bawah
                          Container(
                            width: 24,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : const Color(0xFF1E293B).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // KONTEN FORMULIR LOGIN (DIPINDAHKAN UTUH DENGAN SCROLL & DRAG LISTENER)
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (_isLockedAtBottom) return false;
                        if (notification is OverscrollNotification) {
                          if (notification.overscroll < 0) {
                            _applyDrag(-notification.overscroll, maxDragDown);
                          }
                        } else if (notification is ScrollUpdateNotification) {
                          if (_dragOffset > 0 && (notification.scrollDelta ?? 0) > 0) {
                            _applyDrag(-(notification.scrollDelta ?? 0), maxDragDown);
                          } else if (_scrollController.hasClients &&
                              _scrollController.offset <= 0 &&
                              (notification.scrollDelta ?? 0) < 0) {
                            _applyDrag(-(notification.scrollDelta ?? 0), maxDragDown);
                          }
                        } else if (notification is ScrollEndNotification) {
                          _onDragEnded();
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Heading Selamat Datang
                            Text(
                              'Selamat Datang',
                              style: AppTypography.displayHero(color: isDark ? Colors.white : null),
                            ),

                            // Formulir Input
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text('Email / No. Handphone', style: AppTypography.labelMd(color: isDark ? Colors.white : null)),
                            ),
                            _PillInput(
                              controller: _emailController,
                              hintText: 'nama@email.com',
                              prefixIcon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              isDark: isDark,
                              onChanged: (_) {
                                if (_remember) _saveCredentials();
                              },
                            ),

                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Kata Sandi', style: AppTypography.labelMd(color: isDark ? Colors.white : null)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Lupa Sandi?',
                                      style: AppTypography.labelSm(
                                        color: isDark ? const Color(0xFFFB923C) : AppColors.warmTerracotta,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _PillInput(
                              controller: _passwordController,
                              hintText: 'Masukkan kata sandi',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscure,
                              suffixIcon: _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              onSuffixTap: () => setState(() => _obscure = !_obscure),
                              isDark: isDark,
                              onChanged: (_) {
                                if (_remember) _saveCredentials();
                              },
                            ),

                            // Checkbox Ingat Saya
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () {
                                final nextState = !_remember;
                                setState(() => _remember = nextState);
                                if (nextState) {
                                  _saveCredentials();
                                } else {
                                  _clearCredentials();
                                }
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 4),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _remember
                                          ? (isDark ? Colors.white : AppColors.primary)
                                          : (isDark ? const Color(0xFF1E232B) : AppColors.surfaceCard),
                                      border: Border.all(
                                        color: _remember
                                            ? (isDark ? Colors.white : AppColors.primary)
                                            : (isDark ? Colors.white54 : AppColors.warmBorder),
                                      ),
                                    ),
                                    child: _remember
                                        ? Icon(
                                            Icons.check,
                                            size: 13,
                                            color: isDark ? Colors.black : AppColors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'Ingat saya di perangkat ini',
                                    style: AppTypography.labelSm(
                                      color: isDark ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Masuk ke Akun
                            const SizedBox(height: 20),
                            _StitchButton(
                              label: 'Masuk ke Akun',
                              isDark: isDark,
                              onTap: () async {
                                if (_remember) {
                                  await _saveCredentials();
                                }
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  );
                                }
                              },
                            ),

                            // Divider atau
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(child: Divider(color: isDark ? Colors.white24 : AppColors.warmBorder)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'atau',
                                    style: AppTypography.caption(
                                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: isDark ? Colors.white24 : AppColors.warmBorder)),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Secondary auth buttons (Biometrik & Google)
                            Row(
                              children: [
                                if (_fingerprintEnabled) ...[
                                  Expanded(
                                    child: _SecondaryButton(
                                      label: 'Biometrik',
                                      icon: Icons.fingerprint,
                                      isDark: isDark,
                                      onTap: () async {
                                        final LocalAuthentication auth = LocalAuthentication();
                                        try {
                                          final bool didAuthenticate = await auth.authenticate(
                                            localizedReason: 'Gunakan sidik jari untuk masuk',
                                            biometricOnly: true,
                                          );
                                          if (didAuthenticate && context.mounted) {
                                            if (_remember) {
                                              await _saveCredentials();
                                            }
                                            if (context.mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          debugPrint(e.toString());
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: _SecondaryButton(
                                    label: 'Google',
                                    isDark: isDark,
                                    customIcon: Image.network(
                                      'https://www.google.com/favicon.ico',
                                      width: 18,
                                      height: 18,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.g_mobiledata, size: 20),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),

                            // Link Daftar Akun Baru
                            const SizedBox(height: 26),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTypography.bodySm(
                                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Belum punya akun? '),
                                      TextSpan(
                                        text: 'Daftar Sekarang',
                                        style: AppTypography.bodySm(
                                          color: isDark ? const Color(0xFFFB923C) : AppColors.warmTerracotta,
                                        ).copyWith(
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Buffer bawah agar saat sheet memantul loncat lebih tinggi (overshoot),
                  // bagian bawah layar tetap tertutup penuh dan latar belakang tidak bocor
                  const SizedBox(height: 150.0),
                ],
              ),
            ),
          ),

          // ─── OVERLAY PORTAL ADMIN (MUNCUL SETELAH TAHAN 5 DETIK DI MENTOK BAWAH) ───
          if (_showAdminPortal)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  // Swipe ringan naik langsung menutup portal dan menaikkan user sheet
                  if (details.delta.dy < -2.5) {
                    _unlockAndSpringUp();
                  }
                },
                child: Container(
                  // ─── [1] KEPEKATAN LATAR BELAKANG SCRIM (Ubah nilai alpha di bawah: misal 0.08 s/d 0.20) ───
                  color: Colors.black.withValues(alpha: 0.10),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 360),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          // ─── [2] TRANSPARANSI GLASS CARD ADMIN (Ubah alpha: 0.30 lebih tembus pandang, 0.60 lebih pekat) ───
                          color: Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header badge & close icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B).withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.security, size: 13, color: Colors.white),
                                      const SizedBox(width: 5),
                                      Text(
                                        'PORTAL ADMIN',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _unlockAndSpringUp,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Tulisan Silahkan Login
                            Text(
                              'Silahkan Login',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Field Username
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 19, color: Color(0xFF64748B)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _adminUsernameController,
                                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
                                      decoration: InputDecoration(
                                        hintText: 'Username',
                                        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Field Password
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock_outline, size: 19, color: Color(0xFF64748B)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _adminPasswordController,
                                      obscureText: _adminObscure,
                                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _adminObscure = !_adminObscure),
                                    child: Icon(
                                      _adminObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      size: 18,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Tombol Masuk Portal Admin
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  // ─── [DEV ACCESS]: Validasi dinonaktifkan sementara untuk kemudahan development.
                                  // Saat siap rilis, hilangkan komentar blok validasi di bawah ini:
                                  /*
                                  final u = _adminUsernameController.text.trim();
                                  final p = _adminPasswordController.text;
                                  if (u.isEmpty || p.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Silahkan isi username dan password admin'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }
                                  */

                                  final adminUser = _adminUsernameController.text.trim().isNotEmpty
                                      ? _adminUsernameController.text.trim()
                                      : 'Gibran Widodo';
                                  ClientInfoService.instance.recordAdminLogin(
                                    adminName: adminUser,
                                    adminEmail: 'superadmin@parksmart.id',
                                    role: 'Super Admin',
                                    action: 'Login berhasil (Portal Otentikasi)',
                                  );

                                  // Langsung masuk ke Admin Dashboard (Akses Developer)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                ),
                                child: Text(
                                  'Masuk',
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
      },
    );
  }
}

// ─── Shared Stitch components ─────────────────────────────────────────────

class _PillInput extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isDark;

  const _PillInput({
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : AppColors.surfaceCard, // Kolom field putih saat darkmode
        borderRadius: AppRadii.pillRadius,
        border: Border.all(
          color: isDark ? const Color(0xFFE5E2DB) : AppColors.warmBorder,
        ),
        boxShadow: const [AppShadows.field],
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              prefixIcon,
              size: 20,
              color: isDark ? Colors.black87 : AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              keyboardType: keyboardType,
              cursorColor: isDark ? Colors.black : AppColors.primary,
              style: AppTypography.bodyMd(
                color: isDark ? Colors.black : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.bodyMd(
                  color: isDark ? Colors.black54 : AppColors.textMuted.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          if (suffixIcon != null)
            GestureDetector(
              onTap: onSuffixTap,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 4),
                child: Icon(
                  suffixIcon,
                  size: 20,
                  color: isDark ? Colors.black87 : AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StitchButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _StitchButton({
    required this.label,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : AppColors.primary,
          foregroundColor: isDark ? Colors.black : AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            (isDark ? Colors.black : AppColors.white).withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.buttonLg(
            color: isDark ? Colors.black : AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback onTap;
  final bool isDark;

  const _SecondaryButton({
    required this.label,
    this.icon,
    this.customIcon,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? Colors.white : AppColors.surfaceCard,
          borderRadius: AppRadii.pillRadius,
          border: Border.all(
            color: isDark ? const Color(0xFFE5E2DB) : AppColors.warmBorder.withValues(alpha: 0.9),
          ),
          boxShadow: const [AppShadows.soft],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFF1EEE7) : AppColors.surfaceField,
                shape: BoxShape.circle,
              ),
              child: customIcon != null
                  ? Center(child: customIcon)
                  : Icon(
                      icon,
                      size: 18,
                      color: isDark ? Colors.black : AppColors.textPrimary,
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.buttonSm(
                color: isDark ? Colors.black : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
