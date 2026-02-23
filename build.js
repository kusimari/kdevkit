#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const REPO = __dirname;
const SRC_DIR = path.join(REPO, 'src');
const BUILD_DIR = path.join(REPO, 'build');

const srcFiles = fs.readdirSync(SRC_DIR)
  .filter(f => f.endsWith('.md'))
  .sort()
  .map(f => path.join(SRC_DIR, f));

const parts = srcFiles.map(f => fs.readFileSync(f, 'utf8').replace(/\n+$/, ''));
const timestamp = new Date().toISOString();
const devMd = `<!-- kdevkit:built:${timestamp} -->\n` + parts.join('\n\n') + '\n';

fs.mkdirSync(BUILD_DIR, { recursive: true });
fs.writeFileSync(path.join(BUILD_DIR, 'dev.md'), devMd);
fs.copyFileSync(path.join(REPO, 'index.html'), path.join(BUILD_DIR, 'index.html'));

console.log(`Built build/dev.md from ${srcFiles.length} source file(s):`);
srcFiles.forEach(f => console.log(`  ${path.relative(REPO, f)}`));
console.log('Copied index.html → build/index.html');
