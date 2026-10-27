import fs from 'fs';
import path from 'path';

const DATA_DIR = path.resolve('seed_assets/data');
const SEED_SQL_PATH = path.resolve('lib/database/seed.sql');

function formatSqlValue(val) {
  if (val === null || val === undefined) return 'NULL';
  if (typeof val === 'number') return val;
  if (typeof val === 'boolean') return val ? 'true' : 'false';
  if (Array.isArray(val)) {
    // Array in postgres
    const escapedElements = val.map(e => `"${String(e).replace(/"/g, '\\"')}"`).join(',');
    return `'{${escapedElements}}'`;
  }
  if (typeof val === 'object') {
    return `'${JSON.stringify(val).replace(/'/g, "''")}'::jsonb`;
  }
  return `'${String(val).replace(/'/g, "''")}'`;
}

function generateInsertSql(tableName, records, conflictKey = 'id') {
  if (!records || records.length === 0) return '';

  const columns = Object.keys(records[0]);
  const colNames = columns.join(', ');

  let sql = `-- ============================================================================\n`;
  sql += `-- TABEL: public.${tableName} (${records.length} baris data)\n`;
  sql += `-- ============================================================================\n`;
  sql += `INSERT INTO public.${tableName} (${colNames})\nVALUES\n`;

  const rowsSql = records.map(record => {
    const values = columns.map(c => formatSqlValue(record[c])).join(', ');
    return `(${values})`;
  }).join(',\n');

  sql += rowsSql;
  if (conflictKey) {
    sql += `\nON CONFLICT (${conflictKey}) DO NOTHING;\n\n`;
  } else {
    sql += `;\n\n`;
  }
  return sql;
}

const tableConfigs = [
  { table: 'users', conflict: 'id' },
  { table: 'admins', conflict: 'id' },
  { table: 'system_settings', conflict: 'key' },
  { table: 'vehicles', conflict: 'id' },
  { table: 'parking_locations', conflict: 'id' },
  { table: 'parking_slots', conflict: 'id' },
  { table: 'user_kyc', conflict: 'id' },
  { table: 'user_member_cards', conflict: 'id' },
  { table: 'user_favorites', conflict: 'id' },
  { table: 'bookings', conflict: 'id' },
  { table: 'parking_sessions', conflict: 'id' },
  { table: 'payments', conflict: 'id' },
  { table: 'system_notifications', conflict: 'id' },
  { table: 'admin_audit_logs', conflict: 'id' },
  { table: 'arcade_scores', conflict: 'id' }
];

let fullSql = `-- ============================================================================\n`;
fullSql += `-- MASTER SEED DATA SQL (16 TABEL LENGKAP) - PARKSMART ID\n`;
fullSql += `-- Path: lib/database/seed.sql\n`;
fullSql += `-- Sinkron 100% dengan seed_assets/data/ dan Database Supabase Live\n`;
fullSql += `-- Tanggal Dihasilkan: ${new Date().toISOString()}\n`;
fullSql += `-- ============================================================================\n\n`;

for (const cfg of tableConfigs) {
  const jsonPath = path.join(DATA_DIR, `${cfg.table}.json`);
  if (!fs.existsSync(jsonPath)) continue;

  const data = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
  fullSql += generateInsertSql(cfg.table, data, cfg.conflict);
}

fs.writeFileSync(SEED_SQL_PATH, fullSql, 'utf8');
console.log(`Berhasil mengenerate: ${SEED_SQL_PATH} (${fullSql.length} bytes)`);
