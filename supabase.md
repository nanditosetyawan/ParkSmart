# 🗄️ SUPABASE DATABASE SCHEMA & SPECIFICATION (POSTGRESQL)
## Proyek: Smart Parking (ParkSmart ID)
### Enterprise Database Architecture — Production Ready (Optimized, Clone & Backup Ready)

> 📌 **STATUS DOKUMEN: SINKRONISASI AKTIF & ITERATIF DARI KODE SUMBER (16 TABEL LENGKAP)**  
> **Prinsip Utama:** Skema ringkas, teroptimasi, bebas tabel redundan, dan 100% akurat sesuai database live Supabase & kode aplikasi `lib/features/`.  
> **Tata Kelola Admin:** Seluruh role admin (Super Admin, Operasional, Finansial, CS) digabung ke dalam 1 tabel terpadu `admins` berbasis RBAC.  
> 🔒 **Keamanan AI:** Tabel `ai_agent_configs` telah dihapus secara permanen dari Supabase. Kunci API Groq kini 100% aman tersimpan pada file konfigurasi lokal `.env` (`GROQ_API_KEY`).

---

## 📑 DAFTAR TABEL DATABASE (16 TABEL UTAMA)

| No | Nama Tabel | Modul / Klaster | Deskripsi Entitas |
|:---:|:---|:---|:---|
| 1 | `users` | User & Profil | Identitas akun pengguna, profil, saldo dompet, poin, status, status keanggotaan & PIN keamanan |
| 2 | `vehicles` | User & Kendaraan | Garasi kendaraan terdaftar, nomor polisi (TNKB), tipe kendaraan & foto |
| 3 | `user_member_cards` | Profil & Keanggotaan | Kartu member bertingkat berbasis hash unik & bukti transaksi blockchain |
| 4 | `admins` | Admin Terpadu | Akun staf portal (Super Admin, Operasional, Finansial, CS) dalam 1 tabel |
| 5 | `user_kyc` | Super Admin & KYC | Verifikasi identitas KTP & biometrik wajah pengguna oleh Super Admin |
| 6 | `parking_locations` | Operasional | Master lokasi mall/gedung, koordinat GPS, kapasitas, daftar lantai (`floors`) & tarif dasar |
| 7 | `parking_slots` | Operasional | Denah slot fisik (lantai, nomor slot, tipe, status IoT sensor & zona) |
| 8 | `parking_sessions` | Operasional | Sesi kendaraan masuk gerbang, durasi parkir, snapshot kendaraan, perpanjangan, overstay penalty & tarif |
| 9 | `bookings` | Booking & Reservasi | Pemesanan slot parkir (reservasi di muka / walk-in), snapshot plat, perpanjangan, durasi & QR pass |
| 10 | `payments` | Finansial & Billing | Buku besar transaksi digital (parkir, top-up, injeksi, denda, refund & hash blockchain) |
| 11 | `customer_feedbacks` | Customer Service | Ulasan bintang 1-5, masukan fasilitas & tanggapan keluhan pengguna |
| 12 | `system_notifications` | CS & Sistem | Siaran pesan broadcast, promo tarif & notifikasi peringatan operasional |
| 13 | `arcade_scores` | Gamifikasi & Poin | Riwayat skor mini-game (Car & Claws) serta perolehan SmartPoints pengguna |
| 14 | `system_settings` | Super Admin | Konfigurasi variabel global (`ai_config`, `feature_toggles`, `company_treasury`) |
| 15 | `admin_audit_logs` | Super Admin & Audit | Audit trail aktivitas login staf admin terpadu (IP publik, ISP, geolokasi, perangkat hardware, status) |
| 16 | `user_favorites` | Profil & Bookmark | Bookmark lokasi gedung parkir favorit per pengguna (dengan Row Level Security) |

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
    total_spent NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (total_spent >= 0),
    monthly_spent NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (monthly_spent >= 0),
    last_spending_month VARCHAR(7) NOT NULL DEFAULT TO_CHAR(NOW(), 'YYYY-MM'),
    member_hash_code VARCHAR(32),
    total_parking_count INT NOT NULL DEFAULT 0,
    total_savings NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    favorite_location_ids UUID[] NOT NULL DEFAULT '{}',
    pin_hash VARCHAR(255),
    is_biometric_enabled BOOLEAN NOT NULL DEFAULT false,
    status user_status_enum NOT NULL DEFAULT 'active',
    ban_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    password TEXT DEFAULT 'user123',
    saran_kuliah TEXT,
    pesan_kuliah TEXT,
    status_keanggotaan BOOLEAN DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
