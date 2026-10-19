import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/theme_service.dart';
import '../parking/parking_detail_screen.dart';
import 'backend/favorite_backend.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final List<Map<String, dynamic>> _allFavorites = [
    {
      'name': 'Central Park Mall Parking',
      'type': 'Parkiran Mall',
      'point': const LatLng(-6.1788, 106.7916),
      'slots': 42,
      'isEv': true,
      'distance': '350m',
      'price': 'Rp 5.000 / jam',
      'rating': 4.7,
      'reviews': '1.420',
      'hours': 'Buka • Tutup pukul 22.00 WIB',
      'photos': [
        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
      ],
    },
    {
      'name': 'Grand Indonesia West Mall',
      'type': 'Parkiran Mall',
      'point': const LatLng(-6.1953, 106.8208),
      'slots': 8,
      'isEv': false,
      'distance': '850m',
      'price': 'Rp 6.000 / jam',
      'rating': 4.8,
      'reviews': '1.820',
      'hours': 'Buka • Tutup pukul 22.00 WIB',
      'photos': [
        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
      ],
    },
    {
      'name': 'EV Fast Charging Hub Tomang',
      'type': 'Parkir Khusus EV',
      'point': const LatLng(-6.1740, 106.7940),
      'slots': 6,
      'isEv': true,
      'distance': '1.1km',
      'price': 'Rp 8.000 / jam',
      'rating': 4.8,
      'reviews': '340',
      'hours': 'Buka 24 Jam',
      'photos': [
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600&auto=format&fit=crop&q=80',
      ],
    },
  ];

  List<Map<String, dynamic>> _displayedFavorites = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayedFavorites = List.from(_allFavorites);

    // Ambil data tempat favorit live dari backend Supabase
    FavoriteBackend.instance.fetchFavorites().then((_) {
      if (mounted && FavoriteBackend.instance.favorites.isNotEmpty) {
        setState(() {
          _allFavorites.clear();
          _allFavorites.addAll(FavoriteBackend.instance.favorites);
          _displayedFavorites = List.from(_allFavorites);
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _displayedFavorites = List.from(_allFavorites);
      });
      return;
    }
    final q = query.trim().toLowerCase();
    setState(() {
      _displayedFavorites = _allFavorites.where((loc) {
        final name = (loc['name'] as String).toLowerCase();
        final type = (loc['type'] as String).toLowerCase();
        return name.contains(q) || type.contains(q);
      }).toList();
    });
  }

  void _openDetail(Map<String, dynamic> loc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParkingDetailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        final bg = isDark ? theme.bg : Colors.white;
        final textMain = isDark ? Colors.white : const Color(0xFF1F1F1F);
        final textSub = isDark ? theme.textMuted : const Color(0xFF6B7280);
        final cardBg = isDark ? theme.card : Colors.white;
        final cardBorder = isDark ? theme.border : const Color(0xFFF3F4F6);
        final searchBg = isDark ? theme.surfaceField : const Color(0xFFF3F4F6);

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
              'Favorite Parking',
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
                      hintText: 'Cari tempat favorit...',
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
                child: _displayedFavorites.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ditemukan tempat parkir.',
                          style: GoogleFonts.inter(color: textSub, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _displayedFavorites.length,
                        itemBuilder: (context, index) {
                          final loc = _displayedFavorites[index];
                          final isEv = loc['isEv'] == true;
                          final String imgUrl = (loc['photos'] as List).first;

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
                                        Text(
                                          loc['name'],
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textMain,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${loc['distance']} • ${loc['price']}',
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
                                                isEv ? 'EV Charging' : 'Parkir Reguler',
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
                                                    'Buka',
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
