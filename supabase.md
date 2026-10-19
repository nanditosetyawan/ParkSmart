# 🗄️ SUPABASE DATABASE SCHEMA & SPECIFICATION (POSTGRESQL)
## Proyek: Smart Parking (ParkSmart ID)
### Enterprise Database Architecture — Production Ready (Optimized & Essential)

> 📌 **STATUS DOKUMEN: SINKRONISASI AKTIF & ITERATIF DARI KODE SUMBER**  
> **Prinsip Utama:** Skema ringkas, teroptimasi, bebas tabel redundan, dan 100% akurat sesuai kode aplikasi `lib/features/`.  
> **Tata Kelola Admin:** Seluruh role admin (Super Admin, Operasional, Finansial, CS) digabung ke dalam 1 tabel terpadu `admins` berbasis RBAC.

---

## 📑 DAFTAR TABEL DATABASE (RINGKAS & TEROPTIMASI)

| No | Nama Tabel | Modul / Klaster | Deskripsi Entitas |
|:---:|:---|:---|:---|
| 1 | `users` | User & Profil | Identitas akun pengguna, profil, saldo dompet, poin, status & PIN keamanan |
| 2 | `vehicles` | User & Kendaraan | Garasi kendaraan terdaftar, nomor polisi (TNKB), tipe kendaraan & foto |
| 3 | `admins` | Admin Terpadu | Akun staf portal (Super Admin, Operasional, Finansial, CS) dalam 1 tabel |
| 4 | `user_kyc` | Super Admin & KYC | Verifikasi identitas KTP & biometrik wajah pengguna oleh Super Admin |
| 5 | `parking_locations` | Operasional | Master lokasi mall/gedung, koordinat GPS, kapasitas & tarif dasar |
| 6 | `parking_slots` | Operasional | Denah slot fisik (lantai, nomor slot, tipe, status IoT sensor) |
| 7 | `parking_sessions` | Operasional | Sesi kendaraan masuk gerbang, durasi parkir, overstay penalty & tarif |
| 8 | `bookings` | Booking & Reservasi | Pemesanan slot parkir (reservasi di muka / walk-in), durasi & QR pass |
| 9 | `payments` | Finansial & Billing | Buku besar transaksi digital (parkir, top-up, injeksi, denda, refund & hash blockchain) |
| 10 | `customer_feedbacks` | Customer Service | Ulasan bintang 1-5, masukan fasilitas & tanggapan keluhan pengguna |
| 11 | `system_notifications` | CS & Sistem | Siaran pesan broadcast, promo tarif & notifikasi peringatan operasional |
| 12 | `arcade_scores` | Gamifikasi & Poin | Riwayat skor mini-game (Car & Claws) serta perolehan SmartPoints pengguna |
| 13 | `system_settings` | Super Admin | Konfigurasi variabel global (AI Jarvis, kurs valuta, feature toggles JSONB) |

---

## 1. TIPE DATA KUSTOM (CUSTOM ENUMS) & EKSTENSI

