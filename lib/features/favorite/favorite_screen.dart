import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/language_service.dart';
import '../parking/parking_detail_screen.dart';
import 'backend/favorite_backend.dart';
import '../profile/backend/vehicle_backend.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    FavoriteBackend.instance.fetchFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  void _openDetail(Map<String, dynamic> loc) {
    final String? locId = loc['id']?.toString();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailScreen(locationId: locId),
      ),
    ).then((_) {
      if (mounted) {
        FavoriteBackend.instance.fetchFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, FavoriteBackend.instance, CurrencyService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final backend = FavoriteBackend.instance;

        final bg = isDark ? theme.bg : Colors.white;
        final textMain = isDark ? Colors.white : const Color(0xFF1F1F1F);
        final textSub = isDark ? theme.textMuted : const Color(0xFF6B7280);
        final cardBg = isDark ? theme.card : Colors.white;
        final cardBorder = isDark ? theme.border : const Color(0xFFF3F4F6);
        final searchBg = isDark ? theme.surfaceField : const Color(0xFFF3F4F6);

        final allFavorites = backend.favorites;
        final displayedFavorites = _searchQuery.isEmpty
            ? allFavorites
            : allFavorites.where((loc) {
                final name = (loc['name'] as String? ?? '').toLowerCase();
                final type = (loc['type'] as String? ?? '').toLowerCase();
                return name.contains(_searchQuery) || type.contains(_searchQuery);
              }).toList();

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textMain),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Favorite Parking'.tr,
              style: GoogleFonts.inter(
                color: textMain,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: cardBorder) : null,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.inter(color: textMain, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari tempat favorit...'.tr,
                      hintStyle: GoogleFonts.inter(color: textSub, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: textSub),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // List
              Expanded(
                child: backend.isLoading && allFavorites.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                          ),
                        ),
                      )
                    : displayedFavorites.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.favorite_border_rounded,
                                      size: 36,
                                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Belum Ada Tempat Favorit'.tr,
                                    style: GoogleFonts.inter(
                                      color: textMain,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Simpan lokasi parkir langganan Anda dengan menekan ikon favorit pada halaman detail parkir.'.tr,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: textSub,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: displayedFavorites.length,
                            itemBuilder: (context, index) {
                              final loc = displayedFavorites[index];
                              final isEv = loc['isEv'] == true;
                              final String imgUrl = (loc['photos'] as List).first;
                              final locId = loc['id']?.toString() ?? '';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: cardBorder, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    // Foto Parkir
                                    ClipRRect(
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                      child: Image.network(
                                        imgUrl,
                                        width: 110,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 110,
                                          height: 120,
                                          color: isDark ? theme.surfaceField : Colors.grey[200],
                                          child: Icon(Icons.local_parking, color: textSub),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Info Parkir
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    loc['name'] ?? 'Spot Parkir',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: textMain,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.favorite,
                                                    color: Color(0xFFEF4444),
                                                    size: 20,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  splashRadius: 18,
                                                  onPressed: () async {
                                                    await backend.removeFavorite(locId);
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${loc['distance']} • ${CurrencyService.instance.format(((VehicleBackend.instance.defaultVehicle?.vehicleType.toLowerCase() ?? 'mobil').contains('motor') ? (loc['hourly_rate_motor'] as num?) : (VehicleBackend.instance.defaultVehicle?.vehicleType.toLowerCase() ?? 'mobil').contains('ev') ? ((loc['hourly_rate_ev'] as num?) ?? (loc['hourly_rate_mobil'] as num?)) : (loc['hourly_rate_mobil'] as num?)) ?? (loc['hourly_rate_active'] as num?) ?? 5000)} / jam',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: textSub,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Indikator EV atau Mobil biasa
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isEv
                                                        ? (isDark
                                                            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                                                            : const Color(0xFFDEF7EC))
                                                        : (isDark
                                                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
                                                            : const Color(0xFFE1EFFE)),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    isEv ? 'EV Charging'.tr : 'Parkir Reguler'.tr,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: isEv
                                                          ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF03543F))
                                                          : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E429F)),
                                                    ),
                                                  ),
                                                ),
                                                // Tombol Buka
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 12),
                                                  child: InkWell(
                                                    onTap: () => _openDetail(loc),
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF1A73E8),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        'Buka'.tr,
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

