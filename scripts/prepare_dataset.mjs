import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { Readable } from 'node:stream';
import { pipeline } from 'node:stream/promises';
import { fileURLToPath } from 'node:url';

const recordUrl = 'https://zenodo.org/api/records/19492687';
const requestHeaders = {
  'User-Agent': 'B2B-Parts-Demand-Patterns/1.0 (research; DOI: 10.5281/zenodo.19492687)',
};
const files = [
  ['2024_full_anonymus_v2_final.csv', 31489399, 'fdd55b6232235217ae9a09da2b95c024'],
  ['2025_full_anonymus_v2_final.csv', 35507028, 'af7694454c76e1a65cbc34729761a517'],
  ['2026_full_anonymus_v2_final.csv', 32795956, 'ece67af8b11d00e1faf404c65dc48908'],
  ['2027_full_anonymus_v2_final.csv', 34108555, '97ef8521ba1fea33d93f39643b5336df'],
  ['2028_full_anonymus_v2_final.csv', 30738439, 'e81491571d694eb502789da7c07986de'],
  ['2029_full_anonymus_v2_final.csv', 28871011, 'eb0e67cc9f5240304bab8f931cfaf0af'],
];
const defaultDir = fileURLToPath(new URL('../data/raw/', import.meta.url));
const directory = path.resolve(process.argv.slice(2).find(arg => !arg.startsWith('--')) ?? defaultDir);
const verifyOnly = process.argv.includes('--verify-only');
fs.mkdirSync(directory, { recursive: true });

async function md5(file) {
  const hash = crypto.createHash('md5');
  for await (const chunk of fs.createReadStream(file)) hash.update(chunk);
  return hash.digest('hex');
}

async function assertFile(file, size, checksum) {
  if (fs.statSync(file).size !== size || await md5(file) !== checksum) {
    throw new Error(`Checksum or size mismatch: ${file}. Remove the bad local file and retry.`);
  }
}

let record;
for (const [name, size, checksum] of files) {
  const destination = path.join(directory, name);
  if (!fs.existsSync(destination)) {
    if (verifyOnly) throw new Error(`Missing local source file: ${destination}`);
    if (!record) {
      const response = await fetch(recordUrl, { headers: { ...requestHeaders, Accept: 'application/json' } });
      if (!response.ok) throw new Error(`Zenodo metadata request failed: ${response.status}`);
      record = await response.json();
      if (record.id !== 19492687 || record.metadata?.license?.id !== 'cc-by-4.0') {
        throw new Error('Zenodo record or license differs from the pinned project source.');
      }
    }
    const source = record.files.find(item => item.key === name);
    if (source?.size !== size || source?.checksum !== `md5:${checksum}`) {
      throw new Error(`Zenodo metadata differs from the pinned file: ${name}`);
    }
    const response = await fetch(source.links.self, { headers: requestHeaders });
    if (!response.ok || !response.body) throw new Error(`Download failed: ${name} (${response.status})`);
    const temporary = `${destination}.partial`;
    try {
      await pipeline(Readable.fromWeb(response.body), fs.createWriteStream(temporary));
      await assertFile(temporary, size, checksum);
      fs.renameSync(temporary, destination);
    } finally {
      if (fs.existsSync(temporary)) fs.unlinkSync(temporary);
    }
  }
  await assertFile(destination, size, checksum);
  console.log(`Verified ${name} (${size} bytes)`);
}
console.log(`Source files are ready in ${directory}. Keep this directory out of Git.`);
