import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF111418) : const Color(0xFFF6F3EC),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF181C22) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF28303C) : const Color(0xFFE5E2DB),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Premium Header Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D2824) : const Color(0xFF1C1C18),
                        borderRadius: BorderRadius.circular(20),
                        border: isDark
                            ? Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.6), width: 1.2)
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 15,
                            color: isDark ? const Color(0xFF2DD4BF) : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Bergabung Sekarang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF2DD4BF) : Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Buat Akun\nBaru Anda.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                        height: 1.15,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Isi data di bawah untuk menikmati kemudahan parkir pintar tanpa hambatan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Grouped Form Card (Sleek dark card in dark mode, clean white in light mode)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181C22) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? const Color(0xFF28303C) : const Color(0xFFE5E2DB),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildField(
                            icon: Icons.person_outline,
                            label: 'Nama Lengkap',
                            hint: 'Sarah Natasha',
                            isFirst: true,
                            isDark: isDark,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                            indent: 70,
                          ),
                          _buildField(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            hint: 'nama@email.com',
                            type: TextInputType.emailAddress,
                            isDark: isDark,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                            indent: 70,
                          ),
                          _buildField(
                            icon: Icons.phone_outlined,
                            label: 'No. Handphone',
                            hint: '0812 3456 7890',
                            type: TextInputType.phone,
                            isDark: isDark,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                            indent: 70,
                          ),
                          _buildField(
                            icon: Icons.lock_outline,
                            label: 'Kata Sandi',
                            hint: 'Min. 8 karakter',
                            obscure: _obscurePassword,
                            isLast: true,
                            isDark: isDark,
                            suffix: GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFA29F98),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Button (Tombol putih kontras tinggi dengan teks hitam)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: isDark ? 6 : 0,
                          shadowColor: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Buat Akun',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.black : Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              size: 19,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                            ),
                            children: [
                              const TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(
                                text: 'Masuk di sini',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1C1C18),
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

  Widget _buildField({
    required IconData icon,
    required String label,
    required String hint,
    TextInputType? type,
    bool obscure = false,
    bool isFirst = false,
    bool isLast = false,
    Widget? suffix,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 10 : 6, bottom: isLast ? 10 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 18),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262C36) : const Color(0xFFF5F2EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF7A7874),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF7A7874),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: TextField(
                    obscureText: obscure,
                    keyboardType: type,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFFA29F98),
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 10),
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1C1C18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (suffix != null) Padding(padding: const EdgeInsets.only(right: 18), child: suffix),
        ],
      ),
    );
  }
}
