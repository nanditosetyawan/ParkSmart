import fs from 'fs';
import path from 'path';

// 1. Baca konfigurasi dari .env
function loadEnv() {
  const envPath = path.resolve('.env');
  if (!fs.existsSync(envPath)) {
    console.error("File .env tidak ditemukan!");
    process.exit(1);
  }
  const lines = fs.readFileSync(envPath, 'utf8').split('\n');
  const env = {};
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx !== -1) {
      const key = trimmed.slice(0, idx).trim();
      const val = trimmed.slice(idx + 1).trim();
      env[key] = val;
    }
  }
  return env;
}

const env = loadEnv();
const SUPABASE_URL = env.SUPABASE_URL;
const SUPABASE_KEY = env.SUPABASE_SERVICE_ROLE_KEY || env.SUPABASE_ANON_KEY;
const ORIGINAL_URL = "https://necsdylhtswrrqassvzp.supabase.co"; // URL asal saat dump

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error("SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env!");
  process.exit(1);
}

const BASE_DIR = path.resolve('seed_assets');
const STORAGE_DIR = path.join(BASE_DIR, 'storage');
const DATA_DIR = path.join(BASE_DIR, 'data');

const BUCKETS = ['avatars', 'vehicles', 'parking-locations', 'kyc-documents'];

// Urutan seed tabel yang mematuhi relasi foreign key (FK)
const TABLE_ORDER = [
  'users',
  'admins',
  'system_settings',
  'vehicles',
  'parking_locations',
  'parking_slots',
  'user_kyc',
  'user_member_cards',
  'user_favorites',
  'bookings',
  'parking_sessions',
  'payments',
  'system_notifications',
  'admin_audit_logs',
  'arcade_scores',
  'customer_feedbacks'
];

async function ensureBucket(bucketName) {
  try {
    const res = await fetch(`${SUPABASE_URL}/storage/v1/bucket`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        id: bucketName,
        name: bucketName,
        public: true,
        file_size_limit: 52428800 // 50MB
      })
    });
    if (res.ok) {
      console.log(`[Bucket] Bucket '${bucketName}' berhasil dibuat.`);
    } else {
      // Kemungkinan sudah ada (409 Conflict)
      console.log(`[Bucket] Bucket '${bucketName}' sudah siap.`);
    }
  } catch (e) {
    console.warn(`[Bucket] Catatan bucket '${bucketName}':`, e.message);
  }
}

function getAllFiles(dirPath, arrayOfFiles = []) {
  if (!fs.existsSync(dirPath)) return arrayOfFiles;
  const files = fs.readdirSync(dirPath);

  files.forEach(function(file) {
    const fullPath = path.join(dirPath, file);
    if (fs.statSync(fullPath).isDirectory()) {
      arrayOfFiles = getAllFiles(fullPath, arrayOfFiles);
    } else {
      arrayOfFiles.push(fullPath);
    }
  });

  return arrayOfFiles;
}

async function uploadFile(bucketName, relativeFilePath, fullLocalPath) {
  try {
    const fileBytes = fs.readFileSync(fullLocalPath);
    const normalizedKey = relativeFilePath.replace(/\\/g, '/');

    const uploadUrl = `${SUPABASE_URL}/storage/v1/object/${bucketName}/${normalizedKey}`;
    const res = await fetch(uploadUrl, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'image/jpeg',
        'x-upsert': 'true' // overwrite jika sudah ada
      },
      body: fileBytes
    });

    if (res.ok) {
      console.log(`[Storage] Uploaded: ${bucketName}/${normalizedKey}`);
      return true;
    } else {
      const err = await res.text();
      console.error(`[Storage] Gagal upload ${bucketName}/${normalizedKey}: ${res.status} ${err}`);
      return false;
    }
  } catch (e) {
    console.error(`[Storage] Error upload:`, e.message);
    return false;
  }
}

function replaceSupabaseUrl(obj) {
  if (typeof obj === 'string') {
    return obj.replaceAll(ORIGINAL_URL, SUPABASE_URL);
  } else if (Array.isArray(obj)) {
    return obj.map(item => replaceSupabaseUrl(item));
  } else if (obj !== null && typeof obj === 'object') {
    const res = {};
    for (const [k, v] of Object.entries(obj)) {
      res[k] = replaceSupabaseUrl(v);
    }
    return res;
  }
  return obj;
}

async function upsertTableData(tableName) {
  const filePath = path.join(DATA_DIR, `${tableName}.json`);
  if (!fs.existsSync(filePath)) {
    console.log(`[Database] File ${tableName}.json tidak ada, lewati.`);
    return;
  }

  const rawData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  if (!Array.isArray(rawData) || rawData.length === 0) {
    console.log(`[Database] Tabel '${tableName}': 0 baris.`);
    return;
  }

  // Ganti URL storage lama ke URL Supabase target saat ini
  const transformedData = replaceSupabaseUrl(rawData);

  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/${tableName}`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates' // UPSERT
      },
      body: JSON.stringify(transformedData)
    });

    if (res.ok) {
      console.log(`[Database] Sukses upsert ${transformedData.length} baris ke '${tableName}'`);
    } else {
      const err = await res.text();
      console.error(`[Database] Gagal upsert tabel '${tableName}': ${res.status} ${err}`);
    }
  } catch (e) {
    console.error(`[Database] Error insert ke '${tableName}':`, e.message);
  }
}

async function main() {
  console.log("==================================================================");
  console.log("🚀 PARKSMART SEEDER: MENGISI SUPABASE STORAGE & DATABASE DARI seed_assets/");
  console.log(`🎯 Target Supabase: ${SUPABASE_URL}`);
  console.log("==================================================================");

  // 1. Pastikan seluruh bucket ada
  console.log("\n1. MEMVALIDASI & MEMBUAT BUCKET DI SUPABASE STORAGE...");
  for (const b of BUCKETS) {
    await ensureBucket(b);
  }

  // 2. Upload semua file fisik dari seed_assets/storage/
  console.log("\n2. MENGUNGGAH FILE FISIK DARI seed_assets/storage/ KE CLOUD...");
  for (const b of BUCKETS) {
    const bucketFolder = path.join(STORAGE_DIR, b);
    if (!fs.existsSync(bucketFolder)) continue;

    const files = getAllFiles(bucketFolder);
    console.log(`--> Bucket [${b}]: Ditemukan ${files.length} file lokal.`);
    for (const f of files) {
      const relPath = path.relative(bucketFolder, f);
      await uploadFile(b, relPath, f);
    }
  }

  // 3. Masukkan seluruh data tabel ke Database
  console.log("\n3. MENYUNTIKKAN DATA TABEL KE POSTGRESQL (DENGAN URL TERKOREKSI)...");
  for (const table of TABLE_ORDER) {
    await upsertTableData(table);
  }

  console.log("\n==================================================================");
  console.log("✅ SEEDING SELESAI 100%! SEMUA GAMBAR & TABEL TELAH TERKONEKSI.");
  console.log("==================================================================");
}

main();
