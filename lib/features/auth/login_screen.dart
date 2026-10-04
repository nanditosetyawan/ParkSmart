// PS-01 Login — Reconstructed from actual Stitch HTML
// Font: Plus Jakarta Sans | bg: #FAF7F2 | primary button: charcoal pill
// Input: rounded-full, bg white border warmBorder
// CTA: h-[56px] bg-charcoal rounded-full shadow

import 'package:flutter/material.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _remember = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ─── Top brand row ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Logo pill container — rounded-full bg-white border shadow
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.warmBorder.withOpacity(0.8)),
                          boxShadow: const [AppShadows.soft],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDLoi5lUQ_yrFCiVd8Dn2G6gCles-BYgcTxBL84YCio-v87VwFAUXzZNSU4lSvMRVYDwjCsxDZT6zWWVB4I6mZk1ECThwKRQgDkuX52G2yY4KjXPSwgwTD9-6wsXAiRbZoOgT2H_aCckZh7wYnfAoiafvPV51YKXOCqTZIi2ALwyhdPF9wla46O98kKzJGoxd0FWCJRSbTv4K8UDpXaY5gWkklWhGTetALtFVgOkJ6NLhNU2LKzp4sL',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.local_parking, color: AppColors.warmTerracotta),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: AppTypography.logoTitle(),
                              children: [
                                const TextSpan(text: 'Park'),
                                TextSpan(text: 'Smart', style: AppTypography.logoTitle(color: AppColors.warmTerracotta)),
                              ],
                            ),
                          ),
                          Text('SEAMLESS PARKING', style: AppTypography.overline(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.warmBorder.withOpacity(0.6)),
                    ),
                    child: const Icon(Icons.local_parking, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),

              // ─── Oversized hero heading ──────────────────────────────
              const SizedBox(height: 36),
              Text(
                'Selamat Datang\nKembali.',
                style: AppTypography.displayHero(),
              ),
              const SizedBox(height: 12),
              Text(
                'Masuk untuk kelola pesanan & temukan slot parkir real-time tanpa antre.',
                style: AppTypography.bodySm(color: AppColors.textSecondary),
              ),

              // ─── Form ────────────────────────────────────────────────
              const SizedBox(height: 24),
              // Email/phone label
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Email / No. Handphone', style: AppTypography.labelMd()),
              ),
              _PillInput(
                hintText: 'nama@email.com atau 0812...',
                prefixIcon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),
              // Password label + forgot
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

              // Remember me
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _remember = !_remember),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20, height: 20,
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
                    Text('Ingat saya di perangkat ini', style: AppTypography.labelSm(color: AppColors.textSecondary)),
                  ],
                ),
              ),

              // ─── Primary CTA — charcoal pill h-[56px] ───────────────
              const SizedBox(height: 32),
              _StitchButton(
                label: 'Masuk ke Akun',
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
              ),

              // ─── Divider ─────────────────────────────────────────────
              const SizedBox(height: 28),
              Row(children: [
                const Expanded(child: Divider(color: AppColors.warmBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('atau', style: AppTypography.caption(color: AppColors.textSecondary)),
                ),
                const Expanded(child: Divider(color: AppColors.warmBorder)),
              ]),
              const SizedBox(height: 14),

              // ─── Secondary auth grid ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      label: 'Biometrik',
                      icon: Icons.fingerprint,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SecondaryButton(
                      label: 'Google',
                      customIcon: Image.network(
                        'https://www.google.com/favicon.ico',
                        width: 18, height: 18,
                        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20),
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              // ─── Register link ────────────────────────────────────────
              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
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
            width: 48, height: 48,
            child: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: AppTypography.bodyMd(),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.bodyMd(color: AppColors.textMuted.withOpacity(0.7)),
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
                width: 40, height: 40,
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
          overlayColor: WidgetStateProperty.all(AppColors.white.withOpacity(0.08)),
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
          border: Border.all(color: AppColors.warmBorder.withOpacity(0.9)),
          boxShadow: const [AppShadows.soft],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28, height: 28,
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
