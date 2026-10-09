import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pin/pin_screen.dart';

class PinSettingsScreen extends StatelessWidget {
  const PinSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C18)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pengaturan PIN', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1A1A18), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(
              children: [
                _PinActionRow(
                  icon: Icons.pin_invoke, 
                  title: 'Buat PIN',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PinScreen(
                      nextScreen: const PinSettingsScreen(), 
                      transactionType: 'buat pin',
                      customTitle: 'Buat PIN',
                      backToHome: false,
                    )));
                  },
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                _PinActionRow(
                  icon: Icons.edit_attributes, 
                  title: 'Ganti PIN',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PinScreen(
                      nextScreen: const PinSettingsScreen(), 
                      transactionType: 'ganti pin',
                      customTitle: 'Ganti PIN',
                      backToHome: false,
                    )));
                  },
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                _PinActionRow(
                  icon: Icons.lock_reset, 
                  title: 'Reset PIN',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PinScreen(
                      nextScreen: const PinSettingsScreen(), 
                      transactionType: 'reset pin',
                      customTitle: 'Reset PIN',
                      backToHome: false,
                    )));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PinActionRow({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF5F1E8), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: const Color(0xFF1A1A18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE5E2DB))),
            child: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF1A1A18)),
          ),
        ],
      ),
    );
  }
}
