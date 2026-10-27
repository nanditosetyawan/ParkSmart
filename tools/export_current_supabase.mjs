import fs from 'fs';
import path from 'path';

const SUPABASE_URL = "https://necsdylhtswrrqassvzp.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lY3NkeWxodHN3cnJxYXNzdnpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MjAxNDIsImV4cCI6MjEwNzk5NjE0Mn0.EZDWK_RFCflWiCzjh-X3bA7B71haE4gLMpiIcyc8qTk";

const BASE_DIR = path.resolve('seed_assets');
const STORAGE_DIR = path.join(BASE_DIR, 'storage');
const DATA_DIR = path.join(BASE_DIR, 'data');

// Pastikan direktori ada
fs.mkdirSync(STORAGE_DIR, { recursive: true });
fs.mkdirSync(DATA_DIR, { recursive: true });

async function downloadFile(url, destPath) {
  try {
    const res = await fetch(url);
    if (!res.ok) {
      console.error(`Failed to download ${url}: ${res.statusText}`);
      return false;
    }
    const arrayBuffer = await res.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    fs.mkdirSync(path.dirname(destPath), { recursive: true });
    fs.writeFileSync(destPath, buffer);
    console.log(`Saved: ${destPath} (${buffer.length} bytes)`);
    return true;
  } catch (e) {
    console.error(`Error downloading ${url}:`, e);
    return false;
  }
}

async function fetchTableData(tableName) {
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/${tableName}?select=*`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    if (!res.ok) {
      console.warn(`Table ${tableName} read status: ${res.status} ${res.statusText}`);
      return [];
    }
    return await res.json();
  } catch (e) {
    console.error(`Error fetching table ${tableName}:`, e);
    return [];
  }
}

async function run() {
  console.log("=== MEMULAI DUMP SUPABASE STORAGE & DATABASE KE seed_assets/ ===");

  // 1. Daftar file storage dari database query sebelumnya
  const storageFiles = [
    {
      bucket: 'avatars',
      files: ['df714843-c4cf-4d45-b385-0390404d4429/avatar_df714843-c4cf-4d45-b385-0390404d4429_1793034723450.jpg']
    },
    {
      bucket: 'vehicles',
      files: [
        'c370b869-b78a-4abe-bc73-0c1b3866b9d7/car_c370b869-b78a-4abe-bc73-0c1b3866b9d7_1792983276674.jpg',
        'df714843-c4cf-4d45-b385-0390404d4429/car_df714843-c4cf-4d45-b385-0390404d4429_1792928515651.jpg',
        'df714843-c4cf-4d45-b385-0390404d4429/car_df714843-c4cf-4d45-b385-0390404d4429_1792952802669.jpg'
      ]
    },
    {
      bucket: 'parking-locations',
      files: [
        'loc_1792950362104_6858.jpg',
        'loc_1792950373166_3420.jpg',
        'loc_1792950377025_4885.jpg',
        'loc_1792950715393_9030.jpg',
        'loc_1792950722022_434.jpg',
        'loc_1792951185069_417.jpg',
        'loc_1792951862535_5333.jpg',
        'loc_1793024694116_8254.jpg',
        'loc_1793024697888_7760.jpg',
        'loc_1792950366482_9549.jpg',
        'loc_1792950718477_1617.jpg',
        'loc_1792950725724_1726.jpg',
        'loc_1792951180567_3337.jpg',
        'loc_1792951188190_6454.jpg',
        'loc_1792951191570_5160.jpg',
        'loc_1792951852632_776.jpg',
        'loc_1792951859574_1975.jpg',
        'loc_1792951865820_2014.jpg',
        'loc_1793024702374_3606.jpg',
        'loc_1793025016040_2013.jpg',
        'loc_1793025383295_5440.jpg',
        'loc_1793025389235_3329.jpg',
        'loc_1793024705928_6819.jpg',
        'loc_1793025008655_3233.jpg',
        'loc_1793025012683_5938.jpg',
        'loc_1793025020671_1539.jpg',
        'loc_1793025380114_800.jpg',
        'loc_1793025385866_7021.jpg'
      ]
    },
    {
      bucket: 'kyc-documents',
      files: [
        'df714843-c4cf-4d45-b385-0390404d4429/df714843-c4cf-4d45-b385-0390404d4429_ktp_1793036114262.jpg',
        'df714843-c4cf-4d45-b385-0390404d4429/df714843-c4cf-4d45-b385-0390404d4429_selfie_1793036115390.jpg'
      ]
    }
  ];

  console.log("\n--- Mengunduh Semua File Gambar Fisik dari Supabase Storage ---");
  for (const item of storageFiles) {
    const bucketDir = path.join(STORAGE_DIR, item.bucket);
    fs.mkdirSync(bucketDir, { recursive: true });
    for (const f of item.files) {
      if (f === '.emptyFolderPlaceholder') continue;
      const downloadUrl = `${SUPABASE_URL}/storage/v1/object/public/${item.bucket}/${f}`;
      const destFile = path.join(bucketDir, f);
      await downloadFile(downloadUrl, destFile);
    }
  }

  // 2. Fetch data dari 16 tabel
  const tables = [
    'users',
    'admins',
    'admin_audit_logs',
    'arcade_scores',
    'bookings',
    'customer_feedbacks',
    'parking_locations',
    'parking_sessions',
    'parking_slots',
    'payments',
    'system_notifications',
    'system_settings',
    'user_favorites',
    'user_kyc',
    'user_member_cards',
    'vehicles'
  ];

  console.log("\n--- Mengambil Data Seluruh Tabel Database ---");
  const allData = {};
  for (const table of tables) {
    const data = await fetchTableData(table);
    allData[table] = data;
    const filePath = path.join(DATA_DIR, `${table}.json`);
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    console.log(`Tabel [${table}]: Disimpan ${data.length} baris -> ${filePath}`);
  }

  // Simpan ringkasan manifest
  const manifest = {
    dumpedAt: new Date().toISOString(),
    supabaseUrl: SUPABASE_URL,
    buckets: storageFiles.map(b => ({ bucket: b.bucket, count: b.files.length })),
    tables: Object.fromEntries(Object.entries(allData).map(([k, v]) => [k, v.length]))
  };
  fs.writeFileSync(path.join(BASE_DIR, 'manifest.json'), JSON.stringify(manifest, null, 2), 'utf8');

  console.log("\n=== DUMP SELESAI DENGAN SUKSES! ===");
  console.log(`Semua gambar tersimpan di: ${STORAGE_DIR}`);
  console.log(`Semua data tabel tersimpan di: ${DATA_DIR}`);
}

run();
