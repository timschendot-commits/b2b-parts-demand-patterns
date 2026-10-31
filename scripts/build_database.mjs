import fs from 'node:fs';
import path from 'node:path';
import readline from 'node:readline';
import { DatabaseSync } from 'node:sqlite';

const sourceDirectory = process.argv[2];
const databasePath = process.argv[3];

if (!sourceDirectory || !databasePath) {
  console.error('Usage: node scripts/build_database.mjs <source-csv-directory> <database-path>');
  process.exit(1);
}

const filenames = fs.readdirSync(sourceDirectory)
  .filter(name => /^20\d{2}_full_anonymus_v2_final\.csv$/.test(name))
  .sort();
const expectedHeader = 'ORDER_ID;CUSTOMER_ID;REQUEST_DATE;ITEM_ID;PROJECT_ID;LINE_ID;MACHINE_ID;PRODUCT_MODEL_ID;LOCATION;PRICE_EXACT;ITEM_DESCRIPTION;PROJECT_DESCRIPTION;MACHINE_DESCRIPTION;PRODMODEL_DESCRIPTION';

if (filenames.length !== 6) {
  throw new Error(`Expected six yearly CSV files, found ${filenames.length}`);
}

fs.mkdirSync(path.dirname(databasePath), { recursive: true });
const database = new DatabaseSync(databasePath);
let totalRows = 0;

try {
  database.exec('BEGIN TRANSACTION');
  database.exec(`
    DROP TABLE IF EXISTS transaction_lines;
    CREATE TABLE transaction_lines (
      source_file TEXT NOT NULL,
      source_row INTEGER NOT NULL,
      order_id TEXT NOT NULL,
      customer_id TEXT NOT NULL,
      request_date TEXT NOT NULL,
      item_id TEXT NOT NULL,
      project_id TEXT,
      line_id TEXT,
      machine_id TEXT,
      product_model_id TEXT,
      location TEXT,
      price_exact REAL,
      PRIMARY KEY (source_file, source_row)
    );
  `);

  const insert = database.prepare(`
    INSERT INTO transaction_lines VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  for (const filename of filenames) {
    const input = readline.createInterface({
      input: fs.createReadStream(path.join(sourceDirectory, filename)),
      crlfDelay: Infinity
    });
    let rowNumber = 0;

    for await (const line of input) {
      rowNumber++;
      if (rowNumber === 1) {
        if (line.replace(/^\uFEFF/, '') !== expectedHeader) {
          throw new Error(`${filename} has an unexpected header`);
        }
        continue;
      }
      if (!line.trim()) continue;

      const fields = line.split(';');
      if (fields.length !== 14) {
        throw new Error(`${filename}:${rowNumber} has ${fields.length} fields, expected 14`);
      }

      const price = Number(fields[9]);
      if (fields[9].trim() === '' || !Number.isFinite(price)) {
        throw new Error(`${filename}:${rowNumber} has an invalid price`);
      }

      insert.run(
        filename, rowNumber, fields[0], fields[1], fields[2], fields[3],
        fields[4] || null, fields[5] || null, fields[6] || null,
        fields[7] || null, fields[8] || null, price
      );
      totalRows++;
    }
  }

  database.exec(`
    CREATE INDEX transaction_lines_customer ON transaction_lines(customer_id);
    CREATE INDEX transaction_lines_order ON transaction_lines(order_id);
    CREATE INDEX transaction_lines_item ON transaction_lines(item_id);
  `);
  database.exec('COMMIT');
  console.log(`Imported ${totalRows.toLocaleString()} rows into ${databasePath}`);
} catch (error) {
  database.exec('ROLLBACK');
  throw error;
} finally {
  database.close();
}
