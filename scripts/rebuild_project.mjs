import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const source = fileURLToPath(new URL('../data/raw/', import.meta.url));
const database = fileURLToPath(new URL('../data/b2b.sqlite', import.meta.url));
const reporting = fileURLToPath(new URL('../data/reporting/', import.meta.url));
const scripts = [
  ['prepare_dataset.mjs', source, ...(process.argv.includes('--no-download') ? ['--verify-only'] : [])],
  ['build_database.mjs', source, database],
  ['export_powerbi_data.mjs', database, reporting],
  ['validate_project.mjs', database, reporting],
];

for (const [script, ...args] of scripts) {
  console.log(`\nRunning ${script}`);
  execFileSync(process.execPath, [fileURLToPath(new URL(script, import.meta.url)), ...args], {
    cwd: root,
    stdio: 'inherit',
  });
}
console.log('\nProject data build complete. Open the PBIX and refresh after setting its CSV source to data/reporting/.');