```sql
-- Ekstensi UUID dan Kriptografi
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enum Status Pengguna
DO $$ BEGIN
    CREATE TYPE user_status_enum AS ENUM ('active', 'inactive', 'banned');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Tier Membership Pengguna
DO $$ BEGIN
    CREATE TYPE member_tier_enum AS ENUM ('BRONZE', 'SILVER', 'GOLD', 'PLATINUM');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Kategori Kendaraan
DO $$ BEGIN
    CREATE TYPE vehicle_type_enum AS ENUM ('mobil', 'motor', 'ev');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Role Admin Terpadu (Super Admin, Operasional, Finansial, CS)
DO $$ BEGIN
    CREATE TYPE admin_role_enum AS ENUM ('super_admin', 'operational', 'finance', 'cs');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Akun Admin
DO $$ BEGIN
    CREATE TYPE admin_status_enum AS ENUM ('active', 'inactive');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Verifikasi KYC (Super Admin)
DO $$ BEGIN
    CREATE TYPE kyc_status_enum AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Lokasi Fasilitas Parkir
DO $$ BEGIN
    CREATE TYPE location_status_enum AS ENUM ('active', 'crowded', 'full', 'maintenance');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Tipe Slot Parkir
DO $$ BEGIN
    CREATE TYPE slot_type_enum AS ENUM ('mobil', 'motor', 'ev', 'difabel', 'vip');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Slot Parkir & IoT Sensor
DO $$ BEGIN
    CREATE TYPE slot_status_enum AS ENUM ('available', 'occupied', 'reserved', 'maintenance');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Sesi Parkir Gerbang
DO $$ BEGIN
    CREATE TYPE session_status_enum AS ENUM ('active', 'completed', 'overstay');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Tipe Pemesanan Parkir
DO $$ BEGIN
    CREATE TYPE booking_type_enum AS ENUM ('reservation', 'walk_in');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Pemesanan Parkir
DO $$ BEGIN
    CREATE TYPE booking_status_enum AS ENUM ('upcoming', 'active', 'completed', 'cancelled', 'expired');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Pelunasan Pembayaran
DO $$ BEGIN
    CREATE TYPE payment_status_enum AS ENUM ('unpaid', 'paid', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Tipe Transaksi Keuangan
DO $$ BEGIN
    CREATE TYPE transaction_type_enum AS ENUM ('parking_payment', 'wallet_topup', 'wallet_injection', 'refund', 'cashback', 'penalty');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Metode Pembayaran
DO $$ BEGIN
    CREATE TYPE payment_method_enum AS ENUM ('wallet', 'qris', 'bank_va', 'gopay', 'ovo', 'shopeepay', 'admin_manual');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Enum Status Transaksi Buku Besar
DO $$ BEGIN
    CREATE TYPE transaction_status_enum AS ENUM ('pending', 'success', 'failed', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
```

---

## 2. KLASTER 1: IDENTITAS USER, KENDARAAN & ADMIN TERPADU

### Tabel 1: `users`
Menyimpan seluruh data profil pengguna aplikasi mobile, saldo dompet terintegrasi (*ParkSmart Pay*), akumulasi SmartPoints, level keanggotaan, serta keamanan akun (PIN & Biometrik).
* **File Rujukan Kode:** `lib/features/auth/`, `lib/features/profile/profile_screen.dart`, `edit_profile_screen.dart`, `pin_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    avatar_url TEXT,
    gender VARCHAR(20) DEFAULT 'Laki-laki',
    birth_date DATE,
    address TEXT,
    wallet_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (wallet_balance >= 0),
    points INT NOT NULL DEFAULT 0 CHECK (points >= 0),
    member_tier member_tier_enum NOT NULL DEFAULT 'BRONZE',
    total_parking_count INT NOT NULL DEFAULT 0,
    total_savings NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    theme_mode VARCHAR(20) NOT NULL DEFAULT 'system',
    favorite_location_ids UUID[] NOT NULL DEFAULT '{}',
    pin_hash VARCHAR(255),
    is_biometric_enabled BOOLEAN NOT NULL DEFAULT false,
    status user_status_enum NOT NULL DEFAULT 'active',
    ban_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(status);
```

---

### Tabel 2: `vehicles`
Menyimpan garasi kendaraan pengguna yang digunakan untuk kalkulasi tarif gerbang, reservasi slot, dan auto-detect nomor plat (TNKB) via AI OCR Kamera.
* **File Rujukan Kode:** `lib/features/profile/vehicle_screen.dart`, `lib/features/vehicle/add_vehicle_screen.dart`, `custom_camera_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plate_number VARCHAR(20) NOT NULL,
    vehicle_type vehicle_type_enum NOT NULL DEFAULT 'mobil',
    vehicle_category VARCHAR(30) DEFAULT 'suv', -- 'suv', 'sedan', 'motor', 'ev'
    brand VARCHAR(60) NOT NULL,
    model VARCHAR(80) NOT NULL,
    color VARCHAR(40) NOT NULL,
    plate_expiry VARCHAR(10),
    photo_url TEXT,
    stnk_photo_url TEXT,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_plate UNIQUE (user_id, plate_number)
);

CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON public.vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_plate_number ON public.vehicles(plate_number);
```

