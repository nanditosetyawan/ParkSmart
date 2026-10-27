# 📦 Panduan Lengkap Seed Assets & Supabase Migrator

Direktori ini berisi seluruh salinan aset fisik Cloud Storage dan data tabel PostgreSQL untuk proyek **ParkSmart**.

---

## 📁 Struktur Direktori `seed_assets/`

```
seed_assets/
├── manifest.json              # Ringkasan data dump & jumlah file
├── README.md                  # Panduan penggunaan
├── storage/                   # Seluruh file fisik gambar dari Cloud Storage
│   ├── avatars/               # Foto profil pengguna (.jpg)
│   ├── vehicles/              # Foto kendaraan (.jpg)
│   ├── parking-locations/     # Foto lokasi & denah parkir (.jpg)
│   └── kyc-documents/         # Dokumen fisik KTP & selfie KTP (.jpg)
└── data/                      # Seluruh data 16 tabel database dalam format JSON
    ├── users.json
    ├── admins.json
    ├── admin_audit_logs.json
    ├── arcade_scores.json
    ├── bookings.json
    ├── customer_feedbacks.json
    ├── parking_locations.json
    ├── parking_sessions.json
    ├── parking_slots.json
    ├── payments.json
    ├── system_notifications.json
    ├── system_settings.json
    ├── user_favorites.json
    ├── user_kyc.json
    ├── user_member_cards.json
    └── vehicles.json
```

---

## 🚀 Cara Menjalankan Migrasi / Seeding

Jika Anda ingin mengisi database Supabase baru, akun testing baru, atau me-reset sistem:

### Opsi 1: Menggunakan Dart (Rekomendasi Utama)
```bash
dart run tools/seed_storage.dart
```

### Opsi 2: Menggunakan Node.js
```bash
node tools/seed_all.mjs
```

---

## ⚡ Apa Saja yang Dilakukan oleh Script Tersebut Secara Otomatis?
1. **Otomatis Membaca `.env`**: Mengambil `SUPABASE_URL` dan `SUPABASE_ANON_KEY` atau Service Role Key dari target proyek Anda.
2. **Membuat Bucket Storage**: Memeriksa dan otomatis membuat 4 bucket (`avatars`, `vehicles`, `parking-locations`, `kyc-documents`) di Supabase Storage dengan akses publik/terkonfigurasi.
3. **Mengunggah File Fisik**: Mengunggah 34+ file gambar fisik dari `seed_assets/storage/` ke cloud storage target.
4. **Transformasi URL Otomatis**: Menyesuaikan domain URL gambar agar mengarah ke domain Supabase target Anda tanpa dead link / 404.
5. **Mengisi 16 Tabel Database**: Menyuntikkan seluruh baris data ke database target sesuai urutan foreign-key (FK) dependency.
