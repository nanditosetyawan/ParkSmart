# **PRODUCT REQUIREMENTS DOCUMENT (PRD)**

# **SMART PARKING (ParkSmart ID)**

### Aplikasi Mobile Pintar untuk Pencarian, Reservasi Slot, Manajemen Multi-Role Admin, Kecerdasan Buatan (AI), dan Web3 Blockchain Membership

---

**Versi:** 2.0  
**Status Dokumen:** Production & Feature-Complete (Requirement Baseline & Live System Specification)  
**Tanggal Rilis:** 27 Oktober 2026  
**Mata Kuliah:** Pemrograman Mobile (Semester 5) — Project Akhir  
**Platform Utama:** Android & iOS (Cross-Platform via Flutter)  
**Framework:** Flutter 3.x + Dart 3.x  
**Backend & Database:** Supabase PostgreSQL 15+ & Cloud Storage  
**Web3 Network:** Ethereum Sepolia Testnet (Smart Contract Solidity)  
**AI Inference Engine:** Groq Cloud API (Llama 3 70B & 8B Contextual LLM)  

---

# **0. Kontrol Dokumen & Ringkasan Revisi**

| Atribut | Nilai Spesifikasi |
| :--- | :--- |
| **Nama Produk** | ParkSmart ID (Smart Parking) |
| **Jenis Dokumen** | Product Requirements Document (PRD) — Final Release |
| **Versi Dokumen** | **2.0** *(Upgrade dari Baseline v1.0)* |
| **Status Implementasi** | **100% Selesai & Beroperasi Penuh** |
| **Arsitektur Pengguna** | **1 Role Pengguna (User)** + **4 Role Staf Admin Terpadu (RBAC)** |
| **Penyimpanan Cloud** | Supabase Cloud PostgreSQL (16 Tabel) & Cloud Object Storage (4 Bucket) |
| **Penyimpanan Lokal** | SharedPreferences (Cache Preferensi, Sesi, Multi-Language, Theme, Maintenance State) |
| **Keamanan Perangkat** | Biometric Authentication (`local_auth`: Fingerprint & Face Recognition) + PIN Dompet |
| **Konektivitas Web3** | Ethereum Sepolia Testnet via Infura JSON-RPC & Relayer Smart Contract |
| **Kecerdasan Buatan** | Groq Cloud API Llama 3 dengan Real-time Database Prompt Context Injection |
| **Sensor Perangkat** | Accelerometer & Gyroscope (Mini Arcade Games), GPS Geolocation & Magnetometer |

---

# **Daftar Isi**

1. Ringkasan Eksekutif Produk  
2. Latar Belakang dan Problem Statement  
3. Persona Pengguna dan Skenario Penggunaan  
4. Visi Produk, Target Kinerja, dan Non-Goals  
5. Scope Fitur & Matriks Prioritas  
6. Tata Kelola Role dan Hak Akses (RBAC Terpadu)  
7. Alur Pengguna End-to-End (User Flows)  
8. Aturan Bisnis & Logika Operasional (Business Rules)  
9. Functional Requirements: Modul Pengguna (User)  
10. Functional Requirements: Modul 4 Portal Admin  
11. Functional Requirements: Sistem Pemeliharaan (Global Lockdown, Warning, & Modular)  
12. Model Data & Arsitektur Database (16 Tabel Relasional)  
13. Cloud Object Storage & Seeder Blueprint (`seed_assets/`)  
14. Kecerdasan Buatan (AI Parking Assistant via Groq LLM)  
15. Gamifikasi Sensor & Mini Arcade (Parking Challenge & Claws Car)  
16. Web3 Blockchain Membership (Ethereum Sepolia Testnet)  
17. Verifikasi Identitas KYC e-KTP & Keamanan Biometrik  
18. Notifikasi, Konversi Mata Uang, dan Zona Waktu  
19. Non-Functional Requirements (Keamanan, Skalabilitas, UI/UX)  
20. Panduan Pengujian & Acceptance Criteria  

