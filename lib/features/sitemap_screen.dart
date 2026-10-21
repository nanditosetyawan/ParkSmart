import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/theme_service.dart';

// Admin - Super Admin
import 'admin/super_admin/admin_dashboard_screen.dart';
import 'admin/super_admin/admin_user_management_screen.dart';
import 'admin/super_admin/admin_app_settings_screen.dart';
import 'admin/super_admin/admin_ai_config_screen.dart';

// Admin - Operations
import 'admin/operations/admin_operations_dashboard_screen.dart';
import 'admin/operations/admin_active_users_screen.dart';

import 'admin/operations/admin_bookings_screen.dart';
import 'admin/operations/manage_parking_screen.dart';
import 'admin/operations/admin_operations_notifications_screen.dart';

// Admin - Finance
import 'admin/finance/admin_finance_dashboard_screen.dart';
import 'admin/finance/admin_pricing_screen.dart';
import 'admin/finance/admin_wallet_screen.dart';
import 'admin/finance/admin_transactions_screen.dart';
import 'admin/finance/revenue_screen.dart';
import 'admin/finance/all_locations_revenue_screen.dart';
import 'admin/finance/admin_finance_notifications_screen.dart';

// Admin - CS & Super Admin KYC
import 'admin/cs/admin_cs_dashboard_screen.dart';
import 'admin/super_admin/admin_kyc_screen.dart';
import 'admin/cs/admin_customer_profiles_screen.dart';
import 'admin/cs/admin_feedback_screen.dart';
import 'admin/cs/admin_notifications_screen.dart';
import 'admin/super_admin/admin_arcade_screen.dart';

// AI Assistant
import 'ai_assistant/ai_assistant_screen.dart';
import 'ai_assistant/ai_results_screen.dart';

// Auth
import 'auth/login_screen.dart';
import 'auth/otp_reset_screen.dart';
import 'auth/register_screen.dart';
import 'auth/forgot_password_screen.dart';

// Booking
import 'booking/booking_confirmation_screen.dart';
import 'booking/slot_selection_screen.dart';

// Camera & Scanner
import 'camera/smart_scanner.dart';
import 'vehicle/custom_camera_screen.dart';
import 'profile/ktp_camera_screen.dart';

// Checkout & Session
import 'checkout/checkout_screen.dart';
import 'session/active_session_screen.dart';
import 'session/checkin_screen.dart';
import 'session/expiring_session_screen.dart';
import 'session/extend_session_screen.dart';
import 'session/session_checkout_screen.dart';

// Favorite
import 'favorite/favorite_screen.dart';

// History
import 'history/history_detail_screen.dart';
import 'history/history_screen.dart';
import 'history/verified_parking_sessions_screen.dart';

// Profile, Settings & PIN
import 'profile/profile_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/pin_settings_screen.dart';
import 'profile/vehicle_screen.dart';
import 'profile/payment_methods_screen.dart';
import 'profile/feedback_screen.dart';
import 'pin/pin_screen.dart';
import 'vehicle/add_vehicle_screen.dart';

// Home & Notification & Parking
import 'home/home_screen.dart';
import 'notification/notification_screen.dart';
import 'parking/parking_detail_screen.dart';
import 'map/explore_map_screen.dart';

