#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const SRC_DIR = path.join(__dirname, 'src');
const OUT_FILE = path.join(__dirname, 'commands', 'dev.md');

const files = fs.readdirSync(SRC_DIR)
  .filter(f => f.endsWith('.md'))
  .sort()
  .map(f => path.join(SRC_DIR, f));

const parts = files.map(f => fs.readFileSync(f, 'utf8').replace(/\n+$/, ''));
const output = parts.join('\n\n') + '\n';

fs.mkdirSync(path.dirname(OUT_FILE), { recursive: true });
fs.writeFileSync(OUT_FILE, output);

console.log(`Built ${path.relative(__dirname, OUT_FILE)} from ${files.length} source file(s):`);
files.forEach(f => console.log(`  ${path.relative(__dirname, f)}`));
