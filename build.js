#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const REPO = __dirname;
const SRC_DIR = path.join(REPO, 'src');
const BUILD_DIR = path.join(REPO, 'build');

// ---------------------------------------------------------------------------
// 1. Concatenate src/*.md → build/dev.md
// ---------------------------------------------------------------------------

const srcFiles = fs.readdirSync(SRC_DIR)
  .filter(f => f.endsWith('.md'))
  .sort()
  .map(f => path.join(SRC_DIR, f));

const parts = srcFiles.map(f => fs.readFileSync(f, 'utf8').replace(/\n+$/, ''));
const devMd = parts.join('\n\n') + '\n';

fs.mkdirSync(BUILD_DIR, { recursive: true });
fs.writeFileSync(path.join(BUILD_DIR, 'dev.md'), devMd);

// ---------------------------------------------------------------------------
// 2. Generate build/install.js by injecting the embedded DEV_MD constant
// ---------------------------------------------------------------------------

const template = fs.readFileSync(path.join(REPO, 'install.template.js'), 'utf8');

// JSON.stringify produces a valid JS string literal with all special chars escaped.
// Assign it directly — no JSON.parse needed.
const injection = `const DEV_MD = ${JSON.stringify(devMd)};`;
const installerSrc = template.replace('// {{DEV_MD}}', injection);

const installerPath = path.join(BUILD_DIR, 'install.js');
fs.writeFileSync(installerPath, installerSrc);
fs.chmodSync(installerPath, 0o755);

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

console.log(`Built build/dev.md from ${srcFiles.length} source file(s):`);
srcFiles.forEach(f => console.log(`  ${path.relative(REPO, f)}`));
console.log('Generated build/install.js');
