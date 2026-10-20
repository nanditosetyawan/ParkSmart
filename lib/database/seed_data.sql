-- ============================================================================
-- SCRIPT DATA AWAL (SEED DATA) - PARKSMART ID
-- Path: lib/database/seed_data.sql
-- Status: Sinkron 100% dengan Kondisi Nyata Supabase Aktif Saat Ini
-- ============================================================================

-- 1. SEED DATA AKUN ADMIN TERPADU (SUPER ADMIN)
INSERT INTO public.admins (
    id, email, full_name, phone, role, division, status
) VALUES
(
    'b0000000-0000-0000-0000-000000000001', 'superadmin@parksmart.id', 'Gibran Widodo', '+62 812-0000-0001',
    'super_admin', 'Sistem & Super Admin', 'active'
)
ON CONFLICT (email) DO NOTHING;

-- 2. SEED DATA PENGGUNA BARU (USERS)
INSERT INTO public.users (
    id, email, phone, full_name, wallet_balance, points, member_tier, total_parking_count, total_savings, status
) VALUES
(
    'c0000000-0000-0000-0000-000000000001', 'jokowi.dodo@gmail.com', '+62 811-2345-6789',
    'Jokowi Dodo', 0.00, 0, 'BRONZE', 0, 0.00, 'active'
)
ON CONFLICT (email) DO NOTHING;

-- 3. SEED DATA PENGATURAN GLOBAL (SYSTEM_SETTINGS - JSONB)
INSERT INTO public.system_settings (key, value, description, updated_by)
VALUES
(
    'feature_toggles',
    '{
        "is_arcade_active": true,
        "is_biometric_login_enforced": false,
        "is_ev_charging_booking_enabled": true,
        "is_crypto_blockchain_audit_live": true
    }'::jsonb,
    'Saklar fitur sistem aplikasi ParkSmart ID',
    'b0000000-0000-0000-0000-000000000001'
),
(
    'ai_config',
    '{
        "api_key": "",
        "max_tokens": 1024,
        "model_name": "qwen/qwen3.8-27b",
        "temperature": 0.4,
        "ocr_confidence_threshold": 0.85,
        "is_autonomous_pricing_enabled": true
    }'::jsonb,
    'Konfigurasi model kecerdasan buatan AI Jarvis untuk deteksi plat kamera & dynamic pricing',
    'b0000000-0000-0000-0000-000000000001'
)
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    description = EXCLUDED.description,
    updated_by = EXCLUDED.updated_by;

-- 4. SEED DATA AUDIT LOG LOGIN ADMIN (AUDIT TRAIL SUPER ADMIN)
INSERT INTO public.admin_audit_logs (
    id, admin_name, admin_email, role, action, device_model, ip_address, location, isp, status, is_current_session
) VALUES
(
    'b4a2c453-f0c1-4502-ad87-ec6b2d84a419',
    'Gibran Widodo', 'superadmin@parksmart.id', 'Super Admin', 'Login berhasil (Sesi Aktif)',
    'Web Browser (Chrome/Edge)', '140.213.160.202', 'Yogyakarta, Indonesia', 'PT Telkom Indonesia', 'Berhasil', false
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- CATATAN STATUS TABEL OPERASIONAL LAINNYA:
-- 10 Tabel operasional berikut sengaja dikosongkan (0 baris) agar siap menerima
-- input data riil secara dinamis langsung dari aksi pengguna dan staf admin:
--   - public.vehicles             (Garasi Kendaraan Pengguna)
--   - public.user_kyc             (Verifikasi Identitas KTP Pengguna)
--   - public.parking_locations    (Master Lokasi & Gedung Parkir)
--   - public.parking_slots        (Denah Slot Fisik & Sensor IoT)
--   - public.bookings             (Reservasi & Pemesanan Parkir)
--   - public.parking_sessions     (Sesi Gerbang Masuk/Keluar Lapangan)
--   - public.payments             (Buku Besar Transaksi Keuangan & Blockchain)
--   - public.customer_feedbacks   (Ulasan Bintang & Keluhan CS)
--   - public.system_notifications (Broadcast & Notifikasi Sistem)
--   - public.arcade_scores        (Gamifikasi & Skor Mini-Games)
-- ============================================================================
