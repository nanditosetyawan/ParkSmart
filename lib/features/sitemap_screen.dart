import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Admin
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_locations_screen.dart';
import 'admin/admin_slot_management_screen.dart';
import 'admin/admin_active_users_screen.dart';
import 'admin/admin_feedback_screen.dart';
import 'admin/admin_arcade_screen.dart';
import 'admin/admin_pricing_screen.dart';

// AI Assistant
import 'ai_assistant/ai_assistant_screen.dart';
import 'ai_assistant/ai_results_screen.dart';

// Auth
// import 'auth/register_screen.dart';

// Booking
// import 'booking/reservation_calendar_screen.dart';
// import 'booking/slot_selection_screen.dart';

// Checkout & Session
import 'session/active_session_screen.dart';
import 'session/checkin_screen.dart';
import 'session/expiring_session_screen.dart';
import 'session/extend_session_screen.dart';
import 'session/session_checkout_screen.dart';

// History
import 'history/history_detail_screen.dart';
import 'history/history_screen.dart';
import 'history/verified_parking_sessions_screen.dart';

// Profile & Vehicle
import 'profile/feedback_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/vehicle_screen.dart';
import 'vehicle/add_vehicle_screen.dart';

// Nav & Game
import 'navigation/ar_navigation_screen.dart';
import 'game/game_lobby_screen.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Sitemap')),
      body: ListView(
        children: [
          _buildCategory('Admin / MCP Screens', [
            _Item('AD-01 Dashboard', (c) => const DashboardScreen()),
            _Item('AD-02 Locations', (c) => const LocationsScreen()),
            _Item('AD-03 Slot Management', (c) => const SlotManagementScreen()),
            _Item('AD-05 Active Users', (c) => const ActiveUsersScreen()),
            _Item('AD-06 Arcade & Reward (AD-08)', (c) => const ArcadeAdminScreen()),
            _Item('AD-07 Feedback', (c) => const FeedbackAdminScreen()),
            _Item('AD-xx Konfigurasi Tarif', (c) => const PricingScreen()),
          ]),
          _buildCategory('Session & Checkout (Screenshot 1)', [
            _Item('Sesi Berakhir Segera', (c) => const ExpiringSessionScreen()),
            _Item('Selesai Parkir (Checkout)', (c) => const SessionCheckoutScreen()),
            _Item('Active Session', (c) => const ActiveSessionScreen()),
            _Item('Extend Session', (c) => const ExtendSessionScreen()),
            _Item('Check-In', (c) => const CheckinScreen()),
          ]),
          _buildCategory('AI & Details (Screenshot 2)', [
            _Item('Asisten ParkSmart AI', (c) => const AiAssistantScreen()),
            _Item('Hasil Rekomendasi AI', (c) => const AiResultsScreen()),
          ]),
          _buildCategory('Profile & Settings (Screenshot 3)', [
            _Item('Profil Pengguna', (c) => const ProfileScreen()),
            _Item('Kendaraan Terdaftar', (c) => const VehicleScreen()),
            _Item('Tambah Kendaraan', (c) => const AddVehicleScreen()),
            _Item('Preferensi Aplikasi', (c) => const SettingsScreen()),
            _Item('Bagaimana Pengalaman Parkir', (c) => const FeedbackScreen()),
          ]),
          _buildCategory('History', [
            _Item('Riwayat Parkir Utama', (c) => const HistoryScreen()),
            _Item('Detail Riwayat', (c) => const HistoryDetailScreen()),
            _Item('Sesi Terverifikasi (PS-17b)', (c) => const VerifiedParkingSessionsScreen()),
          ]),
          _buildCategory('Games & AR', [
            _Item('AR Navigation', (c) => const ArNavigationScreen()),
            _Item('Game Lobby', (c) => const GameLobbyScreen()),
            // _Item('PS20 Mini Game', (c) => const Ps20MiniGameScreen()), // Needs implementation maybe
          ]),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<_Item> items) {
    return ExpansionTile(
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      children: items.map((i) => Builder(
        builder: (ctx) => ListTile(
          title: Text(i.name),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.push(ctx, MaterialPageRoute(builder: (context) => i.builder(context)));
          },
        ),
      )).toList(),
    );
  }
}

class _Item {
  final String name;
  final Widget Function(BuildContext) builder;
  _Item(this.name, this.builder);
}
