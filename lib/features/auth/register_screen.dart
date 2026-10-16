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
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                          _FloatingRegisterField(
                            icon: Icons.person_outline,
                            label: 'Nama Lengkap',
                            controller: _nameController,
                            isFirst: true,
                            isDark: isDark,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                            indent: 70,
                          ),
                          _FloatingRegisterField(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            controller: _emailController,
                            type: TextInputType.emailAddress,
                            isDark: isDark,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                            indent: 70,
                          ),
                          _FloatingRegisterField(
                            icon: Icons.phone_outlined,
                            label: 'No. Handphone',
                            controller: _phoneController,
                            type: TextInputType.phone,
                            isDark: isDark,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                            indent: 70,
                          ),
                          _FloatingRegisterField(
                            icon: Icons.lock_outline,
                            label: 'Kata Sandi',
                            controller: _passwordController,
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
}

class _FloatingRegisterField extends StatefulWidget {
  final IconData icon;
  final String label;
  final TextEditingController? controller;
  final TextInputType? type;
  final bool obscure;
  final bool isFirst;
  final bool isLast;
  final Widget? suffix;
  final bool isDark;

  const _FloatingRegisterField({
    required this.icon,
    required this.label,
    this.controller,
    this.type,
    this.obscure = false,
    this.isFirst = false,
    this.isLast = false,
    this.suffix,
    required this.isDark,
  });

  @override
  State<_FloatingRegisterField> createState() => _FloatingRegisterFieldState();
}

class _FloatingRegisterFieldState extends State<_FloatingRegisterField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _ownsController = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_onTextChange);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _controller.text.isNotEmpty;
    final bool isFloating = _isFocused || hasText;
    final isDark = widget.isDark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.isFirst ? 8 : 4,
          bottom: widget.isLast ? 8 : 4,
        ),
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
                widget.icon,
                size: 20,
                color: _isFocused
                    ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF114177))
                    : (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF7A7874)),
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
                                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF114177))
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF7A7874)),
                            letterSpacing: isFloating ? 0.3 : 0.0,
                          ),
                          child: Text(widget.label),
                        ),
                      ),
                    ),
                    // TextField input
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 22,
                      bottom: 4,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        obscureText: widget.obscure,
                        keyboardType: widget.type,
                        cursorColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF114177),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
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
            if (widget.suffix != null)
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: widget.suffix,
              )
            else
              const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}