---

### Tabel 3: `admins` (Identitas Admin Terpadu)
Menggabungkan seluruh akun pengelola sistem: **Super Admin, Admin Operasional, Admin Finansial, dan Admin CS** ke dalam 1 tabel terpusat dengan pembagian wewenang role-based access control (RBAC).
* **File Rujukan Kode:** `lib/features/admin/super_admin/admin_user_management_screen.dart`, `admin_dashboard_screen.dart`, `admin_operations_dashboard_screen.dart`, `admin_finance_dashboard_screen.dart`, `admin_cs_dashboard_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    role admin_role_enum NOT NULL,
    division VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    status admin_status_enum NOT NULL DEFAULT 'active',
    assigned_location_id UUID, -- Referensi ke lokasi parkir tertentu (jika role operasional lapangan)
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_admins_email ON public.admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_role ON public.admins(role);
CREATE INDEX IF NOT EXISTS idx_admins_status ON public.admins(status);
```

---

### Tabel 4: `user_kyc` (Verifikasi KTP & Biometrik — Super Admin)
Menyimpan pengajuan verifikasi identitas resmi pengguna (KTP, NIK 16 digit, data demografi, foto KTP, dan foto biometrik selfie) yang diperiksa dan divalidasi langsung secara eksklusif oleh **Super Admin**.
* **File Rujukan Kode:** `lib/features/admin/super_admin/admin_kyc_screen.dart`, `admin_kyc_detail_modal.dart`, `lib/features/profile/ktp_camera_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.user_kyc (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    nik VARCHAR(16) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    birth_place_city VARCHAR(100),
    birth_date DATE NOT NULL,
    address TEXT NOT NULL,
    gender VARCHAR(20) NOT NULL,
    religion VARCHAR(30),
    occupation VARCHAR(100),
    ktp_image_url TEXT NOT NULL,
    selfie_image_url TEXT,
    status kyc_status_enum NOT NULL DEFAULT 'pending',
    reject_reason TEXT,
    reviewed_by UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_user_kyc_user_id ON public.user_kyc(user_id);
CREATE INDEX IF NOT EXISTS idx_user_kyc_nik ON public.user_kyc(nik);
CREATE INDEX IF NOT EXISTS idx_user_kyc_status ON public.user_kyc(status);
```

---

## 3. KLASTER 2: OPERASIONAL & FASILITAS PARKIR

