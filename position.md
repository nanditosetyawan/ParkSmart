# 🧭 ParkSmart ID — Cheat Sheet & Peta Posisi Kode Lengkap (Untuk Ujian / Presentasi)

> **Dokumen Panduan Cepat (Quick Navigation)**: Dirancang khusus agar Anda dapat mencari file target dan baris kodenya secara instan menggunakan **`Ctrl + F`** saat ditanya oleh dosen penguji.
>
> 🔍 **Keyword Pencarian Cepat**: `[TESTING TIMER]`, `[API]`, `[BOOKING]`, `[CURRENCY]`, `[JAM]`, `[BLOCKCHAIN]`, `[ENKRIPSI]`, `[BIOMETRIK]`, `[SUPABASE]`, `[LOCAL STORAGE]`, `[WARNA]`.

---

### 🌟 1. Jawaban Inti & Konsep Filosofi (Analog Alarm vs Stopwatch):
* **Sistem TIDAK Pernah Ter-reset saat Layar Di-refresh!**
* **Sistem TIDAK Pernah Ter-reset saat HP Mati / Restart / Aplikasi Ditutup!**
* **Alasannya**: Sistem timer ParkSmart ID bekerja seperti **"Alarm Jam Beker" (Timestamp Absolut)**, BUKAN seperti **"Stopwatch" (Detik Relatif)**:
  * Database **tidak** menyimpan teks angka durasi seperti `60 menit` atau `3600 detik`.
  * Database menyimpan **titik jam target kapan tiket selesai** (`expected_check_out_time`, misal: `2026-10-29 21:01:00`).
  * Aplikasi di HP hanya menghitung selisih matematis:
    $$\mathbf{\text{Sisa Detik}} = \mathbf{\text{Target Jam Selesai}} - \mathbf{\text{Jam Sekarang}}$$

---

### 💻 2. Peta Alamat File & Nomor Baris Kode Perhitungan Timer:

