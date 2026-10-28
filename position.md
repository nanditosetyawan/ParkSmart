# Panduan Lengkap Letak & Posisi Pengubahan Warna Aplikasi (ParkSmart ID)

Dokumen ini memetakan seluruh file dan nomor baris kode untuk mengubah warna **Background**, **TopBar / Header**, dan **Bottom Dock Navigation** pada sisi **User** maupun **Admin (Super Admin, Operasional, Finance, CS)**.

---

## 📌 1. Pertanyaan Penting: Apakah 1x Ubah di User Semua Halaman Berubah?

> **Jawaban: SEBAGIAN BESAR YA, NAMUN ADA HALAMAN INDEPENDEN.**
>
> 1. **Halaman Global / Terikat Sistem Tema**:
>    Halaman utama seperti `HomeScreen`, `ProfileScreen`, `AiAssistantScreen`, serta komponen dialog dan kartu **otomatis berubah** jika Anda mengubah token global di `lib/theme/app_colors.dart` dan `lib/core/services/theme_service.dart`.
> 2. **Halaman Independen (Hardcoded)**:
>    Beberapa halaman (seperti `HistoryScreen`, `ActiveSessionScreen`, `SessionCheckoutScreen`, `ExtendSessionScreen`, `CheckinScreen`, `SplashScreen`, dan `LoginScreen`) memiliki warna background sendiri yang ditulis langsung (*hardcoded*) di filenya masing-masing. Jika ingin warnanya seragam total, halaman-halaman independen ini **perlu diubah manual sesuai baris kode yang tertera di bawah**.

---

## 📱 2. Posisi Pengubahan Warna Tampilan User (Pengguna)

### A. Background Global User (Pengaruh Terluas)
Jika ingin mengubah tema warna dasar seluruh aplikasi pengguna:

