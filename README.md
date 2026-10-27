# ParkSmart ID — Smart Parking & Web3 Blockchain Ecosystem

<p align="center">
  <img src="assets/images/app_icon.png" width="100" height="100" alt="ParkSmart Logo" style="border-radius: 20px;" />
</p>

<p align="center">
  <b>Solusi Ekosistem Parkir Cerdas Terintegrasi Kecerdasan Buatan (AI), IoT Real-time, dan Web3 Smart Contract Blockchain Sepolia.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Database%20%26%20Storage-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Ethereum-Sepolia%20Testnet-627EEA?logo=ethereum&logoColor=white" alt="Ethereum" />
  <img src="https://img.shields.io/badge/AI%20Engine-Groq%20Llama%203-F55036?logo=groq&logoColor=white" alt="Groq AI" />

</p>

---

## 📌 1. Deskripsi Eksekutif Proyek

**ParkSmart ID** adalah aplikasi mobile pintar generasi baru yang mentransformasi tata kelola parkir perkotaan dari sistem manual konvensional menjadi ekosistem digital yang transparan, otomatis, dan terdesentralisasi. 

Aplikasi ini menggabungkan:
1. **Navigasi & Pemesanan Slot Presisi**: Memberikan kepastian ketersediaan ruang parkir bagi pengemudi sebelum tiba di lokasi.
2. **Manajemen Multi-Role Admin (RBAC)**: Memisahkan operasional teknis lapangan, audit akuntansi finansial, pelayanan pelanggan (CS), dan kebijakan master platform ke dalam 4 hak akses independen.
3. **Web3 Blockchain Membership**: Menggunakan Smart Contract Ethereum (Sepolia Testnet) untuk pencatatan kartu keanggotaan digital terdesentralisasi yang tidak dapat dipalsukan (*tamper-proof*).
4. **Sistem Pemeliharaan Sistem Dinamis**: Menghadirkan fitur *Global Lockdown*, *Mode Peringatan*, dan *Modular Maintenance* tanpa menghentikan komputasi backend yang sedang berjalan.

---

## 🛠️ 2. Teknologi & Framework

| Komponen | Teknologi | Deskripsi |
| :--- | :--- | :--- |
| **Mobile Frontend** | Flutter & Dart | Antarmuka responsif performa tinggi untuk Android & iOS dengan Material Design 3. |
| **Database Relasional** | PostgreSQL via Supabase | Penyimpanan relasional ACID-compliant dengan Row Level Security (RLS) dan Realtime Socket. |
| **Penyimpanan Media** | Supabase Cloud Storage | Cloud Object Storage untuk foto lokasi parkir, foto kendaraan, avatar, dan dokumen KYC. |
| **Blockchain Smart Contract** | Ethereum Sepolia (Solidity) | Kontrak pintar terverifikasi untuk kartu keanggotaan on-chain dan pembuktian status membership. |
| **Web3 Client** | `web3dart` & Infura RPC | Penghubung RPC antara aplikasi mobile Flutter dengan jaringan blockchain Sepolia. |
| **Kecerdasan Buatan (AI)** | Groq Cloud API | Inference berkecepatan tinggi Llama 3 untuk asisten pencarian kontekstual lokasi dan tarif. |
| **Visi Komputer & OCR** | Google ML Kit | Pemindaian barcode/QR tiket serta pembacaan karakter teks e-KTP secara otomatis. |
| **Peta & Geospasial** | `flutter_map` & OpenStreetMap | Visualisasi peta interaktif dengan perhitungan jarak Haversine dan penentuan rute. |
| **Prakiraan Cuaca Real-time** | Open-Meteo Weather API | Pengambilan data suhu (°C) dan iklim lokal langsung di atas peta navigasi secara live. |
| **Konversi Mata Uang Global** | ExchangeRate-API (Open ER-API) | Konversi kurs valuta asing otomatis untuk multi-currency switcher (IDR, USD, EUR, SGD, MYR, JPY). |

---

## 🌐 3. Integrasi API Eksternal

