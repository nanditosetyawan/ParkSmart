import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../pin/backend/pin_backend.dart';
import '../pin/pin_screen.dart';

class PinSettingsScreen extends StatefulWidget {
  const PinSettingsScreen({super.key});

  @override
  State<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends State<PinSettingsScreen> {
  bool _isLoading = true;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _loadPinStatus();
  }

  Future<void> _loadPinStatus() async {
    setState(() => _isLoading = true);
    final hasPin = await PinBackend.instance.hasPin(forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _isLoading = false;
    });
  }

  Future<void> _confirmDeletePin() async {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? theme.card : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Hapus PIN?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF1A1A18),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus PIN transaksi? Setelah dihapus, Anda harus membuat PIN baru sebelum dapat melakukan pembayaran tiket parkir.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: isDark ? theme.textSecondary : const Color(0xFF555555),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: isDark ? theme.textSecondary : const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus PIN',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await PinBackend.instance.deletePin();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN transaksi berhasil dihapus dari database.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadPinStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PinBackend.instance.errorMessage ?? 'Gagal menghapus PIN.'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          appBar: AppBar(
            backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : const Color(0xFF1C1C18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Pengaturan PIN',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? Colors.white : const Color(0xFF1A1A18),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? theme.card : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: theme.border) : null,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Column(
                        children: [
                          // 1. Jika BELUM ada PIN: Tampilkan "Buat PIN"
                          if (!_hasPin)
                            _PinActionRow(
                              icon: Icons.pin_invoke,
                              title: 'Buat PIN',
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PinScreen(
                                      nextScreen: PinSettingsScreen(),
                                      transactionType: 'buat pin',
                                      customTitle: 'Buat PIN',
                                      backToHome: false,
                                    ),
                                  ),
                                ).then((_) => _loadPinStatus());
                              },
                            ),

                          // 2. Jika SUDAH ada PIN: "Buat PIN" hidden, posisinya diisi "Reset PIN" & "Hapus PIN"
                          if (_hasPin) ...[
                            _PinActionRow(
                              icon: Icons.lock_reset,
                              title: 'Reset PIN',
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PinScreen(
                                      nextScreen: PinSettingsScreen(),
                                      transactionType: 'reset pin',
                                      customTitle: 'Reset PIN',
                                      backToHome: false,
                                    ),
                                  ),
                                ).then((_) => _loadPinStatus());
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                color: isDark ? theme.border : const Color(0xFFF1EEE7),
                                height: 1,
                              ),
                            ),
                            _PinActionRow(
                              icon: Icons.delete_outline,
                              title: 'Hapus PIN',
                              iconColor: const Color(0xFFEF4444),
                              titleColor: const Color(0xFFEF4444),
                              containerBg: const Color(0xFFEF4444).withValues(alpha: 0.1),
                              isDark: isDark,
                              onTap: _confirmDeletePin,
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PinActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;
  final Color? titleColor;
  final Color? containerBg;

  const _PinActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDark = false,
    this.iconColor,
    this.titleColor,
    this.containerBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final defaultBg = isDark ? theme.surfaceField : const Color(0xFFF5F1E8);
    final defaultIconColor = isDark ? Colors.white : const Color(0xFF1A1A18);
    final defaultTextColor = isDark ? Colors.white : const Color(0xFF1A1A18);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: containerBg ?? defaultBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? defaultIconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: titleColor ?? defaultTextColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? theme.surfaceField : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? theme.border : const Color(0xFFE5E2DB),
              ),
            ),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: titleColor ?? (isDark ? Colors.white : const Color(0xFF1A1A18)),
            ),
          ),
        ],
      ),
    );
  }
}
