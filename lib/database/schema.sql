-- ============================================================================
-- SCRIPT DDL POSTGRESQL / SUPABASE - PARKSMART ID
-- Path: lib/database/schema.sql
-- Skema: 16 Tabel Utama Teroptimasi & User-Oriented
-- Siap dieksekusi sekali jalan (Dependency-Ordered)
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
    total_spent NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (total_spent >= 0),
    monthly_spent NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (monthly_spent >= 0),
    last_spending_month VARCHAR(7) NOT NULL DEFAULT TO_CHAR(NOW(), 'YYYY-MM'),
    member_hash_code VARCHAR(66),
    status_keanggotaan BOOLEAN NOT NULL DEFAULT false,
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
    pesan_kuliah TEXT
);

-- 4. TABEL GARASI KENDARAAN PENGGUNA
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

-- 4.1. TABEL KARTU KEANGGOTAAN BLOCKCHAIN MULTI-TIER
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

DROP POLICY IF EXISTS "Allow all for authenticated and anon" ON public.user_member_cards;
CREATE POLICY "Allow all for authenticated and anon" 
ON public.user_member_cards 
FOR ALL 
USING (true) 
WITH CHECK (true);

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
    status admin_status_enum NOT NULL DEFAULT 'active',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    password TEXT DEFAULT 'superadmin123'
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
    facilities TEXT[] DEFAULT ARRAY['CCTV 24 Jam'::text, 'Covered Parking'::text],
    rating NUMERIC(2, 1) NOT NULL DEFAULT 0.0,
    review_count INT NOT NULL DEFAULT 0,
    status location_status_enum NOT NULL DEFAULT 'active',
    image_url TEXT,
    images TEXT[] DEFAULT '{}',
    floors TEXT[] DEFAULT ARRAY['Lantai 1'::text],
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
    zone TEXT DEFAULT 'zoneA',
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
    booking_id UUID, -- Relasi foreign key ditambahkan setelah tabel bookings
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
    plate_number VARCHAR(20),
    vehicle_desc VARCHAR(100),
    extended_count INT NOT NULL DEFAULT 0,
    extended_minutes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Relasi Booking pada Parking Sessions
ALTER TABLE public.parking_sessions
    DROP CONSTRAINT IF EXISTS fk_sessions_booking,
    ADD CONSTRAINT fk_sessions_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL;

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

-- 14. TABEL SKOR ARCADE & POIN
CREATE TABLE IF NOT EXISTS public.arcade_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    game_name VARCHAR(60) NOT NULL,
    score INT NOT NULL DEFAULT 0,
    points_earned INT NOT NULL DEFAULT 0,
    score_type VARCHAR(30) DEFAULT 'current',
    played_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 15. TABEL PENGATURAN GLOBAL SISTEM (JSONB)
CREATE TABLE IF NOT EXISTS public.system_settings (
    key VARCHAR(80) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 16. TABEL AUDIT LOG AKTIVITAS LOGIN ADMIN (AUDIT TRAIL SUPER ADMIN)
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

-- 17. TABEL LOKASI PARKIR FAVORIT PENGGUNA (PER-USER FAVORITE PARKING)
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

-- ============================================================================
-- 18. FUNGSI DAN TRIGGER (TRIGGER SNAPSHOT KENDARAAN)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.snapshot_vehicle_before_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Snapshot ke bookings yang merujuk kendaraan ini
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

  -- Snapshot ke parking_sessions yang merujuk kendaraan ini
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

-- ============================================================================
-- 19. SUPABASE STORAGE BUCKET (DOKUMEN KYC, KENDARAAN, LOKASI & AVATAR)
-- ============================================================================
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

-- ============================================================================
-- 20. INDEKS PERFORMA QUERY
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_created_at ON public.admin_audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_role ON public.admin_audit_logs(role);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
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
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON public.user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_location_id ON public.user_favorites(location_id);
CREATE INDEX IF NOT EXISTS idx_users_member_tier ON public.users(member_tier);

-- ============================================================================
-- 21. FUNGSI & TRIGGER MEMBERSHIP TIER, REGISTRASI & AUTO-EVALUATE
-- ============================================================================

-- 21.1. Trigger Saat Registrasi User Baru: Generate Member Hash Awal
CREATE OR REPLACE FUNCTION public.trg_user_before_insert_membership()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := gen_random_uuid();
    END IF;

    IF NEW.member_hash_code IS NULL OR TRIM(NEW.member_hash_code) = '' THEN
        NEW.member_hash_code := '#' || SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 1, 4) || '-' ||
                                      SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 5, 4) || '-' ||
                                      SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 9, 4);
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_before_insert ON public.users;
CREATE TRIGGER trg_user_before_insert
BEFORE INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.trg_user_before_insert_membership();

