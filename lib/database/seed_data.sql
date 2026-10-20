-- ============================================================================
-- SCRIPT DATA DUMMY AWAL (SEED DATA) - PARKSMART ID
-- Path: lib/database/seed_data.sql
-- Digunakan untuk menginisialisasi data awal di Supabase agar siap dites langsung
-- ============================================================================

-- 1. SEED DATA LOKASI GEDUNG & FASILITAS PARKIR
INSERT INTO public.parking_locations (
    id, code, name, type, city, province, address, latitude, longitude,
    checkin_radius_meters, total_capacity, car_slots_capacity, motor_slots_capacity, ev_slots_capacity,
    hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, operating_hours, facilities, rating, review_count, status, image_url
) VALUES
(
    'a0000000-0000-0000-0000-000000000001', 'LOC-001', 'Central Park Mall', 'Parkiran Mall',
    'Jakarta Barat', 'DKI Jakarta', 'Jl. Letjen S. Parman No. 28, Tanjung Duren',
    -6.1788, 106.7916, 150, 500, 380, 100, 20,
    5000.00, 2000.00, 7500.00, 'Buka 24 Jam',
    ARRAY['CCTV 24 Jam', 'Covered Parking', 'EV Fast Charging', 'Valet Service', 'Ramah Difabel'],
    4.8, 1420, 'active',
    'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80'
),
(
    'a0000000-0000-0000-0000-000000000002', 'LOC-002', 'Grand Indonesia', 'Parkiran Mall',
    'Jakarta Pusat', 'DKI Jakarta', 'Jl. M.H. Thamrin No. 1, Menteng',
    -6.1953, 106.8208, 150, 450, 350, 80, 20,
    6000.00, 2500.00, 8000.00, '06.00 - 22.00 WIB',
    ARRAY['CCTV 24 Jam', 'Covered Parking', 'Valet Service', 'Car Wash'],
    4.7, 1820, 'crowded',
    'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80'
),
(
    'a0000000-0000-0000-0000-000000000003', 'LOC-003', 'Pacific Place SCBD', 'Gedung Parkir',
    'Jakarta Selatan', 'DKI Jakarta', 'Jl. Jend. Sudirman Kav. 52-53, SCBD',
    -6.2244, 106.8097, 150, 200, 160, 25, 15,
    8000.00, 3000.00, 10000.00, 'Buka 24 Jam',
    ARRAY['CCTV 24 Jam', 'EV Fast Charging', 'Covered Parking', 'VIP Valet'],
    4.9, 890, 'full',
    'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600&auto=format&fit=crop&q=80'
),
(
    'a0000000-0000-0000-0000-000000000004', 'LOC-004', 'Malioboro Mall', 'Parkiran Mall',
    'Yogyakarta', 'DI Yogyakarta', 'Jl. Malioboro No. 52-58, Danurejan',
    -7.7928, 110.3658, 150, 200, 120, 70, 10,
    4000.00, 2000.00, 6000.00, '08.00 - 22.00 WIB',
    ARRAY['CCTV 24 Jam', 'Covered Parking'],
    4.6, 640, 'active',
    'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80'
),
(
    'a0000000-0000-0000-0000-000000000005', 'LOC-005', 'Tunjungan Plaza 6', 'Parkiran Mall',
    'Surabaya', 'Jawa Timur', 'Jl. Embong Malang No. 21-31, Tegalsari',
    -7.2618, 112.7388, 150, 350, 250, 80, 20,
    5000.00, 2000.00, 7000.00, 'Buka 24 Jam',
    ARRAY['CCTV 24 Jam', 'Covered Parking', 'EV Fast Charging'],
    4.7, 1120, 'active',
    'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80'
)
ON CONFLICT (code) DO NOTHING;

-- 2. SEED DATA AKUN ADMIN TERPADU (SUPER ADMIN)
INSERT INTO public.admins (
    id, email, full_name, phone, role, division, status
) VALUES
(
    'b0000000-0000-0000-0000-000000000001', 'superadmin@parksmart.id', 'Gibran Widodo', '+62 812-0000-0001',
    'super_admin', 'Sistem & Super Admin', 'active'
)
ON CONFLICT (email) DO NOTHING;