---

# **1. Ringkasan Eksekutif Produk**

**ParkSmart ID** adalah platform mobilitas cerdas (*smart mobility*) berbasis mobile yang memecahkan masalah ketidakpastian parkir perkotaan. Aplikasi ini memindahkan proses pencarian, evaluasi ketersediaan, dan reservasi ruang parkir ke fase **sebelum pengemudi tiba di lokasi**, sehingga mengeliminasi pemborosan waktu, emisi bahan bakar, dan antrean gerbang.

ParkSmart ID mengintegrasikan:
1. **Peta LBS & Reservasi Slot Real-time**: Menampilkan ketersediaan slot mobil, motor, dan EV Charging Station secara interaktif.
2. **Multi-Role RBAC Admin Portal**: Membagi tata kelola manajerial menjadi 4 role independen: **Super Admin**, **Admin Operasional**, **Admin Finansial**, dan **Admin Customer Service**.
3. **Web3 Decentralized Membership Card**: Menerbitkan kartu anggota digital on-chain berbasis Smart Contract Ethereum Sepolia yang terverifikasi dan anti-pemalsuan.
4. **Sistem Pemeliharaan Platform 3-Tingkat**: Memberikan kendali penuh kepada Super Admin untuk melakukan *Global Maintenance Lockdown*, *Mode Peringatan*, maupun *Modular Maintenance* tanpa mematikan proses background API, timer sesi, dan perhitungan tarif.
5. **Kecerdasan Buatan Kontekstual**: AI Assistant berbasis Groq LLM yang mampu membaca basis data slot aktif secara langsung.

---

# **2. Latar Belakang dan Problem Statement**

Pengemudi kendaraan di area perkotaan, kampus, dan pusat perbelanjaan menghadapi friksi konvensional:
* **Ketidakpastian Ketersediaan**: Pengemudi harus tiba di lokasi terlebih dahulu sebelum mengetahui apakah area parkir telah penuh.
* **Informasi Tarif yang Tidak Transparan**: Perbedaan tarif per jam atau per jenis kendaraan sering kali baru diketahui di gerbang tiket.
* **Antrean Gerbang & Tiket Fisik**: Risiko tiket kertas hilang, denda karcis, dan lambatnya transaksi tunai.
* **Ketiadaan Sistem Loyalitas Terpercaya**: Program keanggotaan konvensional rentan dipalsukan dan sulit diverifikasi antar-cabang pengelola parkir.

### Solusi ParkSmart ID:
Menghadirkan ekosistem digital terpadu di mana pengemudi dapat memesan slot spesifik, menavigasi rute, melakukan check-in via QR Scanner, memantau durasi parkir berjalan via live timer, membayar otomatis via e-wallet terintegrasi, dan memiliki kartu anggota digital on-chain.

---

# **3. Persona Pengguna dan Skenario Penggunaan**

### 3.1 Persona Pengguna: Pengemudi Kendaraan Publik (Andi Prawono)
* **Karakteristik**: Pengemudi aktif yang mengutamakan kepastian waktu, kenyamanan reservasi di muka, dan riwayat transaksi transparan.
* **Skenario**: Sebelum berangkat ke kampus/mall, Andi membuka aplikasi, berkonsultasi dengan AI Assistant untuk lokasi termurah, memesan slot A-02, bernavigasi ke gerbang, memindai QR scanner untuk check-in, dan kartu member Gold miliknya otomatis memberikan diskon tarif.

### 3.2 Persona Staf: 4 Role Administrator
1. **Super Admin (Gibran Widodo)**: Menjaga stabilitas platform, mengatur maintenance darurat, mengaudit log aktivitas staf, dan memverifikasi berkas KTP pengguna.
2. **Admin Operasional (Erick Thohir)**: Memantau okupansi slot di lapangan secara live, melakukan validasi plat nomor kendaraan, dan melakukan force check-out jika tiket pengguna terkendala.
3. **Admin Finansial (Sri Mulyani)**: Melakukan rekonsiliasi pembayaran harian, mengaudit perputaran kas dompet digital, dan menganalisis laporan pendapatan per lokasi.
4. **Admin CS (Prabowo Subianto)**: Menjawab pengaduan dan keluhan fasilitas pengguna serta memeriksa kelengkapan pengajuan KYC pengguna.