-- 21.2. Trigger Setelah Registrasi User Baru: Terbitkan Kartu Bronze / Regular
CREATE OR REPLACE FUNCTION public.trg_user_after_insert_membership()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
    VALUES (NEW.id, 'regular', NEW.member_hash_code, true, NOW())
    ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_create_membership ON public.users;
CREATE TRIGGER trg_user_create_membership
AFTER INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.trg_user_after_insert_membership();

-- 21.3. Trigger Auto-Evaluate Saat Update total_spent (Penanganan Inject Database Manual)
CREATE OR REPLACE FUNCTION public.trg_auto_evaluate_spent_membership()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_tier member_tier_enum;
    v_tier_hash VARCHAR(66);
    v_tx_hash VARCHAR(66);
    v_active_hash VARCHAR(66);
BEGIN
    IF (OLD.total_spent IS DISTINCT FROM NEW.total_spent) OR (OLD.member_tier IS NULL) THEN
        
        -- Evaluasi Tier Berdasarkan Total Spent Pengguna:
        -- Bronze: < Rp 100.000
        -- Silver: >= Rp 100.000
        -- Gold: >= Rp 200.000
        -- Platinum: >= Rp 500.000
        IF NEW.total_spent >= 500000 THEN
            v_new_tier := 'PLATINUM';
        ELSIF NEW.total_spent >= 200000 THEN
            v_new_tier := 'GOLD';
        ELSIF NEW.total_spent >= 100000 THEN
            v_new_tier := 'SILVER';
        ELSE
            v_new_tier := 'BRONZE';
        END IF;

        NEW.member_tier := v_new_tier;

        -- 1. Kartu BRONZE/REGULAR selalu aktif
        v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 9, 4);

        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
        VALUES (NEW.id, 'regular', v_tier_hash, (v_new_tier = 'BRONZE'), NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier 
        DO UPDATE SET is_active = (v_new_tier = 'BRONZE');

        v_active_hash := v_tier_hash;

        -- 2. Kartu SILVER jika total_spent >= 100.000
        IF NEW.total_spent >= 100000 THEN
            v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_silver_parksmart'), 1, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_silver_parksmart'), 5, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_silver_parksmart'), 9, 4);

            INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
            VALUES (NEW.id, 'silver', v_tier_hash, (v_new_tier = 'SILVER'), NOW())
            ON CONFLICT ON CONSTRAINT uq_user_tier 
            DO UPDATE SET is_active = (v_new_tier = 'SILVER');

            IF v_new_tier = 'SILVER' THEN
                v_active_hash := v_tier_hash;
            END IF;
        ELSE
            DELETE FROM public.user_member_cards umc WHERE umc.user_id = NEW.id AND umc.card_tier = 'silver';
        END IF;

        -- 3. Kartu GOLD jika total_spent >= 200.000
        IF NEW.total_spent >= 200000 THEN
            v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_gold_parksmart'), 1, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_gold_parksmart'), 5, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_gold_parksmart'), 9, 4);

            INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
            VALUES (NEW.id, 'gold', v_tier_hash, (v_new_tier = 'GOLD'), NOW())
            ON CONFLICT ON CONSTRAINT uq_user_tier 
            DO UPDATE SET is_active = (v_new_tier = 'GOLD');

            IF v_new_tier = 'GOLD' THEN
                v_active_hash := v_tier_hash;
            END IF;
        ELSE
            DELETE FROM public.user_member_cards umc WHERE umc.user_id = NEW.id AND umc.card_tier = 'gold';
        END IF;

        -- 4. Kartu PLATINUM jika total_spent >= 500.000
        IF NEW.total_spent >= 500000 THEN
            v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_platinum_parksmart'), 1, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_platinum_parksmart'), 5, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_platinum_parksmart'), 9, 4);

            INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
            VALUES (NEW.id, 'platinum', v_tier_hash, (v_new_tier = 'PLATINUM'), NOW())
            ON CONFLICT ON CONSTRAINT uq_user_tier 
            DO UPDATE SET is_active = (v_new_tier = 'PLATINUM');

            IF v_new_tier = 'PLATINUM' THEN
                v_active_hash := v_tier_hash;
            END IF;
        ELSE
            DELETE FROM public.user_member_cards umc WHERE umc.user_id = NEW.id AND umc.card_tier = 'platinum';
        END IF;

        NEW.member_hash_code := v_active_hash;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_spent_membership ON public.users;