-- 3. SEED DATA PENGGUNA (USERS)
INSERT INTO public.users (
    id, email, phone, full_name, wallet_balance, points, member_tier, total_parking_count, total_savings, status
) VALUES
(
    'c0000000-0000-0000-0000-000000000001', 'jokowi.dodo@gmail.com', '+62 811-2345-6789',
    'Jokowi Dodo', 0.00, 0, 'BRONZE', 0, 0.00, 'active'
)
ON CONFLICT (email) DO NOTHING;


-- 4. SEED DATA GARASI KENDARAAN (VEHICLES)
INSERT INTO public.vehicles (
    id, user_id, plate_number, vehicle_type, vehicle_category, brand, model, color, plate_expiry, is_default
) VALUES
(
    'd0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001',
    'B 8899 DTO', 'mobil', 'suv', 'Honda', 'HR-V SE', 'Abu-Abu Metalik', '08 • 29', true
),
(
    'd0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002',
    'B 5532 PLM', 'mobil', 'suv', 'Toyota', 'Fortuner VRZ', 'Putih Mutiara', '04 • 28', true
),
(
    'd0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003',
    'B 1111 ION', 'ev', 'ev', 'Hyundai', 'Ioniq 5 Prime', 'Putih', '11 • 29', true
),
(
    'd0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000004',
    'AB 1234 NMX', 'motor', 'motor', 'Yamaha', 'NMAX 155 Connected', 'Hitam Doff', '06 • 27', true
)
ON CONFLICT (user_id, plate_number) DO NOTHING;

-- 5. SEED DATA VERIFIKASI IDENTITAS (USER_KYC - SUPER ADMIN)
INSERT INTO public.user_kyc (
    id, user_id, nik, full_name, birth_place_city, birth_date, address, gender, religion, occupation,
    ktp_image_url, selfie_image_url, status, reviewed_by, submitted_at, reviewed_at
) VALUES
(
    'e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001',
    '3174051508010001', 'Nandito Setyawan', 'Jakarta Barat', '2001-08-15',
    'Jl. Palmerah Barat No. 12, Palmerah, Jakarta Barat', 'Laki-laki', 'Islam', 'Software Engineer',
    'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
    'approved', 'b0000000-0000-0000-0000-000000000001', now() - interval '30 days', now() - interval '29 days'
),
(
    'e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002',
    '3171022004980002', 'Rafi Maulana', 'Jakarta Barat', '1998-04-20',
    'Jl. Kebon Jeruk No. 45, Jakarta Barat', 'Laki-laki', 'Islam', 'Karyawan Swasta',
    'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
    'approved', 'b0000000-0000-0000-0000-000000000001', now() - interval '14 days', now() - interval '13 days'
)
ON CONFLICT (nik) DO NOTHING;