---

# **4. Visi Produk, Target Kinerja, dan Non-Goals**

### 4.1 Product Vision
Menjadi standar platform smart parking terpadu di Indonesia yang menggabungkan kemudahan aplikasi mobile modern dengan integritas teknologi Web3 dan kecerdasan buatan.

### 4.2 Target Kinerja (Key Performance Indicators)
* Latensi pemesanan slot dan respons server Supabase < 800 ms.
* Waktu respons inferensi AI Assistant Groq < 1.5 detik.
* Akurasi validasi jarak geofencing check-in GPS dalam radius toleransi 150 meter.
* Ketersediaan sinkronisasi data seeder offline-to-cloud 100% tanpa kegagalan link gambar.

### 4.3 Non-Goals
* Tidak menggunakan perangkat keras mikrokontroler fisik eksternal (Arduino/ESP32) pada lingkup fase akademik ini; simulasi sensor dilakukan melalui software logic dan sensor smartphone.
* Tidak menggunakan payment gateway perbankan berlisensi produksi komersial (menggunakan simulasi dompet digital dan payment rail terverifikasi).

---

# **5. Tata Kelola Role dan Hak Akses (RBAC Terpadu)**

Sistem ParkSmart mengonsolidasikan seluruh otoritas ke dalam 5 entitas hak akses:

```
+-----------------------------------------------------------------------------------+
|                               PARKSMART ID PLATFORM                               |
+-----------------------------------------------------------------------------------+
|                                                                                   |
|  [ ROLE: USER ]            [ ROLE: SUPER ADMIN ]        [ ROLE: OPERASIONAL ]     |
|  - Booking & Peta          - Master Dashboard Control   - Okupansi Slot Realtime  |
|  - Smart QR Scanner        - Global Maintenance Lock    - Force Check-out Sesi    |
|  - E-Wallet & Payments     - Mode Peringatan Saja       - Validasi Plat Kendaraan |
|  - Member Card Web3        - Modular Maintenance        - Buka/Tutup Slot Manual  |
|  - Mini Games Arcade       - Approval Verifikasi KYC                              |
|  - AI Assistant & KYC      - Audit Logs Akses Staf                                |
|                                                                                   |
|                            [ ROLE: FINANSIAL ]          [ ROLE: CS & SUPPORT ]    |
|                            - Rekonsiliasi Kas & QRIS    - Penanganan Komplain     |
|                            - Laporan Pendapatan Lokasi  - Review Keluhan Slot     |
|                            - Injeksi Saldo Treasury     - Review Berkas KYC Awal  |
|                                                                                   |
+-----------------------------------------------------------------------------------+
```

---

# **6. Functional Requirements: Modul Pengguna (User)**

### 6.1 Peta & Penjelajahan Lokasi Parkir
* Menampilkan marker lokasi parkir interaktif pada peta berbasis OpenStreetMap.
* Indikator ketersediaan slot (Hijau: Tersedia, Oranye: Padat, Merah: Penuh).
* Informasi detail: Alamat lengkap, jam operasional, radius check-in, kapasitas slot mobil, motor, dan EV.

### 6.2 Reservasi & Pemilihan Slot Mandiri
* Memilih lantai parkir (*floors*) dan nomor slot spesifik (misal: Slot B-04).
* Estimasi perhitungan biaya parkir otomatis berdasarkan durasi waktu yang dipilih.
* Penahanan slot (*temporary reservation hold*) untuk mencegah *double-booking*.

