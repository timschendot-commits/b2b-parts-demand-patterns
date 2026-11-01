import fs from 'node:fs';
import path from 'node:path';
import { DatabaseSync } from 'node:sqlite';

const databasePath = process.argv[2];
const outputDirectory = process.argv[3];

if (!databasePath || !outputDirectory) {
  console.error('Usage: node scripts/export_powerbi_data.mjs <database-path> <output-directory>');
  process.exit(1);
}

const database = new DatabaseSync(databasePath);
const sql = fs.readFileSync(new URL('../sql/03_powerbi_views.sql', import.meta.url), 'utf8');
const demandSql = fs.readFileSync(new URL('../sql/04_demand_views.sql', import.meta.url), 'utf8');
const reorderSql = fs.readFileSync(new URL('../sql/05_reorder_views.sql', import.meta.url), 'utf8');
fs.mkdirSync(outputDirectory, { recursive: true });

function writeCsv(filename, rows) {
  if (rows.length === 0) throw new Error(`${filename} has no rows`);
  const columns = Object.keys(rows[0]);
  const csvCell = value => {
    const text = value == null ? '' : String(value);
    return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
  };
  const lines = [columns.join(',')];
  for (const row of rows) {
    lines.push(columns.map(column => csvCell(row[column])).join(','));
  }
  fs.writeFileSync(path.join(outputDirectory, filename), `\uFEFF${lines.join('\n')}\n`);
  console.log(`${filename}: ${rows.length} rows`);
}

try {
  database.exec(sql);
  database.exec(demandSql);
  database.exec(reorderSql);
  writeCsv('overview.csv', database.prepare('SELECT * FROM powerbi_overview').all());
  writeCsv('monthly.csv', database.prepare('SELECT * FROM powerbi_monthly').all());
  writeCsv('region.csv', database.prepare('SELECT * FROM powerbi_region').all());
  writeCsv('item_demand.csv', database.prepare('SELECT * FROM powerbi_item_demand').all());
  writeCsv('customer_reorders.csv', database.prepare('SELECT * FROM powerbi_customer_reorders').all());
  writeCsv('top_customers.csv', database.prepare('SELECT * FROM powerbi_top_customers').all());
  writeCsv('concentration.csv', database.prepare('SELECT * FROM powerbi_concentration').all());
  writeCsv('reorder_region.csv', database.prepare('SELECT * FROM powerbi_reorder_region').all());
  writeCsv('reorder_summary.csv', database.prepare('SELECT * FROM powerbi_reorder_summary').all());
  writeCsv('reorder_order_bands.csv', database.prepare('SELECT * FROM powerbi_reorder_order_bands').all());
} finally {
  database.close();
}