### Tabel 5: `parking_locations` (Master Fasilitas Lokasi & Tarif)
Menyimpan seluruh data gedung, mall, atau area parkir mitra, titik koordinat GPS untuk peta & geofencing radius check-in, kapasitas total dan breakdown per kategori kendaraan, serta skema tarif dasar.
* **File Rujukan Kode:** `lib/features/admin/operations/admin_locations_screen.dart`, `manage_parking_screen.dart`, `lib/features/parking/parking_detail_screen.dart`, `lib/features/map/explore_map_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.parking_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL UNIQUE, -- Contoh: 'LOC-001'
    name VARCHAR(150) NOT NULL,       -- Contoh: 'Central Park Mall'
    type VARCHAR(50) NOT NULL DEFAULT 'Parkiran Mall', -- 'Parkiran Mall', 'Parkir Khusus EV', 'Gedung Parkir'
    city VARCHAR(80) NOT NULL,        -- Contoh: 'Jakarta Barat'
    province VARCHAR(80) NOT NULL,    -- Contoh: 'DKI Jakarta'
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    checkin_radius_meters INT NOT NULL DEFAULT 150,
    total_capacity INT NOT NULL DEFAULT 0,
    car_slots_capacity INT NOT NULL DEFAULT 0,
    motor_slots_capacity INT NOT NULL DEFAULT 0,
    ev_slots_capacity INT NOT NULL DEFAULT 0,
    hourly_rate_mobil NUMERIC(10, 2) NOT NULL DEFAULT 5000.00,
    hourly_rate_motor NUMERIC(10, 2) NOT NULL DEFAULT 2000.00,
    hourly_rate_ev NUMERIC(10, 2) NOT NULL DEFAULT 7500.00,
    operating_hours VARCHAR(100) NOT NULL DEFAULT 'Buka 24 Jam',
    facilities TEXT[] DEFAULT ARRAY['CCTV 24 Jam', 'Covered Parking'],
    rating NUMERIC(2, 1) NOT NULL DEFAULT 4.8,
    review_count INT NOT NULL DEFAULT 0,
    status location_status_enum NOT NULL DEFAULT 'active',
    image_url TEXT,
    images TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_parking_locations_city ON public.parking_locations(city);
CREATE INDEX IF NOT EXISTS idx_parking_locations_status ON public.parking_locations(status);
```

---

### Tabel 6: `parking_slots` (Denah Slot Fisik & Sensor IoT)
Representasi fisik spot parkir per lantai/zona pada fasilitas gedung, memonitor status ketersediaan secara real-time yang terhubung dengan sensor IoT.
* **File Rujukan Kode:** `lib/features/admin/operations/admin_slot_management_screen.dart`, `manage_parking_screen.dart`, `lib/features/booking/slot_selection_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.parking_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES public.parking_locations(id) ON DELETE CASCADE,
    floor_name VARCHAR(50) NOT NULL,     -- Contoh: 'Basement 1', 'Lantai 2', 'Area Outdoor'
    slot_code VARCHAR(30) NOT NULL,      -- Contoh: 'A-01', 'B-01 (EV Fast)', 'C-05'
    slot_type slot_type_enum NOT NULL DEFAULT 'mobil',
    status slot_status_enum NOT NULL DEFAULT 'available',
    sensor_device_id VARCHAR(60),        -- ID hardware sensor ultrasonik/kamera IoT
    current_plate_number VARCHAR(20),    -- Plat nomor kendaraan yang sedang mengisi slot
    occupied_since TIMESTAMPTZ,          -- Waktu mulai terisi
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_location_slot UNIQUE (location_id, floor_name, slot_code)
);

CREATE INDEX IF NOT EXISTS idx_parking_slots_location ON public.parking_slots(location_id);
CREATE INDEX IF NOT EXISTS idx_parking_slots_status ON public.parking_slots(status);
CREATE INDEX IF NOT EXISTS idx_parking_slots_type ON public.parking_slots(slot_type);
```

---

### Tabel 7: `parking_sessions` (Monitoring Sesi Gerbang & Overstay)
Mencatat sesi parkir aktif di lapangan saat kendaraan melakukan tap-in/scan QR di gerbang masuk hingga keluar, menghitung akumulasi durasi parkir, mendeteksi overstay, serta mengkalkulasi denda penalti.
* **File Rujukan Kode:** `lib/features/admin/operations/admin_active_users_screen.dart`, `lib/features/session/active_session_screen.dart`, `checkin_screen.dart`, `expiring_session_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.parking_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_code VARCHAR(30) NOT NULL UNIQUE, -- Contoh: 'SES-9901'
    location_id UUID NOT NULL REFERENCES public.parking_locations(id) ON DELETE RESTRICT,
    slot_id UUID REFERENCES public.parking_slots(id) ON DELETE SET NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    plate_number VARCHAR(20) NOT NULL,
    vehicle_type vehicle_type_enum NOT NULL DEFAULT 'mobil',
    vehicle_desc VARCHAR(100),                -- Contoh: 'Toyota Fortuner Putih'
    check_in_time TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    expected_check_out_time TIMESTAMPTZ,
    check_out_time TIMESTAMPTZ,
    parking_fee NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    is_overstay BOOLEAN NOT NULL DEFAULT false,
    overstay_minutes INT NOT NULL DEFAULT 0,
    overstay_penalty_fee NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total_fee NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    status session_status_enum NOT NULL DEFAULT 'active',
    gate_in_id VARCHAR(50),
    gate_out_id VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_parking_sessions_location ON public.parking_sessions(location_id);
CREATE INDEX IF NOT EXISTS idx_parking_sessions_plate ON public.parking_sessions(plate_number);
CREATE INDEX IF NOT EXISTS idx_parking_sessions_status ON public.parking_sessions(status);
```