### 6.3 Smart Scanner (Check-in & Check-out)
* Pemindai kamera QR Code berkecepatan tinggi untuk membaca token tiket di pos masuk dan pos keluar.
* Validasi geolokasi: Check-in hanya diizinkan jika koordinat GPS pengguna berada di dalam batas radius lokasi parkir.

### 6.4 Timer Sesi Parkir & Perpanjangan (Extend Session)
* Widget penghitung waktu mundur durasi parkir aktif yang berjalan secara real-time.
* Fitur perpanjangan waktu parkir (*Extend Parking Session*) secara instan dengan penyesuaian tagihan otomatis.

### 6.5 Dompet Digital ParkSmart Pay & Multi-Payment
* Pengelolaan saldo dompet, riwayat transaksi, top-up saldo, pembayaran QRIS, dan Virtual Account.
* Pengamanan otorisasi pembayaran menggunakan PIN 4-digit atau autentikasi biometrik.

### 6.6 Asisten AI Cerdas (Groq Cloud LLM)
* Chatbot interaktif berbahasa Indonesia yang memahami konteks basis data lokasi parkir, tarif, dan fasilitas.
* Kemampuan memberikan rekomendasi parkir paling relevan dengan cepat.

### 6.7 Gamifikasi Sensor: Mini Arcade Games
* **Parking Challenge Game**: Mengemudikan mobil virtual masuk ke slot sempit menggunakan sensor gerak smartphone (Accelerometer & Gyroscope).
* **Claws Car Game**: Mesin capit virtual untuk menukarkan akumulasi poin permainan menjadi **Claw Coins**.
* Penyimpanan rekor skor tertinggi (*high score*) dan akumulasi poin game di database cloud.

### 6.8 Kartu Anggota Blockchain Web3 (Ethereum Sepolia)
* Penerbitan kartu member digital on-chain berstandar smart contract.
* 4 Tingkatan Keanggotaan (*Tier*): **Bronze**, **Silver**, **Gold**, dan **Platinum**.
* Kode hash unik kartu (*member hash code*) dan bukti hash transaksi on-chain (`tx_hash`) yang dapat diverifikasi di explorer blockchain.

### 6.9 Verifikasi Identitas KYC e-KTP
* Kamera pemindaian e-KTP dengan ekstraksi OCR otomatis untuk nama dan NIK.
* Pengambilan foto selfie wajah untuk pencocokan biometrik.
* Pengunggahan berkas secara terenkripsi ke Cloud Storage dengan status persetujuan dari Super Admin.

---

# **7. Functional Requirements: Modul 4 Portal Admin**

### 7.1 Portal Super Admin (`super_admin`)
* **Pusat Pengaturan Global Platform**:
  1. *Global Maintenance Lockdown*: Memblokir akses antarmuka seluruh pengguna biasa dengan modal pop-up yang tidak dapat ditutup, dilengkapi estimasi downtime dinamis dan tombol *"Periksa Status Kembali"*.
  2. *Mode Peringatan Saja (Warning Only Mode)*: Menampilkan pop-up pengumuman informasi tanpa memblokir pesanan tiket atau navigasi aplikasi.
  3. *Maintenance Per Modul Sistem*: Menonaktifkan sementara salah satu modul (Booking, AI, KYC, atau Push Notifikasi) secara independen.
* **Verifikasi Dokumen KYC**: Meninjau foto fisik KTP dan selfie pengguna, menyetujui (*Approve*) atau menolak (*Reject*) permohonan.
* **Audit Trail Keamanan**: Memantau jejak audit log seluruh staf admin (IP Address, ISP, geolokasi, tipe perangkat, status sesi).

### 7.2 Portal Admin Operasional (`operational`)
* **Monitoring Lapangan Real-time**: Memantau denah slot dan okupansi kendaraan secara langsung per lantai gedung.
* **Kontrol Ketersediaan Manual**: Mengubah status slot parkir menjadi *Available*, *Booked*, atau *Maintenance*.
* **Pencocokan Kendaraan Gerbang**: Memvalidasi plat nomor fisik kendaraan dengan data tiket pengguna.
* **Force Check-out Darurat**: Menyelesaikan sesi parkir secara manual jika terjadi kendala pada barcode pengguna.

