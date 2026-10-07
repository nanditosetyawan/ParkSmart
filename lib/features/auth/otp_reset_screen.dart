import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EC),
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
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE5E2DB))),
                        child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1C1C18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Icon Header
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: const Center(child: Icon(Icons.mark_email_read_rounded, size: 36, color: Color(0xFF9A442D))),
                  ),
                  const SizedBox(height: 32),
                  
                  // Typography
                  Text('Verifikasi Akun', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1C1C18), letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, color: const Color(0xFF45474A), height: 1.5),
                      children: const [
                        TextSpan(text: 'Kami telah mengirimkan kode 6 digit ke nomor\n'),
                        TextSpan(text: '+62 812 3456 7890', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C1C18))),
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
                      
                      return Container(
                        width: 50, height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isFocused ? const Color(0xFF1C1C18) : (hasValue ? const Color(0xFF1C1C18).withValues(alpha: 0.3) : const Color(0xFFE5E2DB)), width: isFocused ? 2 : 1),
                          boxShadow: isFocused ? [BoxShadow(color: const Color(0xFF1C1C18).withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))] : [],
                        ),
                        child: Center(
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18)),
                            decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
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
                    decoration: BoxDecoration(color: const Color(0xFFE5E2DB).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF45474A)),
                        const SizedBox(width: 8),
                        Text('Kirim ulang dalam 00:45', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C1C18), elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text('Verifikasi Kode', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