---

## 4. KLASTER 3: BOOKING & RESERVASI PARKIR

### Tabel 8: `bookings` (Pemesanan Slot & Tiket QR Pass)
Menyimpan riwayat dan data reservasi tempat parkir oleh pengguna aplikasi, baik reservasi di muka (*Advance Reservation*) maupun pembuatan tiket langsung (*Walk-in*), kode verifikasi QR pass, durasi jam, dan status hangus/pembatalan.
* **File Rujukan Kode:** `lib/features/booking/booking_confirmation_screen.dart`, `slot_selection_screen.dart`, `lib/features/admin/operations/admin_bookings_screen.dart`, `lib/features/history/history_detail_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_code VARCHAR(35) NOT NULL UNIQUE, -- Contoh: 'BKG-20240315-001'
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    location_id UUID NOT NULL REFERENCES public.parking_locations(id) ON DELETE RESTRICT,
    slot_id UUID REFERENCES public.parking_slots(id) ON DELETE SET NULL,
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE SET NULL,
    booking_type booking_type_enum NOT NULL DEFAULT 'reservation',
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    duration_hours INT NOT NULL DEFAULT 1,
    total_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    payment_status payment_status_enum NOT NULL DEFAULT 'unpaid',
    booking_status booking_status_enum NOT NULL DEFAULT 'upcoming',
    qr_code_hash TEXT NOT NULL,
    cancel_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_location_id ON public.bookings(location_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(booking_status);
CREATE INDEX IF NOT EXISTS idx_bookings_start_time ON public.bookings(start_time);
```

---

## 5. KLASTER 4: FINANSIAL, BILLING & TRANSAKSI

### Tabel 9: `payments` (Buku Besar Keuangan & Blockchain Hash)
Mencatat seluruh arus keluar-masuk uang digital sistem ParkSmart: pembayaran parkir, top-up dompet pengguna, penalti overstay, refund pembatalan, cashback loyalty, serta injeksi saldo manual oleh **Admin Finansial / Super Admin**. Dilengkapi dengan hash kriptografi SHA-256 untuk audit on-chain & bukti validitas transaksi anti-manipulasi.
* **File Rujukan Kode:** `lib/features/admin/finance/admin_transactions_screen.dart`, `admin_wallet_screen.dart`, `revenue_screen.dart`, `lib/features/checkout/checkout_screen.dart`, `lib/features/profile/payment_methods_screen.dart`, `lib/features/history/verified_parking_sessions_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_code VARCHAR(40) NOT NULL UNIQUE, -- Contoh: 'TXN-20240315-001'
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    session_id UUID REFERENCES public.parking_sessions(id) ON DELETE SET NULL,
    processed_by_admin_id UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    transaction_type transaction_type_enum NOT NULL DEFAULT 'parking_payment',
    payment_method payment_method_enum NOT NULL DEFAULT 'wallet',
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    admin_note TEXT,                              -- Catatan khusus admin (misal saat injeksi/kompensasi)
    blockchain_hash VARCHAR(66),                  -- Hash kriptografi bukti validasi SHA-256 (0x...)
    status transaction_status_enum NOT NULL DEFAULT 'success',
    completed_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_type ON public.payments(transaction_type);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at);
```