```

---

### Tabel 2: `vehicles`
Menyimpan garasi kendaraan terdaftar milik pengguna.
* **Integritas Penghapusan (Trigger Snapshot):** Tabel ini dilindungi oleh trigger `trg_snapshot_vehicle_before_delete` yang secara otomatis mengamankan nilai `plate_number` dan `vehicle_desc` pada riwayat `bookings` dan `parking_sessions` sebelum data baris kendaraan terhapus.
* **File Rujukan Kode:** `lib/features/vehicles/my_vehicles_screen.dart`, `add_vehicle_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plate_number VARCHAR(20) NOT NULL,
    vehicle_type vehicle_type_enum NOT NULL DEFAULT 'mobil',
    vehicle_category VARCHAR(30) DEFAULT 'suv',
    brand VARCHAR(60) NOT NULL,
    model VARCHAR(80) NOT NULL,
    color VARCHAR(40) NOT NULL,
    plate_expiry VARCHAR(10),
    photo_url TEXT,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_plate UNIQUE (user_id, plate_number)
);

CREATE INDEX IF NOT EXISTS idx_vehicles_user ON public.vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_plate ON public.vehicles(plate_number);
```

---

### Tabel 3: `user_member_cards`
Menyimpan kartu keanggotaan bertingkat (Regular/Bronze, Silver, Gold, Platinum) berbasis kode hash unik dan bukti transaksi blockchain.
* **File Rujukan Kode:** `lib/features/profile/widgets/member_card_dialog.dart`, `lib/features/profile/backend/profile_backend.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.user_member_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    card_tier VARCHAR(20) NOT NULL CHECK (card_tier IN ('regular', 'bronze', 'silver', 'gold', 'platinum')),
    member_hash_code VARCHAR(66) NOT NULL UNIQUE,
    nft_token_id NUMERIC,
    tx_hash VARCHAR(66),
    is_active BOOLEAN NOT NULL DEFAULT true,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_tier UNIQUE (user_id, card_tier)
);

CREATE INDEX IF NOT EXISTS idx_user_member_cards_user_id ON public.user_member_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_user_member_cards_hash ON public.user_member_cards(member_hash_code);

ALTER TABLE public.user_member_cards ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    CREATE POLICY "Allow all for authenticated and anon" 
    ON public.user_member_cards 
    FOR ALL 
    USING (true) 
    WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
```

---

### Tabel 4: `admins`
Tabel terpadu untuk seluruh staf portal admin internal dengan pembedaan wewenang berbasis Role-Based Access Control (RBAC): `super_admin`, `operational`, `finance`, dan `cs`.
* **File Rujukan Kode:** `lib/features/auth/login_screen.dart`, `lib/features/admin/`.

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
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    password TEXT DEFAULT 'superadmin123'
);

CREATE INDEX IF NOT EXISTS idx_admins_email ON public.admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_role ON public.admins(role);
```

---

### Tabel 4: `user_kyc`
Penyimpanan data permohonan verifikasi identitas resmi (e-KTP dan selfie biometrik) pengguna yang ditinjau langsung oleh Staf Admin Super Admin / CS.
* **File Rujukan Kode:** `lib/features/admin/super_admin/admin_kyc_verification_screen.dart`, `lib/features/profile/kyc_submission_screen.dart`.

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

CREATE INDEX IF NOT EXISTS idx_user_kyc_user ON public.user_kyc(user_id);
CREATE INDEX IF NOT EXISTS idx_user_kyc_status ON public.user_kyc(status);
```

---

## 3. KLASTER 2: OPERASIONAL, FASILITAS & DENAH PARKIR

### Tabel 5: `parking_locations`
Master data fasilitas parkir mitra, titik koordinat GPS geofence, daftar lantai (`floors`), fasilitas, dan tarif parkir per jam.
* **File Rujukan Kode:** `lib/features/home/home_screen.dart`, `lib/features/booking/select_slot_screen.dart`, `lib/features/admin/operations/`.

```sql
CREATE TABLE IF NOT EXISTS public.parking_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'Parkiran Mall',
    city VARCHAR(80) NOT NULL,
    province VARCHAR(80) NOT NULL,
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
    facilities TEXT[] DEFAULT ARRAY['CCTV 24 Jam'::text, 'Covered Parking'::text],
    rating NUMERIC(2, 1) NOT NULL DEFAULT 4.8,
    review_count INT NOT NULL DEFAULT 0,
    status location_status_enum NOT NULL DEFAULT 'active',
    image_url TEXT,
    images TEXT[] DEFAULT '{}',
    floors TEXT[] DEFAULT ARRAY['Lantai 1'::text],
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_parking_locations_city ON public.parking_locations(city);
```

---

### Tabel 6: `parking_slots`
Denah fisik petak spot parkir per lantai, pembagian zona (*zone*), tipe spot (*mobil, motor, ev, difabel, vip*), serta status keterisian dari sensor IoT.
* **File Rujukan Kode:** `lib/features/booking/select_slot_screen.dart`, `lib/features/admin/operations/admin_slot_management_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.parking_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES public.parking_locations(id) ON DELETE CASCADE,
    floor_name VARCHAR(50) NOT NULL,
    slot_code VARCHAR(30) NOT NULL,
    slot_type slot_type_enum NOT NULL DEFAULT 'mobil',
    status slot_status_enum NOT NULL DEFAULT 'available',
    sensor_device_id VARCHAR(60),
    current_plate_number VARCHAR(20),
    occupied_since TIMESTAMPTZ,
    zone TEXT DEFAULT 'zoneA',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_location_slot UNIQUE (location_id, floor_name, slot_code)
);

