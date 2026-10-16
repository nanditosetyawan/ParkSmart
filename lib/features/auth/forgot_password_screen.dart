import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import 'otp_reset_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _selectedMethod = 0; // 0 = Email, 1 = No. Handphone
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendReset() async {
    final String target = _selectedMethod == 0 ? _emailController.text.trim() : _phoneController.text.trim();

    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedMethod == 0
                ? 'Harap masukkan alamat email Anda'
                : 'Harap masukkan nomor handphone Anda',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: const Color(0xFFD94B4B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigasi ke halaman OTP Verifikasi dengan destinasi yang sesuai
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpResetScreen(
          destination: target,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        // Token warna sesuai md/DESIGN.md
        final Color bg = isDark ? const Color(0xFF111418) : const Color(0xFFF9F9F9);
        final Color cardBg = isDark ? const Color(0xFF181C22) : Colors.white;
        final Color textMain = isDark ? Colors.white : const Color(0xFF14202B);
        final Color textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color borderColor = isDark ? const Color(0xFF28303C) : const Color(0xFFD8DEE5);
        final Color primaryBrand = isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177);
        final Color activeAccent = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF114177);

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
                            'Pemulihan Keamanan Akun',
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
                      'Jangan khawatir, masukkan kontak akun Anda untuk menerima instruksi kode verifikasi pemulihan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: textSub,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Pilihan Tab Segmented (Email vs SMS/WhatsApp)
                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E232B) : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedMethod = 0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: _selectedMethod == 0
                                      ? (isDark ? const Color(0xFF114177) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: _selectedMethod == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 17,
                                        color: _selectedMethod == 0
                                            ? Colors.white
                                            : textSub,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Via Email',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: _selectedMethod == 0 ? FontWeight.bold : FontWeight.w500,
                                          color: _selectedMethod == 0
                                              ? (isDark ? Colors.white : const Color(0xFF14202B))
                                              : textSub,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedMethod = 1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: _selectedMethod == 1
                                      ? (isDark ? const Color(0xFF114177) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: _selectedMethod == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone_iphone_rounded,
                                        size: 17,
                                        color: _selectedMethod == 1
                                            ? Colors.white
                                            : textSub,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Via No. Ponsel',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: _selectedMethod == 1 ? FontWeight.bold : FontWeight.w500,
                                          color: _selectedMethod == 1
                                              ? (isDark ? Colors.white : const Color(0xFF14202B))
                                              : textSub,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Input Field Tunggal dengan Floating Label
                    Container(
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
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _selectedMethod == 0
                            ? _FloatingInputRow(
                                key: const ValueKey('email_field'),
                                icon: Icons.alternate_email,
                                label: 'Alamat Email Terdaftar',
                                controller: _emailController,
                                type: TextInputType.emailAddress,
                                isDark: isDark,
                                activeAccent: activeAccent,
                                textMain: textMain,
                                textSub: textSub,
                              )
                            : _FloatingInputRow(
                                key: const ValueKey('phone_field'),
                                icon: Icons.phone_outlined,
                                label: 'Nomor Handphone (+62)',
                                controller: _phoneController,
                                type: TextInputType.phone,
                                isDark: isDark,
                                activeAccent: activeAccent,
                                textMain: textMain,
                                textSub: textSub,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info Keamanan Tambahan
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
                            Icons.info_outline_rounded,
                            size: 18,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF006A9A),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedMethod == 0
                                  ? 'Kode verifikasi 6-digit akan dikirimkan ke kotak masuk (inbox) atau folder spam email Anda.'
                                  : 'Kode verifikasi 6-digit akan dikirimkan via SMS resmi ParkSmart ID ke nomor yang terdaftar.',
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

                    // Action Button (Kirim Kode Verifikasi)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendReset,
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
                                  Text(
                                    'Kirim Kode Verifikasi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.black : Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 19,
                                    color: isDark ? Colors.black : Colors.white,
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

class _FloatingInputRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? type;
  final bool isDark;
  final Color activeAccent;
  final Color textMain;
  final Color textSub;

  const _FloatingInputRow({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.type,
    required this.isDark,
    required this.activeAccent,
    required this.textMain,
    required this.textSub,
  });

  @override
  State<_FloatingInputRow> createState() => _FloatingInputRowState();
}

class _FloatingInputRowState extends State<_FloatingInputRow> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;
    final bool isFloating = _isFocused || hasText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 18),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF262C36) : const Color(0xFFF5F2EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                size: 20,
                color: _isFocused
                    ? widget.activeAccent
                    : (widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF7A7874)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    // Animated Floating Label
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      left: 0,
                      top: isFloating ? 7 : 18,
                      child: IgnorePointer(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isFloating ? 11.5 : 15.0,
                            fontWeight: isFloating ? FontWeight.w700 : FontWeight.w500,
                            color: _isFocused
                                ? widget.activeAccent
                                : widget.textSub,
                            letterSpacing: isFloating ? 0.3 : 0.0,
                          ),
                          child: Text(widget.label),
                        ),
                      ),
                    ),
                    // TextField Input
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 22,
                      bottom: 4,
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        keyboardType: widget.type,
                        cursorColor: widget.activeAccent,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.textMain,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}