---

## 6. KLASTER 5: CUSTOMER SERVICE & NOTIFIKASI SISTEM

### Tabel 10: `customer_feedbacks` (Review & Tanggapan CS)
Menyimpan penilaian bintang (1-5), ulasan teks, saran perbaikan fasilitas, dan respons resmi yang diberikan oleh **Admin Customer Service**.
* **File Rujukan Kode:** `lib/features/admin/cs/admin_feedback_screen.dart`, `lib/features/profile/feedback_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.customer_feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    location_id UUID REFERENCES public.parking_locations(id) ON DELETE SET NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    admin_reply TEXT,
    replied_by_admin_id UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    is_resolved BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    replied_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_customer_feedbacks_user ON public.customer_feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_customer_feedbacks_location ON public.customer_feedbacks(location_id);
CREATE INDEX IF NOT EXISTS idx_customer_feedbacks_rating ON public.customer_feedbacks(rating);
```

---

### Tabel 11: `system_notifications` (Broadcast & Notifikasi Admin)
Mencatat seluruh notifikasi push dan siaran pesan (*broadcast promo*, peringatan overstay, kendala teknis gerbang, dan info keamanan akun). Jika `recipient_user_id` bernilai NULL, maka pesan berstatus broadcast publik ke seluruh pengguna.
* **File Rujukan Kode:** `lib/features/admin/cs/admin_notifications_screen.dart`, `lib/features/notification/notification_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.system_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_admin_id UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    recipient_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE, -- NULL = broadcast ke semua user
    target_role VARCHAR(50) NOT NULL DEFAULT 'all', -- 'all', 'user', 'operational', 'finance', 'cs', 'super_admin'
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(40) NOT NULL DEFAULT 'info', -- 'info', 'promo', 'security', 'alert'
    action_type VARCHAR(60), -- Contoh: 'Cek Overstay', 'Cek Dompet', 'Lihat Ulasan', 'Verifikasi KYC'
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_system_notifications_recipient ON public.system_notifications(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_system_notifications_target_role ON public.system_notifications(target_role);
```

---

## 7. KLASTER 6: GAMIFIKASI & PENGATURAN GLOBAL SISTEM

### Tabel 12: `arcade_scores` (SmartPoints & Game Balap)
Menyimpan catatan pencapaian skor dan koin loyalitas (*SmartPoints*) yang didapatkan oleh pengemudi saat memainkan game interaktif (*ParkSmart Car Game* & *Claws Car Machine*).
* **File Rujukan Kode:** `lib/features/game/car_game_screen.dart`, `claws_car_screen.dart`, `lib/features/admin/super_admin/admin_arcade_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.arcade_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    game_name VARCHAR(60) NOT NULL, -- 'car_game', 'claws_car'
    score INT NOT NULL DEFAULT 0,
    points_earned INT NOT NULL DEFAULT 0,
    played_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_arcade_scores_user ON public.arcade_scores(user_id);
CREATE INDEX IF NOT EXISTS idx_arcade_scores_game ON public.arcade_scores(game_name);
```

---

### Tabel 13: `system_settings` (Konfigurasi Global Super Admin)
Struktur tabel variabel dinamis berbasis Key-Value (JSONB) yang mengontrol konfigurasi kecerdasan buatan (*AI Jarvis Engine*), nilai tukar 8 mata uang asing, parameter tarif denda & grace period, serta fitur toggle sistem secara instan tanpa perlu re-deploy aplikasi.
* **File Rujukan Kode:** `lib/features/admin/super_admin/admin_app_settings_screen.dart`, `admin_ai_config_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.system_settings (
    key VARCHAR(80) PRIMARY KEY, -- 'ai_config', 'currency_rates', 'feature_toggles', 'pricing_multipliers'
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);
```
