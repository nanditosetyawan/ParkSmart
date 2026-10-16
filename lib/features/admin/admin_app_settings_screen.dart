import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sitemap_screen.dart';

class AdminAppSettingsScreen extends StatefulWidget {
  const AdminAppSettingsScreen({super.key});

  @override
  State<AdminAppSettingsScreen> createState() => _AdminAppSettingsScreenState();
}

class _AdminAppSettingsScreenState extends State<AdminAppSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Currency Settings
  String _baseCurrency = 'IDR';
  final List<Map<String, String>> _currencies = [
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp', 'rate': '1.0'},
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$', 'rate': '0.000063'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'rate': '0.000058'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£', 'rate': '0.000050'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$', 'rate': '0.000085'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'symbol': 'RM', 'rate': '0.00028'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥', 'rate': '0.0095'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥', 'rate': '0.00045'},
  ];
  final Map<String, TextEditingController> _rateControllers = {};
  bool _autoUpdateRates = true;
  int _rateUpdateIntervalHours = 24;

  // Timezone Settings
  String _defaultTimezone = 'WIB';
  final List<Map<String, String>> _timezones = [
    {'id': 'WIB', 'name': 'Western Indonesia Time (WIB)', 'offset': 'UTC+7', 'cities': 'Jakarta, Bandung, Surabaya, Medan'},
    {'id': 'WITA', 'name': 'Central Indonesia Time (WITA)', 'offset': 'UTC+8', 'cities': 'Makassar, Balikpapan, Manado'},
    {'id': 'WIT', 'name': 'Eastern Indonesia Time (WIT)', 'offset': 'UTC+9', 'cities': 'Jayapura, Ambon, Sorong'},
    {'id': 'UTC', 'name': 'Coordinated Universal Time (UTC)', 'offset': 'UTC+0', 'cities': 'London, Reykjavik'},
    {'id': 'SGT', 'name': 'Singapore Time (SGT)', 'offset': 'UTC+8', 'cities': 'Singapore, Kuala Lumpur'},
  ];
  bool _useDeviceTimezone = false;
  bool _showTimezoneInApp = true;

  // Global Toggles
  final Map<String, bool> _globalToggles = {
    'maintenance_mode': false,
    'enable_booking': true,
    'enable_ai_assistant': true,
    'enable_game_arcade': true,
    'enable_kyc_verification': true,
    'enable_push_notifications': true,
    'enable_email_notifications': false,
    'enable_sms_notifications': false,
    'enable_blockchain_logging': true,
    'enable_analytics_tracking': true,
    'enable_crash_reporting': true,
    'require_vehicle_registration': true,
    'allow_guest_checkout': false,
    'enable_multi_language': true,
    'enable_dark_mode': true,
    'enforce_biometric_auth': false,
    'enable_offline_mode': true,
    'auto_extend_session': false,
    'show_occupancy_realtime': true,
    'enable_loyalty_program': true,
  };

  // Pricing Defaults
  final Map<String, TextEditingController> _pricingControllers = {
    'base_hourly_rate': TextEditingController(text: '5000'),
    'motorcycle_discount_pct': TextEditingController(text: '30'),
    'ev_surcharge_pct': TextEditingController(text: '15'),
    'vip_surcharge_pct': TextEditingController(text: '50'),
    'overstay_multiplier': TextEditingController(text: '2.0'),
    'grace_period_minutes': TextEditingController(text: '15'),
    'min_booking_hours': TextEditingController(text: '1'),
    'max_booking_hours': TextEditingController(text: '24'),
    'cancellation_window_hours': TextEditingController(text: '2'),
    'refund_percentage': TextEditingController(text: '80'),
  };

  // Notification Templates
  final Map<String, TextEditingController> _notificationTemplates = {
    'booking_confirmed': TextEditingController(text: 'Booking Anda dikonfirmasi di {location}. Slot: {slot}. Waktu: {start_time}'),
    'booking_reminder': TextEditingController(text: 'Pengingat: Booking Anda di {location} dimulai dalam 30 menit. Slot: {slot}'),
    'checkin_success': TextEditingController(text: 'Check-in berhasil di {location}. Slot: {slot}. Waktu: {time}'),
    'session_expiring': TextEditingController(text: 'Sesi parkir Anda di {location} akan berakhir dalam 15 menit. Perpanjang sekarang?'),
    'session_ended': TextEditingController(text: 'Sesi parkir selesai. Total biaya: {amount}. Terima kasih telah menggunakan ParkSmart!'),
    'payment_success': TextEditingController(text: 'Pembayaran Rp {amount} berhasil. Invoice: {invoice_id}'),
    'kyc_approved': TextEditingController(text: 'Verifikasi KTP Anda telah DISETUJUI. Selamat datang di ParkSmart!'),
    'kyc_rejected': TextEditingController(text: 'Verifikasi KTP Anda DITOLAK. Alasan: {reason}. Silakan unggah ulang.'),
    'promo_available': TextEditingController(text: 'Promo baru: {promo_name}. Diskon {discount}% untuk parkir di {location}. Kode: {code}'),
    'system_maintenance': TextEditingController(text: 'ParkSmart akan melakukan maintenance pada {date} {time}. Layanan mungkin terganggu.'),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    for (var c in _currencies) {
      _rateControllers[c['code']!] = TextEditingController(text: c['rate']);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var ctrl in _rateControllers.values) {
      ctrl.dispose();
    }
    for (var ctrl in _pricingControllers.values) {
      ctrl.dispose();
    }
    for (var ctrl in _notificationTemplates.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Widget _buildSectionTitle(String title, {String? subtitle, VoidCallback? onAction, String? actionLabel}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              if (subtitle != null) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          if (onAction != null && actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 16),
              label: Text(actionLabel, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF114177)),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: child,
    );
  }

  Widget _buildCurrencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Mata Uang Dasar', subtitle: 'Mata uang referensi untuk semua perhitungan internal'),
          _buildCard(
            child: DropdownButtonFormField<String>(
              initialValue: _baseCurrency,
              decoration: InputDecoration(
                labelText: 'Base Currency',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF114177)),
              ),
              items: _currencies.map((c) => DropdownMenuItem(
                value: c['code'],
                child: Text('${c['symbol']} ${c['code']} — ${c['name']}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
              )).toList(),
              onChanged: (v) => setState(() => _baseCurrency = v ?? 'IDR'),
            ),
          ),
          _buildSectionTitle('Kurs Tukar (Relative to Base)', subtitle: 'Rate 1 unit base currency = X unit target currency'),
          _buildCard(
            child: Column(
              children: _currencies.where((c) => c['code'] != _baseCurrency).map((c) => _buildCurrencyRow(c)).toList(),
            ),
          ),
          _buildSectionTitle('Pengaturan Otomatis'),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Auto-update Exchange Rates', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Ambil kurs dari API eksternal secara berkala', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _autoUpdateRates,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _autoUpdateRates = v),
                ),
                const SizedBox(height: 12),
                _buildSliderRow(
                  label: 'Update Interval: $_rateUpdateIntervalHours jam',
                  value: _rateUpdateIntervalHours.toDouble(),
                  min: 1,
                  max: 168,
                  divisions: 167,
                  onChanged: (v) => setState(() => _rateUpdateIntervalHours = v.round()),
                  icon: Icons.schedule,
                  color: const Color(0xFF114177),
                  enabled: _autoUpdateRates,
                ),
                const SizedBox(height: 8),
                if (_autoUpdateRates)
                  Text('Sumber: exchangerate-api.com (free tier: 1,500 req/bulan)', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
              ],
            ),
          ),
          _buildSectionTitle('Format Tampilan'),
          _buildCard(
            child: Column(
              children: [
                _buildDropdownSetting(
                  label: 'Posisi Simbol',
                  value: 'prefix',
                  items: ['prefix', 'suffix'],
                  itemLabels: {'prefix': 'Depan (Rp 50.000)', 'suffix': 'Belakang (50.000 Rp)'},
                  onChanged: (v) {},
                ),
                const SizedBox(height: 12),
                _buildDropdownSetting(
                  label: 'Desimal',
                  value: '0',
                  items: ['0', '2'],
                  itemLabels: {'0': 'Tanpa desimal (Rp 50.000)', '2': '2 desimal (Rp 50.000,00)'},
                  onChanged: (v) {},
                ),
                const SizedBox(height: 12),
                _buildDropdownSetting(
                  label: 'Pemisah Ribuan',
                  value: '.',
                  items: ['.', ',', ' '],
                  itemLabels: {'.': 'Titik (50.000)', ',': 'Koma (50,000)', ' ': 'Spasi (50 000)'},
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(Map<String, String> currency) {
    final ctrl = _rateControllers[currency['code']!]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(currency['symbol']!, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF114177))))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currency['code']!, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                Text(currency['name']!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180, minWidth: 100),
              child: TextField(
                controller: ctrl,
                style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFF1A1A18)),
                decoration: InputDecoration(
                  labelText: 'Rate',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Zona Waktu Default', subtitle: 'Zona waktu yang digunakan untuk semua jadwal, notifikasi, dan logging'),
          _buildCard(
            child: DropdownButtonFormField<String>(
              initialValue: _defaultTimezone,
              decoration: InputDecoration(
                labelText: 'Default Timezone',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.access_time, color: Color(0xFF114177)),
              ),
              items: _timezones.map((tz) => DropdownMenuItem(
                value: tz['id'],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tz['id']!, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${tz['offset']} — ${tz['cities']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  ],
                ),
              )).toList(),
              onChanged: (v) => setState(() => _defaultTimezone = v ?? 'WIB'),
            ),
          ),
          _buildSectionTitle('Opsi Zona Waktu'),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Gunakan Zona Waktu Perangkat', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Override default dengan zona waktu HP user', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _useDeviceTimezone,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _useDeviceTimezone = v),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Tampilkan Zona Waktu di App', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Tampilkan indikator WIB/WITA/WIT di header/jadwal', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _showTimezoneInApp,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _showTimezoneInApp = v),
                ),
              ],
            ),
          ),
          _buildSectionTitle('Daftar Zona Waktu Tersedia'),
          _buildCard(
            child: Column(
              children: _timezones.map((tz) => _buildTimezoneRow(tz)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneRow(Map<String, String> tz) {
    final isDefault = tz['id'] == _defaultTimezone;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDefault ? const Color(0xFFE8F5E9) : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDefault ? const Color(0xFF17A18A).withValues(alpha: 0.3) : const Color(0xFFE4DFD5)),
      ),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: isDefault ? const Color(0xFF17A18A) : const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(tz['id']!, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: isDefault ? Colors.white : const Color(0xFF114177))))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(tz['name']!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)), overflow: TextOverflow.ellipsis)),
                  if (isDefault) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: const Color(0xFF17A18A), borderRadius: BorderRadius.circular(3)), child: Text('DEFAULT', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)))],
                ]),
                Text(tz['cities']!, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Flexible(child: Text(tz['offset']!, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildGlobalTogglesTab() {
    final categories = {
      'Fitur Utama': ['enable_booking', 'enable_ai_assistant', 'enable_game_arcade', 'enable_kyc_verification'],
      'Notifikasi': ['enable_push_notifications', 'enable_email_notifications', 'enable_sms_notifications'],
      'Sistem & Keamanan': ['enable_blockchain_logging', 'enable_analytics_tracking', 'enable_crash_reporting', 'enforce_biometric_auth', 'maintenance_mode'],
      'Booking & Checkout': ['require_vehicle_registration', 'allow_guest_checkout', 'auto_extend_session', 'show_occupancy_realtime'],
      'Lainnya': ['enable_multi_language', 'enable_dark_mode', 'enable_offline_mode', 'enable_loyalty_program'],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.entries.map((entry) => _buildToggleCategory(entry.key, entry.value)).toList(),
      ),
    );
  }

  Widget _buildToggleCategory(String category, List<String> keys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(category),
        _buildCard(
          child: Column(
            children: keys.map((key) => _buildToggleRow(key)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String key) {
    final labels = {
      'maintenance_mode': ('Mode Maintenance', 'Nonaktifkan semua fitur booking untuk maintenance', Icons.construction, const Color(0xFFD94B4B)),
      'enable_booking': ('Aktifkan Booking', 'Izinkan user membuat booking parkir', Icons.event_available, const Color(0xFF17A18A)),
      'enable_ai_assistant': ('Aktifkan AI Assistant', 'Fitur chat AI untuk pencarian parkir', Icons.smart_toy, const Color(0xFF9B59B6)),
      'enable_game_arcade': ('Aktifkan Arcade Game', 'Mini-game parkir sensor-based', Icons.videogame_asset, const Color(0xFFE07A5F)),
      'enable_kyc_verification': ('Aktifkan Verifikasi KYC', 'Wajib verifikasi KTP sebelum booking', Icons.verified_user, const Color(0xFF114177)),
      'enable_push_notifications': ('Push Notifications', 'Kirim notifikasi via FCM/APNs', Icons.notifications_active, const Color(0xFF45474A)),
      'enable_email_notifications': ('Email Notifications', 'Kirim notifikasi via email', Icons.email, const Color(0xFF76777B)),
      'enable_sms_notifications': ('SMS Notifications', 'Kirim notifikasi via SMS (biaya berlaku)', Icons.sms, const Color(0xFF76777B)),
      'enable_blockchain_logging': ('Blockchain Logging', 'Catat transaksi ke SHA-256 chain', Icons.link, const Color(0xFF114177)),
      'enable_analytics_tracking': ('Analytics Tracking', 'Kumpulkan data penggunaan anonim', Icons.analytics, const Color(0xFF45474A)),
      'enable_crash_reporting': ('Crash Reporting', 'Kirim laporan crash otomatis', Icons.bug_report, const Color(0xFFD94B4B)),
      'require_vehicle_registration': ('Wajib Daftar Kendaraan', 'User harus daftar kendaraan sebelum booking', Icons.directions_car, const Color(0xFF114177)),
      'allow_guest_checkout': ('Izinkan Guest Checkout', 'Booking tanpa login (terbatas)', Icons.person_outline, const Color(0xFFE07A5F)),
      'enable_multi_language': ('Multi Bahasa', 'Dukungan ID/EN (tambah bahasa lain)', Icons.language, const Color(0xFF9B59B6)),
      'enable_dark_mode': ('Dark Mode', 'Izinkan user pilih tema gelap', Icons.dark_mode, const Color(0xFF45474A)),
      'enable_offline_mode': ('Mode Offline', 'Cache data untuk akses offline', Icons.cloud_off, const Color(0xFF76777B)),
      'auto_extend_session': ('Auto Extend Session', 'Perpanjang otomatis saat akan habis', Icons.timer, const Color(0xFF17A18A)),
      'show_occupancy_realtime': ('Tampilkan Occupancy Real-time', 'Tampilkan slot tersedia live di map', Icons.remove_red_eye, const Color(0xFF114177)),
      'enable_loyalty_program': ('Program Loyalitas', 'Poin reward untuk user aktif', Icons.card_giftcard, const Color(0xFFE07A5F)),
      'enforce_biometric_auth': ('Wajib Biometric Auth', 'Paksa fingerprint/faceID untuk aksi sensitif', Icons.fingerprint, const Color(0xFFD94B4B)),
    };

    final (title, desc, icon, color) = labels[key] ?? (key, '', Icons.toggle_on, const Color(0xFF76777B));
    final value = _globalToggles[key] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            onChanged: (v) => setState(() => _globalToggles[key] = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tarif Dasar Parkir', subtitle: 'Konfigurasi harga default untuk semua lokasi (bisa di-override per lokasi)'),
          _buildCard(
            child: Column(
              children: [
                _buildPricingRow('Tarif Dasar per Jam', 'base_hourly_rate', 'Rp', Icons.attach_money, const Color(0xFF114177)),
                _buildPricingRow('Diskon Motor (%)', 'motorcycle_discount_pct', '%', Icons.two_wheeler, const Color(0xFF17A18A)),
                _buildPricingRow('Tambahan EV Charger (%)', 'ev_surcharge_pct', '%', Icons.ev_station, const Color(0xFFE07A5F)),
                _buildPricingRow('Tambahan VIP Slot (%)', 'vip_surcharge_pct', '%', Icons.star, const Color(0xFF9B59B6)),
              ],
            ),
          ),
          _buildSectionTitle('Aturan Booking'),
          _buildCard(
            child: Column(
              children: [
                _buildPricingRow('Min Booking (jam)', 'min_booking_hours', 'jam', Icons.timer, const Color(0xFF45474A)),
                _buildPricingRow('Max Booking (jam)', 'max_booking_hours', 'jam', Icons.timer_off, const Color(0xFF45474A)),
                _buildPricingRow('Jendela Batalkan (jam)', 'cancellation_window_hours', 'jam', Icons.cancel, const Color(0xFFD94B4B)),
                _buildPricingRow('Persentase Refund (%)', 'refund_percentage', '%', Icons.money_off, const Color(0xFF17A18A)),
              ],
            ),
          ),
          _buildSectionTitle('Aturan Overstay & Grace Period'),
          _buildCard(
            child: Column(
              children: [
                _buildPricingRow('Multiplier Overstay (x)', 'overstay_multiplier', 'x', Icons.warning_amber, const Color(0xFFD94B4B)),
                _buildPricingRow('Grace Period (menit)', 'grace_period_minutes', 'menit', Icons.schedule, const Color(0xFF114177)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String key, String suffix, IconData icon, Color color) {
    final ctrl = _pricingControllers[key]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180, minWidth: 100),
              child: TextField(
                controller: ctrl,
                style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                decoration: InputDecoration(
                  labelText: suffix,
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                  suffixText: suffix,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Template Notifikasi', subtitle: 'Variabel: {location}, {slot}, {start_time}, {time}, {amount}, {invoice_id}, {promo_name}, {discount}, {code}, {reason}, {date}'),
          _buildCard(
            child: Column(
              children: _notificationTemplates.entries.map((e) => _buildNotificationTemplateRow(e.key, e.value)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTemplateRow(String key, TextEditingController ctrl) {
    final labels = {
      'booking_confirmed': 'Booking Dikonfirmasi',
      'booking_reminder': 'Pengingat Booking (30 menit)',
      'checkin_success': 'Check-in Berhasil',
      'session_expiring': 'Sesi Akan Berakhir (15 menit)',
      'session_ended': 'Sesi Selesai + Tagihan',
      'payment_success': 'Pembayaran Berhasil',
      'kyc_approved': 'KYC Disetujui',
      'kyc_rejected': 'KYC Ditolak',
      'promo_available': 'Promo Baru Tersedia',
      'system_maintenance': 'Maintenance Sistem',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labels[key] ?? key, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            child: TextField(
              controller: ctrl,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF1A1A18)),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Template pesan...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                contentPadding: const EdgeInsets.all(12),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
    required Color color,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Icon(icon, size: 18, color: enabled ? color : color.withValues(alpha: 0.4)), const SizedBox(width: 8), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: enabled ? const Color(0xFF1A1A18) : const Color(0xFF76777B)))]),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: enabled ? onChanged : null,
          activeColor: color,
          inactiveColor: color.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildDropdownSetting({
    required String label,
    required String value,
    required List<String> items,
    required Map<String, String> itemLabels,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)))),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isDense: true,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(itemLabels[i]!, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
            onChanged: (v) => onChanged(v ?? value),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengaturan Aplikasi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Global Config • Currency • Timezone', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Dev Sitemap',
            icon: const Icon(Icons.developer_board, size: 20, color: Color(0xFF1A1A18)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
          ),
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan disimpan ke Supabase app_settings'), backgroundColor: Color(0xFF17A18A))),
            icon: const Icon(Icons.save, size: 18, color: Color(0xFF17A18A)),
            label: Text('Simpan Semua', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Color(0xFF17A18A))),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF114177),
          unselectedLabelColor: const Color(0xFF76777B),
          indicatorColor: const Color(0xFF114177),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Mata Uang'),
            Tab(text: 'Zona Waktu'),
            Tab(text: 'Fitur Global'),
            Tab(text: 'Harga Default'),
            Tab(text: 'Notifikasi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrencyTab(),
          _buildTimezoneTab(),
          _buildGlobalTogglesTab(),
          _buildPricingTab(),
          _buildNotificationsTab(),
        ],
      ),
    ));
  }
}