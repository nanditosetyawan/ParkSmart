import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/history/history_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/ai_assistant/ai_assistant_screen.dart';
import '../features/camera/smart_scanner.dart';
import '../core/services/maintenance_service.dart';
import '../core/services/language_service.dart';

enum DockTab { home, history, ai, profile }

class BottomDockNavigation extends StatelessWidget {
  final DockTab activeTab;
  
  const BottomDockNavigation({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        // ─── [USER] WARNA LATAR BILAH DOCK NAVIGASI BAWAH ───
        color: const Color(0xFF1C1D1F), // <-- Ubah warna Latar Belakang Dock Navigasi Melayang (Hitam Charcoal)
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1D1F).withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIcon(context, Icons.home, DockTab.home, () {
            if (activeTab != DockTab.home) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
            }
          }),
          _buildIcon(context, Icons.receipt_long_outlined, DockTab.history, () {
            if (activeTab != DockTab.history) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            }
          }),
          // Center: Scan/focus rounded-2xl
          GestureDetector(
            onTap: () => SmartScanner.openCameraAndProcess(context),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.filter_center_focus, size: 24, color: Colors.white),
            ),
          ),
          _buildIcon(context, Icons.auto_awesome_outlined, DockTab.ai, () {
            if (MaintenanceService.instance.isAiMaintenance) {
              MaintenanceService.showModularMaintenanceDialog(
                context,
                title: 'Engine AI Assistant Sedang Maintenance'.tr,
                message:
                    'Fitur asisten pencarian cerdas ParkSmart sementara ditutup untuk pembaruan model. Anda tetap dapat melakukan reservasi dan jelajah peta secara normal.'.tr,
                icon: Icons.smart_toy_outlined,
              );
              return;
            }
            if (activeTab != DockTab.ai) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
            }
          }),
          _buildIcon(context, Icons.person_outline, DockTab.profile, () {
            if (activeTab != DockTab.profile) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }
          }),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, DockTab tab, VoidCallback onTap) {
    final isActive = activeTab == tab;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          // ─── [USER] WARNA TAB AKTIF DI DOCK NAVIGASI ───
          color: isActive ? const Color(0xFFD67B5A) : Colors.transparent, // <-- Ubah warna Lingkaran Tab Aktif (Terracotta Oranye)
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 22,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