| No | File | Baris | Kode Warna Saat Ini | Keterangan |
|---|---|---|---|---|
| 1 | [lib/theme/app_colors.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/theme/app_colors.dart#L10-L12) | **Line 11** | `0xFF111418` | Background User saat **Dark Mode** |
| | | **Line 12** | `0xFFF6F3EC` | Background User saat **Light Mode** (Cream) |
| | | **Line 19** | `0xFF1E232B` | Warna Kartu (Card) saat Dark Mode |
| | | **Line 20** | `0xFFFFFFFF` | Warna Kartu (Card) saat Light Mode (Putih) |
| 2 | [lib/core/services/theme_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/theme_service.dart#L18-L23) | **Line 19** | `0xFF111418` | `bg` ThemeService Dark Mode |
| | | **Line 20** | `0xFFFCF9F2` | `bg` ThemeService Light Mode |
| | | **Line 27** | `0xFF1E232B` | `card` ThemeService Dark Mode |
| | | **Line 28** | `Colors.white` | `card` ThemeService Light Mode |
| 3 | [lib/theme/app_theme.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/theme/app_theme.dart#L10-L12) | **Line 11** | `0xFFFCF9F2` | `scaffoldBackgroundColor` Flutter Light Mode |
| | | **Line 97** | `0xFF111418` | `scaffoldBackgroundColor` Flutter Dark Mode |

---

### B. Bilah Navigasi Melayang Bawah (Bottom Dock Navigation)
File pengatur bilah navigasi bawah user:
📁 [lib/widgets/bottom_dock_navigation.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/widgets/bottom_dock_navigation.dart)

| Bagian | Baris | Kode Warna Saat Ini | Keterangan |
|---|---|---|---|
| **Latar Belakang Dock** | **Line 24** | `const Color(0xFF1C1D1F)` | Warna badan container dock melayang (Charcoal Gelap) |
| **Lingkaran Tab Aktif** | **Line 92** | `const Color(0xFFD67B5A)` | Warna lingkaran oranye terracotta penanda tab yang aktif |
| **Tombol Kamera Scan** | **Line 54** | `Colors.white.withValues(alpha: 0.1)` | Latar tombol pemindai kamera di tengah dock |
| **Ikon Tidak Aktif** | **Line 99** | `Colors.white.withValues(alpha: 0.55)` | Warna ikon dock yang sedang tidak dipilih |

---

### C. TopBar / Header User

| Halaman | File | Baris | Elemen / Keterangan |
|---|---|---|---|
| **Home Screen Header** | [lib/features/home/home_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/home/home_screen.dart#L526) | **Line 526** | Kapsul status GPS/Lokasi: `AppColors.surfaceCard` |
| **Profile Screen TopBar** | [lib/features/profile/profile_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/profile/profile_screen.dart#L96-L101) | **Line 97** | Header bar Profil: border `theme.border` & latar `theme.bg` |
| **AI Assistant TopBar** | [lib/features/ai_assistant/ai_assistant_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/ai_assistant/ai_assistant_screen.dart#L458-L460) | **Line 459** | AppBar AI Assistant: `backgroundColor: theme.bg` |
| **Explore Map TopBar** | [lib/features/map/explore_map_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/map/explore_map_screen.dart#L1040-L1060) | **Line 1045** | Search Bar melayang di atas peta |

---

### D. Halaman Independen User (Wajib Diedit Manual Jika Ingin Seragam)

Halaman-halaman berikut tidak sepenuhnya mengambil dari `AppColors.background` global, melainkan memiliki kode warna tersendiri:

| No | Halaman | File | Baris | Kode Warna & Catatan |
|---|---|---|---|---|
| 1 | **Riwayat Tiket** | [lib/features/history/history_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/history/history_screen.dart#L39) | **Line 39** | `backgroundColor: isDark ? theme.bg : const Color(0xFFFAF7F2)` |
| 2 | **Sesi Aktif Parkir** | [lib/features/session/active_session_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/active_session_screen.dart#L149) | **Line 149** | `backgroundColor: isDark ? theme.bg : const Color(0xFFFAF7F2)` |
| 3 | **Checkout Parkir** | [lib/features/session/session_checkout_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/session_checkout_screen.dart#L134) | **Line 134** | `backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2)` |
| 4 | **Perpanjang Sesi** | [lib/features/session/extend_session_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/extend_session_screen.dart#L42) | **Line 42** | `backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2)` |
| 5 | **Konfirmasi Check-In** | [lib/features/session/checkin_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/checkin_screen.dart#L174) | **Line 174** | `backgroundColor: isDark ? theme.bg : const Color(0xFFF9F9F9)` |
| 6 | **Splash Screen Awal** | [lib/features/splash/splash_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/splash/splash_screen.dart#L128) | **Line 128** | `backgroundColor: const Color(0xFF070B12)` (Obsidian Hitam Pekat) |
| 7 | **Halaman Login** | [lib/features/auth/login_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/auth/login_screen.dart#L656) | **Line 656** | `backgroundColor: Colors.black` + Gambar latar `assets/images/backgroundLogin.jpg` |
| 8 | **Scanner Plat / OCR** | [lib/features/vehicle/custom_camera_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/vehicle/custom_camera_screen.dart#L157) | **Line 157** | `backgroundColor: const Color(0xFF141518)` (Hitam Kamera) |
| 9 | **Peta Parkir (Map)** | [lib/features/map/explore_map_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/map/explore_map_screen.dart#L1020) | **Line 1020** | `backgroundColor: isDark ? theme.bg : Colors.white` |

---

## 🛡️ 3. Posisi Pengubahan Warna Tampilan Admin (4 Divisi)

Keempat dashboard admin dirancang seragam menggunakan standar desain dashboard profesional:
- **Background Utama**: `const Color(0xFFF9F9F9)` (Abu-abu sangat terang dan bersih)
- **TopBar / AppBar**: `Colors.white` (Putih bersih)

### A. Super Admin Dashboard
📁 [lib/features/admin/super_admin/admin_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/super_admin/admin_dashboard_screen.dart)

| Elemen | Baris | Kode Warna Saat Ini | Keterangan |
|---|---|---|---|
| **Background Dashboard** | **Line 654** | `const Color(0xFFF9F9F9)` | Warna latar belakang seluruh Scaffold Super Admin |
| **TopBar / AppBar** | **Line 661** | `Colors.white` | Warna bilah header atas Super Admin |
| **Tombol 'P' Drawer** | **Line 674** | `const Color(0xFF1C1D1F)` | Warna kotak logo "P" pembuka menu samping (drawer) |
| **Aksen Utama Divisi** | **Line 763** | `const Color(0xFF6D28D9)` | Warna aksen ungu Super Admin |

---

### B. Admin Operasional Dashboard
📁 [lib/features/admin/operations/admin_operations_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/operations/admin_operations_dashboard_screen.dart)

| Elemen | Baris | Kode Warna Saat Ini | Keterangan |
|---|---|---|---|
| **Background Dashboard** | **Line 157** | `const Color(0xFFF9F9F9)` | Warna latar belakang seluruh Scaffold Admin Operasional |
| **TopBar / AppBar** | **Line 162** | `Colors.white` | Warna bilah header atas Admin Operasional |
| **Tombol 'P' Drawer** | **Line 171** | `const Color(0xFF114177)` | Warna aksen biru navy pembuka drawer operasional |
| **Aksen Status Aktif** | **Line 1021** | `const Color(0xFF17A18A)` | Warna hijau toska status aktif |

---

### C. Admin Finance Dashboard
📁 [lib/features/admin/finance/admin_finance_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/finance/admin_finance_dashboard_screen.dart)

| Elemen | Baris | Kode Warna Saat Ini | Keterangan |
|---|---|---|---|
| **Background Dashboard** | **Line 94** | `const Color(0xFFF9F9F9)` | Warna latar belakang seluruh Scaffold Admin Finance |
| **TopBar / AppBar** | **Line 99** | `Colors.white` | Warna bilah header atas Admin Finance |
| **Tombol Wallet Drawer** | **Line 111** | `const Color(0xFFD97706)` | Warna amber/emas ikon dompet pembuka drawer finance |
| **Aksen Badge Saldo** | **Line 797** | `const Color(0xFFD97706)` | Warna amber pendapatan & transaksi |

---

### D. Admin Customer Service (CS) Dashboard
📁 [lib/features/admin/cs/admin_cs_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/cs/admin_cs_dashboard_screen.dart)

| Elemen | Baris | Kode Warna Saat Ini | Keterangan |
|---|---|---|---|
| **Background Dashboard** | **Line 101** | `const Color(0xFFF9F9F9)` | Warna latar belakang seluruh Scaffold Admin CS |
| **TopBar / AppBar** | **Line 106** | `Colors.white` | Warna bilah header atas Admin CS |
| **Tombol CS Drawer** | **Line 118** | `const Color(0xFF0D9488)` | Warna teal/toska ikon CS pembuka drawer |
| **Aksen Badge Rating** | **Line 172** | `const Color(0xFF0D9488)` | Warna aksen toska feedback & komplain |

---

## 🎯 4. Rekomendasi Format Kode Warna di Flutter

Saat mengganti kode warna di file Dart, gunakan format ARGB Hexadecimal:
- Format: `const Color(0xFFRRGGBB)`
- Contoh:
  - Putih bersih: `const Color(0xFFFFFFFF)`
  - Hitam pekat: `const Color(0xFF000000)`
  - Abu-abu netral: `const Color(0xFFF3F4F6)`
  - Biru modern: `const Color(0xFF1E40AF)`
  - Hijau emerald: `const Color(0xFF10B981)`
