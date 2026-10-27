-- ============================================================================
-- SCRIPT DATA AWAL (SEED DATA) - PARKSMART ID
-- Path: lib/database/seed.sql
-- Status: Sinkron 100% dengan Kondisi Database Supabase Aktif Saat Ini
-- Sumber Data: Snapshot Live Supabase (necsdylhtswrrqassvzp)
-- ============================================================================

-- 1. SEED DATA AKUN ADMIN TERPADU (4 AKUN RBAC LENGKAP - PASSWORD HASH SHA-256)
INSERT INTO public.admins (
    id, email, full_name, phone, role, division, status, password, created_at, updated_at
) VALUES
(
    'a78f3e2b-4c59-4d81-9b16-83f1245890ab', 'superadmin@parksmart.id', 'Gibran Widodo', '+62 812-0000-0001',
    'super_admin', 'Sistem & Super Admin', 'active',
    'aa2bac57b327374b17d49087d93de6cab2c980bd95ce94bed8e20a641ce0f826', -- Asli: superadmin123
    '2026-10-19 16:32:26.143421+00', '2026-10-19 16:32:26.143421+00'
),
(
    '12d32c66-7b63-4c0c-9146-eff24e9361f1', 'ops@parksmart.id', 'Erick Thohir', '+62 812-7777-8888',
    'operational', 'Admin Operasional', 'active',
    'e407c499ba3feadc23b99e573369c502cd291393a5ace3b02cc866551c963204', -- Asli: ops123
    '2026-10-22 16:25:12.417242+00', '2026-10-22 16:25:12.417242+00'
),
(
    '587b0671-4730-4936-b792-7dbda1b92376', 'finance@parksmart.id', 'Sri Mulyani', '+62 812-3333-4444',
    'finance', 'Admin Finansial', 'active',
    '30e726bea6c739d28bcacd9406586f1fdc176713ad6bfd0353524d397d00e70c', -- Asli: finance123
    '2026-10-22 16:25:11.75688+00', '2026-10-22 16:25:11.75688+00'
),
(
    '69246a1c-021a-4f9f-8534-15fc9643484f', 'cs@parksmart.id', 'Prabowo Subianto', '+62 812-5555-6666',
    'cs', 'Admin CS & KYC', 'active',
    '25b3f3e3ce96bd2106d2dd6ac0d8e157c2454d8e933c492c46cc3682cf5b47ac', -- Asli: cs123
    '2026-10-22 16:25:12.132588+00', '2026-10-22 16:25:12.132588+00'
)
ON CONFLICT (email) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    role = EXCLUDED.role,
    division = EXCLUDED.division,
    status = EXCLUDED.status,
    password = EXCLUDED.password;

-- 2. SEED DATA PENGGUNA RESMI DARI DATABASE AKTIF (2 PENGGUNA - PASSWORD HASH SHA-256)
INSERT INTO public.users (
    id, email, phone, full_name, avatar_url, gender, birth_date, address,
    wallet_balance, points, claw_coins, member_tier, total_spent, monthly_spent,
    last_spending_month, member_hash_code, status_keanggotaan, total_parking_count, total_savings,
    favorite_location_ids, pin_hash, is_biometric_enabled, status, ban_reason, password,
    created_at, updated_at
) VALUES
(
    'df714843-c4cf-4d45-b385-0390404d4429', 'user@gmail.com', '0813277156100', 'Andi Prawono',
    NULL, 'Laki-laki', NULL, NULL,
    38500.00, 25000, 5, 'BRONZE', 0.00, 0.00,
    '2026-10', '#fb9c-c92a-c4a1', false, 0, 0.00,
    '{}', '4040', false, 'active', NULL,
    'd2e165e32219d442bbad138f367beb9988ae9a1f86e0e30756f33c363acc022a', -- Asli: 123456
    '2026-10-25 06:37:52.659729+00', '2026-10-25 14:51:00.031672+00'
),
(
    '225428bf-e24d-4869-98c6-fed811518497', 'aji@gmail.com', '085242636121', 'ajikaja',
    NULL, 'Laki-laki', NULL, NULL,
    182000.00, 0, 5, 'BRONZE', 0.00, 0.00,
    '2026-10', '#46f5-14df-e3a2', false, 0, 0.00,
    '{}', '1111', false, 'active', NULL,
    '892276b46fef3613f01a95d0723a87a145d479cd6048bbc00b5ada3ce12abde7', -- Asli: aji123
    '2026-10-25 06:32:33.554151+00', '2026-10-25 14:51:00.031672+00'
)
ON CONFLICT (email) DO UPDATE SET
    phone = EXCLUDED.phone,
    full_name = EXCLUDED.full_name,
    avatar_url = EXCLUDED.avatar_url,
    wallet_balance = EXCLUDED.wallet_balance,
    points = EXCLUDED.points,
    claw_coins = EXCLUDED.claw_coins,
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

-- 3. SEED DATA GARASI KENDARAAN AKTIF
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

-- 4. SEED DATA KARTU MEMBER BLOCKCHAIN AKTIF
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

-- 5. SEED DATA PENGATURAN GLOBAL SISTEM (SYSTEM_SETTINGS - JSONB)
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

-- ============================================================================
-- CATATAN KONDISI DATABASE SAAT INI (LIVE VERIFIED VIA MCP):
-- 1. Tabel Master & Transaksi dengan baris data aktif:
--    - public.admins               : 4 akun RBAC lengkap
--    - public.users                : 2 pengguna aktif (Andi Prawono & ajikaja)
--    - public.vehicles             : 1 kendaraan terdaftar (AB5894LI - HRV)
--    - public.user_member_cards    : 2 kartu member aktif (hash & on-chain tx)
--    - public.system_settings      : 3 konfigurasi global (kas Rp 46.904.001)
--    - public.admin_audit_logs     : 2 jejak log audit aktif
-- 2. Tabel Operasional yang saat ini berstatus 0 baris (kosong) di database live:
--    - public.parking_locations    : 0 baris
--    - public.parking_slots        : 0 baris
--    - public.user_kyc             : 0 baris
--    - public.bookings             : 0 baris
--    - public.parking_sessions     : 0 baris
--    - public.payments             : 0 baris
--    - public.customer_feedbacks   : 0 baris
--    - public.system_notifications : 0 baris
--    - public.arcade_scores        : 0 baris
--    - public.user_favorites       : 0 baris
-- ============================================================================
