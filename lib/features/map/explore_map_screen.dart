import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../parking/parking_detail_screen.dart';
import 'speech_helper.dart';
import '../home/home_screen.dart';
import '../navigation/ar_navigation_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  final Map<String, dynamic>? initialSelectedParking;
  const ExploreMapScreen({super.key, this.initialSelectedParking});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final MapController _mapController = MapController();

  // Search query, text controller & focus node
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  LatLng? _searchResultPoint;
  String? _searchResultName;
  bool _isSearching = false;
  List<Map<String, dynamic>> _filteredSuggestions = [];
  Map<String, dynamic>? _selectedParking;
  final DraggableScrollableController _placeDetailsController = DraggableScrollableController();
  int _selectedDetailTab = 0; // 0: Ringkasan, 1: Ulasan, 2: Tentang

  final List<String> _feedbackTopics = const [
    'Akurasi Sensor ANPR',
    'Kemudahan Gate',
    'Ketersediaan Slot',
    'Tarif & Pembayaran',
    'Lainnya',
  ];

  String _selectedReviewFilterTopic = 'Semua';

  final List<Map<String, dynamic>> _userReviews = [
    {
      'name': 'Budi Santoso',
      'rating': 5,
      'date': '2 hari yang lalu',
      'review': 'Tempat parkir sangat luas, fasilitas charging EV cepat dan bekerja optimal. Petugas keamanan sangat ramah.',
      'topics': ['Akurasi Sensor ANPR', 'Ketersediaan Slot'],
    },
    {
      'name': 'Jessica Wijaya',
      'rating': 5,
      'date': '1 minggu yang lalu',
      'review': 'Palang otomatis membaca nomor plat tanpa kendala. Lokasi beratap sehingga mobil teduh dan aman dari hujan.',
      'topics': ['Kemudahan Gate', 'Akurasi Sensor ANPR'],
    },
    {
      'name': 'Ahmad Faisal',
      'rating': 4,
      'date': '2 minggu yang lalu',
      'review': 'Akses keluar masuk sangat mudah di pusat kota. Pembayaran cashless sangat praktis.',
      'topics': ['Kemudahan Gate', 'Tarif & Pembayaran'],
    },
    {
      'name': 'Dewi Lestari',
      'rating': 5,
      'date': '3 minggu yang lalu',
      'review': 'CCTV dan penerangan malam hari sangat terang. Sangat direkomendasikan untuk parkir harian.',
      'topics': ['Ketersediaan Slot', 'Lainnya'],
    },
  ];

  // Database Kota, Landmark, dan Lokasi Populer di Seluruh Indonesia
  static final List<Map<String, dynamic>> _indonesiaPlaces = [
    // --- JAWA TIMUR ---
    {'name': 'Surabaya', 'desc': 'Jawa Timur, Indonesia', 'alias': 'sby', 'point': const LatLng(-7.2575, 112.7521), 'zoom': 14.0},
    {'name': 'Tunjungan Plaza', 'desc': 'Surabaya, Jawa Timur', 'alias': 'tp tunjungan mall', 'point': const LatLng(-7.2625, 112.7397), 'zoom': 16.5},
    {'name': 'Galaxy Mall Surabaya', 'desc': 'Mulyorejo, Surabaya, Jawa Timur', 'alias': 'gm surabaya', 'point': const LatLng(-7.2736, 112.7806), 'zoom': 16.5},
    {'name': 'Pakuwon Mall Surabaya', 'desc': 'Surabaya Barat, Jawa Timur', 'alias': 'pakuwon ptc', 'point': const LatLng(-7.2892, 112.6756), 'zoom': 16.5},
    {'name': 'Malang', 'desc': 'Jawa Timur, Indonesia', 'alias': 'mlg kota malang', 'point': const LatLng(-7.9839, 112.6214), 'zoom': 14.0},
    {'name': 'Kota Batu', 'desc': 'Jawa Timur, Indonesia', 'alias': 'batu malang jatim park', 'point': const LatLng(-7.8712, 112.5270), 'zoom': 14.0},
    {'name': 'Sidoarjo', 'desc': 'Jawa Timur, Indonesia', 'alias': 'sda', 'point': const LatLng(-7.4478, 112.7183), 'zoom': 14.0},
    {'name': 'Kediri', 'desc': 'Jawa Timur, Indonesia', 'alias': 'kota kediri', 'point': const LatLng(-7.8480, 112.0178), 'zoom': 14.0},
    {'name': 'Madiun', 'desc': 'Jawa Timur, Indonesia', 'alias': 'kota madiun', 'point': const LatLng(-7.6298, 111.5239), 'zoom': 14.0},
    {'name': 'Jember', 'desc': 'Jawa Timur, Indonesia', 'alias': 'kota jember', 'point': const LatLng(-8.1724, 113.7007), 'zoom': 14.0},
    {'name': 'Banyuwangi', 'desc': 'Jawa Timur, Indonesia', 'alias': 'ketapang bwx', 'point': const LatLng(-8.2192, 114.3691), 'zoom': 14.0},
    {'name': 'Probolinggo', 'desc': 'Jawa Timur, Indonesia', 'alias': 'bromo probolinggo', 'point': const LatLng(-7.7543, 113.2159), 'zoom': 14.0},
    {'name': 'Pasuruan', 'desc': 'Jawa Timur, Indonesia', 'alias': 'kota pasuruan', 'point': const LatLng(-7.6453, 112.9075), 'zoom': 14.0},

    // --- DKI JAKARTA ---
    {'name': 'Jakarta', 'desc': 'DKI Jakarta, Indonesia', 'alias': 'jkt dki ibu kota', 'point': const LatLng(-6.2088, 106.8456), 'zoom': 13.5},
    {'name': 'Central Park Mall', 'desc': 'Tanjung Duren, Jakarta Barat', 'alias': 'cp mall jakarta', 'point': const LatLng(-6.1774, 106.7907), 'zoom': 16.5},
    {'name': 'Grand Indonesia', 'desc': 'Thamrin, Jakarta Pusat', 'alias': 'gi mall bundaran hi', 'point': const LatLng(-6.1965, 106.8228), 'zoom': 16.5},
    {'name': 'Mall Taman Anggrek', 'desc': 'Grogol Petamburan, Jakarta Barat', 'alias': 'mta jakarta', 'point': const LatLng(-6.1790, 106.7925), 'zoom': 16.5},
    {'name': 'Monas', 'desc': 'Gambir, Jakarta Pusat', 'alias': 'monumen nasional', 'point': const LatLng(-6.1754, 106.8272), 'zoom': 16.0},
    {'name': 'Senayan City', 'desc': 'Gelora, Tanah Abang, Jakarta Pusat', 'alias': 'sency senayan', 'point': const LatLng(-6.2274, 106.7974), 'zoom': 16.5},
    {'name': 'Pondok Indah Mall', 'desc': 'Kebayoran Lama, Jakarta Selatan', 'alias': 'pim jakarta', 'point': const LatLng(-6.2652, 106.7844), 'zoom': 16.5},
    {'name': 'Kelapa Gading Mall', 'desc': 'Jakarta Utara', 'alias': 'mkg kelapa gading', 'point': const LatLng(-6.1578, 106.9085), 'zoom': 16.5},

    // --- JAWA BARAT & BANTEN ---
    {'name': 'Bandung', 'desc': 'Jawa Barat, Indonesia', 'alias': 'bdg kota kembang', 'point': const LatLng(-6.9175, 107.6191), 'zoom': 14.0},
    {'name': 'Paris Van Java', 'desc': 'Sukajadi, Bandung, Jawa Barat', 'alias': 'pvj mall bandung', 'point': const LatLng(-6.8897, 107.5959), 'zoom': 16.5},
    {'name': 'Trans Studio Mall Bandung', 'desc': 'Batununggal, Bandung', 'alias': 'tsm bandung', 'point': const LatLng(-6.9261, 107.6366), 'zoom': 16.5},
    {'name': 'Bogor', 'desc': 'Jawa Barat, Indonesia', 'alias': 'bgr kota hujan', 'point': const LatLng(-6.5971, 106.8060), 'zoom': 14.0},
    {'name': 'Depok', 'desc': 'Jawa Barat, Indonesia', 'alias': 'ui depok margonda', 'point': const LatLng(-6.4025, 106.7942), 'zoom': 14.0},
    {'name': 'Bekasi', 'desc': 'Jawa Barat, Indonesia', 'alias': 'summarecon bekasi', 'point': const LatLng(-6.2383, 106.9756), 'zoom': 14.0},
    {'name': 'Tangerang', 'desc': 'Banten, Indonesia', 'alias': 'tng bandara soetta', 'point': const LatLng(-6.1783, 106.6319), 'zoom': 14.0},
    {'name': 'Tangerang Selatan / BSD', 'desc': 'Banten, Indonesia', 'alias': 'bsd city serpong tangsel', 'point': const LatLng(-6.2952, 106.7083), 'zoom': 14.0},
    {'name': 'Cirebon', 'desc': 'Jawa Barat, Indonesia', 'alias': 'kota udang', 'point': const LatLng(-6.7320, 108.5523), 'zoom': 14.0},
    {'name': 'Sukabumi', 'desc': 'Jawa Barat, Indonesia', 'alias': 'kota sukabumi', 'point': const LatLng(-6.9277, 106.9299), 'zoom': 14.0},
    {'name': 'Tasikmalaya', 'desc': 'Jawa Barat, Indonesia', 'alias': 'kota tasik', 'point': const LatLng(-7.3274, 108.2207), 'zoom': 14.0},
    {'name': 'Serang', 'desc': 'Banten, Indonesia', 'alias': 'kota serang', 'point': const LatLng(-6.1200, 106.1503), 'zoom': 14.0},

    // --- JAWA TENGAH & D.I. YOGYAKARTA ---
    {'name': 'Semarang', 'desc': 'Jawa Tengah, Indonesia', 'alias': 'smg simpang lima', 'point': const LatLng(-6.9932, 110.4203), 'zoom': 14.0},
    {'name': 'Yogyakarta', 'desc': 'D.I. Yogyakarta, Indonesia', 'alias': 'jogja djogja malioboro', 'point': const LatLng(-7.7956, 110.3695), 'zoom': 14.0},
    {'name': 'Malioboro', 'desc': 'Danurejan, Kota Yogyakarta', 'alias': 'jalan malioboro jogja', 'point': const LatLng(-7.7926, 110.3658), 'zoom': 16.5},
    {'name': 'Solo (Surakarta)', 'desc': 'Jawa Tengah, Indonesia', 'alias': 'surakarta kota solo', 'point': const LatLng(-7.5666, 110.8250), 'zoom': 14.0},
    {'name': 'Magelang', 'desc': 'Jawa Tengah, Indonesia', 'alias': 'borobudur magelang', 'point': const LatLng(-7.4706, 110.2178), 'zoom': 14.0},
    {'name': 'Purwokerto', 'desc': 'Banyumas, Jawa Tengah', 'alias': 'baturraden banyumas', 'point': const LatLng(-7.4243, 109.2301), 'zoom': 14.0},
    {'name': 'Tegal', 'desc': 'Jawa Tengah, Indonesia', 'alias': 'kota tegal', 'point': const LatLng(-6.8694, 109.1402), 'zoom': 14.0},
    {'name': 'Pekalongan', 'desc': 'Jawa Tengah, Indonesia', 'alias': 'kota batik', 'point': const LatLng(-6.8886, 109.6753), 'zoom': 14.0},
    {'name': 'Salatiga', 'desc': 'Jawa Tengah, Indonesia', 'alias': 'kota salatiga', 'point': const LatLng(-7.3305, 110.5084), 'zoom': 14.0},
    {'name': 'Kudus', 'desc': 'Jawa Tengah, Indonesia', 'alias': 'kota kretek', 'point': const LatLng(-6.8048, 110.8405), 'zoom': 14.0},

    // --- BALI & NUSA TENGGARA ---
    {'name': 'Denpasar', 'desc': 'Bali, Indonesia', 'alias': 'bali dps sanur', 'point': const LatLng(-8.6705, 115.2126), 'zoom': 13.5},
    {'name': 'Kuta', 'desc': 'Badung, Bali, Indonesia', 'alias': 'pantai kuta beachwalk', 'point': const LatLng(-8.7233, 115.1723), 'zoom': 15.0},
    {'name': 'Ubud', 'desc': 'Gianyar, Bali, Indonesia', 'alias': 'ubud bali monkey forest', 'point': const LatLng(-8.5069, 115.2625), 'zoom': 14.5},
    {'name': 'Mataram (Lombok)', 'desc': 'Nusa Tenggara Barat, Indonesia', 'alias': 'lombok ntb gili', 'point': const LatLng(-8.5833, 116.1167), 'zoom': 13.5},
    {'name': 'Labuan Bajo', 'desc': 'Manggarai Barat, NTT', 'alias': 'komodo labuan bajo ntt', 'point': const LatLng(-8.4964, 119.8877), 'zoom': 14.5},
    {'name': 'Kupang', 'desc': 'Nusa Tenggara Timur, Indonesia', 'alias': 'kota kupang ntt', 'point': const LatLng(-10.1772, 123.6070), 'zoom': 13.5},

    // --- SUMATERA ---
    {'name': 'Medan', 'desc': 'Sumatera Utara, Indonesia', 'alias': 'mdn sumut deli', 'point': const LatLng(3.5952, 98.6722), 'zoom': 13.5},
    {'name': 'Palembang', 'desc': 'Sumatera Selatan, Indonesia', 'alias': 'plb ampera sumsel', 'point': const LatLng(-2.9761, 104.7754), 'zoom': 13.5},
    {'name': 'Batam', 'desc': 'Kepulauan Riau, Indonesia', 'alias': 'kepri nagoya barelang', 'point': const LatLng(1.1301, 104.0529), 'zoom': 13.5},
    {'name': 'Pekanbaru', 'desc': 'Riau, Indonesia', 'alias': 'pku riau', 'point': const LatLng(0.5071, 101.4478), 'zoom': 13.5},
    {'name': 'Padang', 'desc': 'Sumatera Barat, Indonesia', 'alias': 'pdg sumbar jam gadang', 'point': const LatLng(-0.9471, 100.4172), 'zoom': 13.5},
    {'name': 'Bandar Lampung', 'desc': 'Lampung, Indonesia', 'alias': 'bdl lampung bakauheni', 'point': const LatLng(-5.4292, 105.2625), 'zoom': 13.5},
    {'name': 'Banda Aceh', 'desc': 'Aceh, Indonesia', 'alias': 'serambi mekkah nad', 'point': const LatLng(5.5483, 95.3238), 'zoom': 13.5},
    {'name': 'Jambi', 'desc': 'Jambi, Indonesia', 'alias': 'kota jambi', 'point': const LatLng(-1.6101, 103.6131), 'zoom': 13.5},
    {'name': 'Bengkulu', 'desc': 'Bengkulu, Indonesia', 'alias': 'kota bengkulu', 'point': const LatLng(-3.7928, 102.2608), 'zoom': 13.5},
    {'name': 'Pangkalpinang', 'desc': 'Bangka Belitung, Indonesia', 'alias': 'bangka belitung babel', 'point': const LatLng(-2.1290, 106.1139), 'zoom': 13.5},

    // --- KALIMANTAN ---
    {'name': 'Balikpapan', 'desc': 'Kalimantan Timur, Indonesia', 'alias': 'bpp kaltim sepinggan', 'point': const LatLng(-1.2379, 116.8529), 'zoom': 13.5},
    {'name': 'Samarinda', 'desc': 'Kalimantan Timur, Indonesia', 'alias': 'smd mahakam kaltim', 'point': const LatLng(-0.5022, 117.1536), 'zoom': 13.5},
    {'name': 'IKN Nusantara', 'desc': 'Sepaku, Penajam Paser Utara, Kaltim', 'alias': 'ibu kota nusantara ikn', 'point': const LatLng(-0.9739, 116.7090), 'zoom': 14.5},
    {'name': 'Banjarmasin', 'desc': 'Kalimantan Selatan, Indonesia', 'alias': 'bjm kalsel pasar terapung', 'point': const LatLng(-3.3194, 114.5908), 'zoom': 13.5},
    {'name': 'Pontianak', 'desc': 'Kalimantan Barat, Indonesia', 'alias': 'ptk kalbar khatulistiwa', 'point': const LatLng(-0.0263, 109.3425), 'zoom': 13.5},
    {'name': 'Palangka Raya', 'desc': 'Kalimantan Tengah, Indonesia', 'alias': 'kalteng palangkaraya', 'point': const LatLng(-2.2161, 113.9140), 'zoom': 13.5},
    {'name': 'Tarakan', 'desc': 'Kalimantan Utara, Indonesia', 'alias': 'kaltara tarakan', 'point': const LatLng(3.3273, 117.5786), 'zoom': 13.5},

    // --- SULAWESI ---
    {'name': 'Makassar', 'desc': 'Sulawesi Selatan, Indonesia', 'alias': 'mks sulsel pantai losari ujung pandang', 'point': const LatLng(-5.1477, 119.4327), 'zoom': 13.5},
    {'name': 'Manado', 'desc': 'Sulawesi Utara, Indonesia', 'alias': 'mdo sulut bunaken', 'point': const LatLng(1.4748, 124.8421), 'zoom': 13.5},
    {'name': 'Palu', 'desc': 'Sulawesi Tengah, Indonesia', 'alias': 'sulteng palu', 'point': const LatLng(-0.9003, 119.8779), 'zoom': 13.5},
    {'name': 'Kendari', 'desc': 'Sulawesi Tenggara, Indonesia', 'alias': 'sultra kendari', 'point': const LatLng(-3.9985, 122.5126), 'zoom': 13.5},
    {'name': 'Gorontalo', 'desc': 'Gorontalo, Indonesia', 'alias': 'kota gorontalo', 'point': const LatLng(0.5435, 123.0568), 'zoom': 13.5},

    // --- MALUKU & PAPUA ---
    {'name': 'Ambon', 'desc': 'Maluku, Indonesia', 'alias': 'ambon manise maluku', 'point': const LatLng(-3.6547, 128.1906), 'zoom': 13.5},
    {'name': 'Jayapura', 'desc': 'Papua, Indonesia', 'alias': 'jayapura papua sentani', 'point': const LatLng(-2.5916, 140.6690), 'zoom': 13.5},
    {'name': 'Sorong', 'desc': 'Papua Barat Daya, Indonesia', 'alias': 'raja ampat sorong', 'point': const LatLng(-0.8762, 131.2558), 'zoom': 13.5},
  ];

  // Mode Tile Map (Standar OSM vs Satelit)
  bool _isSatellite = false;

  // GPS & Pelacakan Lokasi
  bool _isGpsActive = false;
  LatLng? _currentPosition;
  double _heading = 0.0; // Sudut orientasi kompas dalam radian

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  // Draggable Sheet Controller
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // Kategori terpilih (Terdekat, Mall, Parkir EV)
  String _selectedCategory = '';

  // Data lokasi parkir di sekitar dengan informasi rating, jam buka & foto admin
  final List<Map<String, dynamic>> _parkingLocations = [
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
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80',
      ],
    },
    {
      'name': 'Neo Soho Parking Hub',
      'type': 'Parkiran Mall',
      'point': const LatLng(-6.1755, 106.7895),
      'slots': 18,
      'isEv': true,
      'distance': '500m',
      'price': 'Rp 5.000 / jam',
      'rating': 4.6,
      'reviews': '850',
      'hours': 'Buka • Tutup pukul 22.00 WIB',
      'photos': [
        'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80',
      ],
    },
    {
      'name': 'Mall Taman Anggrek Basement',
      'type': 'Parkiran Mall',
      'point': const LatLng(-6.1790, 106.7925),
      'slots': 85,
      'isEv': false,
      'distance': '750m',
      'price': 'Rp 4.000 / jam',
      'rating': 4.5,
      'reviews': '2.100',
      'hours': 'Buka • Tutup pukul 21.30 WIB',
      'photos': [
        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80',
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
        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
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
        'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
      ],
    },
    {
      'name': 'Plaza Indonesia (Lantai 2)',
      'type': 'Parkiran Mall',
      'point': const LatLng(-6.1928, 106.8228),
      'slots': 12,
      'isEv': false,
      'distance': '1.2km',
      'price': 'Rp 5.000 / jam',
      'rating': 4.6,
      'reviews': '1.150',
      'hours': 'Buka • Tutup pukul 22.00 WIB',
      'photos': [
        'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Titik awal peta: Sekitar Central Park Jakarta
    _currentPosition = const LatLng(-6.1774, 106.7907);

    if (widget.initialSelectedParking != null) {
      final loc = widget.initialSelectedParking!;
      if (!_parkingLocations.any((p) => p['name'] == loc['name'])) {
        _parkingLocations.add(loc);
      }
      _selectedParking = loc;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onParkingMarkerTapped(loc);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _positionSub?.cancel();
    _magSub?.cancel();
    _sheetController.dispose();
    _placeDetailsController.dispose();
    super.dispose();
  }

  Future<void> _toggleGpsTracking() async {
    if (_isGpsActive && _currentPosition != null) {
      // Pusatkan kembali peta ke posisi pengguna saat ini
      _mapController.move(_currentPosition!, 16.5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peta dipusatkan ke posisi Anda'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      // 1. Cek Service Enabled khusus di Mobile (Android/iOS)
      // Di Web/Chrome, browser menangani ini lewat navigator.geolocation
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan GPS perangkat belum aktif. Silakan aktifkan GPS.'),
            ),
          );
          return;
        }
      }

      // 2. Request Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 3. Ambil posisi
      LatLng userPos;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
            timeLimit: const Duration(seconds: 8),
          ),
        );
        userPos = LatLng(position.latitude, position.longitude);
      } catch (locErr) {
        // Fallback untuk Chrome/Laptop jika akses lokasi diblokir atau hardware GPS laptop tidak tersedia
        userPos = _currentPosition ?? const LatLng(-6.1774, 106.7907);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menggunakan simulasi lokasi (Pastikan izin lokasi diizinkan di Chrome).'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isGpsActive = true;
          _currentPosition = userPos;
        });
        _mapController.move(userPos, 16.5);
      }

      // 4. Dengarkan aliran posisi GPS
      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 2,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
            if (pos.heading != 0) {
              _heading = (pos.heading * pi) / 180;
            }
          });
        }
      });

      // 5. Dengarkan sensor Magnetometer (hanya di perangkat mobile asli yang memiliki sensor kompas)
      if (!kIsWeb) {
        try {
          _magSub?.cancel();
          _magSub = magnetometerEventStream().listen((event) {
            final rad = atan2(event.y, event.x);
            if (mounted) {
              setState(() {
                _heading = rad;
              });
            }
          });
        } catch (_) {}
      } else {
        // Di web/laptop, buat orientasi menghadap ke atas / sudut awal yang bagus
        if (mounted) {
          setState(() {
            _heading = 0.0;
          });
        }
      }
    } catch (e) {
      // Fallback aman
      if (mounted) {
        setState(() {
          _isGpsActive = true;
          _currentPosition = _currentPosition ?? const LatLng(-6.1774, 106.7907);
        });
        _mapController.move(_currentPosition!, 16.5);
      }
    }
  }

  void _unselectParking() {
    setState(() {
      _selectedParking = null;
    });
    // Kembalikan level zoom peta ke tampilan normal (zoom 15.5)
    final target = _currentPosition ?? const LatLng(-6.1774, 106.7907);
    _mapController.move(target, 15.5);
  }

  void _onParkingMarkerTapped(Map<String, dynamic> loc) {
    setState(() {
      _selectedParking = loc;
      _selectedDetailTab = 0; // Otomatis tab Ringkasan
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_placeDetailsController.isAttached) {
        _placeDetailsController.animateTo(
          0.50,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
    // Auto zoom dekat ke titik yang diklik (zoom 17.0)
    _mapController.move(loc['point'] as LatLng, 17.0);
  }

  void _openVoiceSearchDialog() {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return VoiceSearchBottomSheet(
          onQuerySelected: (query) {
            _performAutoSearch(query);
          },
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _isSearching = false;
      });
      return;
    }

    final results = _indonesiaPlaces.where((place) {
      final name = (place['name'] as String).toLowerCase();
      final desc = (place['desc'] as String).toLowerCase();
      final alias = (place['alias'] as String? ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q) || alias.contains(q);
    }).take(5).toList();

    setState(() {
      _filteredSuggestions = results;
      _isSearching = true;
    });
  }

  void _performAutoSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final q = trimmed.toLowerCase();
    _searchController.text = trimmed;
    _searchFocusNode.unfocus();

    Map<String, dynamic>? matchedPlace;

    // 1. Cari exact / best match dari database kota & tempat Indonesia
    for (final place in _indonesiaPlaces) {
      final name = (place['name'] as String).toLowerCase();
      final alias = (place['alias'] as String? ?? '').toLowerCase();
      if (name == q || alias == q || name.startsWith(q)) {
        matchedPlace = place;
        break;
      }
    }

    // 2. Jika tidak ada yang persis, cari yang mengandung kata kunci
    matchedPlace ??= _indonesiaPlaces.cast<Map<String, dynamic>?>().firstWhere(
      (place) {
        if (place == null) return false;
        final name = (place['name'] as String).toLowerCase();
        final desc = (place['desc'] as String).toLowerCase();
        final alias = (place['alias'] as String? ?? '').toLowerCase();
        return name.contains(q) || desc.contains(q) || alias.contains(q) || q.contains(name);
      },
      orElse: () => null,
    );

    LatLng targetPoint;
    String displayName = trimmed;
    double targetZoom = 14.0;

    if (matchedPlace != null) {
      targetPoint = matchedPlace['point'] as LatLng;
      displayName = matchedPlace['name'] as String;
      targetZoom = (matchedPlace['zoom'] as double?) ?? 14.0;
    } else {
      // Default jika tidak ada kota spesifik: Surabaya
      targetPoint = const LatLng(-7.2575, 112.7521);
      displayName = trimmed;
      targetZoom = 14.0;
    }

    // Tambahkan titik parkir regional jika mencari kota besar tertentu
    if (q.contains('surabaya') && !_parkingLocations.any((loc) => (loc['name'] as String).contains('Tunjungan'))) {
      _parkingLocations.addAll([
        {
          'name': 'Tunjungan Plaza Parking Hub',
          'type': 'Mall',
          'point': const LatLng(-7.2625, 112.7397),
          'slots': 120,
          'isEv': true,
          'price': 'Rp 5.000/j',
        },
        {
          'name': 'Galaxy Mall Surabaya Parking',
          'type': 'Mall',
          'point': const LatLng(-7.2736, 112.7806),
          'slots': 64,
          'isEv': true,
          'price': 'Rp 5.000/j',
        },
      ]);
    } else if (q.contains('bandung') && !_parkingLocations.any((loc) => (loc['name'] as String).contains('PVJ'))) {
      _parkingLocations.addAll([
        {
          'name': 'PVJ Bandung Parking Lot',
          'type': 'Mall',
          'point': const LatLng(-6.8897, 107.5959),
          'slots': 90,
          'isEv': true,
          'price': 'Rp 5.000/j',
        },
        {
          'name': 'TSM Bandung Parking Area',
          'type': 'Mall',
          'point': const LatLng(-6.9261, 107.6366),
          'slots': 75,
          'isEv': true,
          'price': 'Rp 5.000/j',
        },
      ]);
    }

    setState(() {
      _searchQuery = displayName;
      _searchResultPoint = targetPoint;
      _searchResultName = displayName;
      _filteredSuggestions = [];
      _isSearching = false;
    });

    // Otomatis animasi terbang ke kota/lokasi yang dicari
    _mapController.move(targetPoint, targetZoom);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F1F1F),
        content: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFFEA4335), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Menemukan kota "$displayName". Peta dialihkan ke lokasi.',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onCategoryTapped(String cat) {
    setState(() {
      _selectedParking = null;
      _selectedCategory = _selectedCategory == cat ? '' : cat;
    });

    if (cat == 'Terdekat' && _currentPosition != null) {
      _mapController.move(_currentPosition!, 16.5);
    } else if (cat == 'Mall') {
      _mapController.move(const LatLng(-6.1774, 106.7907), 16.0);
    } else if (cat == 'Parkir EV') {
      _mapController.move(const LatLng(-6.1740, 106.7940), 16.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double bottomNavHeight = 64.0;
    final totalBottomHeight = bottomNavHeight + bottomPadding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. FULLSCREEN FLUTTER MAP
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(-6.1774, 106.7907),
                initialZoom: 15.5,
                minZoom: 4.0,
                maxZoom: 19.0,
                onTap: (tapPosition, point) {
                  if (_selectedParking != null) {
                    _unselectParking();
                  }
                  _searchFocusNode.unfocus();
                  if (_isSearching) {
                    setState(() {
                      _isSearching = false;
                      _filteredSuggestions = [];
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _isSatellite
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smart_parking',
                ),
                MarkerLayer(
                  markers: [
                    // MARKER HASIL AUTO-SEARCH (MISAL: SURABAYA)
                    if (_searchResultPoint != null)
                      Marker(
                        point: _searchResultPoint!,
                        width: 180,
                        height: 76,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA4335),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _searchResultName ?? _searchQuery,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Color(0xFFEA4335),
                            ),
                          ],
                        ),
                      ),

                    // Titik-titik marker lokasi parkir
                    ..._parkingLocations.map((loc) {
                      final LatLng pt = loc['point'] as LatLng;
                      final String name = loc['name'] as String;
                      final bool isEv = (loc['isEv'] as bool?) ?? false;
                      final String type = (loc['type'] as String?) ?? 'Mall';
                      final bool isSelected = _selectedParking != null && _selectedParking!['name'] == name;

                      // Filter kategori jika aktif
                      if (_selectedCategory == 'Mall' && !type.contains('Mall')) return null;
                      if (_selectedCategory == 'Parkir EV' && !isEv) return null;

                      // JIKA TITIK INI DIKLIK: Berubah jadi PIN MERAH khas Google Maps!
                      if (isSelected) {
                        return Marker(
                          point: pt,
                          width: 52,
                          height: 64,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => _onParkingMarkerTapped(loc),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFEA4335),
                                      size: 52,
                                      shadows: [
                                        BoxShadow(
                                          color: Color(0x55000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 14,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 9,
                                            height: 9,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFB3261E),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 14,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Tampilan normal sebelum titik diklik
                      return Marker(
                        point: pt,
                        width: 140,
                        height: 52,
                        child: GestureDetector(
                          onTap: () => _onParkingMarkerTapped(loc),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isEv ? const Color(0xFF10B981) : const Color(0xFF1A73E8),
                                      ),
                                      child: Icon(
                                        isEv ? Icons.electric_car : Icons.local_parking,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        name.split(' ').first,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F1F1F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).whereType<Marker>(),

                    // MARKER POSISI PENGGUNA DENGAN CORONG SUDUT PANDANG (DISEBUTKAN & DIPERBESAR SESUAI GAMBAR)
                    if (_isGpsActive && _currentPosition != null)
                      Marker(
                        point: _currentPosition!,
                        width: 320,
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Arah sudut pandang HP: Senter corong besar dengan kontur tegas
                            CustomPaint(
                              size: const Size(320, 320),
                              painter: HeadingConePainter(heading: _heading),
                            ),
                            // Lingkaran aura biru luar (diperbesar)
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1A73E8).withValues(alpha: 0.18),
                                border: Border.all(
                                  color: const Color(0xFF1A73E8).withValues(alpha: 0.38),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Cincin putih kokoh (diperbesar)
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            // Titik bulat biru utama (diperbesar)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1A73E8),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 2. TOMBOL SISI KANAN ATAS (Lapisan Map untuk switch standar / satelit)
          Positioned(
            top: MediaQuery.of(context).padding.top + 116,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSatellite = !_isSatellite;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isSatellite
                          ? 'Beralih ke tampilan Peta Satelit'
                          : 'Beralih ke tampilan Peta Standar',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC2E7FF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Color(0xFF001D35),
                  size: 22,
                ),
              ),
            ),
          ),

          // 3. TOMBOL SISI BAWAH KANAN (Tombol Putih GPS & Ruang Kosong Pengganti Tombol Biru)
          Positioned(
            right: 16,
            bottom: totalBottomHeight + 68,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _toggleGpsTracking,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isGpsActive ? Icons.my_location : Icons.location_disabled,
                      color: _isGpsActive ? const Color(0xFF1A73E8) : const Color(0xFF5F6368),
                      size: 24,
                    ),
                  ),
                ),
                // Ruang kosong untuk menggantikan tombol biru navigasi (agar posisi tombol GPS tetap sama persis seperti referensi)
                const SizedBox(height: 56 + 14),
              ],
            ),
          ),

          // 4. TOP FLOATING SEARCH BAR & CATEGORY PILLS
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Floating Search Bar dengan TextField interaktif untuk cari kota di Indonesia
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        // Logo Google Maps berwarna dari internet link
                        Image.network(
                          'https://img.icons8.com/color/96/google-maps-new.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.location_on,
                              color: Color(0xFFEA4335),
                              size: 24,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Interactive Search TextField
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            onSubmitted: (val) => _performAutoSearch(val),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1F1F1F),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari kota di Indonesia, SPBU...',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF5F6368),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Tombol Clear (X) jika ada teks
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF5F6368), size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                              setState(() {
                                _searchQuery = '';
                                _searchResultPoint = null;
                                _searchResultName = null;
                              });
                            },
                          ),
                        // Mic Icon di sisi paling kanan - memicu Voice Search Dialog
                        IconButton(
                          icon: const Icon(
                            Icons.mic,
                            color: Color(0xFF3C4043),
                            size: 24,
                          ),
                          onPressed: _openVoiceSearchDialog,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),

                  // Autocomplete Dropdown Hasil Pencarian Kota di Indonesia
                  if (_isSearching && _filteredSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: const BoxConstraints(maxHeight: 260),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _filteredSuggestions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 46),
                          itemBuilder: (context, index) {
                            final place = _filteredSuggestions[index];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: const Icon(Icons.location_on_outlined, color: Color(0xFF1A73E8), size: 20),
                              title: Text(
                                place['name'] as String,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                              subtitle: Text(
                                place['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF5F6368),
                                ),
                              ),
                              onTap: () {
                                _performAutoSearch(place['name'] as String);
                              },
                            );
                          },
                        ),
                      ),
                    ),

                  // Horizontal Category Pills (Terdekat, Mall, Parkir EV - tanpa Game)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildCategoryPill(
                          title: 'Terdekat',
                          icon: Icons.near_me_outlined,
                          isSelected: _selectedCategory == 'Terdekat',
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          title: 'Mall',
                          icon: Icons.storefront_outlined,
                          isSelected: _selectedCategory == 'Mall',
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          title: 'Parkir EV',
                          icon: Icons.electric_car_outlined,
                          isSelected: _selectedCategory == 'Parkir EV',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. BOTTOM SHEET DETAIL PARKIR (MUNCUL SETENGAH LAYAR SAAT TITIK DIKLIK)
          if (_selectedParking != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: totalBottomHeight,
              child: DraggableScrollableSheet(
                controller: _placeDetailsController,
                initialChildSize: 0.50, // Langsung muncul setengah layar
                minChildSize: 0.22,
                maxChildSize: 1.0,      // Ditarik ke atas menutup sampai searchbar
                snap: true,
                snapSizes: const [0.22, 0.50, 1.0],
                builder: (context, scrollController) {
                  final loc = _selectedParking!;
                  final List<String> photos = (loc['photos'] as List<dynamic>?)?.cast<String>() ?? [
                    'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
                    'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // AREA HEADER & DRAG HANDLE (Bisa diseret langsung dengan mouse atau jari sampai full 1.0 menutup searchbar)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            if (_placeDetailsController.isAttached) {
                              final screenHeight = MediaQuery.of(context).size.height;
                              final parentHeight = screenHeight - totalBottomHeight;
                              final deltaFraction = (details.primaryDelta ?? 0) / (parentHeight > 0 ? parentHeight : 1);
                              final newSize = (_placeDetailsController.size - deltaFraction).clamp(0.22, 1.0);
                              _placeDetailsController.jumpTo(newSize);
                            }
                          },
                          onVerticalDragEnd: (details) {
                            if (_placeDetailsController.isAttached) {
                              final currentSize = _placeDetailsController.size;
                              final velocity = details.primaryVelocity ?? 0;
                              double targetSize;
                              if (velocity < -200 || currentSize > 0.65) {
                                targetSize = 1.0; // Menutup sampai searchbar
                              } else if (velocity > 350 && currentSize < 0.40) {
                                _unselectParking();
                                return;
                              } else if (currentSize < 0.35) {
                                targetSize = 0.22;
                              } else {
                                targetSize = 0.50;
                              }
                              _placeDetailsController.animateTo(
                                targetSize,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Drag handle pill dengan kursor grab & tap untuk toggle 0.50 <-> 1.0
                              MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    if (_placeDetailsController.isAttached) {
                                      final targetSize = _placeDetailsController.size < 0.75 ? 1.0 : 0.50;
                                      _placeDetailsController.animateTo(
                                        targetSize,
                                        duration: const Duration(milliseconds: 280),
                                        curve: Curves.easeOutCubic,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC7C7C7),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // BARIS 1 MELAYANG (STICKY HEADER 1): Nama Parkiran di kiri, Tombol Silang (X) SAJA di kanan
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.fromLTRB(20, 0, 12, 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        loc['name'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F1F1F),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F3F4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Color(0xFF5F6368),
                                          size: 20,
                                        ),
                                      ),
                                      onPressed: _unselectParking,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // AREA KONTEN SCROLLABLE DENGAN 2 STICKY HEADERS
                        Expanded(
                          child: CustomScrollView(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // Area info yang akan ter-scroll naik dan hilang saat discroll ke atas
                              SliverToBoxAdapter(
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Rating Angka + Bintang + Jumlah Ulasan
                                      Row(
                                        children: [
                                          Text(
                                            '${loc['rating'] ?? 4.8} ',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1F1F1F),
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(5, (_) {
                                              return const Icon(
                                                Icons.star,
                                                color: Color(0xFFF4B400),
                                                size: 15,
                                              );
                                            }),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${loc['reviews'] ?? '340'})',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: const Color(0xFF5F6368),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),

                                      // Kategori & Biaya
                                      Text(
                                        '${loc['type']} • ${loc['price']} • Tersedia ${loc['slots']} slot',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF5F6368),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      // Jam Buka & Tutup
                                      Row(
                                        children: [
                                          Text(
                                            'Buka',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF137333),
                                            ),
                                          ),
                                          Text(
                                            ' • Tutup pukul 22.00 WIB',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: const Color(0xFF5F6368),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Baris Tombol Navigasi & Pesan Slot (1 Line Berbagi Sisi)
                                      Row(
                                        children: [
                                          // 1. Tombol Navigasi (ke ArNavigationScreen)
                                          Expanded(
                                            child: SizedBox(
                                              height: 46,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1C1D1F),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(23),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.navigation_rounded, size: 18),
                                                label: Text(
                                                  'Navigasi',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const ArNavigationScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // 2. Tombol Pesan Slot Parkir
                                          Expanded(
                                            child: SizedBox(
                                              height: 46,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1A73E8),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(23),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.local_parking, size: 18),
                                                label: Text(
                                                  'Pesan Slot',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const ParkingDetailScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // BARIS 2 MELAYANG (STICKY HEADER 2): Tab Bar (Ringkasan, Ulasan, Tentang)
                              // Saat discroll mentok, tombol ini berhenti melayang di bawah nama parkir!
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _SliverTabBarDelegate(
                                  child: _buildDetailTabBar(),
                                ),
                              ),

                              // KONTEN TAB: Background agak keruh (#F6F8FA)
                              SliverToBoxAdapter(
                                child: Container(
                                  color: const Color(0xFFF6F8FA),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: _buildSelectedTabContent(loc, photos),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // 5. DRAGGABLE BOTTOM SHEET ("Suasana lokal" saat tidak ada marker, atau Detail Parkir saat marker diklik)
          if (_selectedParking == null)
          // Bisa diseret dari collapsed (0.12) -> 1/4 layar (0.25) -> Fullscreen (1.0) menutup searchbar
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: totalBottomHeight,
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 1.0,
              snap: true,
              snapSizes: const [0.12, 0.25, 1.0],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Garis tanda seret (Drag handle) dengan interaksi geser & tap
                        MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              if (_sheetController.isAttached) {
                                final current = _sheetController.size;
                                final target = current < 0.20 ? 0.25 : (current < 0.70 ? 1.0 : 0.12);
                                _sheetController.animateTo(
                                  target,
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 10, bottom: 8),
                              alignment: Alignment.center,
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC7C7C7),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Header Row: Suasana lokal + Kotak Cuaca Dummy
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Suasana lokal',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                              // Kotak Cuaca Dummy
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('⛅ ', style: TextStyle(fontSize: 14)),
                                        Text(
                                          '32°',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1F1F1F),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF0B57D0),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ISPU',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF444746),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Rekomendasi Area Parkir Terdekat Berbasis Gambar Full + Gradien Putih
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rekomendasi Parkir Terdekat',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                              _SpinningLoadButton(
                                onRefresh: () async {
                                  await Future.delayed(const Duration(milliseconds: 900));
                                  if (mounted) {
                                    setState(() {
                                      // Simulasi pembaruan ketersediaan slot terkini
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          child: Column(
                            children: _parkingLocations.map((loc) {
                              final List<String> photos = (loc['photos'] as List<dynamic>?)?.cast<String>() ?? [
                                'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
                              ];
                              final String img = photos.first;
                              final String name = loc['name'] as String;
                              final String dist = (loc['distance'] as String?) ?? '350m';
                              final int slots = (loc['slots'] as int?) ?? 20;
                              final String subtitleText = '$dist • $slots slot tersedia';
                              final String price = loc['price'] as String;
                              final bool isEv = (loc['isEv'] as bool?) ?? false;
                              final String rating = (loc['rating'] ?? 4.7).toString();

                              return _buildParkingRecommendationCard(
                                title: name,
                                subtitle: subtitleText,
                                price: price,
                                imageUrl: img,
                                rating: rating,
                                isEv: isEv,
                                onExplore: () {
                                  _onParkingMarkerTapped(loc);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 800),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 6. BOTTOM NAVIGATION BAR (Jelajahi, Favorite, Home)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: totalBottomHeight,
              padding: EdgeInsets.only(bottom: bottomPadding),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E5E5), width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  // Tab 1: Jelajahi (Active style dengan pill background cyan)
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC2E7FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF001D35),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jelajahi',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF001D35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab 2: Favorite (Menggantikan "Anda", bookmark dengan tag merah)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Halaman Favorite'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.bookmark_outline,
                                color: Color(0xFF444746),
                                size: 24,
                              ),
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  width: 6.5,
                                  height: 6.5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFB3261E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Favorite',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444746),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab 3: Home (Menggantikan "Kontribusi", mengarah ke HomeScreen)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.home_outlined,
                            color: Color(0xFF444746),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Home',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444746),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builder untuk Tab Bar berbaris ke kanan (Ringkasan, Ulasan, Tentang)
  Widget _buildDetailTabBar() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          _buildDetailTabItem(index: 0, title: 'Ringkasan'),
          _buildDetailTabItem(index: 1, title: 'Ulasan'),
          _buildDetailTabItem(index: 2, title: 'Tentang'),
        ],
      ),
    );
  }

  Widget _buildDetailTabItem({required int index, required String title}) {
    final isSelected = _selectedDetailTab == index;
    // Hijau toska kegelapan
    const darkTeal = Color(0xFF0F766E);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDetailTab = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? darkTeal : const Color(0xFF3C4043),
                  ),
                ),
              ),
            ),
            // Garis highlight bawah jika tab aktif
            Container(
              height: 3,
              width: 72,
              decoration: BoxDecoration(
                color: isSelected ? darkTeal : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builder untuk isi konten tab (Background agak keruh #F6F8FA)
  Widget _buildSelectedTabContent(Map<String, dynamic> loc, List<String> photos) {
    if (_selectedDetailTab == 0) {
      // TAB 1: RINGKASAN
      return _buildTabRingkasan(loc, photos);
    } else if (_selectedDetailTab == 1) {
      // TAB 2: ULASAN
      return _buildTabUlasan(loc);
    } else {
      // TAB 3: TENTANG (Deskripsi parkiran + Fasilitas & Layanan)
      return _buildTabTentang(loc);
    }
  }

  // TAB RINGKASAN: Galeri Foto Admin & Ringkasan Spesifikasi
  Widget _buildTabRingkasan(Map<String, dynamic> loc, List<String> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Galeri Foto Area Parkir',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Admin Managed',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A73E8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Bingkai Foto Admin
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: photos.length + 1,
            itemBuilder: (context, photoIdx) {
              if (photoIdx == photos.length) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDADCE0), width: 1.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mode Admin: Unggah foto area parkir baru.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF0F766E), size: 32),
                        const SizedBox(height: 6),
                        Text(
                          '+ Tambah Foto',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
                        ),
                        Text('oleh Admin', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF5F6368))),
                      ],
                    ),
                  ),
                );
              }

              final photoUrl = photos[photoIdx];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE8F0FE),
                          child: const Icon(Icons.image, color: Color(0xFF1A73E8), size: 36),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Foto ${photoIdx + 1}',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Card Rincian Spesifikasi Parkir
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rincian Parkir', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F1F))),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.payments_outlined, 'Tarif Resmi', loc['price'] as String),
                const Divider(height: 18),
                _buildInfoRow(Icons.event_seat_outlined, 'Kapasitas', '${loc['slots']} Slot Tersedia'),
                const Divider(height: 18),
                _buildInfoRow(Icons.access_time, 'Operasional', loc['hours'] as String? ?? 'Buka • Tutup 22.00 WIB'),
                const Divider(height: 18),
                _buildInfoRow(Icons.qr_code, 'Metode Masuk', 'Tiket / Palang Otomatis & QRIS'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 600),
      ],
    );
  }

  // Modal untuk menulis ulasan baru dengan Topik Masukan hitam putih
  void _showAddReviewDialog(BuildContext context) {
    int rating = 5;
    final Set<String> selectedTopics = {'Akurasi Sensor ANPR'};
    final TextEditingController textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
            return Container(
              margin: EdgeInsets.only(bottom: bottomInset),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7C7C7),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Beri Ulasan Tempat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1C18),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Color(0xFF5F6368)),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bagikan pengalaman parkir Anda untuk membantu pengguna lain.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF5F6368),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rating Bintang
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          final isSelected = star <= rating;
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              size: 34,
                              color: isSelected ? const Color(0xFFF4B400) : const Color(0xFFE0E0E0),
                            ),
                            onPressed: () {
                              setModalState(() {
                                rating = star;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Topik Masukan (Style Hitam Putih persis FeedbackScreen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Topik Masukan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C1C18),
                          ),
                        ),
                        Text(
                          'Pilih satu atau lebih',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF76777B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _feedbackTopics.map((topic) {
                        final isSel = selectedTopics.contains(topic);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSel) {
                                selectedTopics.remove(topic);
                              } else {
                                selectedTopics.add(topic);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF020304) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSel ? const Color(0xFF020304) : const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1C1D1F).withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              topic,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSel ? Colors.white : const Color(0xFF1C1C18),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Input Text
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan deskripsi pengalaman parkir Anda...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9AA0A6)),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF020304), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF020304),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final text = textController.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan masukkan deskripsi ulasan terlebih dahulu.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _userReviews.insert(0, {
                              'name': 'Anda (Pengguna)',
                              'rating': rating,
                              'date': 'Baru saja',
                              'review': text,
                              'topics': selectedTopics.toList(),
                            });
                          });
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ulasan Anda berhasil ditambahkan!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'Kirim Ulasan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // TAB ULASAN: Rating Skor, Filter Topik Masukan, dan Daftar Ulasan Nyata
  Widget _buildTabUlasan(Map<String, dynamic> loc) {
    final filteredReviews = _selectedReviewFilterTopic == 'Semua'
        ? _userReviews
        : _userReviews.where((r) => ((r['topics'] as List<dynamic>?) ?? []).contains(_selectedReviewFilterTopic)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Ringkasan Rating & Skor
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                // Skor Besar
                Column(
                  children: [
                    Text(
                      '',
                      style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w800, color: const Color(0xFF1F1F1F)),
                    ),
                    Row(
                      children: List.generate(5, (_) => const Icon(Icons.star, color: Color(0xFFF4B400), size: 16)),
                    ),
                    const SizedBox(height: 4),
                    Text(' ulasan', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF5F6368))),
                  ],
                ),
                const SizedBox(width: 24),
                // Bar Rating 5 - 1
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar('5', 0.85),
                      _buildRatingBar('4', 0.10),
                      _buildRatingBar('3', 0.03),
                      _buildRatingBar('2', 0.01),
                      _buildRatingBar('1', 0.01),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Header Ulasan Pengunjung + Tombol Tulis Ulasan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan Pengunjung',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showAddReviewDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020304),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.rate_review_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '+ Tulis Ulasan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
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
          const SizedBox(height: 10),

          // FILTER BAR TOPIK MASUKAN (Style Hitam Putih)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Semua',
                ..._feedbackTopics,
              ].map((topic) {
                final isSelected = _selectedReviewFilterTopic == topic;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedReviewFilterTopic = topic;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF020304) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF020304) : const Color(0xFFE5E5E5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        topic,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF1C1C18),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Kartu Ulasan Nyata
          if (filteredReviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Belum ada ulasan dengan topik ini.',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF70757A)),
                ),
              ),
            )
          else
            ...filteredReviews.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReviewCard(
                  name: r['name'] as String,
                  rating: r['rating'] as int,
                  date: r['date'] as String,
                  review: r['review'] as String,
                  topics: ((r['topics'] as List<dynamic>?) ?? []).cast<String>(),
                ),
              );
            }),

          const SizedBox(height: 600),
        ],
      ),
    );
  }

  // TAB TENTANG: Deskripsi Parkiran + Fasilitas & Layanan
  Widget _buildTabTentang(Map<String, dynamic> loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Deskripsi Parkiran
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tentang Parkiran', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F1F))),
                const SizedBox(height: 8),
                Text(
                  '${loc['name']} adalah fasilitas parkir pintar modern yang terintegrasi langsung dengan sistem navigasi mobile. Memiliki area luas dengan proteksi keamanan 24 jam, kemudahan akses keluar masuk otomatis, dan fasilitas penunjang ramah lingkungan untuk seluruh pengendara.',
                  style: GoogleFonts.inter(fontSize: 13.5, height: 1.5, color: const Color(0xFF444746)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card Fasilitas & Layanan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fasilitas & Layanan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F1F))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFacilityBadge(Icons.security, 'CCTV 24 Jam'),
                    _buildFacilityBadge(Icons.electric_car, 'Stasiun EV'),
                    _buildFacilityBadge(Icons.roofing, 'Atap Tertutup'),
                    _buildFacilityBadge(Icons.sensor_door, 'Palang Otomatis'),
                    _buildFacilityBadge(Icons.qr_code_2, 'Cashless / QRIS'),
                    _buildFacilityBadge(Icons.shield, 'Security 24 Jam'),
                    _buildFacilityBadge(Icons.lightbulb_outline, 'Penerangan LED'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 600),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F766E)),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF5F6368))),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1F1F1F))),
      ],
    );
  }

  Widget _buildRatingBar(String star, double ratio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(star, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF5F6368))),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF4B400)),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRecommendationCard({
    required String title,
    required String subtitle,
    required String price,
    required String imageUrl,
    String? rating = '4.8',
    bool isEv = false,
    VoidCallback? onExplore,
  }) {
    return GestureDetector(
      onTap: onExplore,
      child: Container(
        height: 360,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. FULL BACKGROUND IMAGE (Menampilkan mobil & area parkir dengan jelas)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(Icons.local_parking, size: 52, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),

              // 2. BADGE KATEGORI DI POJOK KANAN ATAS
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: isEv ? const Color(0xFF0F766E).withValues(alpha: 0.94) : Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isEv ? Icons.electric_car : Icons.local_parking, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        isEv ? 'Khusus EV' : 'Mobil & Motor',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. GRADIEN PUTIH LUNTUR PUDAR (Hanya di ~38% sisi bawah, menyisakan >62% foto mobil jernih tanpa blur)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.98),
                        Colors.white.withValues(alpha: 0.75),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.16, 0.26, 0.34, 0.40],
                    ),
                  ),
                ),
              ),

              // 4. KONTEN INFORMASI & TOMBOL EXPLORE DI SISI BAWAH PUTIH
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Baris Nama Parkiran & Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1C1D1F),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFF4B400), size: 15),
                                const SizedBox(width: 2),
                                Text(
                                  rating,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F1F1F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Keterangan Jarak & Slot
                      Row(
                        children: [
                          const Icon(Icons.near_me_outlined, size: 13, color: Color(0xFF5F6368)),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5F6368),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Baris Tarif Parkir & Tombol Explore
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Keterangan Harga
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TARIF PARKIR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF76777B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                price,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                            ],
                          ),
                          // Tombol Explore
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C1D1F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.explore_rounded, size: 16),
                            label: Text(
                              'Explore',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: onExplore,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String date,
    required String review,
    List<String> topics = const [],
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0] : 'U',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF0F766E)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1F1F1F))),
                  Text(date, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF70757A))),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(rating, (_) => const Icon(Icons.star, color: Color(0xFFF4B400), size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review,
            style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: const Color(0xFF3C4043)),
          ),

          // BAGIAN TOPIK MASUKAN (Tergantung opsi yang diklik user saat ulasan, style hitam putih elegan)
          if (topics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F3F4), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Topik Masukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C18),
                        ),
                      ),
                      Text(
                        ' dipilih',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF76777B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: topics.map((topic) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020304), // Hitam pekat persis seperti di FeedbackScreen
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C1D1F).withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              topic,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFacilityBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1A73E8)),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3C4043),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onCategoryTapped(title),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0FE) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A73E8) : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF3C4043),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter untuk arah sudut pandang HP (Senter Tipis Bentuk Corong / Flashlight Cone)
class HeadingConePainter extends CustomPainter {
  final double heading; // Compass orientation in radians

  HeadingConePainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Rotate towards compass heading (offset so 0 is pointing upward)
    canvas.rotate(heading - (pi / 2));

    // Ukuran diperbesar sesuai gambar referensi user
    const double radius = 145.0; // Panjang corong diperbesar ~145px
    const double sweep = 65.0 * pi / 180.0; // Sudut bukaan corong ~65 derajat
    const double halfSweep = sweep / 2;

    // Gradien corong senter pandang Google Maps (terang di dekat titik, memudar ke ujung)
    final beamPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        radius,
        [
          const Color(0x994285F4),
          const Color(0x664285F4),
          const Color(0x334285F4),
          const Color(0x084285F4),
          Colors.transparent,
        ],
        [0.0, 0.35, 0.70, 0.92, 1.0],
      );

    final path = Path();
    path.moveTo(0, 0);
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      -halfSweep,
      sweep,
      false,
    );
    path.close();

    // Gambar isi corong senter
    canvas.drawPath(path, beamPaint);

    // Gambar garis kontur tepi corong tegas persis seperti gambar coretan orange user
    final borderPaint = Paint()
      ..color = const Color(0x994285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HeadingConePainter oldDelegate) =>
      oldDelegate.heading != heading;
}


/// Widget Modal Pencarian Suara Google Assistant / Google Maps Style
class VoiceSearchBottomSheet extends StatefulWidget {
  final Function(String query) onQuerySelected;