-- 6. SEED DATA DENAH SPOT PARKIR (PARKING_SLOTS)
INSERT INTO public.parking_slots (
    id, location_id, floor_name, slot_code, slot_type, status, sensor_device_id, current_plate_number
) VALUES
-- Central Park Mall (LOC-001)
('f0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Basement 1', 'A-01', 'mobil', 'available', 'IOT-SN-001', NULL),
('f0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'Basement 1', 'A-02', 'mobil', 'available', 'IOT-SN-002', NULL),
('f0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'Basement 2', 'B-01 (EV Fast)', 'ev', 'occupied', 'IOT-SN-003', 'B 1111 ION'),
('f0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 'Basement 2', 'C-01', 'mobil', 'occupied', 'IOT-SN-004', 'B 5532 PLM'),
('f0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001', 'Basement 2', 'C-02', 'difabel', 'available', 'IOT-SN-005', NULL),
-- Grand Indonesia (LOC-002)
('f0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000002', 'West Mall B1', 'B-12', 'mobil', 'available', 'IOT-GI-012', NULL)
ON CONFLICT (location_id, floor_name, slot_code) DO NOTHING;

-- 7. SEED DATA PENGATURAN GLOBAL (SYSTEM_SETTINGS - JSONB)
INSERT INTO public.system_settings (key, value, description, updated_by)
VALUES
(
    'ai_config',
    '{
        "model_name": "gemini-1.5-pro",
        "temperature": 0.4,
        "max_tokens": 1024,
        "ocr_confidence_threshold": 0.85,
        "is_autonomous_pricing_enabled": true
    }'::jsonb,
    'Konfigurasi model kecerdasan buatan AI Jarvis untuk deteksi plat kamera & dynamic pricing',
    'b0000000-0000-0000-0000-000000000001'
),
(
    'feature_toggles',
    '{
        "is_arcade_active": true,
        "is_ev_charging_booking_enabled": true,
        "is_crypto_blockchain_audit_live": true,
        "is_biometric_login_enforced": false
    }'::jsonb,
    'Saklar fitur sistem aplikasi ParkSmart ID',
    'b0000000-0000-0000-0000-000000000001'
)
ON CONFLICT (key) DO NOTHING;

-- 8. SEED DATA ULASAN CUSTOMER (CUSTOMER_FEEDBACKS)
INSERT INTO public.customer_feedbacks (
    id, user_id, location_id, rating, comment, admin_reply, replied_by_admin_id, is_resolved, created_at, replied_at
) VALUES
(
    '70000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000003',
    'a0000000-0000-0000-0000-000000000003', 5,
    'Slot EV Fast Charger di Pacific Place sangat luar biasa! Daya pengisian 22 kW stabil dan proses booking sangat mulus.',
    'Terima kasih banyak atas ulasan positifnya Ibu Dewi! Senang layanan EV Hub kami dapat memuaskan perjalanan Anda.',
    'b0000000-0000-0000-0000-000000000004', true, now() - interval '2 days', now() - interval '1 day'
),
(
    '70000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000004',
    'a0000000-0000-0000-0000-000000000004', 4,
    'Fitur extend timer parkir pas meeting di Malioboro Mall sangat menolong. Tidak perlu lari keluar cuma buat bayar karcis.',
    'Senang mendengar fitur extend timer tiket membantu kelancaran aktivitas Bapak Budi di Malioboro!',
    'b0000000-0000-0000-0000-000000000004', true, now() - interval '3 days', now() - interval '2 days'
)
ON CONFLICT (id) DO NOTHING;

-- 9. SEED DATA BROADCAST & NOTIFIKASI SISTEM
INSERT INTO public.system_notifications (
    id, sender_admin_id, recipient_user_id, target_role, title, message, notification_type, action_type, is_read
) VALUES
(
    '80000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000004',
    NULL, 'user', 'Promo Spesial Weekend Cashback 20%',
    'Nikmati cashback saldo 20% untuk setiap pemesanan slot parkir di Central Park dan Grand Indonesia akhir pekan ini!',
    'promo', 'Lihat Promo', false
),
(
    '80000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001', 'user', 'Verifikasi e-KTP (KYC) Berhasil!',
    'Selamat Nandito, identitas e-KTP Anda telah divalidasi oleh Super Admin. Limit dompet ParkSmart Pay Anda kini menjadi Rp 20.000.000.',
    'security', 'Cek Akun', true
)
ON CONFLICT (id) DO NOTHING;

-- 10. SEED DATA AUDIT LOG LOGIN ADMIN (AUDIT TRAIL SUPER ADMIN)
INSERT INTO public.admin_audit_logs (
    admin_name, admin_email, role, action, device_model, ip_address, location, isp, status, created_at
) VALUES
(
    'Gibran Widodo', 'superadmin@parksmart.id', 'Super Admin', 'Login berhasil (Sesi Aktif)',
    'Web Browser (Chrome/Edge)', '140.213.160.202', 'Yogyakarta, Indonesia', 'PT Telkom Indonesia', 'Berhasil',
    NOW()
);

