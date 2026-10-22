-- ============================================================================
-- SCRIPT DATA AWAL (SEED DATA) - PARKSMART ID
-- Path: lib/database/seed.sql
-- Status: Sinkron 100% dengan Database Supabase Aktif Saat Ini
-- ============================================================================

-- 1. SEED DATA AKUN ADMIN TERPADU (4 AKUN ROLE RBAC LENGKAP)
INSERT INTO public.admins (
    id, email, full_name, phone, role, division, status, password
) VALUES
(
    'a78f3e2b-4c59-4d81-9b16-83f1245890ab', 'superadmin@parksmart.id', 'Gibran Widodo', '+62 812-0000-0001',
    'super_admin', 'Sistem & Super Admin', 'active', 'superadmin123'
),
(
    '12d32c66-7b63-4c0c-9146-eff24e9361f1', 'ops@parksmart.id', 'Erick Thohir', '+62 812-7777-8888',
    'operational', 'Admin Operasional', 'active', 'ops123'
),
(
    '587b0671-4730-4936-b792-7dbda1b92376', 'finance@parksmart.id', 'Sri Mulyani', '+62 812-3333-4444',
    'finance', 'Admin Finansial', 'active', 'finance123'
),
(
    '69246a1c-021a-4f9f-8534-15fc9643484f', 'cs@parksmart.id', 'Prabowo Subianto', '+62 812-5555-6666',
    'cs', 'Admin CS & KYC', 'active', 'cs123'
)
ON CONFLICT (email) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    role = EXCLUDED.role,
    division = EXCLUDED.division,
    status = EXCLUDED.status,
    password = EXCLUDED.password;

-- 2. SEED DATA PENGGUNA (KHUSUS HANYA user@gmail.com SESUAI ATURAN)
INSERT INTO public.users (
    id, email, phone, full_name, avatar_url, gender, address,
    wallet_balance, points, member_tier, total_parking_count, total_savings,
    favorite_location_ids, pin_hash, is_biometric_enabled, status, password
) VALUES
(
    '5d7d4224-c3f8-4add-a94f-7d87a62d9356', 'user@gmail.com', '0812769494', 'user 1',
    'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/avatars/5d7d4224-c3f8-4add-a94f-7d87a62d9356/avatar_5d7d4224-c3f8-4add-a94f-7d87a62d9356_1792685516418.jpg',
    'Laki-laki', '', 48000.00, 0, 'BRONZE', 6, 0.00,
    '{}', '4040', false, 'active', '123456'
)
ON CONFLICT (email) DO UPDATE SET
    phone = EXCLUDED.phone,
    full_name = EXCLUDED.full_name,
    avatar_url = EXCLUDED.avatar_url,
    wallet_balance = EXCLUDED.wallet_balance,
    points = EXCLUDED.points,
    member_tier = EXCLUDED.member_tier,
    total_parking_count = EXCLUDED.total_parking_count,
    total_savings = EXCLUDED.total_savings,
    pin_hash = EXCLUDED.pin_hash,
    status = EXCLUDED.status,
    password = EXCLUDED.password;

-- 3. SEED DATA PENGATURAN GLOBAL (SYSTEM_SETTINGS - JSONB)
INSERT INTO public.system_settings (key, value, description)
VALUES
(
    'feature_toggles',
    '{
        "is_arcade_active": true,
        "is_biometric_login_enforced": false,
        "is_ev_charging_booking_enabled": true,
        "is_crypto_blockchain_audit_live": true
    }'::jsonb,
    'Toggle fitur aplikasi'
),
(
    'company_treasury',
    '{
        "balance": 48904000,
        "currency": "IDR",
        "last_user_id": "0c97c583-cffc-41be-a45c-e234e572e500",
        "last_injection": 546000
    }'::jsonb,
    'Saldo kas utama cadangan operasional ParkSmart ID'
),
(
    'ai_config',
    '{
        "max_tokens": 1024,
        "model_name": "qwen/qwen3.8-27b",
        "temperature": 0.7,
        "is_autonomous_pricing_enabled": true
    }'::jsonb,
    'Konfigurasi model kecerdasan buatan AI Jarvis untuk deteksi plat kamera & dynamic pricing'
)
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    description = EXCLUDED.description,
    updated_at = timezone('utc'::text, now());

-- ============================================================================
-- CATATAN KHUSUS SEEDING KENDARAAN & TABEL OPERASIONAL LAINNYA:
-- 1. public.vehicles: Dikosongkan (0 baris) sesuai instruksi pengguna.
-- 2. public.users: HANYA menyertakan user@gmail.com (user lain diabaikan).
-- 3. 11 Tabel Operasional Lainnya dikosongkan (0 baris) agar siap beroperasi riil:
--    - public.vehicles             (0 baris)
--    - public.user_kyc             (0 baris)
--    - public.parking_locations    (0 baris)
--    - public.parking_slots        (0 baris)
--    - public.bookings             (0 baris)
--    - public.parking_sessions     (0 baris)
--    - public.payments             (0 baris)
--    - public.customer_feedbacks   (0 baris)
--    - public.system_notifications (0 baris)
--    - public.arcade_scores        (0 baris)
--    - public.admin_audit_logs     (0 baris)
--    - public.user_favorites       (0 baris)
-- ============================================================================