  const VoiceSearchBottomSheet({super.key, required this.onQuerySelected});

  @override
  State<VoiceSearchBottomSheet> createState() => _VoiceSearchBottomSheetState();
}

class _VoiceSearchBottomSheetState extends State<VoiceSearchBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String _statusText = 'Mendengarkan...';
  String _recognizedText = '';
  bool _isProcessing = false;

  final List<String> _quickSuggestions = [
    'Surabaya',
    'Grand Indonesia',
    'Bandung',
    'Malang',
    'Semarang',
    'SPBU Terdekat',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _startListening();
  }

  Future<void> _startListening() async {
    try {
      final text = await recordSpeech();
      if (!mounted) return;
      if (text != null && text.trim().isNotEmpty) {
        setState(() {
          _recognizedText = text.trim();
          _statusText = 'Terdengar: "$_recognizedText"';
          _isProcessing = true;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.pop(context);
          widget.onQuerySelected(_recognizedText);
        }
      }
    } catch (_) {}
  }

  void _selectSuggestion(String suggestion) {
    if (_isProcessing) return;
    setState(() {
      _recognizedText = suggestion;
      _statusText = 'Dipilih: "$suggestion"';
      _isProcessing = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onQuerySelected(suggestion);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    'https://img.icons8.com/color/96/google-maps-new.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.mic,
                      color: Color(0xFF1A73E8),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pencarian Suara',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Animated Pulsing Mic with Sound Waves
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple wave
                  Container(
                    width: 96 * _scaleAnimation.value,
                    height: 96 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                    ),
                  ),
                  // Middle ripple wave
                  Container(
                    width: 80 * _scaleAnimation.value,
                    height: 80 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A73E8).withValues(alpha: 0.22),
                    ),
                  ),
                  // Inner solid button
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF1A73E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x401A73E8),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Status & Instruction Text
          Text(
            _statusText,
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Katakan lokasi tujuan Anda, misalnya "Surabaya"',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF5F6368),
            ),
          ),
          const SizedBox(height: 20),

          // Suggestion Chips (Bisa diklik langsung untuk pengujian instan)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Atau pilih contoh suara:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF70757A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSuggestions.map((suggestion) {
              return ActionChip(
                backgroundColor: const Color(0xFFF1F3F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
                ),
                avatar: const Icon(
                  Icons.volume_up_outlined,
                  size: 16,
                  color: Color(0xFF1A73E8),
                ),
                label: Text(
                  suggestion,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                onPressed: () => _selectSuggestion(suggestion),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


/// Sliver Header Delegate untuk Tab Bar yang melayang (Sticky Header baris 2)
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) => true;
}


/// Tombol refresh / load dengan ikon yang berputar halus saat diklik
class _SpinningLoadButton extends StatefulWidget {
  final Future<void> Function()? onRefresh;
  const _SpinningLoadButton({this.onRefresh});

  @override
  State<_SpinningLoadButton> createState() => _SpinningLoadButtonState();
}

class _SpinningLoadButtonState extends State<_SpinningLoadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isRotating) return;
    setState(() => _isRotating = true);
    _rotationController.repeat();

    try {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      } else {
        await Future.delayed(const Duration(milliseconds: 900));
      }
    } finally {
      if (mounted) {
        _rotationController.stop();
        _rotationController.reset();
        setState(() => _isRotating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _handleTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: RotationTransition(
            turns: _rotationController,
            child: const Icon(
              Icons.refresh_rounded,
              size: 22,
              color: Color(0xFF5F6368),
            ),
          ),
        ),
      ),
    );
  }
}
