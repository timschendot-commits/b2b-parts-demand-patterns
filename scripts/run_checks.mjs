import fs from 'node:fs';
import { DatabaseSync } from 'node:sqlite';

const databasePath = process.argv[2];
const sqlPath = process.argv[3] ?? new URL('../sql/01_check_grain.sql', import.meta.url);
if (!databasePath) {
  console.error('Usage: node scripts/run_checks.mjs <database-path> [sql-file]');
  process.exit(1);
}

const database = new DatabaseSync(databasePath, { readOnly: true });
const sql = fs.readFileSync(sqlPath, 'utf8');
const queries = sql.split(';').map(part => part.trim()).filter(Boolean);

try {
  for (const query of queries) {
    console.log(JSON.stringify(database.prepare(query).get(), null, 2));
  }
} finally {
  database.close();
}
