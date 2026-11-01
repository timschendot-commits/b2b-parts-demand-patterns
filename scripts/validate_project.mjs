import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { DatabaseSync } from 'node:sqlite';

const databasePath = process.argv[2] ?? fileURLToPath(new URL('../data/b2b.sqlite', import.meta.url));
const reporting = process.argv[3] ?? fileURLToPath(new URL('../data/reporting/', import.meta.url));
const database = new DatabaseSync(databasePath, { readOnly: true });

function expect(actual, expected, label) {
  if (actual !== expected) throw new Error(`${label}: expected ${expected}, received ${actual}`);
  console.log(`OK ${label}: ${actual}`);
}

try {
  expect(database.prepare('PRAGMA integrity_check').get().integrity_check, 'ok', 'SQLite integrity');
  const totals = database.prepare(`SELECT COUNT(*) AS lines,
    COUNT(DISTINCT source_file) AS files, COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_id) AS customers, COUNT(DISTINCT item_id) AS items
    FROM transaction_lines`).get();
  for (const [key, value] of Object.entries({files: 6, lines: 285941, orders: 24532, customers: 238, items: 21143})) {
    expect(totals[key], value, key);
  }
  const orderConflicts = database.prepare(`SELECT COUNT(*) AS conflicts FROM (
    SELECT order_id FROM transaction_lines GROUP BY order_id
    HAVING COUNT(DISTINCT customer_id) > 1 OR COUNT(DISTINCT request_date) > 1
  )`).get().conflicts;
  expect(orderConflicts, 0, 'orders with multiple customers or dates');
  const repeat = database.prepare('SELECT * FROM powerbi_reorder_summary').get();
  expect(repeat.customer_item_pairs, 73020, 'customer-item pairs');
  expect(repeat.reordered_pairs, 34664, 'later-date repeat pairs');
  expect(repeat.reordered_pair_percent, 47.47, 'pair-weighted repeat percentage');
  const spread = database.prepare('SELECT * FROM powerbi_customer_repeat_spread').all();
  expect(spread.length, 2, 'customer cohorts');
  expect(spread.find(row => row.cohort === '全部客户')?.median_customer_percent, 20.92, 'all-customer median percentage');
  expect(spread.find(row => row.cohort === '至少10单')?.median_customer_percent, 40.37, '10+ order median percentage');
  expect(database.prepare('SELECT SUM(customers) AS n FROM powerbi_customer_repeat_histogram').get().n, 134, 'histogram customers');
  const csvFiles = [
    'overview.csv', 'monthly.csv', 'region.csv', 'item_demand.csv',
    'customer_reorders.csv', 'top_customers.csv', 'concentration.csv',
    'reorder_region.csv', 'reorder_summary.csv', 'reorder_order_bands.csv',
    'customer_repeat_spread.csv', 'customer_repeat_cards.csv', 'customer_repeat_histogram.csv',
  ];
  for (const name of csvFiles) {
    const contents = fs.readFileSync(path.join(reporting, name), 'utf8');
    if (!contents.startsWith('\uFEFF') || contents.trim().split(/\r?\n/).length < 2) {
      throw new Error(`Missing or empty reporting export: ${name}`);
    }
  }
  console.log(`OK reporting exports: ${csvFiles.length} CSV files`);
} finally {
  database.close();
}