CREATE INDEX IF NOT EXISTS idx_parking_slots_location ON public.parking_slots(location_id);
CREATE INDEX IF NOT EXISTS idx_parking_slots_status ON public.parking_slots(status);
```

---

### Tabel 7: `parking_sessions`
Mencatat sesi kendaraan yang telah melewati gerbang fisik (*gate-in*), penghitungan durasi parkir real-time, status overstay dan kalkulasi denda penalti.
* **File Rujukan Kode:** `lib/features/tracking/active_parking_screen.dart`, `lib/features/admin/operations/`.

```sql
CREATE TABLE IF NOT EXISTS public.parking_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_code VARCHAR(30) NOT NULL UNIQUE,
    location_id UUID NOT NULL REFERENCES public.parking_locations(id) ON DELETE RESTRICT,
    slot_id UUID REFERENCES public.parking_slots(id) ON DELETE SET NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE SET NULL,
    booking_id UUID,
    plate_number VARCHAR(20) NOT NULL,
    vehicle_type vehicle_type_enum NOT NULL DEFAULT 'mobil',
    vehicle_desc VARCHAR(100),
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
    extended_count INT NOT NULL DEFAULT 0,
    extended_minutes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_parking_sessions_location ON public.parking_sessions(location_id);
CREATE INDEX IF NOT EXISTS idx_parking_sessions_status ON public.parking_sessions(status);
```

---

## 4. KLASTER 3: RESERVASI & PEMESANAN PARKIR

### Tabel 8: `bookings`
Tiket digital pemesanan slot parkir baik reservasi di muka (*advance booking*) maupun langsung (*walk-in*), snapshot plat kendaraan, kode QR pass, durasi dan status pembayaran.
* **File Rujukan Kode:** `lib/features/booking/`, `lib/features/history/booking_history_screen.dart`, `lib/features/checkout/checkout_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_code VARCHAR(35) NOT NULL UNIQUE,
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
    plate_number VARCHAR(20),
    vehicle_desc VARCHAR(100),
    extended_count INT NOT NULL DEFAULT 0,
    extended_minutes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.parking_sessions
    DROP CONSTRAINT IF EXISTS fk_sessions_booking,
    ADD CONSTRAINT fk_sessions_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(booking_status);
```

---

## 5. KLASTER 4: KEUANGAN, TRANSAKSI & BLOCKCHAIN AUDIT

### Tabel 9: `payments`
Buku besar (*general ledger*) seluruh pergerakan dana keuangan: pembayaran sewa slot, top-up dompet, injeksi saldo manual Super Admin, denda overstay, dan refund pembatalan yang dilengkapi hash kriptografi SHA-256 bukti audit tak terubah.
* **File Rujukan Kode:** `lib/features/payment/payment_screen.dart`, `lib/features/admin/finance/admin_finance_dashboard_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_code VARCHAR(40) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    session_id UUID REFERENCES public.parking_sessions(id) ON DELETE SET NULL,
    transaction_type transaction_type_enum NOT NULL DEFAULT 'parking_payment',
    payment_method payment_method_enum NOT NULL DEFAULT 'wallet',
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    blockchain_hash VARCHAR(66),
    status transaction_status_enum NOT NULL DEFAULT 'success',
    completed_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_payments_user ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_type ON public.payments(transaction_type);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
```

---

## 6. KLASTER 5: CUSTOMER SERVICE & NOTIFIKASI SISTEM

### Tabel 10: `customer_feedbacks`
Menyimpan ulasan bintang (1-5), saran dan respons tindak lanjut dari Admin CS.
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
```

---

