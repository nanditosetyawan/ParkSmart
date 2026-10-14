// PS-01 Login — Reconstructed from Stitch reference with 3-Layer scenic parallax
// Layer 1: Full-screen backgroundLogin.jpg
// Layer 2: ParkSmart logo + text directly on background (no circle)
// Layer 3: 3/4 white sheet with 2 handle indicator lines, heavy drag resistance downwards

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../home/home_screen.dart';
import '../auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _obscure = true;
  bool _remember = false;

  // Jarak seret ke bawah (0.0 = posisi normal 3/4, bertambah saat diseret turun)
  double _dragOffset = 0.0;
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

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
      duration: const Duration(milliseconds: 380),
    );

    _springController.addListener(() {
      setState(() {
        _dragOffset = _springAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyDrag(double deltaDy, double maxDrag) {
    if (_springController.isAnimating) {
      _springController.stop();
    }
    // Efek seret berat banget: pergerakan diperlambat dengan faktor redaman (0.24)
    setState(() {
      _dragOffset = (_dragOffset + deltaDy * 0.24).clamp(0.0, maxDrag);
    });
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
    final mediaQuery = MediaQuery.of(context);
    final double screenH = mediaQuery.size.height;

    // Layer 3 menutupi sekitar 3/4 layar dari bawah (dimulai dari 26% dari atas)
    final double normalTop = screenH * 0.26;
    final double maxDragDown = screenH * 0.52; // Bisa diseret turun membuka pemandangan layer 1
    final double currentTop = normalTop + _dragOffset;

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
          // (Dapat diseret ke bawah dengan efek berat banget untuk intip layer 1)
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2), // Warna putih hangat sesuai tema
                borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
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
                  // Area drag handle untuk seret ke bawah
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      _applyDrag(details.delta.dy, maxDragDown);
                    },
                    onVerticalDragEnd: (_) => _springBack(),
                    onVerticalDragCancel: () => _springBack(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 14, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Garis atas
                          Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          // Garis bawah
                          Container(
                            width: 24,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.13),
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
                        if (notification is ScrollUpdateNotification) {
                          // Jika scroll berada di paling atas dan user menyeret ke bawah
                          if (_scrollController.hasClients &&
                              _scrollController.offset <= 0 &&
                              (notification.scrollDelta ?? 0) < 0) {
                            _applyDrag(-(notification.scrollDelta ?? 0), maxDragDown);
                          }
                        } else if (notification is ScrollEndNotification) {
                          if (_dragOffset > 0) {
                            _springBack();
                          }
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Heading Selamat Datang Kembali
                            Text(
                              'Selamat Datang\nKembali.',
                              style: AppTypography.displayHero(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Masuk untuk kelola pesanan & temukan slot parkir real-time tanpa antre.',
                              style: AppTypography.bodySm(color: AppColors.textSecondary),
                            ),

                            // Formulir Input
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text('Email / No. Handphone', style: AppTypography.labelMd()),
                            ),
                            const _PillInput(
                              hintText: 'nama@email.com atau 0812...',
                              prefixIcon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('Kata Sandi', style: AppTypography.labelMd()),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text('Lupa Sandi?', style: AppTypography.labelMd(color: AppColors.warmTerracotta)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _PillInput(
                              hintText: 'Masukkan kata sandi',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscure,
                              suffixIcon: _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              onSuffixTap: () => setState(() => _obscure = !_obscure),
                            ),

                            // Remember me checkbox
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => setState(() => _remember = !_remember),
                              child: Row(
                                children: [
                                  const SizedBox(width: 4),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _remember ? AppColors.primary : AppColors.surfaceCard,
                                      border: Border.all(
                                        color: _remember ? AppColors.primary : AppColors.warmBorder,
                                      ),
                                    ),
                                    child: _remember
                                        ? const Icon(Icons.check, size: 13, color: AppColors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Ingat saya di perangkat ini',
                                    style: AppTypography.labelSm(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Masuk ke Akun
                            const SizedBox(height: 30),
                            _StitchButton(
                              label: 'Masuk ke Akun',
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              ),
                            ),

                            // Divider atau
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Expanded(child: Divider(color: AppColors.warmBorder)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('atau', style: AppTypography.caption(color: AppColors.textSecondary)),
                                ),
                                const Expanded(child: Divider(color: AppColors.warmBorder)),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Secondary auth buttons (Biometrik & Google)
                            Row(
                              children: [
                                Expanded(
                                  child: _SecondaryButton(
                                    label: 'Biometrik',
                                    icon: Icons.fingerprint,
                                    onTap: () async {
                                      final LocalAuthentication auth = LocalAuthentication();
                                      try {
                                        final bool didAuthenticate = await auth.authenticate(
                                          localizedReason: 'Gunakan sidik jari untuk masuk',
                                          biometricOnly: true,
                                        );
                                        if (didAuthenticate && context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                                          );
                                        }
                                      } catch (e) {
                                        debugPrint(e.toString());
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SecondaryButton(
                                    label: 'Google',
                                    customIcon: Image.network(
                                      'https://www.google.com/favicon.ico',
                                      width: 18,
                                      height: 18,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 20),
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
                                    style: AppTypography.bodySm(color: AppColors.textSecondary),
                                    children: [
                                      const TextSpan(text: 'Belum punya akun? '),
                                      TextSpan(
                                        text: 'Daftar Sekarang',
                                        style: AppTypography.bodySm().copyWith(
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                          color: AppColors.textPrimary,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Stitch components ────────────────────────────────────────────────

class _PillInput extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;

  const _PillInput({
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.pillRadius,
        border: Border.all(color: AppColors.warmBorder),
        boxShadow: const [AppShadows.field],
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: AppTypography.bodyMd(),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.bodyMd(color: AppColors.textMuted.withValues(alpha: 0.7)),
                border: InputBorder.none,
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
                child: Icon(suffixIcon, size: 20, color: AppColors.textSecondary),
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

  const _StitchButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(AppColors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTypography.buttonLg(color: AppColors.white)),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward, size: 19),
          ],
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

  const _SecondaryButton({required this.label, this.icon, this.customIcon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadii.pillRadius,
          border: Border.all(color: AppColors.warmBorder.withValues(alpha: 0.9)),
          boxShadow: const [AppShadows.soft],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: AppColors.surfaceField, shape: BoxShape.circle),
              child: customIcon != null
                  ? Center(child: customIcon)
                  : Icon(icon, size: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.buttonSm()),
          ],
        ),
      ),
    );
  }
}