CREATE TRIGGER trg_user_spent_membership
BEFORE UPDATE OF total_spent ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.trg_auto_evaluate_spent_membership();

-- 21.4. Fungsi Prosedural Evaluasi Tier Pengguna Berdasarkan Belanja Transaksi
-- Bronze (< 100k), Silver (>= 100k), Gold (>= 200k), Platinum (>= 500k)
-- Syarat Bertahan di Platinum: Belanja bulanan >= 700k. Jika tidak, turun bertahap ke Gold.
CREATE OR REPLACE FUNCTION public.evaluate_user_membership_tier(
    p_user_id UUID,
    p_additional_spend NUMERIC DEFAULT 0.00
)
RETURNS TABLE (
    user_id UUID,
    member_tier member_tier_enum,
    total_spent NUMERIC,
    monthly_spent NUMERIC,
    last_spending_month VARCHAR,
    member_hash_code VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user RECORD;
    v_current_month VARCHAR(7);
    v_new_tier member_tier_enum;
    v_total NUMERIC;
    v_monthly NUMERIC;
    v_last_month VARCHAR(7);
    v_active_hash VARCHAR(32);
    v_tier_hash VARCHAR(32);
BEGIN
    SELECT * INTO v_user
    FROM public.users
    WHERE id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    v_current_month := TO_CHAR(NOW(), 'YYYY-MM');
    v_total := COALESCE(v_user.total_spent, 0);
    v_monthly := COALESCE(v_user.monthly_spent, 0);
    v_last_month := COALESCE(v_user.last_spending_month, v_current_month);
    v_new_tier := v_user.member_tier;

    -- Evaluasi pergantian bulan & retensi Platinum
    IF v_current_month <> v_last_month THEN
        IF v_new_tier = 'PLATINUM' THEN
            IF v_monthly < 700000 THEN
                v_new_tier := 'GOLD';
            END IF;
        END IF;
        v_monthly := 0.00;
        v_last_month := v_current_month;
    END IF;

    -- Tambah belanja baru
    IF p_additional_spend > 0 THEN
        v_total := v_total + p_additional_spend;
        v_monthly := v_monthly + p_additional_spend;
    END IF;

    -- Pastikan kartu BRONZE / REGULAR awal selalu ada
    v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_bronze_parksmart'), 1, 4) || '-' ||
                          SUBSTRING(MD5(p_user_id::text || '_bronze_parksmart'), 5, 4) || '-' ||
                          SUBSTRING(MD5(p_user_id::text || '_bronze_parksmart'), 9, 4);
    
    INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
    VALUES (p_user_id, 'regular', v_tier_hash, true, NOW())
    ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
    
    v_active_hash := v_tier_hash;

    -- Evaluasi Tingkat Keanggotaan Berdasarkan Total Belanja
    IF v_total >= 500000 THEN
        v_new_tier := 'PLATINUM';
    ELSIF v_total >= 200000 THEN
        v_new_tier := 'GOLD';
    ELSIF v_total >= 100000 THEN
        v_new_tier := 'SILVER';
    ELSE
        v_new_tier := 'BRONZE';
    END IF;

    -- Hanya terbitkan kartu SILVER jika belanja >= 100.000, jika tidak hapus
    IF v_total >= 100000 THEN
        v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_silver_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_silver_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_silver_parksmart'), 9, 4);
        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
        VALUES (p_user_id, 'silver', v_tier_hash, true, NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
        IF v_new_tier = 'SILVER' THEN
            v_active_hash := v_tier_hash;
        END IF;
    ELSE
        DELETE FROM public.user_member_cards umc WHERE umc.user_id = p_user_id AND umc.card_tier = 'silver';
    END IF;

    -- Hanya terbitkan kartu GOLD jika belanja >= 200.000, jika tidak hapus
    IF v_total >= 200000 THEN
        v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_gold_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_gold_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_gold_parksmart'), 9, 4);
        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
        VALUES (p_user_id, 'gold', v_tier_hash, true, NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
        IF v_new_tier = 'GOLD' THEN
            v_active_hash := v_tier_hash;
        END IF;
    ELSE
        DELETE FROM public.user_member_cards umc WHERE umc.user_id = p_user_id AND umc.card_tier = 'gold';
    END IF;

    -- Hanya terbitkan kartu PLATINUM jika belanja >= 500.000, jika tidak hapus
    IF v_total >= 500000 THEN
        v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_platinum_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_platinum_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_platinum_parksmart'), 9, 4);
        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
        VALUES (p_user_id, 'platinum', v_tier_hash, true, NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
        IF v_new_tier = 'PLATINUM' THEN
            v_active_hash := v_tier_hash;
        END IF;
    ELSE
        DELETE FROM public.user_member_cards umc WHERE umc.user_id = p_user_id AND umc.card_tier = 'platinum';
    END IF;

    -- Ambil hash kode kartu aktif yang sesuai tier saat ini
    SELECT umc.member_hash_code INTO v_active_hash
    FROM public.user_member_cards umc
    WHERE umc.user_id = p_user_id 
      AND (umc.card_tier = LOWER(v_new_tier::text) OR (v_new_tier = 'BRONZE' AND umc.card_tier IN ('regular', 'bronze')))
    LIMIT 1;

    IF v_active_hash IS NULL THEN
        v_active_hash := v_tier_hash;
    END IF;

    -- Update status aktif tier tertinggi & hash code aktif pada tabel users
    UPDATE public.users u
    SET member_tier = v_new_tier,
        total_spent = v_total,
        monthly_spent = v_monthly,
        last_spending_month = v_last_month,
        member_hash_code = v_active_hash,
        updated_at = NOW()
    WHERE u.id = p_user_id;

    RETURN QUERY
    SELECT p_user_id, v_new_tier, v_total, v_monthly, v_last_month, v_active_hash;
END;
$$;

-- 21.5. Fungsi Reset & Evaluasi Retensi Bulanan Tier Platinum
CREATE OR REPLACE FUNCTION public.evaluate_all_membership_tiers_monthly()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_month VARCHAR(7);
BEGIN
    v_current_month := TO_CHAR(NOW(), 'YYYY-MM');

    UPDATE public.users
    SET member_tier = 'GOLD',
        monthly_spent = 0.00,
        last_spending_month = v_current_month,
        updated_at = NOW()
    WHERE last_spending_month <> v_current_month
      AND member_tier = 'PLATINUM'
      AND monthly_spent < 700000;

    UPDATE public.users
    SET monthly_spent = 0.00,
        last_spending_month = v_current_month,
        updated_at = NOW()
    WHERE last_spending_month <> v_current_month;
END;
$$;

-- 21.6. Trigger Evaluasi Tier Otomatis Saat Pembayaran Parkir Berhasil
CREATE OR REPLACE FUNCTION public.trg_process_payment_membership()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.status = 'success' AND NEW.transaction_type IN ('parking_payment') AND NEW.user_id IS NOT NULL THEN
        PERFORM public.evaluate_user_membership_tier(NEW.user_id, COALESCE(NEW.amount, 0));
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_payment_membership ON public.payments;
CREATE TRIGGER trg_payment_membership
AFTER INSERT OR UPDATE OF status
ON public.payments
FOR EACH ROW
EXECUTE FUNCTION public.trg_process_payment_membership();

-- ============================================================================
-- 22. STORED PROCEDURES & RPC FUNCTIONS (CLEANUP OTOMATIS & EXTEND PARKIR)
-- ============================================================================

-- 22.1. Pembersihan Otomatis Booking Kedaluwarsa & Pembebasan Slot
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

-- 22.2. Perpanjangan Sesi / Booking Parkir Dinamis
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

-- ============================================================================
-- 23. AKTIVASI SUPABASE REALTIME REPLICATION PUBLICATION
-- ============================================================================
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE 
        public.bookings, 
        public.parking_sessions, 
        public.parking_slots, 
        public.system_notifications, 
        public.customer_feedbacks;
EXCEPTION WHEN OTHERS THEN NULL; END $$;