1. **Supabase REST & Realtime API**: Sinkronisasi data slot, pesanan, notifikasi, dan sesi parkir secara instan.
2. **Groq LLM API (`llama3-70b-8192` / `llama3-8b-8192`)**: Asisten AI kontekstual yang membaca data ketersediaan slot aktual secara real-time.
3. **Ethereum Sepolia JSON-RPC Endpoint (Infura)**: Eksekusi transaksi *minting* kartu anggota, pengecekan saldo relayer, dan validasi hash transaksi on-chain.
4. **OpenStreetMap / OSRM Routing Engine**: Penentuan rute perjalanan dari posisi GPS pengguna menuju lokasi parkir tujuan.
5. **Biometric Security API (`local_auth`)**: Autentikasi biometrik lokal (Fingerprint & Face Recognition) untuk otorisasi dompet parkir.
6. **Open-Meteo Weather Forecast API**: Menyajikan data cuaca real-time (suhu dalam °C, cuaca cerah/berawan/hujan, dan ikon dinamis) pada peta navigasi lokasi parkir sesuai titik koordinat GPS pengguna.
7. **ExchangeRate-API (Open ER-API)**: Sinkronisasi kurs valuta asing live (IDR ke USD, EUR, SGD, MYR, JPY) dengan sistem caching cerdas 12 jam untuk mendukung konversi multi-mata uang bagi pengguna internasional.

---

## 💾 4. Arsitektur Penyimpanan Data (Online vs Offline)

### A. Penyimpanan Online (Cloud & On-chain)
- **Supabase PostgreSQL**:
  * 16 Tabel Relasional (`users`, `admins`, `parking_locations`, `parking_slots`, `bookings`, `parking_sessions`, `payments`, `vehicles`, `user_kyc`, `arcade_scores`, `user_member_cards`, `system_settings`, dll).
- **Supabase Cloud Object Storage**:
  * Bucket `parking-locations`: Foto tempat parkir, foto gerbang, denah lantai.
  * Bucket `vehicles`: Foto fisik kendaraan pengguna untuk validasi pos parkir.
  * Bucket `avatars`: Foto profil pengguna.
  * Bucket `kyc-documents`: Foto fisik e-KTP dan selfie verifikasi identitas (dilindungi RLS).
- **Ethereum Sepolia Blockchain**:
  * Catatan kepemilikan kartu member on-chain, status keanggotaan permanen, serta hash token digital.

### B. Penyimpanan Offline & Lokal (Client-Side)
**`SharedPreferences`**:
  * Cache token sesi login, konfigurasi bahasa aktif (Indonesia/English), tema aplikasi (Dark/Light Mode), riwayat pencarian peta, dan salinan lokal status pemeliharaan sistem.


---

## 📱 5. Rincian Fitur Aplikasi Pengguna (User)

1. **Peta Interaktif, Pencarian Lokasi & Cuaca Live**:
   - Menampilkan lokasi parkir terdekat secara live berdasarkan koordinat GPS pengguna.
   - Widget prakiraan cuaca lokal real-time (suhu °C, awan/hujan/cerah, dan emoji dinamis) terintegrasi via Open-Meteo API.
   - Informasi detail kapasitas slot mobil, motor, dan slot khusus kendaraan listrik (EV Charging Station).
2. **Reservasi & Pemilihan Slot Terjadwal**:
   - Memilih lantai dan nomor slot parkir secara visual.
   - Perhitungan estimasi biaya otomatis berdasarkan durasi parkir yang direncanakan.
3. **Smart Scanner Tiket (Check-In & Check-Out)**:
   - Pemindaian kamera QR Code di pos gerbang masuk dan pos gerbang keluar.
   - Pintu gerbang terbuka secara otomatis saat kode terverifikasi.
4. **Dompet Digital ParkSmart & Multi-Payment**:
   - Saldo dompet internal, QRIS dinamis, Virtual Account Bank, dan transfer instan.
   - Otorisasi pembayaran menggunakan PIN 4-digit atau biometrik sidik jari.
5. **Timer Sesi Parkir Real-time**:
   - Penghitung durasi parkir aktif yang berjalan otomatis saat check-in.
   - Penghitungan tarif dinamis berjalan secara transparan dan akurat.
6. **Asisten AI Chatbot Kontekstual**:
   - Konsultasi rekomendasi parkir terdekat, informasi tarif termurah, fasilitas khusus, dan jam operasional.
7. **Mini Arcade Game (Parking Challenge & Claws Car)**:
   - Game simulasi parkir mobil untuk mengisi waktu luang.
   - Pencatatan skor tertinggi sepanjang sejarah (*highest score*) dan akumulasi poin permainan.
   - Penukaran poin game menjadi **Claw Coins** untuk keuntungan ekstra.
