import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = true;
  bool _notifEnabled = true;
  String _cacheSize = '128.4 MB tersimpan';
  bool _isCacheCleared = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF9F2).withValues(alpha: 0.8),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 1))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1C1C18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(Icons.settings, size: 24, color: const Color(0xFF114177)), // Using settings icon instead of logo for simplicity
                          const SizedBox(width: 8),
                          Text('Pengaturan', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Profile Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.06), blurRadius: 32, offset: const Offset(0, 12))],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDpCYtgl-hGVXRQdhh0hHqX3XniI-C7Lxg0yDeOLXcMqOjE46TInnh-OrhgMgEuWTCRGldtvleaFHMYyWaQJ1mquPwZd7Wml55E3cC1V_VeKZ8d3xzBuHnAybOMqARFWoTE_k9nnrnzlSBgmrSJf0f_4mfvGIQfY0UR4vW0oNI3neJvNiqlN6jEnILQFveVtdwSEsvQSXEw1pAGo4CXJcw1vAUCCtRHm53H5N4XDk72XHIaYnPJnTlD'), fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(color: const Color(0xFFBBEED4), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.check, size: 10, color: Color(0xFF1F4F3C)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Arya Raditya', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 16, color: Color(0xFF9A442D)),
                                ],
                              ),
                              Text('arya.raditya@gmail.com', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                                child: Text('Gold Member', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF1C1C18))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 1: Akun & Keamanan
                  _SectionTitle(title: 'Akun & Keamanan', icon: Icons.lock),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Column(
                      children: [
                        _SettingToggleRow(
                          icon: Icons.fingerprint, title: 'Biometrik', subtitle: 'Face ID / Fingerprint login',
                          value: _biometricEnabled,
                          onChanged: (val) => setState(() => _biometricEnabled = val),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                        _SettingActionRow(
                          icon: Icons.pin, title: 'Kunci Transaksi PIN', subtitle: 'Wajib untuk sesi parkir otomatis',
                          actionWidget: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE5E2DB))),
                            child: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1C1C18)),
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 2: Preferensi Aplikasi
                  _SectionTitle(title: 'Preferensi Aplikasi', icon: Icons.tune),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Column(
                      children: [
                        _SettingActionRow(
                          icon: Icons.language, title: 'Bahasa', subtitle: 'Bahasa Indonesia', actionWidget: const Icon(Icons.chevron_right, color: Color(0xFF1C1C18)),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                        _SettingActionRow(
                          icon: Icons.payments, title: 'Mata Uang', subtitle: 'IDR (Rupiah)',
                          actionWidget: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)), child: Text('IDR', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold))),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                        _SettingToggleRow(
                          icon: Icons.notifications_active, title: 'Notifikasi Sesi & Promo', subtitle: 'Pemberitahuan durasi & cashback',
                          value: _notifEnabled,
                          onChanged: (val) => setState(() => _notifEnabled = val),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                        _SettingStatusRow(
                          icon: Icons.palette, title: 'Light Mode', subtitle: '',
                          statusWidget: Text('Default', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 3: Privasi & Data
                  _SectionTitle(title: 'Privasi & Data', icon: Icons.shield),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Column(
                      children: [

                        Row(
                          children: [
                            Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFF6F3EC), shape: BoxShape.circle), child: const Icon(Icons.cleaning_services, size: 20, color: Color(0xFF1C1C18))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hapus Riwayat Cache', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
                                  Text(_cacheSize, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _isCacheCleared ? null : () {
                                setState(() {
                                  _cacheSize = '0 KB tersimpan (Bersih)';
                                  _isCacheCleared = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
                                child: _isCacheCleared 
                                  ? Row(children: [const Icon(Icons.done, size: 14, color: Color(0xFF45474A)), const SizedBox(width: 4), Text('Beres', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A)))])
                                  : Text('Bersihkan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  

                  
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5F8F78), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('ParkSmart v2.4.0 (Build 2026.10)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.token, size: 14, color: Color(0xFF45474A)),
                            const SizedBox(width: 6),
                            Text('Blockchain Verified Network • Jakarta Smart Mobility', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A), letterSpacing: 1.0)),
        Icon(icon, size: 16, color: const Color(0xFF45474A)),
      ],
    );
  }
}

class _SettingToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFF6F3EC), shape: BoxShape.circle), child: Icon(icon, size: 20, color: const Color(0xFF1C1C18))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
              if (subtitle.isNotEmpty) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeThumbColor: Colors.white, activeTrackColor: const Color(0xFF020304)),
      ],
    );
  }
}

class _SettingActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final Widget? actionWidget;

  const _SettingActionRow({required this.icon, required this.title, required this.subtitle, this.actionText, this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFF6F3EC), shape: BoxShape.circle), child: Icon(icon, size: 20, color: const Color(0xFF1C1C18))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
              if (subtitle.isNotEmpty) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
            ],
          ),
        ),
        if (actionText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Text(actionText!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 14, color: Color(0xFF1C1C18)),
              ],
            ),
          )
        else ?actionWidget
      ],
    );
  }
}

class _SettingStatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? statusText;
  final Widget? statusWidget;

  const _SettingStatusRow({required this.icon, required this.title, required this.subtitle, this.statusText, this.statusWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFF6F3EC), shape: BoxShape.circle), child: Icon(icon, size: 20, color: const Color(0xFF1C1C18))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
              if (subtitle.isNotEmpty) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
            ],
          ),
        ),
        if (statusText != null)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFBBEED4), borderRadius: BorderRadius.circular(16)),
                child: Text(statusText!, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1F4F3C))),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF45474A)),
            ],
          )
        else if (statusWidget != null)
          Row(
            children: [
              statusWidget!,
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF45474A)),
            ],
          )
      ],
    );
  }
}