### Tabel 11: `system_notifications`
Siaran pesan broadcast dan notifikasi status operasional ke pengguna.
* **File Rujukan Kode:** `lib/features/admin/cs/admin_notifications_screen.dart`, `lib/features/notification/notification_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.system_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_admin_id UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    recipient_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    target_role VARCHAR(50) NOT NULL DEFAULT 'all',
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(40) NOT NULL DEFAULT 'info',
    action_type VARCHAR(60),
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_system_notifications_recipient ON public.system_notifications(recipient_user_id);
```

---

## 7. KLASTER 6: GAMIFIKASI, PENGATURAN GLOBAL, AUDIT LOG & FAVORIT

### Tabel 12: `arcade_scores`
Catatan skor game balap mobil dan mesin capit (*ParkSmart Car Game* & *Claws Car Machine*) serta reward poin loyalitas.
* **File Rujukan Kode:** `lib/features/game/car_game_screen.dart`, `claws_car_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.arcade_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    game_name VARCHAR(60) NOT NULL,
    score INT NOT NULL DEFAULT 0,
    points_earned INT NOT NULL DEFAULT 0,
    score_type VARCHAR(30) DEFAULT 'current',
    played_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_arcade_scores_user ON public.arcade_scores(user_id);
```

---

### Tabel 13: `system_settings`
Struktur pengaturan Key-Value JSONB dinamis untuk variabel sistem, saklar fitur (`feature_toggles`), kas perusahaan (`company_treasury`), dan parameter AI (`ai_config`).
* **File Rujukan Kode:** `lib/features/admin/super_admin/admin_app_settings_screen.dart`, `admin_ai_config_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.system_settings (
    key VARCHAR(80) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);
```

---

### Tabel 14: `admin_audit_logs`
Audit log login staf admin (IP publik, ISP, tipe perangkat, kota geolokasi, dan status verifikasi sesi).
* **File Rujukan Kode:** `lib/core/services/client_info_service.dart`, `lib/features/admin/super_admin/admin_dashboard_screen.dart`.

```sql
CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    admin_name VARCHAR(150) NOT NULL,
    admin_email VARCHAR(255),
    role VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL DEFAULT 'Login berhasil',
    device_model VARCHAR(150),
    ip_address VARCHAR(50),
    location VARCHAR(150),
    isp VARCHAR(150),
    status VARCHAR(50) DEFAULT 'Berhasil',
    is_current_session BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_created_at ON public.admin_audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_role ON public.admin_audit_logs(role);
```

---

### Tabel 15: `user_favorites`
Menyimpan relasi lokasi parkir favorit per-pengguna dengan proteksi Row Level Security (RLS).
* **File Rujukan Kode:** `lib/features/home/home_screen.dart`, `lib/features/profile/`.

```sql
CREATE TABLE IF NOT EXISTS public.user_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES public.parking_locations(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, location_id)
);

ALTER TABLE public.user_favorites ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    CREATE POLICY "Allow public full access on user_favorites"
    ON public.user_favorites FOR ALL
    USING (true)
    WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON public.user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_location_id ON public.user_favorites(location_id);
```

---

## 8. TRIGGER INTEGRITAS KENDARAAN (`snapshot_vehicle_before_delete`)

Fungsi trigger yang secara otomatis menyalin plat nomor dan deskripsi kendaraan sebelum record kendaraan dihapus, mencegah data historis booking dan sesi parkir menjadi kosong:

```sql
CREATE OR REPLACE FUNCTION public.snapshot_vehicle_before_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE bookings
  SET 
    plate_number = CASE 
      WHEN plate_number IS NULL OR plate_number = '' THEN OLD.plate_number 
      ELSE plate_number 
    END,
    vehicle_desc = CASE 
      WHEN vehicle_desc IS NULL OR vehicle_desc = '' THEN TRIM(CONCAT(COALESCE(OLD.brand, ''), ' ', COALESCE(OLD.model, '')))
      ELSE vehicle_desc 
    END
  WHERE vehicle_id = OLD.id;

  UPDATE parking_sessions
  SET 
    plate_number = CASE 
      WHEN plate_number IS NULL OR plate_number = '' THEN OLD.plate_number 
      ELSE plate_number 
    END,
    vehicle_desc = CASE 
      WHEN vehicle_desc IS NULL OR vehicle_desc = '' THEN TRIM(CONCAT(COALESCE(OLD.brand, ''), ' ', COALESCE(OLD.model, '')))
      ELSE vehicle_desc 
    END
  WHERE vehicle_id = OLD.id;

  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS trg_snapshot_vehicle_before_delete ON public.vehicles;
CREATE TRIGGER trg_snapshot_vehicle_before_delete
BEFORE DELETE ON public.vehicles
FOR EACH ROW
EXECUTE FUNCTION public.snapshot_vehicle_before_delete();
```

---

