import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E2DB)),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1C1C18)),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Premium Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF1C1C18), borderRadius: BorderRadius.circular(12)),
                  child: Text('Bergabung Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 16),
                Text('Buat Akun\nBaru Anda.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w800, color: const Color(0xFF1C1C18), height: 1.1, letterSpacing: -1.0)),
                const SizedBox(height: 12),
                Text('Isi data di bawah untuk menikmati kemudahan parkir pintar tanpa hambatan.', 
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, color: const Color(0xFF45474A), height: 1.5)),
                const SizedBox(height: 36),
                
                // Grouped Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E2DB)),
                    boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      _buildField(icon: Icons.person_outline, label: 'Nama Lengkap', hint: 'Sarah Natasha', isFirst: true),
                      const Divider(height: 1, color: Color(0xFFF1EEE7), indent: 52),
                      _buildField(icon: Icons.email_outlined, label: 'Email', hint: 'nama@email.com', type: TextInputType.emailAddress),
                      const Divider(height: 1, color: Color(0xFFF1EEE7), indent: 52),
                      _buildField(icon: Icons.phone_outlined, label: 'No. Handphone', hint: '0812 3456 7890', type: TextInputType.phone),
                      const Divider(height: 1, color: Color(0xFFF1EEE7), indent: 52),
                      _buildField(
                        icon: Icons.lock_outline, label: 'Kata Sandi', hint: 'Min. 8 karakter', 
                        obscure: _obscurePassword, isLast: true,
                        suffix: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: const Color(0xFFA29F98)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 36),
                
                // Action Button
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1C18), elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Buat Akun', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, size: 19, color: Colors.white),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login Link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A)),
                        children: [
                          const TextSpan(text: 'Sudah punya akun? '),
                          TextSpan(
                            text: 'Masuk di sini', 
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), decoration: TextDecoration.underline),
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
  }

  Widget _buildField({required IconData icon, required String label, required String hint, TextInputType? type, bool obscure = false, bool isFirst = false, bool isLast = false, Widget? suffix}) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 8 : 4, bottom: isLast ? 8 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 20),
          Icon(icon, size: 20, color: const Color(0xFF7A7874)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF7A7874), letterSpacing: 0.2)),
                SizedBox(
                  height: 36,
                  child: TextField(
                    obscureText: obscure, keyboardType: type,
                    decoration: InputDecoration(
                      hintText: hint, border: InputBorder.none,
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: const Color(0xFFA29F98)),
                      contentPadding: const EdgeInsets.only(bottom: 12),
                    ),
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18)),
                  ),
                ),
              ],
            ),
          ),
          if (suffix != null) Padding(padding: const EdgeInsets.only(right: 20), child: suffix),
        ],
      ),
    );
  }
}
