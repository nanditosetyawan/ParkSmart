import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../core/services/theme_service.dart';

class OtpResetScreen extends StatefulWidget {
  const OtpResetScreen({super.key});

  @override
  State<OtpResetScreen> createState() => _OtpResetScreenState();
}

class _OtpResetScreenState extends State<OtpResetScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        final bg = isDark ? theme.bg : const Color(0xFFF6F3EC);
        final cardBg = isDark ? theme.card : Colors.white;
        final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);
        final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A);
        final borderColor = isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(Icons.arrow_back, size: 20, color: textMain),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Icon Header
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: isDark ? Border.all(color: borderColor) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mark_email_read_rounded,
                          size: 36,
                          color: isDark ? const Color(0xFFFB923C) : const Color(0xFF9A442D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Typography
                    Text(
                      'Verifikasi Akun',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textMain,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: textSub,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Kami telah mengirimkan kode 6 digit ke nomor\n'),
                          TextSpan(
                            text: '+62 812 3456 7890',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        bool isFocused = _focusNodes[index].hasFocus;
                        bool hasValue = _controllers[index].text.isNotEmpty;

                        final Color fieldBg = isDark ? const Color(0xFF1E232B) : Colors.white;
                        final Color fieldBorder = isFocused
                            ? (isDark ? Colors.white : const Color(0xFF1C1C18))
                            : (hasValue
                                ? (isDark ? Colors.white70 : const Color(0xFF1C1C18).withValues(alpha: 0.3))
                                : borderColor);

                        return Container(
                          width: 50,
                          height: 64,
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: fieldBorder,
                              width: isFocused ? 2 : 1,
                            ),
                            boxShadow: isFocused
                                ? [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : const Color(0xFF1C1C18).withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              cursorColor: textMain,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              onChanged: (val) => _onChanged(val, index),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Resend Timer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E232B) : const Color(0xFFE5E2DB).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: isDark ? Border.all(color: borderColor) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: textSub),
                          const SizedBox(width: 8),
                          Text(
                            'Kirim ulang dalam 00:45',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSub,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: Text(
                          'Verifikasi Kode',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
