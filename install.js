#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');

const RAW_BASE = 'https://raw.githubusercontent.com/kusimari/kdevkit/main/build';
const AGENT_COMPANION_FILES = ['install-agent.md', 'feature-setup.md', 'git-practices.md'];

// ---------------------------------------------------------------------------
// Argument parsing
// ---------------------------------------------------------------------------

function printHelp() {
  console.log(`kdevkit installer

Usage:
  npx github:kusimari/kdevkit [--global]
  node install.js [--local] [--global]

Flags:
  --local       Use local build/kdevkit-dev.md instead of fetching from GitHub
                (requires running 'npm run build' first)
  --global      Install at user scope (~/.claude/agents/) rather than project scope

Examples:
  npx github:kusimari/kdevkit
  npx github:kusimari/kdevkit --global
  node install.js --local
`);
}

function parseArgs(argv) {
  const opts = { global: false, local: false };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--global') {
      opts.global = true;
    } else if (arg === '--local') {
      opts.local = true;
    } else if (arg === '--help' || arg === '-h') {
      printHelp(); process.exit(0);
    } else {
      die(`Unknown option: ${arg}`);
    }
  }
  return opts;
}

function die(msg) {
  console.error(`Error: ${msg}`);
  console.error('Run with --help for usage.');
  process.exit(1);
}

// ---------------------------------------------------------------------------
// File helpers
// ---------------------------------------------------------------------------

function writeFile(dest, content) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(dest, content);
  console.log(`  installed: ${dest}`);
}

// ---------------------------------------------------------------------------
// Metadata injection
// ---------------------------------------------------------------------------

function injectSource(content, source) {
  // Insert <!-- kdevkit:source:... --> immediately after the <!-- kdevkit:built:... --> line.
  // This works correctly for agent files where the built comment follows YAML frontmatter.
  const builtIdx = content.indexOf('<!-- kdevkit:built:');
  if (builtIdx !== -1) {
    const newlineAfterBuilt = content.indexOf('\n', builtIdx);
    if (newlineAfterBuilt !== -1) {
      return content.slice(0, newlineAfterBuilt + 1) +
        `<!-- kdevkit:source:${source} -->\n` +
        content.slice(newlineAfterBuilt + 1);
    }
  }
  // Fallback: insert after first line
  const newline = content.indexOf('\n');
  if (newline === -1) return `<!-- kdevkit:source:${source} -->\n` + content;
  return content.slice(0, newline + 1) +
    `<!-- kdevkit:source:${source} -->\n` +
    content.slice(newline + 1);
}

// ---------------------------------------------------------------------------
// Fetch files
// ---------------------------------------------------------------------------

function fetchUrl(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        return fetchUrl(res.headers.location).then(resolve, reject);
      }
      if (res.statusCode !== 200) {
        return reject(new Error(`HTTP ${res.statusCode} from ${url}`));
      }
      const chunks = [];
      res.on('data', chunk => chunks.push(chunk));
      res.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
      res.on('error', reject);
    }).on('error', reject);
  });
}

async function getFile(opts, filename) {
  if (opts.local) {
    const localPath = path.join(__dirname, 'build', filename);
    if (!fs.existsSync(localPath)) {
      die(`build/${filename} not found. Run 'npm run build' first.`);
    }
    return fs.readFileSync(localPath, 'utf8');
  }
  const url = `${RAW_BASE}/${filename}`;
  console.log(`  fetching: ${url}`);
  return fetchUrl(url);
}

async function getAgentCompanionFiles(opts) {
  const files = {};
  for (const filename of AGENT_COMPANION_FILES) {
    files[filename] = await getFile(opts, filename);
  }
  return files;
}

// ---------------------------------------------------------------------------
// Installer
// ---------------------------------------------------------------------------

function installClaudeCodeAgent(agentMd, agentCompanionFiles, opts) {
  const scope = opts.global ? 'global' : 'project';
  const targetDir = opts.global
    ? path.join(os.homedir(), '.claude', 'agents')
    : path.join(process.cwd(), '.claude', 'agents');
  const source = opts.local ? 'local' : 'raw';
  writeFile(path.join(targetDir, 'kdevkit-dev.md'), injectSource(agentMd, source));
  // install-agent.md goes directly in agents/ alongside kdevkit-dev.md
  const { 'install-agent.md': installAgent, ...kdevkitFiles } = agentCompanionFiles;
  if (installAgent) {
    writeFile(path.join(targetDir, 'install-agent.md'), installAgent);
  }
  for (const [filename, content] of Object.entries(kdevkitFiles)) {
    writeFile(path.join(targetDir, 'kdevkit', filename), content);
  }
  console.log(`\nInstalled kdevkit-dev agent (scope: ${scope})`);
  console.log(`Agents directory: ${targetDir}`);
  console.log('Tell Claude: "use the kdevkit-dev agent for feature: <name>"');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const opts = parseArgs(process.argv.slice(2));

  const scopeLabel = opts.global ? ' (global)' : ' (project)';
  const sourceLabel = opts.local ? ' [local build]' : ' [GitHub raw]';
  console.log(`Installing kdevkit-dev agent${scopeLabel}${sourceLabel}`);
  console.log('');

  const agentMd = await getFile(opts, 'kdevkit-dev.md');
  const agentCompanionFiles = await getAgentCompanionFiles(opts);
  installClaudeCodeAgent(agentMd, agentCompanionFiles, opts);
}

main().catch(err => { console.error(`Error: ${err.message}`); process.exit(1); });