// Navigation & Games
import 'navigation/ar_navigation_screen.dart';
import 'game/game_lobby_screen.dart';
import 'game/game_list_screen.dart';
import 'game/car_game_screen.dart';
import 'game/claws_car_screen.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : Colors.white,
          appBar: AppBar(
            backgroundColor: isDark ? theme.bg : Colors.white,
            elevation: 0,
            title: Text(
              'Developer Sitemap',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          body: ListView(
            children: [
              // ─── USER CLIENT SCREENS ───
              _buildCategory('1. Auth & Onboarding', [
                _Item('Login (Masuk)', 'login_screen.dart', (c) => const LoginScreen()),
                _Item('Register (Daftar Akun)', 'register_screen.dart', (c) => const RegisterScreen()),
                _Item('Lupa Sandi (Forgot Password)', 'forgot_password_screen.dart', (c) => const ForgotPasswordScreen(), isNew: true),
                _Item('OTP & Reset Sandi', 'otp_reset_screen.dart', (c) => const OtpResetScreen()),
              ], isDark, theme),
              _buildCategory('2. Main Navigation & Exploration', [
                _Item('Home (Beranda Utama)', 'home_screen.dart', (c) => const HomeScreen()),
                _Item('Favorit Parkir Terverifikasi', 'favorite_screen.dart', (c) => const FavoriteScreen(), isNew: true),
                _Item('Peta Jelajah (Explore Map)', 'explore_map_screen.dart', (c) => const ExploreMapScreen()),
                _Item('Pusat Notifikasi', 'notification_screen.dart', (c) => const NotificationScreen()),
                _Item('Detail Tempat Parkir', 'parking_detail_screen.dart', (c) => const ParkingDetailScreen()),
              ], isDark, theme),
              _buildCategory('3. Booking & Reservasi', [
                _Item('Pilih Slot Parkir (Slot Selection)', 'slot_selection_screen.dart', (c) => const SlotSelectionScreen()),
                _Item('Konfirmasi Booking', 'booking_confirmation_screen.dart', (c) => const BookingConfirmationScreen()),
                _Item('Navigasi AR (AR Wayfinding)', 'ar_navigation_screen.dart', (c) => const ArNavigationScreen()),
                _Item('Checkout & Pembayaran Booking', 'checkout_screen.dart', (c) => const CheckoutScreen()),
              ], isDark, theme),
              _buildCategory('4. Sesi Parkir (Park Session)', [
                _Item('Check-In Masuk Parkir (QR Gate)', 'checkin_screen.dart', (c) => const CheckinScreen()),
                _Item('Sesi Parkir Aktif (Active Session)', 'active_session_screen.dart', (c) => const ActiveSessionScreen()),
                _Item('Peringatan Sesi Segera Berakhir', 'expiring_session_screen.dart', (c) => const ExpiringSessionScreen()),
                _Item('Perpanjangan Durasi Parkir (Extend)', 'extend_session_screen.dart', (c) => const ExtendSessionScreen()),
                _Item('Checkout & Selesai Parkir (Exit)', 'session_checkout_screen.dart', (c) => const SessionCheckoutScreen()),
              ], isDark, theme),
              _buildCategory('5. Riwayat & Transaksi (History)', [
                _Item('Riwayat Parkir Utama', 'history_screen.dart', (c) => const HistoryScreen()),
                _Item('Detail Riwayat Parkir', 'history_detail_screen.dart', (c) => const HistoryDetailScreen()),
                _Item('Sesi Parkir Terverifikasi', 'verified_parking_sessions_screen.dart', (c) => const VerifiedParkingSessionsScreen()),
              ], isDark, theme),
              _buildCategory('6. AI Assistant (ParkSmart AI)', [
                _Item('Asisten Suara & Chat ParkSmart AI', 'ai_assistant_screen.dart', (c) => const AiAssistantScreen()),
                _Item('Hasil Rekomendasi Pintar AI', 'ai_results_screen.dart', (c) => const AiResultsScreen()),
              ], isDark, theme),
              _buildCategory('7. Profil Pengguna & Keamanan', [
                _Item('Profil Pengguna Utama', 'profile_screen.dart', (c) => const ProfileScreen()),
                _Item('Edit Profil Lengkap', 'edit_profile_screen.dart', (c) => const EditProfileScreen(), isNew: true),
                _Item('Pengaturan PIN Transaksi', 'pin_settings_screen.dart', (c) => const PinSettingsScreen(), isNew: true),
                _Item('Verifikasi PIN Layar Penuh', 'pin_screen.dart', (c) => const PinScreen(
                  nextScreen: HomeScreen(),
                  transactionType: 'parkir',
                ), isNew: true),
                _Item('Pengaturan & Preferensi App', 'settings_screen.dart', (c) => const SettingsScreen()),
                _Item('Metode Pembayaran & Saldo', 'payment_methods_screen.dart', (c) => const PaymentMethodsScreen()),
                _Item('Kirim Ulasan & Pengalaman Parkir', 'feedback_screen.dart', (c) => const FeedbackScreen()),
              ], isDark, theme),
              _buildCategory('8. Kendaraan & Kamera Scanner', [
                _Item('Daftar Kendaraan Terdaftar', 'vehicle_screen.dart', (c) => const VehicleScreen()),
                _Item('Tambah Kendaraan Baru', 'add_vehicle_screen.dart', (c) => const AddVehicleScreen()),
                _Item('Kamera Pindai Plat & STNK', 'custom_camera_screen.dart', (c) => const CustomCameraScreen(), isNew: true),
                _Item('Kamera KYC KTP & Selfie Wajah', 'ktp_camera_screen.dart', (c) => const KtpCameraScreen(), isNew: true),
                _Item('Smart Scanner ML Kit (AI Vision / Barcode)', 'smart_scanner.dart', null, onAction: (ctx) {
                  SmartScanner.openCameraAndProcess(ctx);
                }, isNew: true),
              ], isDark, theme),
              _buildCategory('9. Arcade & Mini Games', [
                _Item('Lobi Game (Arcade Hub)', 'game_lobby_screen.dart', (c) => const GameLobbyScreen()),
                _Item('Daftar Mini-Game Terpilih', 'game_list_screen.dart', (c) => const GameListScreen(), isNew: true),
                _Item('Car Game (Parkir 2D Runner)', 'car_game_screen.dart', (c) => const CarGameScreen()),
                _Item('Claws Car (Mesin Capit Hadiah 3D)', 'claws_car_screen.dart', (c) => const ClawsCarScreen(), isNew: true),
              ], isDark, theme),

              // ─── ADMIN HEADER DIVIDER & ROLE GUIDE ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PANEL ADMIN & KLASIFIKASI ROLE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRoleLegendBadge('Super Admin', isDark),
                          const SizedBox(width: 8),
                          _buildRoleLegendBadge('Operations', isDark),
                          const SizedBox(width: 8),
                          _buildRoleLegendBadge('Finance', isDark),
                          const SizedBox(width: 8),
                          _buildRoleLegendBadge('CS', isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined, size: 16, color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Konsep RBAC: Super Admin mengelola tata kelola sistem, verifikasi KTP KYC, manajemen akun admin, dan konfigurasi AI. Admin divisi (Operasional, Finansial, CS) terisolasi pada fungsinya masing-masing.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                height: 1.4,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── ADMIN CLUSTER 1: SISTEM & SUPER ADMIN ───
              _buildCategory('10. Admin: Sistem & Super Admin', [
                _Item('Dashboard Utama Admin', 'super_admin/admin_dashboard_screen.dart', (c) => const DashboardScreen(), role: 'Super Admin'),
                _Item('Verifikasi Dokumen KTP (KYC)', 'super_admin/admin_kyc_screen.dart', (c) => const AdminKycScreen(), role: 'Super Admin'),
                _Item('Manajemen Akun Admin (RBAC)', 'super_admin/admin_user_management_screen.dart', (c) => const AdminUserManagementScreen(), role: 'Super Admin'),
                _Item('Pengaturan Parameter Global App', 'super_admin/admin_app_settings_screen.dart', (c) => const AdminAppSettingsScreen(), role: 'Super Admin'),
                _Item('Konfigurasi Engine & Model AI', 'super_admin/admin_ai_config_screen.dart', (c) => const AdminAiConfigScreen(), role: 'Super Admin'),
                _Item('Pengaturan Poin, Arcade & Hadiah', 'super_admin/admin_arcade_screen.dart', (c) => const ArcadeAdminScreen(), role: 'Super Admin'),
              ], isDark, theme),

              // ─── ADMIN CLUSTER 2: OPERASIONAL & FASILITAS ───
              _buildCategory('11. Admin: Operasional & Fasilitas Parkir', [
                _Item('Dashboard Khusus Operasional', 'operations/admin_operations_dashboard_screen.dart', (c) => const AdminOperationsDashboardScreen(), role: 'Operations', isNew: true),
                _Item('Kelola Titik Parkir, Denah & Tarif', 'operations/manage_parking_screen.dart', (c) => const ManageParkingScreen(), role: 'Operations'),
                _Item('Monitoring Kendaraan Aktif & Overstay', 'operations/admin_active_users_screen.dart', (c) => const ActiveUsersScreen(), role: 'Operations'),
                _Item('Manajemen Data Reservasi & Booking', 'operations/admin_bookings_screen.dart', (c) => const AdminBookingsScreen(), role: 'Operations'),
                _Item('Pusat Notifikasi Operasional', 'operations/admin_operations_notifications_screen.dart', (c) => const AdminOperationsNotificationsScreen(), role: 'Operations'),
              ], isDark, theme),

              // ─── ADMIN CLUSTER 3: FINANSIAL & TRANSAKSI ───
              _buildCategory('12. Admin: Finansial, Billing & Pendapatan', [
                _Item('Dashboard Khusus Finansial', 'finance/admin_finance_dashboard_screen.dart', (c) => const AdminFinanceDashboardScreen(), role: 'Finance', isNew: true),
                _Item('Konfigurasi Tarif & Aturan Waktu', 'finance/admin_pricing_screen.dart', (c) => const PricingScreen(), role: 'Finance'),
                _Item('Injeksi Saldo & Wallet Admin', 'finance/admin_wallet_screen.dart', (c) => const AdminWalletScreen(), role: 'Finance'),
                _Item('Riwayat & Mutasi Transaksi', 'finance/admin_transactions_screen.dart', (c) => const AdminTransactionsScreen(), role: 'Finance'),
                _Item('Laporan Pendapatan & Revenue Analytics', 'finance/revenue_screen.dart', (c) => const RevenueScreen(), role: 'Finance'),
                _Item('Detail Omzet Seluruh Lokasi', 'finance/all_locations_revenue_screen.dart', (c) => const AllLocationsRevenueScreen(), role: 'Finance'),
                _Item('Pusat Notifikasi Finansial', 'finance/admin_finance_notifications_screen.dart', (c) => const AdminFinanceNotificationsScreen(), role: 'Finance'),
              ], isDark, theme),

              // ─── ADMIN CLUSTER 4: LAYANAN PELANGGAN (CS) ───
              _buildCategory('13. Admin: Layanan Pelanggan (Customer Service)', [
                _Item('Dashboard Khusus CS', 'cs/admin_cs_dashboard_screen.dart', (c) => const AdminCsDashboardScreen(), role: 'CS', isNew: true),
                _Item('Profil Customer & Riwayat CRM', 'cs/admin_customer_profiles_screen.dart', (c) => const AdminCustomerProfilesScreen(), role: 'CS'),
                _Item('Review Feedback & Keluhan Pengguna', 'cs/admin_feedback_screen.dart', (c) => const FeedbackAdminScreen(), role: 'CS'),
                _Item('Pusat Notifikasi & Broadcast Masal', 'cs/admin_notifications_screen.dart', (c) => const AdminNotificationsScreen(), role: 'CS'),
              ], isDark, theme),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleLegendBadge(String role, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getRoleBgColor(role, isDark),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getRoleBorderColor(role), width: 1),
      ),
      child: Text(
        role,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getRoleTextColor(role, isDark),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<_Item> items, bool isDark, ThemeService theme) {
    final newCount = items.where((i) => i.isNew).length;

    return ExpansionTile(
      collapsedIconColor: isDark ? const Color(0xFF94A3B8) : Colors.black54,
      iconColor: isDark ? Colors.white : Colors.black,
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (newCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981), width: 1),
              ),
              child: Text(
                '$newCount baru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
        ],
      ),
      children: items.map((i) => Builder(
        builder: (ctx) => ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  i.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1C1C18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (i.role != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleBgColor(i.role!, isDark),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getRoleBorderColor(i.role!), width: 1),
                  ),
                  child: Text(
                    i.role!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getRoleTextColor(i.role!, isDark),
                    ),
                  ),
                ),
              ],
              if (i.isNew) ...[
                const SizedBox(width: 6),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981), width: 1),
                  ),
                  child: Text(
                    '(baru)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: i.fileName,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  if (i.isNew)
                    TextSpan(
                      text: ' (baru)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                ],
              ),
            ),
          ),
          trailing: Icon(
            i.onAction != null ? Icons.camera_alt_outlined : Icons.arrow_forward_ios,
            size: 14,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
          onTap: () {
            if (i.onAction != null) {
              i.onAction!(ctx);
            } else if (i.builder != null) {
              Navigator.push(ctx, MaterialPageRoute(builder: (context) => i.builder!(context)));
            }
          },
        ),
      )).toList(),
    );
  }

  static Color _getRoleBgColor(String role, bool isDark) {
    switch (role) {
      case 'Super Admin':
        return isDark ? const Color(0xFF5B21B6).withValues(alpha: 0.3) : const Color(0xFFEDE9FE);
      case 'Operations':
        return isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFDBEAFE);
      case 'Finance':
        return isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF3C7);
      case 'CS':
      case 'CS & KYC':
        return isDark ? const Color(0xFF134E4A).withValues(alpha: 0.3) : const Color(0xFFCCFBF1);
      default:
        return isDark ? Colors.white10 : const Color(0xFFF1F5F9);
    }
  }

  static Color _getRoleBorderColor(String role) {
    switch (role) {
      case 'Super Admin':
        return const Color(0xFF8B5CF6);
      case 'Operations':
        return const Color(0xFF3B82F6);
      case 'Finance':
        return const Color(0xFFF59E0B);
      case 'CS':
      case 'CS & KYC':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  static Color _getRoleTextColor(String role, bool isDark) {
    switch (role) {
      case 'Super Admin':
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
      case 'Operations':
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
      case 'Finance':
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
      case 'CS':
      case 'CS & KYC':
        return isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E);
      default:
        return isDark ? Colors.white70 : Colors.black87;
    }
  }
}

class _Item {
  final String name;
  final String fileName;
  final Widget Function(BuildContext)? builder;
  final void Function(BuildContext)? onAction;
  final bool isNew;
  final String? role;

  _Item(
    this.name,
    this.fileName,
    this.builder, {
    this.onAction,
    this.isNew = false,
    this.role,
  });
}
