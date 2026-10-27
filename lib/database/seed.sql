-- ============================================================================
-- MASTER SEED DATA SQL (16 TABEL LENGKAP) - PARKSMART ID
-- Path: lib/database/seed.sql
-- Sinkron 100% dengan seed_assets/data/ dan Database Supabase Live
-- Tanggal Dihasilkan: 2026-10-27T05:17:16.166Z
-- ============================================================================

-- ============================================================================
-- TABEL: public.users (2 baris data)
-- ============================================================================
INSERT INTO public.users (id, auth_user_id, email, phone, full_name, avatar_url, gender, birth_date, address, wallet_balance, points, member_tier, total_parking_count, total_savings, favorite_location_ids, pin_hash, is_biometric_enabled, status, ban_reason, created_at, updated_at, password, saran_kuliah, pesan_kuliah, total_spent, monthly_spent, last_spending_month, member_hash_code, status_keanggotaan, claw_coins)
VALUES
('df714843-c4cf-4d45-b385-0390404d4429', NULL, 'user@gmail.com', '0813277156100', 'Andi Prawono', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/avatars/df714843-c4cf-4d45-b385-0390404d4429/avatar_df714843-c4cf-4d45-b385-0390404d4429_1793034723450.jpg', 'Laki-laki', NULL, '', 1044500, 19500, 'GOLD', 2, 0, '{"923f7d1b-9c9f-408a-84f2-41e4c506807b"}', '4040', false, 'active', NULL, '2026-10-25T06:37:52.659729+00:00', '2026-10-27T00:41:46.431674+00:00', 'd2e165e32219d442bbad138f367beb9988ae9a1f86e0e30756f33c363acc022a', 'WKWKWKWKWK', 'TES 123 123', 216000, 108000, '2026-10', '#69b1-d973-580b', false, 5),
('225428bf-e24d-4869-98c6-fed811518497', NULL, 'aji@gmail.com', '085242636121', 'ajikaja', NULL, 'Laki-laki', NULL, NULL, 177000, 0, 'BRONZE', 1, 0, '{}', '1111', false, 'active', NULL, '2026-10-25T06:32:33.554151+00:00', '2026-10-26T02:54:47.323002+00:00', '892276b46fef3613f01a95d0723a87a145d479cd6048bbc00b5ada3ce12abde7', NULL, NULL, 10000, 5000, '2026-10', '#46f5-14df-e3a2', false, 5)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.admins (4 baris data)
-- ============================================================================
INSERT INTO public.admins (id, auth_user_id, email, full_name, phone, role, division, avatar_url, status, last_login_at, created_at, updated_at, password)
VALUES
('a78f3e2b-4c59-4d81-9b16-83f1245890ab', NULL, 'superadmin@parksmart.id', 'Gibran Widodo', '+62 812-0000-0001', 'super_admin', 'Sistem & Super Admin', NULL, 'active', NULL, '2026-10-19T16:32:26.143421+00:00', '2026-10-19T16:32:26.143421+00:00', 'aa2bac57b327374b17d49087d93de6cab2c980bd95ce94bed8e20a641ce0f826'),
('587b0671-4730-4936-b792-7dbda1b92376', NULL, 'finance@parksmart.id', 'Sri Mulyani', '+62 812-3333-4444', 'finance', 'Admin Finansial', NULL, 'active', NULL, '2026-10-22T16:25:11.75688+00:00', '2026-10-22T16:25:11.75688+00:00', '30e726bea6c739d28bcacd9406586f1fdc176713ad6bfd0353524d397d00e70c'),
('69246a1c-021a-4f9f-8534-15fc9643484f', NULL, 'cs@parksmart.id', 'Prabowo Subianto', '+62 812-5555-6666', 'cs', 'Admin CS & KYC', NULL, 'active', NULL, '2026-10-22T16:25:12.132588+00:00', '2026-10-22T16:25:12.132588+00:00', '25b3f3e3ce96bd2106d2dd6ac0d8e157c2454d8e933c492c46cc3682cf5b47ac'),
('12d32c66-7b63-4c0c-9146-eff24e9361f1', NULL, 'ops@parksmart.id', 'Erick Thohir', '+62 812-7777-8888', 'operational', 'Admin Operasional', NULL, 'active', NULL, '2026-10-22T16:25:12.417242+00:00', '2026-10-22T16:25:12.417242+00:00', 'e407c499ba3feadc23b99e573369c502cd291393a5ace3b02cc866551c963204')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.system_settings (4 baris data)
-- ============================================================================
INSERT INTO public.system_settings (key, value, description, updated_by, updated_at)
VALUES
('feature_toggles', '{"is_arcade_active":true,"is_biometric_login_enforced":false,"is_ev_charging_booking_enabled":true,"is_crypto_blockchain_audit_live":true}'::jsonb, 'Toggle fitur aplikasi', NULL, '2026-10-22T11:44:58.10404+00:00'),
('ai_config', '{"max_tokens":1024,"model_name":"qwen/qwen3.8-27b","temperature":0.7,"is_autonomous_pricing_enabled":true}'::jsonb, 'Konfigurasi model kecerdasan buatan AI Jarvis untuk deteksi plat kamera & dynamic pricing', NULL, '2026-10-22T15:50:37.349929+00:00'),
('company_treasury', '{"balance":46404001,"currency":"IDR","last_user_id":"df714843-c4cf-4d45-b385-0390404d4429","last_injection":500000}'::jsonb, 'Saldo kas utama cadangan operasional ParkSmart ID', NULL, '2026-10-26T09:52:27.31358+00:00'),
('modular_maintenance', '{"ai":true,"kyc":false,"push":false,"booking":false}'::jsonb, 'Pemeliharaan modular per fitur (booking, AI, KYC, Push)', NULL, '2026-10-27T00:49:55.344603+00:00')
ON CONFLICT (key) DO NOTHING;

-- ============================================================================
-- TABEL: public.vehicles (3 baris data)
-- ============================================================================
INSERT INTO public.vehicles (id, user_id, plate_number, vehicle_type, vehicle_category, brand, model, color, plate_expiry, photo_url, is_default, created_at, updated_at)
VALUES
('c370b869-b78a-4abe-bc73-0c1b3866b9d7', '225428bf-e24d-4869-98c6-fed811518497', 'B 1111 ABB', 'mobil', 'suv', 'Kendaraan', 'Saya', 'Hitam Solid', '10 • 28', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/vehicles/c370b869-b78a-4abe-bc73-0c1b3866b9d7/car_c370b869-b78a-4abe-bc73-0c1b3866b9d7_1792983276674.jpg', true, '2026-10-26T02:52:56.781793+00:00', '2026-10-26T09:54:37.548473+00:00'),
('cd02e022-f451-4082-8812-c44690acdfa1', 'df714843-c4cf-4d45-b385-0390404d4429', 'AB5894LI', 'mobil', 'suv', 'HRV', 'HRV', 'Merah Maroon', '11•26', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/vehicles/df714843-c4cf-4d45-b385-0390404d4429/car_df714843-c4cf-4d45-b385-0390404d4429_1792928515651.jpg', false, '2026-10-25T11:41:56.16632+00:00', '2026-10-25T11:41:56.166459+00:00'),
('2b82696f-274c-4102-ae42-ffa26ed895e9', 'df714843-c4cf-4d45-b385-0390404d4429', 'B2975KP', 'motor', 'motor', 'Beat', '125', 'Putih Mutiara', '11 • 30', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/vehicles/df714843-c4cf-4d45-b385-0390404d4429/car_df714843-c4cf-4d45-b385-0390404d4429_1792952802669.jpg', true, '2026-10-25T18:26:43.218341+00:00', '2026-10-25T18:26:43.21836+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.parking_locations (7 baris data)
-- ============================================================================
INSERT INTO public.parking_locations (id, code, name, type, city, province, address, latitude, longitude, checkin_radius_meters, total_capacity, car_slots_capacity, motor_slots_capacity, ev_slots_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, operating_hours, facilities, rating, review_count, status, image_url, images, created_at, updated_at, floors, is_ev_ready)
VALUES
('1de5fe38-9f54-4f99-adc2-206e5fefdd88', 'PKR-304501', 'Universitas Ahmad Dahlan Kampus 4', 'Kampus', 'Yogyakarta', 'Yogyakarta', 'Jl. Ki Ageng Pemanahan, Kragilan, Tamanan, Kec. Banguntapan, Kabupaten Bantul, Daerah Istimewa Yogyakarta 55191', -7.8334, 110.383029, 150, 4, 3, 1, 0, 5000, 1000, 7500, '06:00 - 17:00', '{"CCTV 24 Jam","Covered Parking","EV Charging Station"}', 0, 0, 'active', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951180567_3337.jpg', '{"https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951180567_3337.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951185069_417.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951188190_6454.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951191570_5160.jpg"}', '2026-10-25T18:01:45.622241+00:00', '2026-10-26T14:26:32.820621+00:00', '{"Lantai 1"}', true),
('e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'PKR-978865', 'Universitas Negeri Surabaya - Kampus 1', 'Kampus', 'Surabaya', 'Surabaya', 'Jl. Ketintang Wiyata, Ketintang, Kec. Gayungan, Surabaya, Jawa Timur 60231', -7.3131, 112.7283, 150, 15, 11, 3, 2, 4000, 1745, 7500, '06:00 - 20:00', '{"CCTV 24 Jam","Covered Parking","EV Charging Station"}', 0, 0, 'active', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951852632_776.jpg', '{"https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951852632_776.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951859574_1975.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951862535_5333.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792951865820_2014.jpg"}', '2026-10-25T18:12:59.842296+00:00', '2026-10-25T18:12:59.842296+00:00', '{"Lantai 1","Lantai 2"}', true),
('7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'PKR-221862', 'Universitas Pembangunan Nasional Veteran Yogyakarta', 'Kampus', 'Yogyakarta', 'Yogyakarta', 'Jl. Babarsari Jl. Tambak Bayan No.2, Janti, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', -7.76211, 110.409282, 150, 20, 14, 4, 2, 5000, 2000, 7500, '06:00 - 17:00', '{"CCTV 24 Jam","Covered Parking","EV Charging Station"}', 0, 0, 'active', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950362104_6858.jpg', '{"https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950362104_6858.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950366482_9549.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950373166_3420.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950377025_4885.jpg"}', '2026-10-25T17:43:42.863973+00:00', '2026-10-25T17:54:52.762994+00:00', '{"Lantai 1","Lantai 2","Lantai 3"}', true),
('923f7d1b-9c9f-408a-84f2-41e4c506807b', 'PKR-867439', 'Pakuwon Mall Yogyakarta', 'Mall / Pusat Perbelanjaan', 'Yogyakarta', 'Yogyakarta', 'Jl. Ring Road Utara, Kaliwaru, Condongcatur, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', -7.758611, 110.399, 150, 10, 7, 2, 1, 20000, 15000, 35000, '10:00 - 22:00', '{"CCTV 24 Jam","Covered Parking","EV Charging Station"}', 0, 0, 'active', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950715393_9030.jpg', '{"https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950715393_9030.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950718477_1617.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950722022_434.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1792950725724_1726.jpg"}', '2026-10-25T17:54:28.481726+00:00', '2026-10-25T17:54:28.481726+00:00', '{"Lantai 1","Lantai 2","Lantai 3"}', true),
('a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'PKR-725328', 'Tunjungan Plaza Surabaya', 'Mall / Pusat Perbelanjaan', 'Surabaya', 'Surabaya', 'Tunjungan plaza, Jl. Jenderal Basuki Rachmat No.8-12 Lt 5, Kedungdoro, Kec. Tegalsari, Surabaya, Jawa Timur 60261', -7.26278, 112.73917, 150, 10, 8, 2, 0, 7000, 5000, 0, '10:00 - 23:00', '{"CCTV 24 Jam","Covered Parking"}', 0, 0, 'active', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793024702374_3606.jpg', '{"https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793024702374_3606.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793024694116_8254.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793024697888_7760.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793024705928_6819.jpg"}', '2026-10-26T14:25:26.385221+00:00', '2026-10-26T14:25:26.385221+00:00', '{"Lantai 1","Lantai 2","Lantai 3"}', false),
('addb6297-bba0-4a27-bc13-74bf2751d22c', 'PKR-101181', 'Pasar Tradisional Beringharjo', 'Mall / Pusat Perbelanjaan', 'Yogyakarta', 'Yogyakarta', 'Jl. Margo Mulyo No.16, Ngupasan, Kec. Gondomanan, Kota Yogyakarta, Daerah Istimewa Yogyakarta 55122', -7.7988, 110.3657, 150, 5, 4, 1, 0, 50000, 15000, 0, '06:00 - 23:00', '{"CCTV 24 Jam","Covered Parking"}', 0, 0, 'active', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025008655_3233.jpg', '{"https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025008655_3233.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025012683_5938.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025016040_2013.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025020671_1539.jpg"}', '2026-10-26T14:31:42.227155+00:00', '2026-10-26T14:31:42.227155+00:00', '{"Lantai 1"}', false),
('b6de51f3-130c-4cdf-ada0-93a45e24f611', 'PKR-421761', 'PT Freeport Indonesia', 'Industri', 'Papua', 'Papua', 'Jl. Mandala Raya Selatan No. 1 Kuala Kencana, Koperapoka, Distrik Mimka Baru, Kabupaten Mimika, Papua Tengah 99920', -4.0517, 137.1117, 150, 20, 14, 4, 2, 5000, 1000, 7500, '06:00 - 23:00', '{"CCTV 24 Jam","Covered Parking","EV Charging Station"}', 0, 0, 'active', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025380114_800.jpg', '{"https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025380114_800.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025383295_5440.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025385866_7021.jpg","https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/parking-locations/loc_1793025389235_3329.jpg"}', '2026-10-26T14:37:02.883509+00:00', '2026-10-26T14:37:02.883509+00:00', '{"Lantai 1","Lantai 2","Lantai 3"}', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.parking_slots (84 baris data)
-- ============================================================================
INSERT INTO public.parking_slots (id, location_id, floor_name, slot_code, slot_type, status, sensor_device_id, current_plate_number, occupied_since, created_at, updated_at, zone)
VALUES
('41b4793c-fd7c-434e-9f76-b138ad457f4e', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'B-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T18:14:01.011713+00:00', '2026-10-25T18:14:01.011713+00:00', 'zoneB'),
('f1519abe-fcf4-43df-9174-5a49778f8de6', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'B-04', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T18:14:04.750309+00:00', '2026-10-25T18:14:04.750309+00:00', 'zoneB'),
('3ef3f4bd-aac5-4f6d-a508-77c45d03ed88', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'B-05', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T18:14:10.031462+00:00', '2026-10-25T18:14:10.031462+00:00', 'zoneB'),
('8fa2af10-402c-42e7-a504-9823287fc245', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'B-06', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T18:14:13.039736+00:00', '2026-10-25T18:14:13.039736+00:00', 'zoneB'),
('4a1abcb2-be4c-4eb3-a53b-9c7fe1d419ec', '1de5fe38-9f54-4f99-adc2-206e5fefdd88', 'Lantai 1', 'B-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T18:02:01.095627+00:00', '2026-10-25T18:02:01.095627+00:00', 'zoneB'),
('3245e532-35cc-49ee-b159-faa6e69e030b', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'A-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:46:34.727235+00:00', '2026-10-25T17:46:34.727235+00:00', 'zoneA'),
('2bb306c3-d660-4b41-a412-e970e0708c3a', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'A-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:46:36.681301+00:00', '2026-10-25T17:46:36.681301+00:00', 'zoneA'),
('52c00f2c-66e0-41fc-ae8b-3d79857dbdd9', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'A-04', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:46:37.800802+00:00', '2026-10-25T17:46:37.800802+00:00', 'zoneA'),
('01528d93-cc06-4012-bfa8-7e43f59509fb', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'A-05', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:46:38.965997+00:00', '2026-10-25T17:46:38.965997+00:00', 'zoneA'),
('5e2044d0-f6b0-4fcf-a67b-fb9c61597790', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'B-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:46:40.560473+00:00', '2026-10-25T17:46:40.560473+00:00', 'zoneB'),
('2ef08e7a-2ea4-4c0d-b176-a8e5cc4d821f', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'B-02', 'difabel', 'available', NULL, NULL, NULL, '2026-10-25T17:46:44.06194+00:00', '2026-10-25T17:46:44.06194+00:00', 'zoneB'),
('38e00609-4fbd-4138-b4a8-48df7a943cb7', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'B-03', 'difabel', 'available', NULL, NULL, NULL, '2026-10-25T17:46:49.274303+00:00', '2026-10-25T17:46:49.274303+00:00', 'zoneB'),
('d5adb286-35d0-458d-8bef-d4aae3b9886c', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'B-04', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T17:46:52.721612+00:00', '2026-10-25T17:46:52.721612+00:00', 'zoneB'),
('eeceeec3-840f-42c7-ac07-c28e4f586dd9', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'B-05', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:47:04.201256+00:00', '2026-10-25T17:47:04.201256+00:00', 'zoneB'),
('da8c70c4-4744-4044-90b2-dd9308b51d6c', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 2', 'A-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:47:17.510038+00:00', '2026-10-25T17:47:17.510038+00:00', 'zoneA'),
('d650f1f6-f32b-409c-ae6f-034f539b11ed', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 2', 'A-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:47:18.888541+00:00', '2026-10-25T17:47:18.888541+00:00', 'zoneA'),
('fc864175-e2d8-4b4c-b3d9-76d264374a19', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 2', 'B-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:47:20.171189+00:00', '2026-10-25T17:47:20.171189+00:00', 'zoneB'),
('df892cc6-5b66-4d00-be1f-869e28e25ccb', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 2', 'B-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:47:22.792164+00:00', '2026-10-25T17:47:22.792164+00:00', 'zoneB'),
('c50ddf98-8d50-4056-8f90-db3baf27d66e', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 3', 'A-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:47:28.773952+00:00', '2026-10-25T17:47:28.773952+00:00', 'zoneA'),
('766a8ec9-6826-49c0-b227-bd3648f7fbb7', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 3', 'A-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:47:31.581348+00:00', '2026-10-25T17:47:31.581348+00:00', 'zoneA'),
('b789b0bd-4756-40d5-9b90-192a3a59bcbe', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 3', 'B-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:47:34.467951+00:00', '2026-10-25T17:47:34.467951+00:00', 'zoneB'),
('5a46cb81-7f59-4238-86d5-60474947086b', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 3', 'B-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:47:37.447612+00:00', '2026-10-25T17:47:37.447612+00:00', 'zoneB'),
('e3979d59-ad8d-44b3-8895-be08256fd0da', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 3', 'B-03', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:47:40.448878+00:00', '2026-10-25T17:47:40.448878+00:00', 'zoneB'),
('121bb8ea-fce0-46f7-afeb-8f637b4dee0f', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 1', 'B-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:55:19.084305+00:00', '2026-10-25T17:55:19.084305+00:00', 'zoneB'),
('1dea927b-0b5e-455a-b62a-87ae494f8395', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 1', 'B-02', 'ev', 'available', NULL, NULL, NULL, '2026-10-25T17:55:22.196553+00:00', '2026-10-25T17:55:22.196553+00:00', 'zoneB'),
('558c78f9-f17c-47ae-bb66-511df4075305', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 1', 'A-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:55:34.947565+00:00', '2026-10-25T17:55:34.947565+00:00', 'zoneA'),
('67d41ebe-6610-4eb2-abd7-1e58ce0ce015', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 2', 'A-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:55:40.715866+00:00', '2026-10-25T17:55:40.715866+00:00', 'zoneA'),
('a4a8a4a9-d41a-4394-b687-45001e61f623', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 2', 'A-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:55:43.573988+00:00', '2026-10-25T17:55:43.573988+00:00', 'zoneA'),
('84a004ea-a35d-4f93-91b2-f09d89f3947f', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 2', 'B-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:55:48.152892+00:00', '2026-10-25T17:55:48.152892+00:00', 'zoneB'),
('80abeed0-84c0-4bbf-9e53-6f720b3c44a3', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 2', 'B-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:55:50.763076+00:00', '2026-10-25T17:55:50.763076+00:00', 'zoneB'),
('23994b8b-ef97-45d0-93ed-81a0188f61e2', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 3', 'A-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T17:55:58.761806+00:00', '2026-10-25T17:55:58.761806+00:00', 'zoneA'),
('cb4a26df-cb4a-4b68-8219-7b5426ebaed1', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 3', 'B-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T17:56:03.732323+00:00', '2026-10-25T17:56:03.732323+00:00', 'zoneB'),
('9e8d1f39-fb97-49e9-bfa8-4332fee09967', '1de5fe38-9f54-4f99-adc2-206e5fefdd88', 'Lantai 1', 'A-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T18:01:55.171693+00:00', '2026-10-25T18:01:55.171693+00:00', 'zoneA'),
('c4c130d7-7acf-4a32-98ae-724cc1c3858e', '1de5fe38-9f54-4f99-adc2-206e5fefdd88', 'Lantai 1', 'A-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T18:01:56.70131+00:00', '2026-10-25T18:01:56.70131+00:00', 'zoneA'),
('8c9dbebe-973c-422e-ad90-03051ad62b83', '1de5fe38-9f54-4f99-adc2-206e5fefdd88', 'Lantai 1', 'B-02', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T18:02:04.558452+00:00', '2026-10-25T18:02:04.558452+00:00', 'zoneB'),
('fc54d3e7-6cd1-4fa5-843b-f58106027f35', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'Lantai 1', 'A-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T17:55:32.048261+00:00', '2026-10-26T02:52:00.047017+00:00', 'zoneA'),
('304ecf27-75b9-45b9-8b9d-198b64938e71', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 1', 'A-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T18:13:05.883413+00:00', '2026-10-25T18:13:05.883413+00:00', 'zoneA'),
('ae8e6ba4-34ce-4e10-bf53-f07f99f6ccca', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 1', 'B-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T18:13:08.861263+00:00', '2026-10-25T18:13:08.861263+00:00', 'zoneB'),
('aebe21ae-9143-464c-ac26-3d55c12ab9d0', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 1', 'A-02', 'difabel', 'available', NULL, NULL, NULL, '2026-10-25T18:13:14.173431+00:00', '2026-10-25T18:13:14.173431+00:00', 'zoneA'),
('fe51452d-b434-4a49-a574-27cfcda12d86', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 1', 'A-03', 'difabel', 'available', NULL, NULL, NULL, '2026-10-25T18:13:17.431948+00:00', '2026-10-25T18:13:17.431948+00:00', 'zoneA'),
('a14efbdc-cf77-4a89-9e79-f687d1c95a51', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 1', 'B-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-25T18:13:19.837944+00:00', '2026-10-25T18:13:19.837944+00:00', 'zoneB'),
('656aa6fb-c38e-4635-96b4-58a812111248', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'A-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T18:13:28.81342+00:00', '2026-10-25T18:13:28.81342+00:00', 'zoneA'),
('6bfa7710-c48b-4bb0-a51f-22f54298a76b', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'A-02', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T18:13:31.92016+00:00', '2026-10-25T18:13:31.92016+00:00', 'zoneA'),
('20374a0a-fb07-4ad8-83f7-8e8c3015e227', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'A-03', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T18:13:35.164207+00:00', '2026-10-25T18:13:35.164207+00:00', 'zoneA'),
('4c028647-ae05-4336-8043-4cd02cd76da2', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'A-04', 'motor', 'available', NULL, NULL, NULL, '2026-10-25T18:13:38.500532+00:00', '2026-10-25T18:13:38.500532+00:00', 'zoneA'),
('e830329e-9ed7-40f0-ab2a-2d77b42c4be7', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'B-01', 'ev', 'available', NULL, NULL, NULL, '2026-10-25T18:13:42.019745+00:00', '2026-10-25T18:13:42.019745+00:00', 'zoneB'),
('6b07f0cd-d0ee-4412-ae86-c8e20c62054a', 'e93e16e8-1d53-47b0-8010-68a004d7b3cf', 'Lantai 2', 'B-02', 'ev', 'available', NULL, NULL, NULL, '2026-10-25T18:13:45.483911+00:00', '2026-10-25T18:13:45.483911+00:00', 'zoneB'),
('f0238f8e-1c46-4880-b6f8-760bcd96e2ff', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 1', 'A-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:46:33.470638+00:00', '2026-10-26T02:54:44.077816+00:00', 'zoneA'),
('0f671cb9-695d-40e3-8e73-11916504b9f4', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 3', 'A-03', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:26:07.235873+00:00', '2026-10-26T14:26:07.235873+00:00', 'zoneA'),
('58b63eab-ea0e-4e8a-b3d6-d10a70840b86', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'Lantai 2', 'B-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-25T17:47:21.703024+00:00', '2026-10-26T07:04:00.141261+00:00', 'zoneB'),
('29f1ccc4-c429-41a3-a175-56bffea26f83', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 1', 'A-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-26T14:25:33.767121+00:00', '2026-10-26T14:25:33.767121+00:00', 'zoneA'),
('a4e5caef-b4b9-4c42-ac33-ed8b76ab0f2e', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 1', 'A-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-26T14:25:38.424754+00:00', '2026-10-26T14:25:38.424754+00:00', 'zoneA'),
('60b4c533-826e-4b27-86cf-5308ce2c0320', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 2', 'A-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-26T14:25:46.888782+00:00', '2026-10-26T14:25:46.888782+00:00', 'zoneA'),
('eb721f9d-2e04-45bd-ab4b-d207bb7fd7d1', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 2', 'A-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:25:50.519538+00:00', '2026-10-26T14:25:50.519538+00:00', 'zoneA'),
('fb91ae9d-6117-4dba-b5f4-df054df65e68', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 2', 'A-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:25:53.02251+00:00', '2026-10-26T14:25:53.02251+00:00', 'zoneA'),
('a46789b1-8e23-4689-bf58-b56b3c67a4ba', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 3', 'A-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:26:00.024582+00:00', '2026-10-26T14:26:00.024582+00:00', 'zoneA'),
('d7621d69-0ea2-40d5-b7ed-7f8fd51ccf0c', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 3', 'A-02', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:26:04.730841+00:00', '2026-10-26T14:26:04.730841+00:00', 'zoneA'),
('a1bde542-0cc1-403e-88d6-b005cb5b7e0e', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 3', 'A-04', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:26:10.40942+00:00', '2026-10-26T14:26:10.40942+00:00', 'zoneA'),
('a17313d2-2a25-4afb-b741-7992308cb62c', 'a1b1534f-51e0-42ca-bf09-5dd03de42e22', 'Lantai 3', 'B-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:26:15.080694+00:00', '2026-10-26T14:26:15.080694+00:00', 'zoneB'),
('2bb67a35-9779-41e7-a957-8b7bd73e63d0', 'addb6297-bba0-4a27-bc13-74bf2751d22c', 'Lantai 1', 'A-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:31:48.060827+00:00', '2026-10-26T14:31:48.060827+00:00', 'zoneA'),
('9c3f753b-9ff9-4114-9c03-c9c54609f416', 'addb6297-bba0-4a27-bc13-74bf2751d22c', 'Lantai 1', 'B-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:31:54.558807+00:00', '2026-10-26T14:31:54.558807+00:00', 'zoneB'),
('14927bd0-8fce-4c71-882c-5f4f7cb4f2fe', 'addb6297-bba0-4a27-bc13-74bf2751d22c', 'Lantai 1', 'B-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:31:57.847333+00:00', '2026-10-26T14:31:57.847333+00:00', 'zoneB'),
('d691a8c5-82b9-4fcf-ac37-3adda8e064dd', 'addb6297-bba0-4a27-bc13-74bf2751d22c', 'Lantai 1', 'B-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:31:59.947621+00:00', '2026-10-26T14:31:59.947621+00:00', 'zoneB'),
('5c253cf0-16dd-4ce2-a35e-bf1b07d16f0d', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 1', 'A-01', 'vip', 'available', NULL, NULL, NULL, '2026-10-26T14:37:10.684822+00:00', '2026-10-26T14:37:10.684822+00:00', 'zoneA'),
('92ea5024-e3d3-4ff9-b8e3-73c8bd63d116', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 1', 'A-02', 'vip', 'available', NULL, NULL, NULL, '2026-10-26T14:37:14.65582+00:00', '2026-10-26T14:37:14.65582+00:00', 'zoneA'),
('f6490a1d-049d-45fd-aaa6-6b891a1d6eb7', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 1', 'A-03', 'vip', 'available', NULL, NULL, NULL, '2026-10-26T14:37:18.778077+00:00', '2026-10-26T14:37:18.778077+00:00', 'zoneA'),
('425fda61-1bd8-40a2-b144-28a2dd42c0d4', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 1', 'B-01', 'ev', 'available', NULL, NULL, NULL, '2026-10-26T14:37:23.140103+00:00', '2026-10-26T14:37:23.140103+00:00', 'zoneB'),
('91a35252-a181-4c4c-ad47-3517c824593c', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 1', 'B-02', 'ev', 'available', NULL, NULL, NULL, '2026-10-26T14:37:26.943298+00:00', '2026-10-26T14:37:26.943298+00:00', 'zoneB'),
('194d6d78-dcbd-44a8-89da-c4502a5bebb7', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 1', 'B-03', 'ev', 'available', NULL, NULL, NULL, '2026-10-26T14:37:30.380002+00:00', '2026-10-26T14:37:30.380002+00:00', 'zoneB'),
('bd98a960-28a1-4328-b6bc-d3976fcdbe24', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 2', 'A-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:37:40.951154+00:00', '2026-10-26T14:37:40.951154+00:00', 'zoneA'),
('8e97e7c4-40f1-47b5-965c-c2a01a26b6ca', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 2', 'A-02', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:37:43.669828+00:00', '2026-10-26T14:37:43.669828+00:00', 'zoneA'),
('11a8fcb4-87b3-4412-b3f8-39e7de62a07b', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 2', 'B-04', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:37:59.040062+00:00', '2026-10-26T14:37:59.040062+00:00', 'zoneB'),
('81b37e42-c796-4a49-a4c5-194836bf655d', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 3', 'A-04', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:38:12.385069+00:00', '2026-10-26T14:38:12.385069+00:00', 'zoneA'),
('d155402d-b8a8-4a86-a118-c0d47e5217a3', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 3', 'B-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:38:17.140943+00:00', '2026-10-26T14:38:17.140943+00:00', 'zoneB'),
('d70af8c1-4f87-49ae-8c3d-04d82d6e774e', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 1', 'B-04', 'ev', 'available', NULL, NULL, NULL, '2026-10-26T14:37:33.303641+00:00', '2026-10-26T14:37:33.303641+00:00', 'zoneB'),
('619069af-f232-4bc5-86ce-b0f81061bd0c', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 2', 'B-01', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:37:46.511208+00:00', '2026-10-26T14:37:46.511208+00:00', 'zoneB'),
('bc728271-bf48-40fd-9435-835c28fc3bde', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 2', 'B-02', 'motor', 'available', NULL, NULL, NULL, '2026-10-26T14:37:49.535285+00:00', '2026-10-26T14:37:49.535285+00:00', 'zoneB'),
('cd9bd259-1c4c-44d5-8663-d8850903cdd9', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 3', 'A-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:38:09.262795+00:00', '2026-10-26T14:38:09.262795+00:00', 'zoneA'),
('e8848010-7c07-4b74-89ea-de1da206fa5e', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 3', 'A-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:38:10.3593+00:00', '2026-10-26T14:38:10.3593+00:00', 'zoneA'),
('f8c558e4-be63-4414-a617-1cdcd832fc63', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 3', 'B-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:38:15.893716+00:00', '2026-10-26T14:38:15.893716+00:00', 'zoneB'),
('3e2ad659-d4a6-4e8d-86e5-112cd25d8597', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 2', 'B-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:37:54.647007+00:00', '2026-10-26T14:37:54.647007+00:00', 'zoneB'),
('f8bc65d0-3a8d-4a56-8384-5abc90fbed8d', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 3', 'A-01', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:38:07.906084+00:00', '2026-10-26T14:38:07.906084+00:00', 'zoneA'),
('34779c7b-3079-4674-b46a-371b21a99db4', 'b6de51f3-130c-4cdf-ada0-93a45e24f611', 'Lantai 3', 'B-03', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:38:20.603175+00:00', '2026-10-26T14:38:20.603175+00:00', 'zoneB'),
('a1178615-f2db-43ae-a69c-fdf602d00ec7', 'addb6297-bba0-4a27-bc13-74bf2751d22c', 'Lantai 1', 'A-02', 'mobil', 'available', NULL, NULL, NULL, '2026-10-26T14:32:01.401275+00:00', '2026-10-26T15:22:36.339542+00:00', 'zoneA')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.user_kyc (1 baris data)
-- ============================================================================
INSERT INTO public.user_kyc (id, user_id, nik, full_name, birth_place_city, birth_date, address, gender, religion, occupation, ktp_image_url, selfie_image_url, status, reject_reason, reviewed_by, submitted_at, reviewed_at, created_at, updated_at)
VALUES
('0cd550a9-e8d6-4653-8301-3b7a29ce2397', 'df714843-c4cf-4d45-b385-0390404d4429', '3171714843444538', 'Andi Prawono', 'Surakarta', '1961-06-21', 'Jl. Kutai Utara, Solo', 'Laki-laki', 'Islam', 'Wirausaha', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/kyc-documents/df714843-c4cf-4d45-b385-0390404d4429/df714843-c4cf-4d45-b385-0390404d4429_ktp_1793036114262.jpg', 'https://necsdylhtswrrqassvzp.supabase.co/storage/v1/object/public/kyc-documents/df714843-c4cf-4d45-b385-0390404d4429/df714843-c4cf-4d45-b385-0390404d4429_selfie_1793036115390.jpg', 'pending', NULL, NULL, '2026-10-27T00:35:16.280940+00:00', NULL, '2026-10-26T17:35:17.288526+00:00', '2026-10-27T00:35:16.281006+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.user_member_cards (4 baris data)
-- ============================================================================
INSERT INTO public.user_member_cards (id, user_id, card_tier, member_hash_code, nft_token_id, tx_hash, is_active, unlocked_at, created_at, updated_at)
VALUES
('ecad6d6d-9aea-4a1b-9e5d-07651c757c75', 'df714843-c4cf-4d45-b385-0390404d4429', 'regular', '#fb9c-c92a-c4a1', NULL, '0x7eac80c8de57394420e4cff2544e1c74b016c6bfaa6244e7a4aa9ee22d9a8da6', false, '2026-10-25T06:37:52.659729+00:00', '2026-10-25T06:37:52.659729+00:00', '2026-10-25T06:37:52.659729+00:00'),
('e5ae4b82-c31c-4e35-b0cf-d24d14c6f7d8', 'df714843-c4cf-4d45-b385-0390404d4429', 'silver', '#83d5-aa57-3ab5', NULL, '0xf4badc970005f612020e1d3421171c7dcc04435b0cdce39374b24cf5b4e06e31', false, '2026-10-26T15:22:40.494451+00:00', '2026-10-26T15:22:40.494451+00:00', '2026-10-26T15:22:40.494451+00:00'),
('41c835db-4e4c-4c5c-b68e-7bade3eecd3f', 'df714843-c4cf-4d45-b385-0390404d4429', 'gold', '#69b1-d973-580b', NULL, '0xc9110bf9a0b36f2dba4ca4110b2566cf900b4afd7050a051bbca3a278a165075', true, '2026-10-26T15:22:40.697243+00:00', '2026-10-26T15:22:40.697243+00:00', '2026-10-26T15:22:40.697243+00:00'),
('96e0f5a8-3068-4f58-bbce-a6eb843859d5', '225428bf-e24d-4869-98c6-fed811518497', 'regular', '#46f5-14df-e3a2', NULL, '0x25dbe8ba509bfd6aeb07df07906428974aa5c5e10e510c9dc5b8cbda52e6048f', true, '2026-10-25T06:32:33.554151+00:00', '2026-10-25T06:32:33.554151+00:00', '2026-10-25T06:32:33.554151+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.user_favorites (1 baris data)
-- ============================================================================
INSERT INTO public.user_favorites (id, user_id, location_id, created_at)
VALUES
('0896deb3-3c9d-47ad-98b7-9ebddad3719c', 'df714843-c4cf-4d45-b385-0390404d4429', '923f7d1b-9c9f-408a-84f2-41e4c506807b', '2026-10-25T18:19:22.317129+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.bookings (4 baris data)
-- ============================================================================
INSERT INTO public.bookings (id, booking_code, user_id, location_id, slot_id, vehicle_id, booking_type, start_time, end_time, duration_hours, total_price, payment_status, booking_status, qr_code_hash, cancel_reason, created_at, updated_at, plate_number, vehicle_desc, extended_count, extended_minutes)
VALUES
('6fbe4d0b-31cc-4dda-b76f-3f75bb17dbdf', 'BK-83266113-803', '225428bf-e24d-4869-98c6-fed811518497', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'f0238f8e-1c46-4880-b6f8-760bcd96e2ff', 'c370b869-b78a-4abe-bc73-0c1b3866b9d7', 'reservation', '2026-10-26T02:54:00+00:00', '2026-10-26T03:54:00+00:00', 1, 5000, 'paid', 'completed', 'PARKSMART-BK-83266113-803', NULL, '2026-10-26T02:54:25.913774+00:00', '2026-10-26T02:54:25.913774+00:00', 'B 1111 ABB', 'Kendaraan Saya', 0, 0),
('98574ca1-edfc-4176-a4dd-adc93bca271f', 'BK-83110686-822', '225428bf-e24d-4869-98c6-fed811518497', '923f7d1b-9c9f-408a-84f2-41e4c506807b', 'fc54d3e7-6cd1-4fa5-843b-f58106027f35', NULL, 'reservation', '2026-10-26T02:51:00+00:00', '2026-10-26T03:51:00+00:00', 1, 20000, 'unpaid', 'cancelled', 'PARKSMART-BK-83110686-822', 'Waktu pembayaran habis (Auto Cancel)', '2026-10-26T02:51:50.489267+00:00', '2026-10-26T02:54:56.128402+00:00', 'B 1945 RI', 'Toyota Land Cruiser', 0, 0),
('623a015a-70df-439a-8ce2-195827a15ea2', 'BK-83739083-588', 'df714843-c4cf-4d45-b385-0390404d4429', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', '58b63eab-ea0e-4e8a-b3d6-d10a70840b86', '2b82696f-274c-4102-ae42-ffa26ed895e9', 'reservation', '2026-10-26T03:02:00+00:00', '2026-10-26T06:05:00+00:00', 4, 8000, 'paid', 'completed', 'PARKSMART-BK-83739083-588', NULL, '2026-10-26T03:02:20.074542+00:00', '2026-10-26T06:05:00.050911+00:00', 'B2975KP', 'Beat 125', 0, 0),
('a3f8bb7e-0895-4eed-95a3-7b308f159adf', 'BK-28148409-243', 'df714843-c4cf-4d45-b385-0390404d4429', 'addb6297-bba0-4a27-bc13-74bf2751d22c', 'a1178615-f2db-43ae-a69c-fdf602d00ec7', 'cd02e022-f451-4082-8812-c44690acdfa1', 'reservation', '2026-10-26T15:22:00+00:00', '2026-10-26T16:59:00+00:00', 2, 100000, 'paid', 'completed', 'PARKSMART-BK-28148409-243', NULL, '2026-10-26T15:22:29.399073+00:00', '2026-10-26T15:22:29.399073+00:00', 'AB5894LI', 'HRV HRV', 0, 0)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.parking_sessions (3 baris data)
-- ============================================================================
INSERT INTO public.parking_sessions (id, session_code, location_id, slot_id, user_id, vehicle_id, booking_id, plate_number, vehicle_type, vehicle_desc, check_in_time, expected_check_out_time, check_out_time, parking_fee, is_overstay, overstay_minutes, overstay_penalty_fee, total_fee, status, gate_in_id, gate_out_id, created_at, updated_at, extended_count, extended_minutes)
VALUES
('7996584e-73fc-4aa8-9f9f-f92cb5faccdc', 'SES-574455', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', 'f0238f8e-1c46-4880-b6f8-760bcd96e2ff', '225428bf-e24d-4869-98c6-fed811518497', 'c370b869-b78a-4abe-bc73-0c1b3866b9d7', '6fbe4d0b-31cc-4dda-b76f-3f75bb17dbdf', 'B 1111 ABB', 'mobil', 'Kendaraan Saya', '2026-10-26T02:55:54.906466+00:00', '2026-10-26T03:55:54.906466+00:00', '2026-10-26T02:56:36.210077+00:00', 5000, false, 0, 0, 5000, 'completed', 'Gate Masuk 01', NULL, '2026-10-26T02:55:54.779172+00:00', '2026-10-26T02:55:54.779172+00:00', 0, 0),
('c2e74e28-5e62-4be2-899e-878d9faf3ddd', 'SES-373095', '7b22a0aa-f92a-497f-a628-162dcfe0ada1', '58b63eab-ea0e-4e8a-b3d6-d10a70840b86', 'df714843-c4cf-4d45-b385-0390404d4429', '2b82696f-274c-4102-ae42-ffa26ed895e9', '623a015a-70df-439a-8ce2-195827a15ea2', 'B2975KP', 'mobil', 'Beat 125', '2026-10-26T03:03:25.879454+00:00', '2026-10-26T07:03:25.879454+00:00', '2026-10-26T07:04:00.141261+00:00', 8000, false, 0, 0, 8000, 'completed', 'Gate Masuk 01', NULL, '2026-10-26T03:03:27.082597+00:00', '2026-10-26T07:04:00.141261+00:00', 0, 0),
('26a47e17-cb89-48f3-8d51-7661c1f364d2', 'SES-581036', 'addb6297-bba0-4a27-bc13-74bf2751d22c', 'a1178615-f2db-43ae-a69c-fdf602d00ec7', 'df714843-c4cf-4d45-b385-0390404d4429', 'cd02e022-f451-4082-8812-c44690acdfa1', 'a3f8bb7e-0895-4eed-95a3-7b308f159adf', 'AB5894LI', 'mobil', 'HRV HRV', '2026-10-26T15:22:49.983741+00:00', '2026-10-26T17:22:49.983741+00:00', '2026-10-26T15:37:26.713063+00:00', 100000, false, 0, 0, 100000, 'completed', 'Gate Masuk 01', NULL, '2026-10-26T15:22:51.078221+00:00', '2026-10-26T15:22:51.078221+00:00', 0, 0)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.payments (13 baris data)
-- ============================================================================
INSERT INTO public.payments (id, transaction_code, user_id, booking_id, session_id, transaction_type, payment_method, amount, description, blockchain_hash, status, completed_at, created_at)
VALUES
('fa85d4b4-f0d7-4392-8429-8af1d1bdd261', 'CLM-49878554', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'wallet', 1000, 'Hadiah Koin Mesin Capit Claws Car (Rp 1000)', NULL, 'success', '2026-10-26T00:37:58.554147+00:00', '2026-10-25T17:37:59.556559+00:00'),
('9c896860-c482-49d7-8472-52b4dd0c480a', 'CLM-49920753', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'wallet', 1000, 'Hadiah Koin Mesin Capit Claws Car (Rp 1000)', NULL, 'success', '2026-10-26T00:38:40.753738+00:00', '2026-10-25T17:38:41.732257+00:00'),
('a647f3ff-49d6-4051-b3f9-6916dba58eef', 'TOPUP-1792950016915', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'bank_va', 200000, 'Top Up Saldo ParkSmart Pay (bank_va)', NULL, 'success', '2026-10-25T17:40:16.91543+00:00', '2026-10-25T17:40:17.887731+00:00'),
('4477fdc5-0e17-4613-85ea-c6858d9b06a4', 'TOPUP-1792950019655', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'bank_va', 200000, 'Top Up Saldo ParkSmart Pay (bank_va)', NULL, 'success', '2026-10-25T17:40:19.655443+00:00', '2026-10-25T17:40:20.626098+00:00'),
('e00c8901-10e6-49ef-9d64-fbebd219aed7', 'TOPUP-1792950021758', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'bank_va', 200000, 'Top Up Saldo ParkSmart Pay (bank_va)', NULL, 'success', '2026-10-25T17:40:21.758153+00:00', '2026-10-25T17:40:22.735554+00:00'),
('4c149a48-af20-44d7-b10f-dadb0854d9de', 'INJ-147448', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_injection', 'admin_manual', 500000, 'kayaaa', NULL, 'success', '2026-10-26T09:52:27.448081+00:00', '2026-10-26T02:52:28.526616+00:00'),
('deeb5c6b-b1dc-4079-8ff8-c0716ac594ae', 'TRX-83287541', '225428bf-e24d-4869-98c6-fed811518497', '6fbe4d0b-31cc-4dda-b76f-3f75bb17dbdf', NULL, 'parking_payment', 'wallet', 5000, 'Reservasi Parkir Universitas Pembangunan Nasional Veteran Yogyakarta Slot A-01 (BK-83266113-803)', NULL, 'success', '2026-10-26T09:54:47.541185+00:00', '2026-10-26T02:54:47.323002+00:00'),
('6cda0d0b-d791-40f7-af0c-1661f43dc859', 'TRX-83776778', 'df714843-c4cf-4d45-b385-0390404d4429', '623a015a-70df-439a-8ce2-195827a15ea2', NULL, 'parking_payment', 'gopay', 8000, 'Reservasi Parkir Universitas Pembangunan Nasional Veteran Yogyakarta Slot B-02 (BK-83739083-588)', NULL, 'success', '2026-10-26T10:02:56.778422+00:00', '2026-10-26T03:02:57.879387+00:00'),
('8cc0d64c-3b09-4519-98cc-6d99790837ee', 'CLM-44674692', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'wallet', 1000, 'Hadiah Koin Mesin Capit Claws Car (Rp 1000)', NULL, 'success', '2026-10-25T23:11:14.692+00:00', '2026-10-25T16:11:14.302577+00:00'),
('aa5a92e7-e040-4285-9d76-f144358a566f', 'CLM-44686981', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'wallet', 1000, 'Hadiah Koin Mesin Capit Claws Car (Rp 1000)', NULL, 'success', '2026-10-25T23:11:26.981+00:00', '2026-10-25T16:11:26.532588+00:00'),
('aa7076ab-be3e-435d-b155-9b6113370988', 'CLM-49661957', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'wallet', 1000, 'Hadiah Koin Mesin Capit Claws Car (Rp 1000)', NULL, 'success', '2026-10-26T00:34:21.957395+00:00', '2026-10-25T17:34:22.922437+00:00'),
('0b679e03-1ca4-4942-b3fd-cde3f1af2d07', 'CLM-49750076', 'df714843-c4cf-4d45-b385-0390404d4429', NULL, NULL, 'wallet_topup', 'wallet', 1000, 'Hadiah Koin Mesin Capit Claws Car (Rp 1000)', NULL, 'success', '2026-10-26T00:35:50.076777+00:00', '2026-10-25T17:35:51.056672+00:00'),
('c0b5c17d-cd85-4766-aed5-25b1176f7f89', 'TRX-28159700', 'df714843-c4cf-4d45-b385-0390404d4429', 'a3f8bb7e-0895-4eed-95a3-7b308f159adf', NULL, 'parking_payment', 'wallet', 100000, 'Reservasi Parkir Pasar Tradisional Beringharjo Slot A-02 (BK-28148409-243)', NULL, 'success', '2026-10-26T22:22:39.70059+00:00', '2026-10-26T15:22:40.697243+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.system_notifications (2 baris data)
-- ============================================================================
INSERT INTO public.system_notifications (id, sender_admin_id, recipient_user_id, target_role, title, message, notification_type, action_type, is_read, created_at)
VALUES
('76759292-fe23-4be5-ae69-fa588e0257c8', NULL, 'df714843-c4cf-4d45-b385-0390404d4429', 'finance', 'Injeksi Saldo Dompet', 'Berhasil menambahkan saldo Rp 500.000 ke dompet Andi Prawono. Keterangan: kayaaa', 'success', 'wallet_injection', false, '2026-10-26T09:52:27.766865+00:00'),
('98c3517f-e563-43e8-ba22-ede023ec6446', NULL, 'df714843-c4cf-4d45-b385-0390404d4429', 'user', 'Saldo Dompet Masuk', 'Saldo sebesar Rp 500.000 telah ditambahkan ke dompet digital Anda oleh Admin Finansial. Keterangan: kayaaa', 'wallet_injection', 'wallet', true, '2026-10-26T09:52:27.882924+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.admin_audit_logs (3 baris data)
-- ============================================================================
INSERT INTO public.admin_audit_logs (id, admin_id, admin_name, admin_email, role, action, device_model, ip_address, location, isp, status, is_current_session, created_at)
VALUES
('a0ab05a6-f9fd-4ecb-a4c2-53790f4e53b6', NULL, 'Gibran Widodo', 'superadmin@parksmart.id', 'Super Admin', 'Login berhasil (Sesi Aktif)', 'Vivo V2602', '182.2.85.224', 'Surakarta, Indonesia', 'PT Telekomunikasi Selular Indonesia', 'Berhasil (Real-Time)', false, '2026-10-23T07:39:05.527212+00:00'),
('65f08184-16c5-4fad-a150-7291ba4f5708', NULL, 'Admin Finansial', NULL, 'Admin Finansial', 'Injeksi Saldo Dompet 500000 ke User wowok', 'Portal Finansial Admin', NULL, NULL, NULL, 'Berhasil', false, '2026-10-25T11:51:12.056375+00:00'),
('c02afc75-4404-4273-8385-3e36ee2bf576', NULL, 'Admin Finansial', NULL, 'Admin Finansial', 'Injeksi Saldo Dompet 500000 ke User Andi Prawono', 'Portal Finansial Admin', NULL, NULL, NULL, 'Berhasil', false, '2026-10-26T09:52:27.652054+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TABEL: public.arcade_scores (2 baris data)
-- ============================================================================
INSERT INTO public.arcade_scores (id, user_id, game_name, score, points_earned, played_at, score_type)
VALUES
('29321296-8756-4cfd-a988-a74785cd948d', 'df714843-c4cf-4d45-b385-0390404d4429', 'car_racing', 4500, 4500, '2026-10-27T00:41:44.739456+00:00', 'current'),
('12c7a09f-47e2-4fa4-b127-9fc4aaf06170', 'df714843-c4cf-4d45-b385-0390404d4429', 'car_racing', 4500, 4500, '2026-10-27T00:44:17.598628+00:00', 'highest')
ON CONFLICT (id) DO NOTHING;