| Komponen / Aksi | File Target | Nomor Baris | Potongan Kode Kunci & Logika |
|---|---|---|---|
| **1. Pembacaan Target Waktu dari Database** | [lib/features/session/backend/active_session_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/backend/active_session_backend.dart#L132) | **Line 132** | `_expectedCheckOutTime = DateTime.tryParse(session['expected_check_out_time'].toString())?.toLocal();`<br>*(Membaca timestamp target absolut dari Supabase)* |
| **2. Rumus Perhitungan Selisih Detik (RAM)** | [lib/features/session/active_session_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/active_session_screen.dart#L74) | **Line 74** | `final diff = checkout.difference(DateTime.now()).inSeconds;`<br>`_remainingSeconds = diff > 0 ? diff : 0;`<br>*(Menghitung selisih waktu di RAM lokal tanpa network call)* |
| **3. Loop Ticking 1 Detik Sekali** | [lib/features/session/active_session_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/active_session_screen.dart#L69) | **Line 69** | `_timer = Timer.periodic(const Duration(seconds: 1), (timer) { ... });` |
| **4. Fitur Tarik Layar ke Bawah (Pull-to-Refresh)** | [lib/features/session/active_session_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/active_session_screen.dart#L339) | **Line 339** | `RefreshIndicator(onRefresh: () async { await ActiveSessionBackend.instance.fetchActiveSession(); ... })`<br>*(Tarik layar ke bawah untuk reload target waktu baru)* |
| **5. Pemicu Waktu Habis (Overtime / Denda)** | [lib/features/session/active_session_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/active_session_screen.dart#L95) | **Line 95** | `void _onSessionExpired() async { ... }`<br>*(Aktif otomatis saat sisa detik == 0, membuka alur denda)* |

---

### 🧪 3. Query SQL Injeksi 1 Menit (Untuk Demo di Depan Dosen):

Jalankan query 1 baris ini di **Supabase Dashboard > SQL Editor**:

```sql
-- [QUERY INJEKSI TESTING DOSEN: SET BATAS WAKTU TIKET JADI 1 MENIT DARI SEKARANG]
UPDATE public.parking_sessions
SET expected_check_out_time = NOW() + INTERVAL '1 minute'
WHERE status = 'active';
```

---

### 🚀 4. Skenario Simulasi & Pembuktian Nyata:

#### A. Skenario Di-refresh (Misal dari 1 menit sudah jalan 40 detik, sisa 20 detik):
1. Misal jam dinding: `21:00:00`. Target di database terkunci: `21:01:00`.
2. Setelah 40 detik, jam menunjukkan `21:00:40` (sisa 20 detik di layar).
3. Anda **tarik layar ke bawah (Pull-to-Refresh)**:
   * Aplikasi membaca database: nilai di DB tetap `21:01:00` (tidak berubah).
   * Aplikasi menghitung: `21:01:00 - 21:00:40` = **20 DETIK**.
   * **Hasil**: Layar tetap di 20 detik dan terus jalan ke 19, 18, 17... **TIDAK TERESET KE 1 MENIT!**

#### B. Skenario HP Mati / Force Close:
1. Saat sisa waktu 40 detik, HP mati atau aplikasi ditutup paksa.
2. 30 detik kemudian HP dinyalakan kembali, dan aplikasi dibuka:
   * Aplikasi membaca target dari DB: `21:01:00`.
   * Jam HP sekarang: `21:00:50`.
   * Rumus: `21:01:00 - 21:00:50` = **10 DETIK**.
   * **Hasil**: Layar langsung melanjutkan sisa waktu nyata **10 detik**!
3. Jika HP baru dibuka setelah jam `21:02:00` (lewat target), rumus bernilai negatif ($\le 0$) dan layar seketika masuk ke status **Tiket Kedaluwarsa / Denda Overtime**!

<br>
<br>

---
---

<br>
<br>

## 📑 Daftar Isi Cepat (Index)
1. 🌐 [Daftar Seluruh API Eksternal & Internal](#1--daftar-seluruh-api-eksternal--internal-api)
2. 🎫 [Function Pemesanan Tiket Booking & Pembayaran](#2--function-pemesanan-tiket-booking--pembayaran-booking)
3. 💱 [Function Currency (Mata Uang & Kurs Real-Time)](#3--function-currency-mata-uang--kurs-real-time-currency)
4. ⏰ [Jam Real-Time di Super Admin (Multi-Zona Waktu)](#4--jam-real-time-di-super-admin-multi-zona-waktu-jam)
5. ⛓️ [Blockchain Ethereum Sepolia & Smart Contract](#5--blockchain-ethereum-sepolia--smart-contract-blockchain)
6. 🔐 [Enkripsi Password (Salted SHA-256)](#6--enkripsi-password-salted-sha-256-enkripsi)
7. 👆 [Biometrik (Sidik Jari, Face ID, dan Transaksi PIN)](#7--biometrik-sidik-jari-face-id-dan-transaksi-pin-biometrik)
8. ⚡ [Pemanggilan Supabase: SDK Query vs Direct REST API](#8--pemanggilan-supabase-sdk-query-vs-direct-rest-api-supabase)
9. 💾 [Sistem Penyimpanan Lokal (Local Storage & Dual-Layer Cache)](#9--sistem-penyimpanan-lokal-local-storage--dual-layer-cache-local-storage)
10. 🎨 [Peta Pengubahan Warna Aplikasi (Background, TopBar, Dock)](#10--peta-pengubahan-warna-tampilan-aplikasi-warna)

---

## 🌐 1. Daftar Seluruh API Eksternal & Internal `[API]`

Berikut adalah pemetaan seluruh API yang digunakan di aplikasi ParkSmart ID beserta endpoint, cara ambil data, file implementasi, dan baris kodenya:

| No | Nama API & Layanan | Endpoint / URL | Jenis / Protokol | File Target | Baris Kode | Cara Ambil Data & Keterangan |
|---|---|---|---|---|---|---|
| **1** | **Groq Cloud AI (LPU™)** | `https://api.groq.com/openai/v1/chat/completions` | HTTP POST (OpenAI JSON) | [lib/features/admin/super_admin/backend/admin_ai_config_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/super_admin/backend/admin_ai_config_backend.dart#L121) | **Line 121** | Mengirim prompt JSON dengan header `Authorization: Bearer <key>`. Digunakan untuk uji koneksi live AI dan asisten pintar. |
| **2** | **AI Inference Default Endpoint** | `https://api.groq.com/openai/v1/chat/completions` | REST Config | [lib/core/services/ai_config_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/ai_config_service.dart#L30) | **Line 30** | Konstanta endpoint default untuk model LLM Qwen 2.5 / Llama 3. |
| **3** | **Kurs Mata Uang (Exchange Rates)** | `https://open.er-api.com/v6/latest/IDR` | HTTP GET JSON (Publik, Free) | [lib/core/services/currency_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/currency_service.dart#L143) | **Line 143** | Mengambil kurs valas terkini terhadap IDR (USD, EUR, SGD, MYR, JPY) tanpa API Key, lalu di-cache 12 jam. |
| **4** | **IP Publik Pengguna (Ipify)** | `https://api.ipify.org?format=json` | HTTP GET JSON (Publik, Free) | [lib/core/services/client_info_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/client_info_service.dart#L124) | **Line 124** | Mengambil alamat IP publik perangkat pengguna untuk keperluan audit trail keamanan login & transaksi. |
| **5** | **Geolocation Kota & ISP (IP-API)** | `http://ip-api.com/json/` | HTTP GET JSON (Publik, Free) | [lib/core/services/client_info_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/client_info_service.dart#L147) | **Line 147** | Mendeteksi otomatis kota, negara, dan nama ISP penyedia jaringan pengguna berdasarkan alamat IP. |
| **6** | **Cuaca Real-Time (Open-Meteo)** | `https://api.open-meteo.com/v1/forecast` | HTTP GET JSON (Publik, Free) | [lib/features/map/explore_map_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/map/explore_map_screen.dart#L568) | **Line 568** | Mengirim parameter lat/lng koordinat parkir, mengambil suhu (°C) dan kode cuaca (Cerah, Berawan, Hujan) untuk ditampilkan di peta. |
| **7** | **Rute Navigasi Jalan (OSRM)** | `https://router.project-osrm.org/route/v1/driving/` | HTTP GET JSON (OSRM Engine) | [lib/features/navigation/backend/ar_navigation_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/navigation/backend/ar_navigation_backend.dart#L81) | **Line 81** | Mengirim titik koordinat pengguna & tujuan parkir. Menghasilkan polyline rute jalan, jarak meter, dan estimasi waktu berkendara. |
| **8** | **Blockchain Node Sepolia RPC** | `https://ethereum-sepolia-rpc.publicnode.com` | Web3 JSON-RPC over HTTP | [lib/ui/layanan/layanan_blockchain.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/ui/layanan/layanan_blockchain.dart#L25) | **Line 25, 59** | Node RPC Ethereum Sepolia Testnet untuk interaksi read/write smart contract keanggotaan parkir on-chain. |
| **9** | **Supabase Direct PostgREST API** | `$cleanUrl/rest/v1/system_settings?...` | HTTP GET REST (Direct Header) | [lib/core/services/ai_config_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/ai_config_service.dart#L93) | **Line 93** | Memanggil API REST Supabase secara langsung menggunakan header `apikey` & `Authorization: Bearer` (tanpa SDK). |
| **10** | **Supabase Background REST API** | `$supabaseUrl/rest/v1/system_notifications?...` | HTTP GET REST (Isolate Background) | [lib/core/services/parking_notification_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/parking_notification_service.dart#L555) | **Line 555** | Memeriksa notifikasi darurat dari background isolate tanpa bergantung pada instance Flutter SDK. |
| **11** | **Peta Satelit ArcGIS Tile API** | `https://server.arcgisonline.com/ArcGIS/rest/...` | Raster Tile HTTP Image | [lib/features/map/explore_map_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/map/explore_map_screen.dart#L1065) | **Line 1065** | Tile satelit presisi tinggi untuk tampilan peta udara (Satellite Layer). |
| **12** | **Peta OpenStreetMap Tile API** | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` | Vector/Raster Tile HTTP | [lib/features/map/explore_map_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/map/explore_map_screen.dart#L1066) | **Line 1066** | Tile peta jalanan standar OpenStreetMap untuk navigasi dan peta utama. |

---

## 🎫 2. Function Pemesanan Tiket Booking & Pembayaran `[BOOKING]`

Alur pemesanan tiket di ParkSmart ID dibagi menjadi 2 tahap: **Reservasi Sementara (Hold Slot 2:59 menit)** dan **Finalisasi Pembayaran (Konfirmasi & Bayar)**.

| Alur / Operasi | File Target | Baris Kode | Function / Kode | Keterangan & Cara Kerja |
|---|---|---|---|---|
| **1. Buat Reservasi Sementara (Hold Slot)** | [lib/features/checkout/backend/checkout_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/checkout/backend/checkout_backend.dart#L351) | **Line 351** | `createOrUpdateHoldBooking()` | Melakukan `INSERT` ke tabel `public.bookings` dengan status `payment_status: 'unpaid'`, mengunci slot menjadi `reserved`, dan mengaktifkan timer hold 2 menit 59 detik. |
| **2. Pembuatan Tiket Baru (Hold Baru)** | [lib/features/checkout/backend/checkout_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/checkout/backend/checkout_backend.dart#L460) | **Line 460** | `createHoldBooking()` | Insert data pemesanan baru (`booking_code`, `plate_number`, `duration_hours`, `total_price`, `start_time`, `end_time`). |
| **3. Finalisasi & Eksekusi Pembayaran** | [lib/features/checkout/backend/checkout_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/checkout/backend/checkout_backend.dart#L844) | **Line 844** | `markBookingAsPaid()` | 1. Memeriksa validitas waktu hold 2:59 menit.<br>2. Memotong saldo wallet (`users.wallet_balance`) jika menggunakan ParkSmart Pay.<br>3. Mengubah status booking jadi `paid` & slot jadi `occupied`.<br>4. Mencatat riwayat ke tabel `public.payments`. |
| **4. Pembatalan Slot Saat Waktu Habis** | [lib/features/checkout/backend/checkout_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/checkout/backend/checkout_backend.dart#L500) | **Line 500** | `cancelHoldBooking()` | Melepas slot kembali menjadi `available` jika pengguna membatalkan atau waktu 2:59 menit habis. |
| **5. Query Tiket Konfirmasi Selesai** | [lib/features/booking/backend/booking_confirmation_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/booking/backend/booking_confirmation_backend.dart#L55) | **Line 55** | `fetchLatestBooking()` | Targeted Column Query ke tabel `bookings` untuk menampilkan tiket reservasi resmi, QR code hash, dan rincian spot. |

---

## 💱 3. Function Currency (Mata Uang & Kurs Real-Time) `[CURRENCY]`

Semua urusan nilai nominal uang, konversi kurs valuta asing, dan formatting mata uang berpusat pada service:
📁 [lib/core/services/currency_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/currency_service.dart)

| Nama Function | Baris Kode | Parameter | Return Type | Keterangan & Cara Kerja |
|---|---|---|---|---|
| **`fetchLatestRates()`** | **Line 135** | - | `Future<bool>` | Memanggil API `https://open.er-api.com/v6/latest/IDR`, menguraikan kurs IDR terhadap USD, EUR, SGD, MYR, JPY, dan menyimpannya ke SharedPreferences. |
| **`convert()`** | **Line 209** | `num amountInIdr, [String? targetCurrency]` | `double` | Mengalikan nominal Rupiah dengan nilai tukar target (contoh: `Rp 16.000 * 0.0000625 = $1.00`). Jika konversi nonaktif, nilai asli IDR dikembalikan. |
| **`format()`** | **Line 227** | `num amountInIdr, {bool includeCode = false}` | `String` | Mengubah angka mentah menjadi string berformat rapi. Contoh IDR: `Rp 15.000` (pemisah titik ribuan). Contoh USD: `$ 0.95`. |
| **`setCurrency()`** | **Line 193** | `String code` | `Future<void>` | Mengubah mata uang aktif pengguna (misal ganti ke 'USD' atau 'SGD') dan menyimpan pilihan ke SharedPreferences. |
| **`getRateString()`** | **Line 254** | `String targetCode` | `String` | Menghasilkan teks perbandingan kurs untuk info UI (contoh: `1 USD ($) ≈ Rp 16.500`). |

---

## ⏰ 4. Jam Real-Time di Super Admin (Multi-Zona Waktu) `[JAM]`

Dashboard Super Admin dilengkapi jam digital multi-zona waktu (WIB, WITA, WIT, London BST/GMT) yang berdetik setiap detik:
📁 [lib/features/admin/super_admin/admin_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/super_admin/admin_dashboard_screen.dart)

| Komponen / Bagian | Baris Kode | Logika & Kode Kunci | Keterangan |
|---|---|---|---|
| **Pemicu Dialog Jam di Header** | **Line 997** | `_RealtimeTimeZonesDialog()` | Tombol ikon jam pada AppBar Super Admin yang membuka modal popup waktu realtime. |
| **Timer Berdetik 1 Detik** | **Line 2911** | `_timer = Timer.periodic(const Duration(seconds: 1), ...)` | Mengupdate state detik per detik secara konsisten tanpa lag. |
| **Perhitungan Multi-Zona Waktu** | **Line 3031-3035** | `final nowUtc = DateTime.now().toUtc();`<br>`wib = nowUtc.add(Duration(hours: 7));`<br>`wita = nowUtc.add(Duration(hours: 8));`<br>`wit = nowUtc.add(Duration(hours: 9));` | Mengambil basis waktu UTC global lalu menambahkan offset masing-masing zona waktu Indonesia secara matematis. |
| **Logika Waktu London (DST Aware)** | **Line 3037-3040** | `final isLondonDst = _isLondonDst(nowUtc);`<br>`london = nowUtc.add(Duration(hours: isLondonDst ? 1 : 0));` | Otomatis menyesuaikan waktu London antara BST (musim panas UTC+1) dan GMT (musim dingin UTC+0). |
| **Auto-Refresh Data Statistik Admin** | [admin_dashboard_backend.dart#L98](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/super_admin/backend/admin_dashboard_backend.dart#L98) | `Timer.periodic(const Duration(seconds: 30), ...)` | Timer otomatis setiap 30 detik untuk memperbarui grafik transaksi, slot parkir, dan pendapatan. |

---

## ⛓️ 5. Blockchain Ethereum Sepolia & Smart Contract `[BLOCKCHAIN]`

ParkSmart ID mengintegrasikan jaringan blockchain Ethereum (Sepolia Testnet) untuk validasi kartu anggota anti-pemalsuan:
📁 [lib/ui/layanan/layanan_blockchain.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/ui/layanan/layanan_blockchain.dart)

| Fungsi / Komponen | Baris Kode | Kode Kunci | Keterangan & Cara Kerja |
|---|---|---|---|
| **Endpoint RPC Sepolia** | **Line 25** | `https://ethereum-sepolia-rpc.publicnode.com` | Koneksi JSON-RPC publik ke jaringan Sepolia. |
| **Alamat Smart Contract** | **Line 44** | `0x032220cE1517622D0622a72A76EbF76d55c16179` | Alamat kontrak `KeanggotaanParkir` yang telah di-deploy on-chain di Sepolia. |
| **Pemuatan Berkas ABI** | **Line 68** | `rootBundle.loadString('assets/abi_keanggotaan.json')` | Memuat Application Binary Interface (ABI) untuk mengetahui daftar fungsi kontrak pintar. |
| **Validasi Keanggotaan (Read-Only)** | **Line 91** | `cekStatusKeanggotaan(alamatDompet)` | Memanggil fungsi view `cekStatusKeanggotaan` via `klienWeb3.call()` tanpa biaya gas. |
| **Validasi Hash Kartu On-Chain** | **Line 119** | `validasiKodeHash(memberHashCode)` | Mencocokkan hash kode kartu fisik pengguna dengan data di blockchain. |
| **Broadcast Minting On-Chain (Write)** | **Line 207** | `broadcastMemberCardOnChain(...)` | Mengirim transaksi nyata ke Sepolia menggunakan `RELAYER_PRIVAT_KEY` (Chain ID 11155111) untuk menerbitkan kartu anggota baru. |
| **Verifikasi Link Etherscan** | [member_card_dialog.dart#L594](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/profile/widgets/member_card_dialog.dart#L594) | `https://sepolia.etherscan.io/tx/$txHash` | Tautan browser Etherscan untuk pembuktian transaksi terdesentralisasi kepada dosen. |

---

## 🔐 6. Enkripsi Password (Salted SHA-256) `[ENKRIPSI]`

Aplikasi mengamankan kata sandi menggunakan teknik **Salted Cryptographic Hash (SHA-256)**:
📁 [lib/core/utils/hash_util.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/utils/hash_util.dart)

| Operasi Enkripsi | File Target | Baris Kode | Function / Kode | Keterangan |
|---|---|---|---|---|
| **Definisi Salt & Algoritma Hash** | [hash_util.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/utils/hash_util.dart#L16-L24) | **Line 16, 19** | `HashUtil.hashPassword()` | Rumus: `sha256(utf8('ParkSmart_Secure_Salt_2026:' + password))`. Menghasilkan 64 karakter heksadesimal ireversibel. |
| **Verifikasi Password saat Login** | [hash_util.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/utils/hash_util.dart#L28) | **Line 28** | `HashUtil.verifyPassword()` | Memverifikasi apakah hash dari input password cocok dengan nilai `password` di database Supabase. |
| **Hashing saat Pendaftaran (Register)** | [register_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/auth/register_screen.dart#L124) | **Line 124** | `'password': HashUtil.hashPassword(password)` | Password di-hash sebelum dikirim ke tabel `public.users`. Plaintext tidak pernah tersimpan di server. |
| **Pengecekan Hash saat Login User** | [login_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/auth/login_screen.dart#L321) | **Line 321** | `HashUtil.verifyPassword(password, dbPassword)` | Validasi otentikasi login pengguna. |
| **Pengecekan Hash Login Admin** | [login_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/auth/login_screen.dart#L468) | **Line 468** | `HashUtil.verifyPassword(password, dbPassword)` | Validasi otentikasi akun admin. |
| **Hashing saat Reset Password** | [forgot_password_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/auth/forgot_password_screen.dart#L100) | **Line 100** | `'password': HashUtil.hashPassword(newPassword)` | Password baru langsung di-hash saat pembaruan kata sandi. |

---

## 👆 7. Biometrik (Sidik Jari, Face ID, dan Transaksi PIN) `[BIOMETRIK]`

ParkSmart ID memiliki 3 lapis otentikasi biometrik dan keamanan perangkat:

| Jenis Biometrik | Komponen & Package | File Target | Baris Kode | Keterangan & Cara Kerja |
|---|---|---|---|---|
| **1. Sidik Jari (Fingerprint)** | `package:local_auth`<br>`LocalAuthentication` | [lib/features/profile/settings_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/profile/settings_screen.dart#L205) | **Line 205** | `_handleFingerprintToggle()`: Memeriksa dukungan sensor HP (`canCheckBiometrics`), lalu memanggil `auth.authenticate(biometricOnly: true)`. |
| **Login Cepat via Sidik Jari** | `LocalAuthentication` | [lib/features/auth/login_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/auth/login_screen.dart#L1009) | **Line 1009** | Login tanpa mengetik password: sensor sidik jari HP memvalidasi user, lalu mengambil profil akun dari Supabase. |
| **2. Pemindaian Wajah (Face ID)** | `FaceIdScannerDialog`<br>`package:camera` | [lib/features/auth/face_id_scanner_dialog.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/auth/face_id_scanner_dialog.dart#L20) | **Line 20** | Membuka kamera depan dengan animasi pemindai laser oval, memverifikasi wajah pengguna secara visual. |
| **Aktivasi Face ID di Pengaturan** | `FaceIdScannerDialog.show()` | [lib/features/profile/settings_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/profile/settings_screen.dart#L153) | **Line 153** | `_handleFaceIdToggle()`: Mengaktifkan opsi Face ID dan menyimpan status ke SharedPreferences. |
| **3. Transaksi PIN (6 Digit)** | `PinBackend`<br>Kolom `users.pin_hash` | [lib/features/pin/backend/pin_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/pin/backend/pin_backend.dart#L31) | **Line 31, 46** | Memverifikasi PIN transaksi sebelum pembayaran tiket parkir atau transfer saldo. |

---

## ⚡ 8. Pemanggilan Supabase: SDK Query vs Direct REST API `[SUPABASE]`

Arsitektur aplikasi membagi pemanggilan basis data Supabase menjadi 2 metode terpisah:

### A. Targeted Column Query via SDK (`.from().select()`)
Digunakan pada sebagian besar halaman untuk performa tinggi dengan **tidak pernah menggunakan `SELECT *`**:

| Modul / Fitur | File Target | Baris Kode | Contoh Sintaks Targeted Query |
|---|---|---|---|
| **Sesi Parkir Aktif** | [lib/features/session/backend/active_session_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/session/backend/active_session_backend.dart#L92) | **Line 92** | `_client.from('parking_sessions').select('id, session_code, location_id, slot_id, check_in_time, expected_check_out_time, ...')` |
| **Detail Konfirmasi Booking** | [lib/features/booking/backend/booking_confirmation_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/booking/backend/booking_confirmation_backend.dart#L60) | **Line 60** | `_client.from('bookings').select('id, booking_code, start_time, end_time, duration_hours, total_price, ...')` |
| **Pembuatan Reservasi Tiket** | [lib/features/checkout/backend/checkout_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/checkout/backend/checkout_backend.dart#L351) | **Line 351** | `_client.from('bookings').insert({...}).select('id, booking_code, total_price, ...')` |
| **Profil Pengguna** | [lib/features/profile/backend/profile_backend.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/profile/backend/profile_backend.dart#L125) | **Line 125** | `_client.from('users').select('full_name, email, phone, member_tier, wallet_balance, ...')` |

### B. Direct PostgREST HTTP API (Tanpa SDK / Tanpa `select()` SDK)
Digunakan pada proses latar belakang (*background isolate*) atau pemuatan konfigurasi independen di mana Flutter engine SDK belum tentu aktif:

| Kegunaan | File Target | Baris Kode | Endpoint & Header HTTP |
|---|---|---|---|
| **Konfigurasi Sistem Global** | [lib/core/services/ai_config_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/ai_config_service.dart#L93) | **Line 93** | `http.get('$cleanUrl/rest/v1/system_settings?key=eq.ai_config&select=*', headers: {'apikey': ..., 'Authorization': 'Bearer ...'})` |
| **Background Urgent Notifications** | [lib/core/services/parking_notification_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/parking_notification_service.dart#L555) | **Line 555** | `http.get('$supabaseUrl/rest/v1/system_notifications?recipient_user_id=eq...&notification_type=eq.urgent', headers: {...})` |
| **Unggah Dokumen Storage (KYC)** | [lib/core/services/supabase_storage_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/supabase_storage_service.dart#L42) | **Line 42** | `_client.storage.from('kyc-documents').uploadBinary(storagePath, bytes, ...)` |

---

## 💾 9. Sistem Penyimpanan Lokal (Local Storage & Dual-Layer Cache) `[LOCAL STORAGE]`

Penyimpanan lokal di ParkSmart ID menggunakan kombinasi **RAM (In-Memory)** dan **Disk (SharedPreferences)**:

### A. Dual-Layer Cache Balancer
📁 [lib/core/services/database_cache_balancer_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/database_cache_balancer_service.dart#L42)
* **Layer 1 (In-Memory RAM)**: Menggunakan `Map<String, _CacheEntry>` untuk akses seketika (*0 ms latency*) saat aplikasi berjalan.
* **Layer 2 (Disk SharedPreferences)**: Menyimpan salinan JSON terkompresi dengan format key:
  * Data: `cache_<queryKey>`
  * Waktu simpan: `cache_time_<queryKey>`
* **Fungsi**: Mencegah kuota Supabase jebol akibat query berulang untuk data yang sama.

### B. Penyimpanan Sesi Pengguna & Admin (`SessionService`)
📁 [lib/core/services/session_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/session_service.dart#L31-L38)
* `ps_session_is_logged_in`: Boolean penanda status login.
* `ps_session_user_type`: Menentukan apakah masuk sebagai `'user'` atau `'admin'`.
* `ps_session_user_id`: UUID identitas akun dari Supabase.
* `ps_session_admin_role`: Hak akses admin (`'super_admin'`, `'operations'`, `'finance'`, `'cs'`).
* `ps_session_last_active_time`: Timestamp aktivitas terakhir untuk fitur **Auto-Logout 30 Menit**.

### C. Kunci Pengaturan Lainnya di SharedPreferences
* **Mata Uang**: `'selected_currency'` & `'currency_conversion_enabled'` di [currency_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/currency_service.dart#L20)
* **Biometrik**: `'fingerprint_enabled'` & `'face_id_enabled'` di [settings_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/profile/settings_screen.dart#L107)
* **Tema Gelap / Terang**: `'theme_mode'` di [theme_service.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/core/services/theme_service.dart#L45)

---

## 🎨 10. Peta Pengubahan Warna Tampilan Aplikasi `[WARNA]`

### A. Background & Tema Global User
📁 [lib/theme/app_colors.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/theme/app_colors.dart)
* **Line 11**: `0xFF111418` — Background User Dark Mode
* **Line 12**: `0xFFF6F3EC` — Background User Light Mode (Cream)
* **Line 19**: `0xFF1E232B` — Warna Kartu (Card) Dark Mode
* **Line 20**: `0xFFFFFFFF` — Warna Kartu (Card) Light Mode

### B. Bilah Navigasi Bawah Melayang (Bottom Dock)
📁 [lib/widgets/bottom_dock_navigation.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/widgets/bottom_dock_navigation.dart)
* **Line 24**: `const Color(0xFF1C1D1F)` — Background badan dock navigation
* **Line 92**: `const Color(0xFFD67B5A)` — Lingkaran aksen tab aktif (Terracotta)
* **Line 54**: `Colors.white.withValues(alpha: 0.1)` — Tombol tengah kamera scanner

### C. Dashboard 4 Divisi Admin
* **Super Admin**: [lib/features/admin/super_admin/admin_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/super_admin/admin_dashboard_screen.dart#L654) — **Line 654** (`0xFFF9F9F9` background), **Line 661** (`Colors.white` AppBar), **Line 763** (`0xFF6D28D9` aksen ungu).
* **Operasional**: [lib/features/admin/operations/admin_operations_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/operations/admin_operations_dashboard_screen.dart#L157) — **Line 157** (background), **Line 162** (AppBar), **Line 171** (`0xFF114177` aksen navy).
* **Finance**: [lib/features/admin/finance/admin_finance_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/finance/admin_finance_dashboard_screen.dart#L94) — **Line 94** (background), **Line 99** (AppBar), **Line 111** (`0xFFD97706` aksen amber).
* **Customer Service**: [lib/features/admin/cs/admin_cs_dashboard_screen.dart](file:///d:/DITO/kuliah/Semester%205/teori%20mobile/project_akhir/smart_parking/lib/features/admin/cs/admin_cs_dashboard_screen.dart#L101) — **Line 101** (background), **Line 106** (AppBar), **Line 118** (`0xFF0D9488` aksen toska).