### 7.3 Portal Admin Finansial (`finance`)
* **Rekonsiliasi Pembayaran Digital**: Memverifikasi seluruh mutasi kas dari dompet digital, QRIS, dan Virtual Account.
* **Analisis Pendapatan Komparatif**: Memantau grafik pendapatan per hari, per minggu, dan per lokasi mall/gedung.
* **Manajemen Kas Treasury Platform**: Memantau cadangan dana operasional sistem.

### 7.4 Portal Admin Customer Service (`cs`)
* **Penanganan Feedback & Ulasan**: Membaca rating bintang 1-5, saran, dan keluhan fasilitas dari pengguna.
* **Penyelesaian Masalah**: Membalas keluhan pengguna dan menandai status tiket pengaduan (*Resolved*).
* **Pemeriksaan Berkas KYC Tahap Awal**: Membantu memverifikasi kejelasan foto identitas pengguna.

---

# **8. Model Data & Arsitektur Database (16 Tabel Relasional)**

Seluruh arsitektur data dibangun di atas PostgreSQL Supabase dan mematuhi aturan normalisasi data:

| No | Nama Tabel | Klaster | Deskripsi Entitas & Integritas |
| :---: | :--- | :--- | :--- |
| 1 | **`users`** | Akun & Profil | Identitas pengguna, saldo dompet, poin loyalitas, claw coins, tier member, status KYC, dan PIN keamanan. |
| 2 | **`admins`** | Staf RBAC | Tabel tunggal terpadu untuk 4 role staf admin (Super Admin, Ops, Finance, CS) dengan kata sandi terenkripsi. |
| 3 | **`parking_locations`** | Operasional | Gedung/lokasi parkir, koordinat GPS, radius geofence, fasilitas, daftar lantai (`floors`), dan tarif per jam. |
| 4 | **`parking_slots`** | Denah & IoT | Denah spot slot per lantai, tipe slot (mobil/motor/EV), zona, dan status ketersediaan. |
| 5 | **`bookings`** | Reservasi | Tiket reservasi slot di muka / walk-in, barcode QR pass, perpanjangan waktu, dan status pembayaran. |
| 6 | **`parking_sessions`** | Sesi Lapangan | Sesi kendaraan aktif di lokasi (check-in s.d. check-out), durasi riil, timer berjalan, dan denda overstay. |
| 7 | **`payments`** | Billing & Keuangan | Buku besar mutasi kas (pembayaran parkir, top-up, injeksi kas, refund) dan hash transaksi blockchain. |
| 8 | **`vehicles`** | Garasi Kendaraan | Kendaraan terdaftar milik pengguna, plat nomor (TNKB), tipe kendaraan, dan foto kendaraan. |
| 9 | **`user_kyc`** | Identitas Resmi | Berkas NIK 16-digit, data diri, URL foto KTP, URL foto selfie, dan status verifikasi Super Admin. |
| 10 | **`user_member_cards`** | Blockchain Web3 | Multi-kartu keanggotaan digital pengguna, kode hash unik kartu, dan tx_hash transaksi Ethereum Sepolia. |
| 11 | **`arcade_scores`** | Gamifikasi | Rekor skor game (Parking Challenge & Claws Car), akumulasi poin, dan waktu bermain. |
| 12 | **`system_settings`** | Super Admin | Konfigurasi platform JSONB: `maintenance_mode`, `modular_maintenance`, `feature_toggles`, dan `company_treasury`. |
| 13 | **`admin_audit_logs`** | Keamanan & Audit | Rekam jejak audit aktivitas login staf admin (IP publik, ISP, geolokasi, perangkat hardware, status login). |
| 14 | **`user_favorites`** | Personalisasi | Bookmark lokasi parkir favorit per pengguna dengan proteksi Row Level Security (RLS). |
| 15 | **`system_notifications`**| CS & Siaran | Notifikasi siaran pengumuman, promosi tarif, dan peringatan darurat sistem. |
| 16 | **`customer_feedbacks`** | CS & Evaluasi | Ulasan bintang (1-5), saran marka/fasilitas, dan respons resmi Customer Service. |

