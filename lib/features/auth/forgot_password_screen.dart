import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/theme_service.dart';
import '../../core/utils/hash_util.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      _showError('Harap masukkan alamat email Anda.');
      return;
    }

    if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$').hasMatch(email)) {
      _showError('Format alamat email tidak valid.');
      return;
    }

    if (newPassword.isEmpty) {
      _showError('Harap masukkan kata sandi baru.');
      return;
    }

    if (newPassword.length < 6) {
      _showError('Kata sandi baru minimal terdiri dari 6 karakter.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Konfirmasi kata sandi baru tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final inputEmail = email.toLowerCase();

      // 1. Cek di tabel users
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('id, email, full_name')
          .ilike('email', inputEmail)
          .maybeSingle();

      if (userResponse != null) {
        await Supabase.instance.client
            .from('users')
            .update({
              'password': HashUtil.hashPassword(newPassword),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userResponse['id']);

        if (!mounted) return;
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kata sandi berhasil diperbarui untuk ${userResponse['email']}. Silakan masuk dengan kata sandi baru.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      // 2. Jika tidak ada di users, cek di tabel admins
      final adminResponse = await Supabase.instance.client
          .from('admins')
          .select('id, email, full_name')
          .ilike('email', inputEmail)
          .maybeSingle();

      if (adminResponse != null) {
        await Supabase.instance.client
            .from('admins')
            .update({
              'password': HashUtil.hashPassword(newPassword),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', adminResponse['id']);

        if (!mounted) return;
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kata sandi admin berhasil diperbarui untuk ${adminResponse['email']}. Silakan masuk dengan kata sandi baru.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      // 3. Email tidak cocok di database
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Email tidak terdaftar di database. Silakan periksa kembali email Anda.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Gagal memperbarui kata sandi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        final Color bg = isDark ? const Color(0xFF111418) : const Color(0xFFF9F9F9);
        final Color cardBg = isDark ? const Color(0xFF181C22) : Colors.white;
        final Color textMain = isDark ? Colors.white : const Color(0xFF14202B);
        final Color textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color borderColor = isDark ? const Color(0xFF28303C) : const Color(0xFFD8DEE5);
        final Color primaryBrand = isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Tombol Kembali
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: textMain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Badge Keamanan Akun
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F2338) : const Color(0xFFEBF3FC),
                        borderRadius: BorderRadius.circular(20),
                        border: isDark
                            ? Border.all(color: primaryBrand.withValues(alpha: 0.6), width: 1.2)
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: primaryBrand,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reset Kata Sandi Akun',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: primaryBrand,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Judul Utama
                    Text(
                      'Lupa Kata\nSandi Anda?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: textMain,
                        height: 1.15,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Masukkan email akun Anda dan tentukan kata sandi baru. Kata sandi akan langsung diperbarui jika email terdaftar.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        color: textSub,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Card Form Input (Email & Kata Sandi Baru)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Input Email
                          _InputField(
                            controller: _emailController,
                            label: 'Alamat Email Terdaftar',
                            hint: 'contoh: pengguna@gmail.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            isDark: isDark,
                            borderColor: borderColor,
                            textMain: textMain,
                            textSub: textSub,
                            primaryBrand: primaryBrand,
                          ),
                          const SizedBox(height: 18),

                          // 2. Input Password Baru
                          _InputField(
                            controller: _passwordController,
                            label: 'Kata Sandi Baru',
                            hint: 'Minimal 6 karakter',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            isDark: isDark,
                            borderColor: borderColor,
                            textMain: textMain,
                            textSub: textSub,
                            primaryBrand: primaryBrand,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: textSub,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 3. Konfirmasi Password Baru
                          _InputField(
                            controller: _confirmPasswordController,
                            label: 'Konfirmasi Kata Sandi Baru',
                            hint: 'Ulangi kata sandi baru',
                            icon: Icons.lock_reset_rounded,
                            obscureText: _obscureConfirmPassword,
                            isDark: isDark,
                            borderColor: borderColor,
                            textMain: textMain,
                            textSub: textSub,
                            primaryBrand: primaryBrand,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: textSub,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info Keamanan (Tanpa OTP)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161E28) : const Color(0xFFF0F5FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF223447) : const Color(0xFFD6E4F0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF006A9A),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kata sandi akan langsung diubah di database jika email cocok, tanpa memerlukan verifikasi kode OTP.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Button (Simpan Kata Sandi Baru)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : const Color(0xFF114177),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: isDark ? 6 : 0,
                          shadowColor: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 20,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Simpan Kata Sandi Baru',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.black : Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tautan Kembali ke Halaman Login
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: textSub,
                            ),
                            children: [
                              const TextSpan(text: 'Sudah ingat kata sandi? '),
                              TextSpan(
                                text: 'Masuk Sekarang',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool isDark;
  final Color borderColor;
  final Color textMain;
  final Color textSub;
  final Color primaryBrand;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    required this.isDark,
    required this.borderColor,
    required this.textMain,
    required this.textSub,
    required this.primaryBrand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textMain,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: textMain,
            ),
            cursorColor: primaryBrand,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: textSub.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