8. **Kartu Anggota Digital On-Chain Blockchain**:
   - Penerbitan kartu digital dengan verifikasi transaksi Ethereum Sepolia.
   - Tingkatan keanggotaan (*Tier*): Bronze, Silver, Gold, dan Platinum.
   - Kode hash identitas unik yang dapat diverifikasi di explorer blockchain.
9. **Verifikasi Identitas KYC e-KTP**:
   - Pengambilan foto e-KTP dan foto selfie wajah langsung melalui kamera aplikasi.
   - Pembacaan data NIK dan identitas otomatis melalui OCR deteksi dokumen.
10. **Multi-Currency Global Converter**:
    - Konversi nilai tarif parkir dan saldo dompet secara dinamis ke 6 mata uang global: Rupiah (IDR 🇮🇩), US Dollar (USD 🇺🇸), Euro (EUR 🇪🇺), Singapore Dollar (SGD 🇸🇬), Ringgit Malaysia (MYR 🇲🇾), dan Yen Jepang (JPY 🇯🇵).
    - Nilai tukar terhubung live via ExchangeRate-API dengan sistem penyimpanan lokal otomatis.

---

## 🛡️ 6. Rincian Fitur ke-4 Role Admin (RBAC)

ParkSmart membagi pengelolaan sistem ke dalam **4 portal admin khusus**:

```
                   ┌─────────────────────────────────────────────┐
                   │             SUPER ADMIN PORTAL              │
                   │ (Master Control, Lockdown & Verifikasi KYC) │
                   └──────────────────────┬──────────────────────┘
                                          │
             ┌────────────────────────────┼────────────────────────────┐
             │                            │                            │
┌────────────┴────────────┐  ┌────────────┴────────────┐  ┌────────────┴────────────┐
│    ADMIN OPERASIONAL    │  │     ADMIN FINANSIAL     │  │ ADMIN CUSTOMER SERVICE  │
│ (Slot, Pos & Kendaraan) │  │ (Inject Saldo & Revenue)│  │ (Keluhan & Feedback CS) │
└─────────────────────────┘  └─────────────────────────┘  └─────────────────────────┘
```

### 1. 👑 Super Admin (`super_admin`)
* **Master Dashboard**: Memantau statistik global seluruh pengguna, pendapatan kotor, total okupansi parkir se-kota, dan ringkasan audit log.
* **Pengaturan Global Platform**:
  - *Global Maintenance Lockdown*: Mengunci seluruh akses antarmuka pengguna saat pemeliharaan besar, dengan pesan dinamis dan estimasi downtime.
  - *Mode Peringatan Saja (Warning Only Mode)*: Menampilkan pop-up pengumuman informasi tanpa memblokir navigasi dan pesanan tiket pengguna.
  - *Maintenance Per Modul Sistem*: Menonaktifkan sementara modul tertentu (Gateway Booking, Engine AI Assistant, Modul KYC KTP, atau Gateway Push Notifikasi) secara terpisah.
* **Verifikasi KYC**: Meninjau foto KTP dan foto selfie pengguna, menyetujui (*Approve*) atau menolak (*Reject*) dengan alasan penolakan.
* **Manajemen Data**: Kontrol penuh data admin operasional, lokasi parkir, dan audit log keamanan.

### 2. 🚦 Admin Operasional Lapangan (`operational`)
* **Monitoring Okupansi Lapangan**: Melihat denah slot mobil, motor, dan EV di lokasi secara real-time.
* **Kontrol Ketersediaan Manual**: Mengubah status slot menjadi *Available*, *Booked*, atau *Maintenance*.
* **Force Check-out Darurat**: Menyelesaikan sesi parkir secara manual apabila pengguna mengalami kendala teknis atau tiket hilang.

### 3. 💳 Admin Finansial & Akuntansi (`finance`)
* **Rekonsiliasi Pembayaran**: Memverifikasi seluruh aliran dana masuk dari QRIS, Virtual Account, dan saldo dompet.
* **Audit Transaksi Harian & Bulanan**: Memeriksa detail transaksi pembayaran tiket, perpanjangan durasi, dan penalti keterlambatan.
* **Analisis Pendapatan per Lokasi**: Melihat laporan pendapatan tertinggi dan tingkat utilitas komersial setiap lokasi parkir.
* **Inject Saldo User**: Mentransfer Saldo K user tertentu dengan fitur search.