---

# **9. Cloud Storage & Seeder Blueprint (`seed_assets/`)**

Sistem penyimpanan media cloud dibagi ke dalam 4 bucket terstruktur:
* 🗂️ **`avatars`** *(Public)*: Foto profil pengguna aplikasi.
* 🗂️ **`vehicles`** *(Public)*: Foto fisik kendaraan pengguna untuk pencocokan gerbang.
* 🗂️ **`parking-locations`** *(Public)*: 28+ foto lokasi parkir, mall mitra, kampus, dan denah lantai.
* 🗂️ **`kyc-documents`** *(Protected RLS)*: Foto fisik KTP dan selfie wajah verifikasi pengguna.

### Seeder Otomatis 1-Langkah (`tools/seed_storage.dart`)
Untuk proses deployment atau migrasi instan ke akun Supabase baru tanpa hambatan manual:
1. Skrip otomatis membaca kredensial `.env`.
2. Otomatis membuat ke-4 bucket di cloud storage target.
3. Mengunggah 34+ file fisik dari folder [`seed_assets/storage/`](seed_assets/storage/) ke cloud.
4. Menyesuaikan URL gambar ke domain target secara dinamis.
5. Mengisi data seluruh 16 tabel dari [`seed_assets/data/`](seed_assets/data/) ke PostgreSQL.

---

# **10. Kredensial Akun Pengujian & Validasi Sistem**

### A. Kredensial 4 Staf Admin (RBAC)

| Role Admin | Nama Staf | Email Login | Password Default | Hak Akses Utama |
| :--- | :--- | :--- | :--- | :--- |
| **Super Admin** | Gibran Widodo | `superadmin@parksmart.id` | `superadmin123` | Master Control, Maintenance Lockdown, Approval KYC, Audit Logs |
| **Admin Operasional** | Erick Thohir | `ops@parksmart.id` | `ops123` | Monitoring Slot Lapangan, Force Check-out, Validasi Kendaraan |
| **Admin Finansial** | Sri Mulyani | `finance@parksmart.id` | `finance123` | Rekonsiliasi Kas, Audit Transaksi, Laporan Revenue Lokasi |
| **Admin CS** | Prabowo Subianto | `cs@parksmart.id` | `cs123` | Penanganan Pengaduan Pengguna, Review Berkas KYC Awal |

### B. Kredensial Pengguna Publik (User)

| Pengguna | Email Login | Password Default | PIN Dompet | Saldo Dompet | Tier Member | Status KYC |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **User Utama** | `user@gmail.com` | `123456` | `4040` | Rp 1.044.500,- | **GOLD** | Sedang Diajukan (*Pending*) |
| **User Sekunder** | `aji@gmail.com` | `aji123` | `1111` | Rp 182.000,- | **BRONZE** | Terverifikasi (*Approved*) |

---

# **11. Panduan Menjalankan Sistem (Execution Guide)**

### Langkah 1: Setup Environment File (`.env`)
```bash
cp .env.example .env
```
Isi variabel dengan kredensial Supabase, Groq API Key, dan Infura Sepolia RPC.

### Langkah 2: Jalankan Seeder Otomatis (Storage + Database)
```bash
dart run tools/seed_storage.dart
```

### Langkah 3: Jalankan Aplikasi
```bash
flutter pub get
flutter run
```

---

<p align="center">
  <b>ParkSmart ID — Production Requirements Document (PRD v2.0)</b><br/>
  Disahkan untuk Final Project Pemrograman Mobile Semester 5.<br/>
  © 2026 ParkSmart ID Team. All Rights Reserved.
</p>
