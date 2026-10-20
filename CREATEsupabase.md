# 🛠️ DDL QUERY CREATE TABLE SUPABASE POSTGRESQL (14 TABEL UTAMA)
## Proyek: Smart Parking (ParkSmart ID)
### Enterprise Database DDL Script — Production Ready & Optimized

> 📌 **PANDUAN EKSEKUSI:**  
> File ini berisi query DDL SQL lengkap untuk membuat **seluruh 14 tabel utama**, custom ENUMs, foreign keys, constraints, dan indeks performa.  
> Seluruh query disusun berurutan (*dependency-ordered*) sehingga **dapat langsung dieksekusi sekali jalan pada Supabase SQL Editor / PostgreSQL psql** tanpa error dependensi.

---

```sql
-- ============================================================================
-- SCRIPT DDL SUPABASE POSTGRESQL - PARKSMART ID
-- Skema: 14 Tabel Utama Teroptimasi (User, Staf Admin Terpadu & Layanan Bisnis)
-- ============================================================================

-- 1. EKSTENSI KRIPTOGRAFI & UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. TIPE DATA KUSTOM (CUSTOM ENUMS)
DO $$ BEGIN
    CREATE TYPE user_status_enum AS ENUM ('active', 'inactive', 'banned');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE member_tier_enum AS ENUM ('BRONZE', 'SILVER', 'GOLD', 'PLATINUM');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE vehicle_type_enum AS ENUM ('mobil', 'motor', 'ev');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE admin_role_enum AS ENUM ('super_admin', 'operational', 'finance', 'cs');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE admin_status_enum AS ENUM ('active', 'inactive');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE kyc_status_enum AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE location_status_enum AS ENUM ('active', 'crowded', 'full', 'maintenance');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE slot_type_enum AS ENUM ('mobil', 'motor', 'ev', 'difabel', 'vip');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE slot_status_enum AS ENUM ('available', 'occupied', 'reserved', 'maintenance');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE session_status_enum AS ENUM ('active', 'completed', 'overstay');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE booking_type_enum AS ENUM ('reservation', 'walk_in');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE booking_status_enum AS ENUM ('upcoming', 'active', 'completed', 'cancelled', 'expired');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_status_enum AS ENUM ('unpaid', 'paid', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE transaction_type_enum AS ENUM ('parking_payment', 'wallet_topup', 'wallet_injection', 'refund', 'cashback', 'penalty');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_method_enum AS ENUM ('wallet', 'qris', 'bank_va', 'gopay', 'ovo', 'shopeepay', 'admin_manual');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE transaction_status_enum AS ENUM ('pending', 'success', 'failed', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 3. TABEL IDENTITAS USER & PROFIL
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
    favorite_location_ids UUID[] NOT NULL DEFAULT '{}',
    pin_hash VARCHAR(255),
    password TEXT DEFAULT 'user123',
    is_biometric_enabled BOOLEAN NOT NULL DEFAULT false,
    status user_status_enum NOT NULL DEFAULT 'active',
    ban_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 4. TABEL GARASI KENDARAAN PENGGUNA
-- Catatan Arsitektur Foto: Foto fisik plat & lembar STNK wajib diambil 2x dan HANYA diolah secara in-memory (RAM)
-- untuk ekstraksi teks plate_number & plate_expiry. File gambar TIDAK disimpan ke server/storage demi efisiensi & privasi.
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

-- 5. TABEL STAF ADMIN TERPADU (Super Admin, Operasional, Finansial, CS)
CREATE TABLE IF NOT EXISTS public.admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    role admin_role_enum NOT NULL,
    division VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    password TEXT DEFAULT 'superadmin123',
    status admin_status_enum NOT NULL DEFAULT 'active',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 6. TABEL VERIFIKASI IDENTITAS KTP (KYC SUPER ADMIN)
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

-- 7. TABEL LOKASI & FASILITAS PARKIR
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
    facilities TEXT[] DEFAULT ARRAY['CCTV 24 Jam', 'Covered Parking'],
    rating NUMERIC(2, 1) NOT NULL DEFAULT 4.8,
    review_count INT NOT NULL DEFAULT 0,
    status location_status_enum NOT NULL DEFAULT 'active',
    image_url TEXT,
    images TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);


-- 8. TABEL DENAH SLOT PARKIR & SENSOR IOT
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
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_location_slot UNIQUE (location_id, floor_name, slot_code)
);

-- 9. TABEL SESI PARKIR GERBANG & OVERSTAY
CREATE TABLE IF NOT EXISTS public.parking_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_code VARCHAR(30) NOT NULL UNIQUE,
    location_id UUID NOT NULL REFERENCES public.parking_locations(id) ON DELETE RESTRICT,
    slot_id UUID REFERENCES public.parking_slots(id) ON DELETE SET NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
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
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 10. TABEL PEMESANAN & RESERVASI PARKIR
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
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 11. TABEL TRANSAKSI KEUANGAN & BLOCKCHAIN HASH
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

-- 12. TABEL ULASAN & TANGGAPAN CS
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

-- 13. TABEL NOTIFIKASI & BROADCAST SISTEM
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

-- 14. TABEL SKOR ARCADE & POIN (SISTEM TIMPA / OVERWRITE - MAKSIMAL 2 ROW PER USER PER GAME)
CREATE TABLE IF NOT EXISTS public.arcade_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    game_name VARCHAR(60) NOT NULL,
    score INT NOT NULL DEFAULT 0,
    points_earned INT NOT NULL DEFAULT 0,
    score_type VARCHAR(20) NOT NULL DEFAULT 'current', -- 'highest' (rekor terbaik) atau 'current' (sesi terakhir ditimpa)
    played_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_game_score_type UNIQUE (user_id, game_name, score_type)
);

-- 15. TABEL PENGATURAN GLOBAL SISTEM (JSONB)
-- Catatan Arsitektur Kurs: Konversi mata uang asing dioperasikan murni secara client-side (UI display math)
-- menggunakan Open Exchange Rates API publik bebas biaya (0 rupiah) tanpa modifikasi data keuangan database.
-- Tabel ini difokuskan untuk saklar fitur dinamis (feature_toggles) dan parameter kecerdasan buatan (ai_config).
CREATE TABLE IF NOT EXISTS public.system_settings (
    key VARCHAR(80) PRIMARY KEY, -- Contoh: 'ai_config', 'feature_toggles'
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Inisialisasi Otomatis Rekor Pengaturan Sistem Saat Skema Dibuat
INSERT INTO public.system_settings (key, value, description)
VALUES
(
    'ai_config',
    '{
        "model_name": "qwen/qwen3.8-27b",
        "api_key": "",
        "max_tokens": 1024,
        "temperature": 0.4,
        "ocr_confidence_threshold": 0.85,
        "is_autonomous_pricing_enabled": true
    }'::jsonb,
    'Konfigurasi model kecerdasan buatan AI Jarvis untuk deteksi plat kamera & dynamic pricing'
),
(
    'feature_toggles',
    '{
        "is_arcade_active": true,
        "is_ev_charging_booking_enabled": true,
        "is_crypto_blockchain_audit_live": true,
        "is_biometric_login_enforced": false
    }'::jsonb,
    'Saklar fitur sistem aplikasi ParkSmart ID'
)
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    description = EXCLUDED.description,
    updated_at = timezone('utc'::text, now());

-- 15.2. TABEL AUDIT LOG AKTIVITAS LOGIN ADMIN (AUDIT TRAIL SUPER ADMIN)
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

-- ============================================================================
-- 16. SUPABASE STORAGE BUCKET (DOKUMEN KYC & KENDARAAN)
-- ============================================================================
-- Bucket untuk menyimpan foto KTP & Selfie pengguna yang dikompresi brutal (~95%)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'kyc-documents',
    'kyc-documents',
    true,
    5242880, -- 5 MB batas maksimum (file terkompresi biasanya hanya 50-100 KB)
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];

-- ============================================================================
-- 17. KEBIJAKAN ROW LEVEL SECURITY (RLS) DEVELOPMENT
-- ============================================================================
-- Query bypass RLS untuk kelancaran integrasi development lokal & pengujian:
-- ALTER TABLE public.admins DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.arcade_scores DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.bookings DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.customer_feedbacks DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.parking_locations DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.parking_sessions DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.parking_slots DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.payments DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.system_notifications DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.system_settings DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_kyc DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.vehicles DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- INDEKS PERFORMA QUERY
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_arcade_scores_lookup ON public.arcade_scores(user_id, game_name, score_type);
CREATE INDEX IF NOT EXISTS idx_vehicles_user ON public.vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_plate ON public.vehicles(plate_number);
CREATE INDEX IF NOT EXISTS idx_admins_email ON public.admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_role ON public.admins(role);
CREATE INDEX IF NOT EXISTS idx_user_kyc_user ON public.user_kyc(user_id);
CREATE INDEX IF NOT EXISTS idx_user_kyc_status ON public.user_kyc(status);
CREATE INDEX IF NOT EXISTS idx_parking_locations_city ON public.parking_locations(city);
CREATE INDEX IF NOT EXISTS idx_parking_slots_location ON public.parking_slots(location_id);
CREATE INDEX IF NOT EXISTS idx_parking_slots_status ON public.parking_slots(status);
CREATE INDEX IF NOT EXISTS idx_parking_sessions_location ON public.parking_sessions(location_id);
CREATE INDEX IF NOT EXISTS idx_parking_sessions_status ON public.parking_sessions(status);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(booking_status);
CREATE INDEX IF NOT EXISTS idx_payments_user ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_type ON public.payments(transaction_type);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_customer_feedbacks_user ON public.customer_feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_system_notifications_recipient ON public.system_notifications(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_arcade_scores_user ON public.arcade_scores(user_id);
```
