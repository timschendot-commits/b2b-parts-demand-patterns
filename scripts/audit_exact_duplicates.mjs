import fs from 'node:fs';
import path from 'node:path';
import readline from 'node:readline';

const sourceDirectory = process.argv[2];
if (!sourceDirectory) {
  console.error('Usage: node scripts/audit_exact_duplicates.mjs <source-csv-directory>');
  process.exit(1);
}

const filenames = fs.readdirSync(sourceDirectory)
  .filter(name => /^20\d{2}_full_anonymus_v2_final\.csv$/.test(name))
  .sort();
const expectedHeader = 'ORDER_ID;CUSTOMER_ID;REQUEST_DATE;ITEM_ID;PROJECT_ID;LINE_ID;MACHINE_ID;PRODUCT_MODEL_ID;LOCATION;PRICE_EXACT;ITEM_DESCRIPTION;PROJECT_DESCRIPTION;MACHINE_DESCRIPTION;PRODMODEL_DESCRIPTION';
if (filenames.length !== 6) {
  throw new Error(`Expected six yearly CSV files, found ${filenames.length}`);
}

const results = [];
const affectedOrders = new Set();
for (const filename of filenames) {
  const counts = new Map();
  const input = readline.createInterface({
    input: fs.createReadStream(path.join(sourceDirectory, filename)),
    crlfDelay: Infinity
  });
  let lines = 0;
  let firstLine = true;
  for await (const line of input) {
    if (firstLine) {
      firstLine = false;
      if (line.replace(/^\uFEFF/, '') !== expectedHeader) {
        throw new Error(`${filename} has an unexpected header`);
      }
      continue;
    }
    if (!line) continue;
    const requestDate = line.split(';', 4)[2];
    if (!requestDate?.startsWith(filename.slice(0, 4))) {
      throw new Error(`${filename} contains a date outside its year`);
    }
    lines++;
    counts.set(line, (counts.get(line) ?? 0) + 1);
  }

  let duplicateGroups = 0;
  let duplicateExcess = 0;
  let rowsInDuplicateGroups = 0;
  let maxCopies = 0;
  for (const [line, copies] of counts) {
    if (copies < 2) continue;
    duplicateGroups++;
    duplicateExcess += copies - 1;
    rowsInDuplicateGroups += copies;
    maxCopies = Math.max(maxCopies, copies);
    affectedOrders.add(line.slice(0, line.indexOf(';')));
  }
  results.push({
    file: filename,
    lines,
    exact_distinct_lines: counts.size,
    duplicate_excess: duplicateExcess,
    duplicate_groups: duplicateGroups,
    rows_in_duplicate_groups: rowsInDuplicateGroups,
    max_copies: maxCopies
  });
}

const totalLines = results.reduce((sum, row) => sum + row.lines, 0);
const totalExcess = results.reduce((sum, row) => sum + row.duplicate_excess, 0);
console.log(JSON.stringify({
  files: results,
  total_lines: totalLines,
  exact_distinct_lines: totalLines - totalExcess,
  duplicate_excess: totalExcess,
  duplicate_excess_percent: +(100 * totalExcess / totalLines).toFixed(2),
  affected_orders: affectedOrders.size
}, null, 2));