### 4. 🎧 Admin Customer Service & Keluhan (`cs`)
**Pusat Feedback**: Menerima ulasan bintang pengguna.


---

## 🔑 7. Data Kredensial Login Pengujian

Gunakan akun resmi berikut untuk menguji seluruh hak akses sistem:

### A. Tabel Kredensial Akun Admin (4 Role)

| Role Admin | Nama Petugas | Email Login | Password | Hak Akses Utama |
| :--- | :--- | :--- | :--- | :--- |
| **Super Admin** | Gibran Widodo | `superadmin@parksmart.id` | `superadmin123` | Master Dashboard, Maintenance Lockdown, Verifikasi KYC, Audit Log |
| **Admin Operasional** | Erick Thohir | `ops@parksmart.id` | `ops123` | Monitoring Slot Lapangan, Force Check-out, Validasi Gerbang |
| **Admin Finansial** | Sri Mulyani | `finance@parksmart.id` | `finance123` | Rekonsiliasi Pembayaran, Audit Transaksi, Laporan Revenue |
| **Admin Customer Service** | Prabowo Subianto | `cs@parksmart.id` | `cs123` | Penanganan Pengaduan Pengguna, Review Identitas KYC |

### B. Tabel Kredensial Akun Pengguna (User)

| Pengguna | Email Login | Password | PIN Dompet | Saldo Dompet | Member Tier | Status KYC |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **User Utama** | `user@gmail.com` | `123456` | `4040` | Rp 1.044.500,- | **GOLD** | Sedang Diajukan (*Pending*) |
| **User Sekunder** | `aji@gmail.com` | `aji123` | `1111` | Rp 182.000,- | **BRONZE** | Belum Diajukan |

---

## 🚀 8. Panduan Instalasi & Urutan Migrasi Database Terpadu

Agar instalasi berjalan lancar dan tidak terjadi tabrakan ketergantungan database maupun dependensi paket, **ikuti urutan langkah teknis berikut secara disiplin**:

```
┌─────────────────────────┐       ┌─────────────────────────┐       ┌─────────────────────────┐
│  LANGKAH 1: GIT CLONE   │ ───►  │  LANGKAH 2: PUB GET     │ ───►  │  LANGKAH 3: SETUP .ENV  │
│ Unduh repositori proyek │       │  Unduh dependensi Dart  │       │  Konfigurasi Kredensial │
└─────────────────────────┘       └─────────────────────────┘       └───────────┬─────────────┘
                                                                                │
                                                                                ▼
┌─────────────────────────┐       ┌─────────────────────────┐       ┌───────────┴─────────────┐
│  LANGKAH 6: FLUTTER RUN │ ◄───  │ LANGKAH 5: SEED STORAGE │ ◄───  │ LANGKAH 4: SCHEMA (SQL) │
│ Jalankan Aplikasi Utama │       │  Upload 34 Foto & 16 DB │       │ Buat 16 Tabel & Trigger │
└─────────────────────────┘       └─────────────────────────┘       └─────────────────────────┘
```

---

### 📥 Langkah 1: Klon Repositori

Unduh repositori kode sumber ParkSmart ke komputer lokal Anda dan masuk ke direktori proyek:

```bash
git clone https://github.com/nanditosetyawan/ParkSmart.git
cd ParkSmart
```

---

### 📦 Langkah 2: Unduh Dependensi Proyek (`flutter pub get`)

Unduh seluruh pustaka pihak ketiga yang dibutuhkan aplikasi ke direktori `.dart_tool/`:

```bash
flutter pub get
```

> [!TIP]
> **Mengapa Dependensi Harus Diunduh di Langkah Ini?**
> Skrip seeder otomatis (`tools/seed_storage.dart`) membutuhkan pustaka Dart seperti `package:http/http.dart`. Menjalankan `flutter pub get` di awal memastikan seluruh dependensi Flutter & Dart terpasang lengkap sebelum Anda mengeksekusi skrip seeder di terminal.

---

### ⚙️ Langkah 3: Konfigurasi File Environment (`.env`)

Buat salinan file environment dari template yang telah disediakan:

```bash
cp .env.example .env
```

Buka file `.env` yang baru dibuat menggunakan text editor. Berikut adalah struktur lengkap seluruh variabel environment beserta nilai contohnya:

```env
# ==============================================================================
# 1. KREDENSIAL SUPABASE (DATABASE & CLOUD STORAGE)
# ==============================================================================
# ID unik proyek Supabase (didapat dari: Project Settings > General)
SUPABASE_PROJECT_ID=isi_project_id

# URL endpoint REST & Realtime API (format: https://<project-id>.supabase.co)
SUPABASE_URL=https://<abcdefghijklmnopqrst>.supabase.co

# Kunci API publik anonim untuk otorisasi client (didapat dari: Project Settings > API)
SUPABASE_ANON_KEY=SAMPLE_ANON_SIGNATURE_KEY_HERE...

# Personal Access Token pengelola untuk upload storage & DDL (didapat dari: Account > Access Tokens) ijin akses full di profile and never expired
SUPABASE_ACCESS_TOKEN=isi_token_access

# ==============================================================================
# 2. AI ENGINE API (GROQ CLOUD LLM)
# ==============================================================================
# Kunci API inferensi Groq Llama 3 (didapat dari: https://console.groq.com/keys)
GROQ_API_KEY=isi_api_key

# ==============================================================================
# 3. WEB3 BLOCKCHAIN SEPOLIA TESTNET
# ==============================================================================
# Endpoint JSON-RPC Ethereum Sepolia (didapat dari: https://infura.io/ atau https://alchemy.com/)
SEPOLIA_RPC_URL=your_infura_api_key_here

# Alamat kontrak pintar kartu anggota (didapat dari deploy di https://remix.ethereum.org/)
SEPOLIA_CONTRACT_ADDRESS=isi_contract_address

# Private Key relayer admin untuk pembayaran gas fee transaksi minting member on-chain, buka menu Detail Akun di metamask (Account Details), lalu klik Show Private Key
RELAYER_PRIVAT_KEY=isi_privat_key

# Sakelar siaran on-chain (atur true untuk broadcast live ke Sepolia testnet)
ENABLE_ONCHAIN_BROADCAST=true
```

#### 📖 Panduan Cara Memperoleh Kredensial `.env`

Berikut adalah rincian panduan ringkas 2 kalimat untuk masing-masing variabel environment:

| Variabel Environment | Sumber & Cara Memperolehnya | Keterangan & Fungsi Singkat |
| :--- | :--- | :--- |
| **`SUPABASE_PROJECT_ID`** | Buka **Supabase Dashboard** > pilih proyek Anda > klik menu **Project Settings** > **General**. | Salin string unik pada kolom *Reference ID*. Nilai ini merupakan penanda unik repositori database cloud proyek Anda. |
| **`SUPABASE_URL`** | Buka **Supabase Dashboard** > **Project Settings** > klik menu **API**. | Salin tautan pada kolom *Project URL* yang berformat `https://<id>.supabase.co`. Tautan ini menjadi basis endpoint REST API & Realtime Socket. |
| **`SUPABASE_ANON_KEY`** | Buka **Supabase Dashboard** > **Project Settings** > klik menu **API**. | Salin token panjang pada bagian *Project API keys* bertuliskan `anon` `public`. Kunci publik ini mengotorisasi aplikasi Flutter untuk mengakses tabel dengan proteksi RLS. |
| **`SUPABASE_ACCESS_TOKEN`** | Klik profil Anda di pojok Supabase Dashboard > pilih [Access Tokens](https://supabase.com/dashboard/account/tokens) > klik **Generate new token**. | Berikan izin *Full Access* dan centang masa berlaku *Never Expire*. Token ini dipakai oleh terminal untuk otomatis membuat bucket storage dan mengunggah gambar fisik. |
| **`GROQ_API_KEY`** | Buka konsol pengembang Groq di [console.groq.com/keys](https://console.groq.com/keys) lalu klik tombol **Create API Key**. | Beri nama kunci dan salin string token yang diawali `gsk_...`. Token ini mengaktifkan AI chatbot Llama 3 untuk pencarian tempat parkir dan rekomendasi tarif. |
| **`SEPOLIA_RPC_URL`** | Buat akun di [infura.io](https://www.infura.io/) atau [alchemy.com](https://www.alchemy.com/), buat *API Key* baru, lalu pilih jaringan **Ethereum Sepolia**. | Salin link endpoint RPC HTTP yang berformat `https://sepolia.infura.io/v3/...`. URL ini menjadi pintu masuk aplikasi Flutter untuk membaca status blockchain. |
| **`SEPOLIA_CONTRACT_ADDRESS`** | deploy kode Solidity via [Remix IDE](https://remix.ethereum.org/). | Alamat ini menunjuk ke lokasi smart contract kartu anggota di Sepolia. Seluruh mutasi tier pengguna dicatat permanen pada alamat kontrak ini. |
| **`RELAYER_PRIVAT_KEY`** | Buka ekstensi **MetaMask**, pilih akun admin berdana Sepolia ETH, klik **Titik Tiga** > **Account Details** > klik **Show Private Key**. | Masukkan sandi MetaMask Anda dan salin kode heksadesimal 64 karakter. Private key ini mendanai gas fee otomatis sehingga pengguna biasa dapat menerima kartu member secara gratis. |
| **`ENABLE_ONCHAIN_BROADCAST`** | Cukup isi dengan nilai teks `true` (atau `false` jika ingin simulasi offline saja). | Berfungsi sebagai sakelar keamanan sistem. Jika bernilai `true`, setiap aktivasi kartu anggota akan otomatis disiarkan langsung ke blockchain Sepolia. |

---

### 🗄️ Langkah 4: Eksekusi Skema Database (`schema.sql`) — **WAJIB SEBELUM SEED**

> [!IMPORTANT]
> **Mengapa `schema.sql` Harus Dijalankan Sebelum Seed Storage?**
> Pada proyek Supabase baru, database masih kosong melompong (belum memiliki tabel relasional). Script *seeder* (`seed_storage.dart`) memasukkan data melalui REST API Supabase. Jika Anda menjalankan seeder sebelum tabelnya dibuat, Supabase akan menolak dengan error `404 Not Found` / `42P01 relation does not exist`. 
> 
> Oleh karena itu, **skema tabel fisik (`schema.sql`) WAJIB dibuat terlebih dahulu!**

#### Cara Eksekusi (Melalui Supabase SQL Editor):
1. Buka browser dan masuk ke [Supabase Dashboard](https://supabase.com/dashboard).
2. Pilih proyek Supabase Anda, lalu klik menu **SQL Editor** (ikon `>_` di bilah kiri).
3. Buka file lokal proyek Anda di [`lib/database/schema.sql`](lib/database/schema.sql), lalu salin seluruh kodenya (`Ctrl + A` -> `Ctrl + C`).
4. Tempel (*paste*) kode tersebut ke lembar kerja SQL Editor Supabase.
5. Klik tombol **Run** (atau tekan pintasan `Ctrl + Enter`).
6. Tunggu 2–3 detik hingga muncul konfirmasi hijau: `Success. No rows returned`.

> [!TIP]
> Skrip `schema.sql` di atas secara otomatis membuat **16 tabel relasional**, tipe data custom ENUM, indeks performa, relasi Foreign Key antar tabel, trigger otomatis kenaikan tier member (*spending accumulator*), stored procedure `extend_parking_session`, dan pendaftaran realtime publication.

---

### 🚀 Langkah 5: Eksekusi Seeder Data & Cloud Storage Otomatis (`seed_storage.dart`)

Setelah seluruh ke-16 tabel fisik berhasil terbentuk di Langkah 4, sekarang Anda dapat mengisi data awal dan mengunggah gambar fisik ke Supabase Storage secara otomatis.

> [!NOTE]
> **Apa Saja yang Dilakukan Script Seeder Ini Secara Otomatis?**
> 1. Memeriksa dan otomatis membuat 4 Bucket Supabase Storage jika belum ada: `avatars`, `vehicles`, `parking-locations`, dan `kyc-documents`.
> 2. Mengunggah **34 file gambar fisik asli** dari folder lokal [`seed_assets/storage/`](seed_assets/storage/) ke cloud storage Supabase.
> 3. Mengambil URL publik resmi dari masing-masing gambar yang berhasil terunggah.
> 4. Menyuntikkan seluruh baris data awal ke dalam **16 tabel database** (7 lokasi parkir, 84 slot, 4 akun admin, 2 akun pengguna, data KYC e-KTP, riwayat pembayaran, game arcade, dan konfigurasi maintenance) dengan URL gambar yang sudah cocok 100%!

Jalankan perintah berikut di terminal Anda:

```bash
dart run tools/seed_storage.dart
```

*(Atau jika lingkungan Anda menggunakan runtime Node.js, Anda juga dapat menjalankan)*:
```bash
node tools/seed_all.mjs
```

**Hasil Terminal yang Diharapkan:**
```text
================================================================
  PARKSMART SEED STORAGE & DATABASE SINKRONISASI
================================================================
[1/2] Memproses unggah file fisik ke Supabase Storage...
[Storage] Memeriksa/membuat bucket: avatars, vehicles, parking-locations, kyc-documents... OK!
[Storage] Mengunggah 34 aset gambar fisik... Selesai 100%!
[2/2] Menyuntikkan data JSON ke 16 tabel Supabase...
  - Tabel admins: 4 baris berhasil disinkronkan.
  - Tabel users: 2 baris berhasil disinkronkan.
  - Tabel parking_locations: 7 lokasi berhasil disinkronkan.
  - Tabel parking_slots: 84 slot berhasil disinkronkan.
  - ... (seluruh 16 tabel sukses)
================================================================
DATABASE DAN STORAGE BERHASIL DISINKRONISASI DENGAN SEMPURNA!
================================================================
```

*(Opsi Tambahan Tanpa Upload Gambar Fisik)*: Jika Anda hanya ingin mengisi database dengan teks tanpa mengunggah file gambar ke Cloud Storage, Anda cukup menyalin isi file [`lib/database/seed.sql`](lib/database/seed.sql) ke Supabase SQL Editor dan klik **Run**. Namun, **`seed_storage.dart` sangat direkomendasikan** agar antarmuka aplikasi menampilkan foto fisik asli.

---

### 📱 Langkah 6: Jalankan Aplikasi Flutter

Setelah dependensi terunduh serta database dan storage terisi lengkap, jalankan aplikasi pada emulator atau perangkat fisik Anda:

```bash
flutter run
```

---

## 📚 9. Dokumentasi & Blueprint Database Terpadu

Repositori ini menyediakan dokumentasi arsitektur dan skrip database lengkap yang telah **disinkronkan 100%**:

| File / Folder | Fungsi & Status | Kapan Digunakan? |
| :--- | :--- | :--- |
| **[`seed_assets/`](seed_assets/)** & **[`tools/seed_storage.dart`](tools/seed_storage.dart)** | **Master Seeder Otomatis (Storage + Database)**.<br/>Membuat bucket, upload 34 gambar fisik asli, dan mengisi 16 tabel. | **Paling Direkomendasikan** untuk setup cepat di Supabase baru via 1 command: `dart run tools/seed_storage.dart`. |
| **[`lib/database/schema.sql`](lib/database/schema.sql)** | **Master DDL PostgreSQL (16 Tabel Utuh)**.<br/>Mencakup ekstensi UUID/pgcrypto, custom ENUMs, foreign keys, triggers tier spending, stored procedure `extend_parking_session`, dan realtime publication. | Digunakan jika ingin membuat seluruh struktur tabel via Supabase SQL Editor dari awal. |
| **[`lib/database/seed.sql`](lib/database/seed.sql)** | **Master Seed SQL Murni**.<br/>Query `INSERT INTO` untuk seluruh 16 tabel (7 lokasi, 84 slot, admin, user, kyc, games, payments). | Digunakan jika ingin menyuntikkan data via Supabase SQL Editor tanpa menjalankan skrip terminal. |
| **[`RAT.md`](RAT.md)** | **Diagram Relasi Antar Tabel (RAT / ERD)**.<br/>Visualisasi kardinalitas antar 16 entitas dalam format box-drawing dan skema relasional. | Sangat penting untuk pelaporan akademik, skripsi, dan dokumentasi arsitektur. |
| **[`supabase.md`](supabase.md)** & **[`CREATEsupabase.md`](CREATEsupabase.md)** | **Kamus Data & Spesifikasi Teknis Database**.<br/>Dokumentasi tipe data, enkripsi, dan panduan konfigurasi manual. | Rujukan teknis backend dan arsitektur keamanan data. |
| **[`lib/database/migrations/`](lib/database/migrations/)** | **Arsip Riwayat Migrasi (Changelog)**.<br/>Rekam jejak tahapan penambahan blockchain, auto-spent trigger, dan realtime. | Bersifat historis (*seluruh isinya sudah terkonsolidasi utuh di dalam `schema.sql`*). |

---

<p align="center">
  Dibuat dengan dedikasi untuk penyelesaian <b>Project Akhir Teori Mobile</b>.<br/>
  © 2026 <b>ParkSmart ID Team</b>. Hak Cipta Dilindungi Undang-Undang.
</p>
