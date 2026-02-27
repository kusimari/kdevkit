#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const REPO = __dirname;
const SRC_DIR = path.join(REPO, 'src');
const BUILD_DIR = path.join(REPO, 'build');

const MANIFEST = {
  'kdevkit-dev.md': [
    'agent-header.md',
    '01-header.md',
    '02-project-context.md',
    '03-feature-context.md',
    '04-feature-setup.md',
    '05-git-practices.md',
    '06-session-behaviour.md',
    '07-confirm.md',
  ],
};

fs.mkdirSync(BUILD_DIR, { recursive: true });

for (const [outputFile, srcFileNames] of Object.entries(MANIFEST)) {
  const parts = srcFileNames.map(name => {
    const filePath = path.join(SRC_DIR, name);
    return fs.readFileSync(filePath, 'utf8').replace(/\n+$/, '');
  });

  const content = parts.join('\n\n') + '\n';

  fs.writeFileSync(path.join(BUILD_DIR, outputFile), content);
  console.log(`Built build/${outputFile} from ${srcFileNames.length} source file(s):`);
  srcFileNames.forEach(name => console.log(`  src/${name}`));
}
