#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const REPO = __dirname;
const SRC_DIR = path.join(REPO, 'src');
const BUILD_DIR = path.join(REPO, 'build');

// Maps each output file to the ordered list of src/ files that compose it.
// kdevkit-dev.md gets the <!-- kdevkit:built:TIMESTAMP --> header (used by self-update).
// The timestamp is inserted after the closing --- of the YAML frontmatter so
// YAML parsing is unaffected.
const MANIFEST = {
  'kdevkit-dev.md': [
    'agent-header.md',
    '00-selfupdate.md',
    '01-header.md',
    '02-project-context.md',
    '03-feature-context.md',
    '05-git-practices-stub.md',
    '06-session-behaviour.md',
    '07-confirm.md',
  ],
  'feature-setup.md': ['04-feature-setup-reference.md'],
  'git-practices.md': ['05-git-practices-reference.md'],
  'install-agent.md': ['install-agent.md'],
};

const timestamp = new Date().toISOString();

fs.mkdirSync(BUILD_DIR, { recursive: true });

for (const [outputFile, srcFileNames] of Object.entries(MANIFEST)) {
  const parts = srcFileNames.map(name => {
    const filePath = path.join(SRC_DIR, name);
    return fs.readFileSync(filePath, 'utf8').replace(/\n+$/, '');
  });

  let content = parts.join('\n\n') + '\n';

  if (outputFile === 'kdevkit-dev.md') {
    // Insert timestamp comment after the closing --- of the YAML frontmatter
    // so the frontmatter remains valid.
    const lines = content.split('\n');
    const fmCloseIdx = lines.indexOf('---', 1); // find second ---
    if (fmCloseIdx !== -1) {
      lines.splice(fmCloseIdx + 1, 0, `<!-- kdevkit:built:${timestamp} -->`);
    } else {
      lines.unshift(`<!-- kdevkit:built:${timestamp} -->`);
    }
    content = lines.join('\n');
  }

  fs.writeFileSync(path.join(BUILD_DIR, outputFile), content);
  console.log(`Built build/${outputFile} from ${srcFileNames.length} source file(s):`);
  srcFileNames.forEach(name => console.log(`  src/${name}`));
}
