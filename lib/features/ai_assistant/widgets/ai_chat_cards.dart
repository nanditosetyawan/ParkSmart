import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/currency_service.dart';
import '../../checkout/checkout_screen.dart';
import '../../history/history_detail_screen.dart';
import '../../map/explore_map_screen.dart';
import '../../parking/parking_detail_screen.dart';

/// Kartu visual kaya untuk lokasi parkir rekomendasi AI
class AiParkingCard extends StatelessWidget {
  final Map<String, dynamic> location;

  const AiParkingCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final name = location['name']?.toString() ?? 'Lokasi Parkir';
    final city = location['city']?.toString() ?? 'Jakarta';
    final address = location['address']?.toString() ?? '';
    final imageUrl = location['image_url']?.toString();
    final opHours = location['operating_hours']?.toString() ?? 'Buka 24 Jam';
    final availSlots = (location['available_slots'] as num?)?.toInt() ?? 0;
    final totalSlots = (location['total_capacity'] as num?)?.toInt() ?? 50;
    final rateMobil = (location['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
    final rating = (location['rating'] as num?)?.toDouble() ?? 4.5;
    final reviews = (location['reviews'] as List?) ?? [];

    final lat = (location['latitude'] as num?)?.toDouble() ?? -6.1754;
    final lng = (location['longitude'] as num?)?.toDouble() ?? 106.7933;

    // Persiapkan model payload untuk ExploreMapScreen
    final mapPayload = {
      ...location,
      'id': location['id']?.toString(),
      'name': name,
      'address': address,
      'point': LatLng(lat, lng),
      'price': 'Rp $rateMobil / jam',
      'hourly_rate_mobil': rateMobil,
      'rating': rating,
      'operating_hours': opHours,
      'available_slots': availSlots,
      'total_capacity': totalSlots,
      'photos': imageUrl != null && imageUrl.isNotEmpty ? [imageUrl] : <String>[],
    };

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Lokasi Parkir
          Stack(
            children: [
              Container(
                height: 125,
                width: double.infinity,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(isDark),
                      )
                    : _buildImagePlaceholder(isDark),
              ),
              // Badge Ketersediaan Slot
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: availSlots > 0 ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: availSlots > 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        availSlots > 0 ? '$availSlots/$totalSlots Slot Tersedia' : 'Slot Penuh',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Badge Jam Operasional
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        opHours,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Informasi Lokasi
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  address.isNotEmpty ? '$address, $city' : city,
                  style: GoogleFonts.inter(fontSize: 12, color: textSub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Tarif & Cuplikan Ulasan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyService.instance.format(rateMobil.toDouble())} / jam',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'Mobil & Motor',
                      style: GoogleFonts.inter(fontSize: 11, color: textSub),
                    ),
                  ],
                ),

                if (reviews.isNotEmpty && reviews.first['comment'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reviews.first['comment'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: textSub,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExploreMapScreen(
                                initialSelectedParking: mapPayload,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text('Buka di Peta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ParkingDetailScreen(
                                locationId: location['id']?.toString(),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textMain,
                          side: BorderSide(color: cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Pesan Slot',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_parking_rounded, size: 36, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
          const SizedBox(height: 4),
          Text(
            'ParkSmart Location',
            style: GoogleFonts.inter(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

/// Kartu visual untuk status pesanan / booking pengguna di AI Chat
class AiBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const AiBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final id = booking['id']?.toString() ?? '';
    final code = booking['booking_code']?.toString() ?? '#BKG';
    final locName = booking['parking_locations']?['name']?.toString() ?? 'Lokasi Parkir';
    final price = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
    final payStatus = booking['payment_status']?.toString().toLowerCase() ?? 'unpaid';
    final bkgStatus = booking['booking_status']?.toString().toLowerCase() ?? 'upcoming';
    final plate = booking['plate_number']?.toString() ?? '-';

    final isUnpaid = payStatus == 'unpaid';
    final isActive = bkgStatus == 'active' || bkgStatus == 'upcoming';

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnpaid ? const Color(0xFFF59E0B) : cardBorder,
          width: isUnpaid ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code,
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnpaid
                      ? const Color(0xFFFEF3C7)
                      : (isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUnpaid
                      ? 'BELUM DIBAYAR'
                      : (isActive ? 'AKTIF / READY' : 'SELESAI'),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUnpaid
                        ? const Color(0xFFB45309)
                        : (isActive ? const Color(0xFF047857) : const Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            locName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.directions_car, size: 14, color: textSub),
              const SizedBox(width: 4),
              Text(
                'Plat: $plate',
                style: GoogleFonts.inter(fontSize: 12, color: textSub),
              ),
              const Spacer(),
              Text(
                CurrencyService.instance.format(price),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isUnpaid)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(existingBookingId: id),
                    ),
                  );
                },
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('Bayar Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryDetailScreen(id: id),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('Lihat Detail Bukti'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textMain,
                  side: BorderSide(color: cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