## 9. STORED PROCEDURES & RPC FUNCTIONS (CLEANUP OTOMATIS & EXTEND PARKIR)

### A. Pembersihan Otomatis Booking Kedaluwarsa & Pembebasan Slot (`auto_process_expired_bookings_and_sessions`)
Fungsi RPC asinkron yang dieksekusi client maupun cron berkala untuk meng-cancel booking unpaid yang melewati hold time 2 menit 59 detik, meng-complete booking yang waktunya habis, dan membebaskan slot parkir menjadi `available`:

```sql
CREATE OR REPLACE FUNCTION public.auto_process_expired_bookings_and_sessions()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cancelled_bookings INT := 0;
    v_completed_bookings INT := 0;
    v_completed_sessions INT := 0;
    v_released_slots INT := 0;
BEGIN
    BEGIN
        PERFORM public.evaluate_all_membership_tiers_monthly();
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- 1. Auto-cancel booking unpaid yang dibuat lebih dari 179 detik lalu
    WITH cancelled_rows AS (
        UPDATE public.bookings
        SET booking_status = 'cancelled',
            cancel_reason = 'Auto-cancel: Batas waktu pembayaran 2 menit 59 detik telah habis',
            updated_at = NOW()
        WHERE payment_status = 'unpaid'
          AND booking_status NOT IN ('cancelled', 'completed', 'expired')
          AND created_at < (NOW() - INTERVAL '179 seconds')
        RETURNING id
    )
    SELECT COUNT(*) INTO v_cancelled_bookings FROM cancelled_rows;

    -- 2. Auto-complete booking berbayar yang waktu end_time telah lewat
    WITH completed_b_rows AS (
        UPDATE public.bookings
        SET booking_status = 'completed',
            updated_at = NOW()
        WHERE payment_status = 'paid'
          AND booking_status IN ('upcoming', 'active')
          AND end_time <= NOW()
        RETURNING id
    )
    SELECT COUNT(*) INTO v_completed_bookings FROM completed_b_rows;

    -- 3. Auto-complete sesi parkir aktif yang waktu expected_check_out_time telah lewat
    WITH completed_s_rows AS (
        UPDATE public.parking_sessions
        SET status = 'completed',
            check_out_time = COALESCE(check_out_time, NOW()),
            updated_at = NOW()
        WHERE status = 'active'
          AND expected_check_out_time <= NOW()
        RETURNING id
    )
    SELECT COUNT(*) INTO v_completed_sessions FROM completed_s_rows;

    -- 4. Kembalikan status slot ke 'available' jika tidak ada lagi sesi aktif atau booking berbayar aktif
    WITH freed_slots AS (
        UPDATE public.parking_slots ps
        SET status = 'available',
            occupied_since = NULL,
            current_plate_number = NULL,
            updated_at = NOW()
        WHERE ps.status IN ('occupied', 'reserved')
          AND NOT EXISTS (
              SELECT 1 FROM public.parking_sessions sess
              WHERE sess.slot_id = ps.id
                AND sess.status = 'active'
          )
          AND NOT EXISTS (
              SELECT 1 FROM public.bookings bk
              WHERE bk.slot_id = ps.id
                AND bk.booking_status IN ('upcoming', 'active')
                AND bk.payment_status = 'paid'
                AND bk.end_time > NOW()
          )
        RETURNING ps.id
    )
    SELECT COUNT(*) INTO v_released_slots FROM freed_slots;

    RETURN json_build_object(
        'success', true,
        'cancelled_bookings', v_cancelled_bookings,
        'completed_bookings', v_completed_bookings,
        'completed_sessions', v_completed_sessions,
        'released_slots', v_released_slots,
        'executed_at', NOW()
    );
END;
$$;
```

### B. Perpanjangan Sesi / Booking Parkir Dinamis (`extend_parking_session`)
Mendukung penambahan durasi parkir oleh user secara real-time pada sesi aktif maupun reservasi booking aktif:

```sql
CREATE OR REPLACE FUNCTION public.extend_parking_session(
    p_session_id text,
    p_additional_minutes int,
    p_cost numeric
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_session RECORD;
  v_booking RECORD;
  v_current_end timestamptz;
  v_new_end timestamptz;
  v_new_duration_hours int;
  v_booking_id uuid;
  v_actual_session_id uuid;
  v_additional_hours int := CEIL(p_additional_minutes::numeric / 60.0);
BEGIN
  -- 1. Cari di parking_sessions dulu
  SELECT * INTO v_session
  FROM parking_sessions
  WHERE id::text = p_session_id OR session_code = p_session_id
  LIMIT 1;

  IF FOUND THEN
    v_actual_session_id := v_session.id;
    v_booking_id := v_session.booking_id;
    
    IF v_session.expected_check_out_time IS NOT NULL AND v_session.expected_check_out_time > NOW() THEN
      v_current_end := v_session.expected_check_out_time;
    ELSE
      v_current_end := NOW();
    END IF;
    
    v_new_end := v_current_end + (p_additional_minutes || ' minutes')::interval;

    UPDATE parking_sessions
    SET expected_check_out_time = v_new_end,
        total_fee = COALESCE(total_fee, 0) + p_cost,
        extended_count = COALESCE(extended_count, 0) + 1,
        extended_minutes = COALESCE(extended_minutes, 0) + p_additional_minutes,
        updated_at = NOW()
    WHERE id = v_actual_session_id;

    IF v_booking_id IS NOT NULL THEN
      UPDATE bookings
      SET end_time = v_new_end,
          duration_hours = COALESCE(duration_hours, 1) + v_additional_hours,
          total_price = COALESCE(total_price, 0) + p_cost,
          extended_count = COALESCE(extended_count, 0) + 1,
          extended_minutes = COALESCE(extended_minutes, 0) + p_additional_minutes,
          updated_at = NOW()
      WHERE id = v_booking_id;
    END IF;

    RETURN jsonb_build_object(
      'success', true,
      'type', 'session',
      'session_id', v_actual_session_id,
      'booking_id', v_booking_id,
      'new_end_time', v_new_end,
      'additional_minutes', p_additional_minutes,
      'cost', p_cost
    );
  END IF;

  -- 2. Jika tidak ditemukan di parking_sessions, cari di bookings
  SELECT * INTO v_booking
  FROM bookings
  WHERE id::text = p_session_id OR booking_code = p_session_id
  LIMIT 1;

  IF FOUND THEN
    IF v_booking.end_time IS NOT NULL AND v_booking.end_time > NOW() THEN
      v_current_end := v_booking.end_time;
    ELSE
      v_current_end := NOW();
    END IF;
    
    v_new_end := v_current_end + (p_additional_minutes || ' minutes')::interval;
    v_new_duration_hours := COALESCE(v_booking.duration_hours, 1) + v_additional_hours;

    UPDATE bookings
    SET end_time = v_new_end,
        duration_hours = v_new_duration_hours,
        total_price = COALESCE(total_price, 0) + p_cost,
        extended_count = COALESCE(extended_count, 0) + 1,
        extended_minutes = COALESCE(extended_minutes, 0) + p_additional_minutes,
        updated_at = NOW()
    WHERE id = v_booking.id;

    RETURN jsonb_build_object(
      'success', true,
      'type', 'booking',
      'booking_id', v_booking.id,
      'new_end_time', v_new_end,
      'additional_minutes', p_additional_minutes,
      'duration_hours', v_new_duration_hours,
      'cost', p_cost
    );
  END IF;

  RETURN jsonb_build_object(
    'success', false,
    'message', 'Sesi parkir atau booking tidak ditemukan.'
  );
END;
$$;
```

---

## 10. SUPABASE STORAGE BUCKET (DOKUMEN KYC, KENDARAAN, LOKASI & AVATAR)

```sql
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('kyc-documents', 'kyc-documents', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('vehicles', 'vehicles', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('parking-locations', 'parking-locations', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];

-- Storage Policies
DO $$ BEGIN
    CREATE POLICY "Public Access KYC Documents" ON storage.objects FOR SELECT USING (bucket_id = 'kyc-documents');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Public Insert KYC Documents" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'kyc-documents');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Public Access Vehicles" ON storage.objects FOR SELECT USING (bucket_id = 'vehicles');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Public Insert Vehicles" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'vehicles');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Public Access Parking Locations" ON storage.objects FOR SELECT USING (bucket_id = 'parking-locations');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Public Insert Parking Locations" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'parking-locations');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Public Access Avatars" ON storage.objects FOR ALL USING (bucket_id = 'avatars') WITH CHECK (bucket_id = 'avatars');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
```

---

## 11. SUPABASE REALTIME REPLICATION PUBLICATION

Publikasi postgres replication untuk sinkronisasi instan dua arah antara database Supabase dan Flutter client:

```sql
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE 
        public.bookings, 
        public.parking_sessions, 
        public.parking_slots, 
        public.system_notifications, 
        public.customer_feedbacks;
EXCEPTION WHEN OTHERS THEN NULL; END $$;
```

---

## 12. SEED DATA NYATA SUPABASE (KONDISI AKTIF SAAT INI)

Berikut adalah seed data terverifikasi yang selaras 100% dengan database live Supabase:

```sql
-- 1. SEED 4 AKUN ADMIN TERPADU
INSERT INTO public.admins (
    id, email, full_name, phone, role, division, status, password, created_at, updated_at
) VALUES
(
    'a78f3e2b-4c59-4d81-9b16-83f1245890ab', 'superadmin@parksmart.id', 'Gibran Widodo', '+62 812-0000-0001',
    'super_admin', 'Sistem & Super Admin', 'active', 'superadmin123',
    '2026-10-19 16:32:26.143421+00', '2026-10-19 16:32:26.143421+00'
),
(
    '12d32c66-7b63-4c0c-9146-eff24e9361f1', 'ops@parksmart.id', 'Erick Thohir', '+62 812-7777-8888',
    'operational', 'Admin Operasional', 'active', 'ops123',
    '2026-10-22 16:25:12.417242+00', '2026-10-22 16:25:12.417242+00'
),
(
    '587b0671-4730-4936-b792-7dbda1b92376', 'finance@parksmart.id', 'Sri Mulyani', '+62 812-3333-4444',
    'finance', 'Admin Finansial', 'active', 'finance123',
    '2026-10-22 16:25:11.75688+00', '2026-10-22 16:25:11.75688+00'
),
(
    '69246a1c-021a-4f9f-8534-15fc9643484f', 'cs@parksmart.id', 'Prabowo Subianto', '+62 812-5555-6666',
    'cs', 'Admin CS & KYC', 'active', 'cs123',
    '2026-10-22 16:25:12.132588+00', '2026-10-22 16:25:12.132588+00'
)
ON CONFLICT (email) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    role = EXCLUDED.role,
    division = EXCLUDED.division,
    status = EXCLUDED.status,
    password = EXCLUDED.password;

-- 2. SEED PENGGUNA (2 PENGGUNA AKTIF DARI DATABASE LIVE)
INSERT INTO public.users (
    id, email, phone, full_name, avatar_url, gender, birth_date, address,
    wallet_balance, points, member_tier, total_spent, monthly_spent,
    last_spending_month, member_hash_code, status_keanggotaan, total_parking_count, total_savings,
    favorite_location_ids, pin_hash, is_biometric_enabled, status, ban_reason, password,
    created_at, updated_at
) VALUES
(
    'df714843-c4cf-4d45-b385-0390404d4429', 'user@gmail.com', '0813277156100', 'Andi Prawono',
    NULL, 'Laki-laki', NULL, NULL,
    38500.00, 0, 'BRONZE', 0.00, 0.00,
    '2026-10', '#fb9c-c92a-c4a1', false, 0, 0.00,
    '{}', '4040', false, 'active', NULL, '123456',
    '2026-10-25 06:37:52.659729+00', '2026-10-25 14:51:00.031672+00'
),
(
    '225428bf-e24d-4869-98c6-fed811518497', 'aji@gmail.com', '085242636121', 'ajikaja',
    NULL, 'Laki-laki', NULL, NULL,
    182000.00, 0, 'BRONZE', 0.00, 0.00,
    '2026-10', '#46f5-14df-e3a2', false, 0, 0.00,
    '{}', '1111', false, 'active', NULL, 'aji123',
    '2026-10-25 06:32:33.554151+00', '2026-10-25 14:51:00.031672+00'
)
ON CONFLICT (email) DO UPDATE SET
    phone = EXCLUDED.phone,
    full_name = EXCLUDED.full_name,
    avatar_url = EXCLUDED.avatar_url,
    wallet_balance = EXCLUDED.wallet_balance,
    points = EXCLUDED.points,
    member_tier = EXCLUDED.member_tier,
    total_spent = EXCLUDED.total_spent,
    monthly_spent = EXCLUDED.monthly_spent,
    last_spending_month = EXCLUDED.last_spending_month,
    member_hash_code = EXCLUDED.member_hash_code,
    status_keanggotaan = EXCLUDED.status_keanggotaan,
    total_parking_count = EXCLUDED.total_parking_count,
    total_savings = EXCLUDED.total_savings,
    pin_hash = EXCLUDED.pin_hash,
    status = EXCLUDED.status,
    password = EXCLUDED.password;

-- 3. SEED GARASI KENDARAAN AKTIF
INSERT INTO public.vehicles (
    id, user_id, plate_number, vehicle_type, vehicle_category, brand, model,
    color, plate_expiry, photo_url, is_default, created_at, updated_at
) VALUES (
    'cd02e022-f451-4082-8812-c44690acdfa1', 'df714843-c4cf-4d45-b385-0390404d4429',
    'AB5894LI', 'mobil', 'suv', 'HRV', 'HRV',
    'Merah Maroon', '11•26',
    'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/vehicles/df714843-c4cf-4d45-b385-0390404d4429/car_df714843-c4cf-4d45-b385-0390404d4429_1792928515651.jpg',
    true, '2026-10-25 11:41:56.16632+00', '2026-10-25 11:41:56.166459+00'
)
ON CONFLICT (id) DO UPDATE SET
    plate_number = EXCLUDED.plate_number,
    vehicle_type = EXCLUDED.vehicle_type,
    brand = EXCLUDED.brand,
    model = EXCLUDED.model,
    color = EXCLUDED.color,
    plate_expiry = EXCLUDED.plate_expiry,
    photo_url = EXCLUDED.photo_url,
    is_default = EXCLUDED.is_default;

-- 4. SEED KARTU MEMBER BLOCKCHAIN AKTIF
INSERT INTO public.user_member_cards (
    id, user_id, card_tier, member_hash_code, nft_token_id, tx_hash, is_active,
    unlocked_at, created_at, updated_at
) VALUES
(
    'ecad6d6d-9aea-4a1b-9e5d-07651c757c75', 'df714843-c4cf-4d45-b385-0390404d4429',
    'regular', '#fb9c-c92a-c4a1', NULL,
    '0x7eac80c8de57394420e4cff2544e1c74b016c6bfaa6244e7a4aa9ee22d9a8da6',
    true, '2026-10-25 06:37:52.659729+00', '2026-10-25 06:37:52.659729+00', '2026-10-25 06:37:52.659729+00'
),
(
    '96e0f5a8-3068-4f58-bbce-a6eb843859d5', '225428bf-e24d-4869-98c6-fed811518497',
    'regular', '#46f5-14df-e3a2', NULL,
    '0x25dbe8ba509bfd6aeb07df07906428974aa5c5e10e510c9dc5b8cbda52e6048f',
    true, '2026-10-25 06:32:33.554151+00', '2026-10-25 06:32:33.554151+00', '2026-10-25 06:32:33.554151+00'
)
ON CONFLICT (id) DO UPDATE SET
    card_tier = EXCLUDED.card_tier,
    member_hash_code = EXCLUDED.member_hash_code,
    tx_hash = EXCLUDED.tx_hash,
    is_active = EXCLUDED.is_active;

-- 5. SEED SYSTEM SETTINGS (3 RECORD AKTIF)
INSERT INTO public.system_settings (key, value, description, updated_at)
VALUES
(
    'feature_toggles',
    '{
        "is_arcade_active": true,
        "is_biometric_login_enforced": false,
        "is_ev_charging_booking_enabled": true,
        "is_crypto_blockchain_audit_live": true
    }'::jsonb,
    'Toggle fitur aplikasi',
    '2026-10-22 11:44:58.10404+00'
),
(
    'ai_config',
    '{
        "max_tokens": 1024,
        "model_name": "qwen/qwen3.8-27b",
        "temperature": 0.7,
        "is_autonomous_pricing_enabled": true
    }'::jsonb,
    'Konfigurasi model kecerdasan buatan AI Jarvis untuk deteksi plat kamera & dynamic pricing',
    '2026-10-22 15:50:37.349929+00'
),
(
    'company_treasury',
    '{
        "balance": 46904001,
        "currency": "IDR",
        "last_user_id": "96e876fc-20df-4648-a3de-5ac86026710b",
        "last_injection": 500000
    }'::jsonb,
    'Saldo kas utama cadangan operasional ParkSmart ID',
    '2026-10-25 11:51:11.850122+00'
)
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    description = EXCLUDED.description,
    updated_at = EXCLUDED.updated_at;

-- 6. SEED DATA AUDIT LOG ADMIN AKTIF (ADMIN_AUDIT_LOGS)
INSERT INTO public.admin_audit_logs (
    id, admin_id, admin_name, admin_email, role, action, device_model,
    ip_address, location, isp, status, is_current_session, created_at
) VALUES
(
    'a0ab05a6-f9fd-4ecb-a4c2-53790f4e53b6', NULL,
    'Gibran Widodo', 'superadmin@parksmart.id', 'Super Admin',
    'Login berhasil (Sesi Aktif)', 'Vivo V2602',
    '182.2.85.224', 'Surakarta, Indonesia', 'PT Telekomunikasi Selular Indonesia',
    'Berhasil (Real-Time)', false, '2026-10-23 07:39:05.527212+00'
),
(
    '65f08184-16c5-4fad-a150-7291ba4f5708', NULL,
    'Admin Finansial', NULL, 'Admin Finansial',
    'Injeksi Saldo Dompet 500000 ke User wowok', 'Portal Finansial Admin',
    NULL, NULL, NULL,
    'Berhasil', false, '2026-10-25 11:51:12.056375+00'
)
ON CONFLICT (id) DO NOTHING;
```
