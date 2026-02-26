#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');

const PAGES_BASE = 'https://kusimari.github.io/kdevkit';
const PAGES_URL = `${PAGES_BASE}/dev.md`;
const COMPANION_FILES = ['feature-setup.md', 'git-practices.md'];
const AGENT_COMPANION_FILES = ['install-agent.md', 'feature-setup.md', 'git-practices.md'];

// ---------------------------------------------------------------------------
// Argument parsing
// ---------------------------------------------------------------------------

function printHelp() {
  console.log(`kdevkit installer

Usage:
  npx github:kusimari/kdevkit <agent> [--global]
  node install.js <agent> [--local] [--global]

Agents:
  claude-code-agent  Claude Code / Claude Code on the web (.claude/agents/)
  claude-code        Claude Code slash command (.claude/commands/) [legacy]
  gemini             Gemini CLI   (GEMINI.md or ~/.gemini/GEMINI.md)
  kiro               Amazon Kiro  (.kiro/steering/)

Flags:
  --local       Use local build/dev.md (or build/agent.md) instead of fetching from GitHub Pages
                (requires running 'npm run build' first)
  --global      Install at user scope rather than project scope
                (claude-code-agent and claude-code: ~/.claude/; Gemini only; Kiro is project-only)

Examples:
  npx github:kusimari/kdevkit claude-code-agent
  npx github:kusimari/kdevkit claude-code-agent --global
  npx github:kusimari/kdevkit gemini --global
  node install.js claude-code-agent --local
`);
}

function parseArgs(argv) {
  const opts = { agent: null, global: false, local: false };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--agent') {
      if (!argv[i + 1]) die('--agent requires a value');
      opts.agent = argv[++i];
    } else if (arg === '--global') {
      opts.global = true;
    } else if (arg === '--local') {
      opts.local = true;
    } else if (arg === '--help' || arg === '-h') {
      printHelp(); process.exit(0);
    } else if (!arg.startsWith('-')) {
      opts.agent = arg;
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

function appendSection(targetFile, heading, content) {
  const existing = fs.existsSync(targetFile) ? fs.readFileSync(targetFile, 'utf8') : '';
  if (existing.split('\n').some(line => line === heading)) {
    console.log(`  skipped (already present): ${heading}`);
    return false;
  }
  fs.mkdirSync(path.dirname(targetFile), { recursive: true });
  fs.appendFileSync(targetFile, `\n${heading}\n\n${content}`);
  console.log(`  appended: ${heading} → ${path.basename(targetFile)}`);
  return true;
}

// ---------------------------------------------------------------------------
// Metadata injection
// ---------------------------------------------------------------------------

function injectSource(devMd, source) {
  // Insert <!-- kdevkit:source:... --> on the line immediately after the
  // <!-- kdevkit:built:... --> timestamp comment (first line).
  const newline = devMd.indexOf('\n');
  if (newline === -1) return `<!-- kdevkit:source:${source} -->\n` + devMd;
  return devMd.slice(0, newline + 1) +
    `<!-- kdevkit:source:${source} -->\n` +
    devMd.slice(newline + 1);
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
  const url = `${PAGES_BASE}/${filename}`;
  console.log(`  fetching: ${url}`);
  return fetchUrl(url);
}

async function getDevMd(opts) {
  return getFile(opts, 'dev.md');
}

async function getAgentMd(opts) {
  return getFile(opts, 'agent.md');
}

async function getCompanionFiles(opts) {
  const files = {};
  for (const filename of COMPANION_FILES) {
    files[filename] = await getFile(opts, filename);
  }
  return files;
}

async function getAgentCompanionFiles(opts) {
  const files = {};
  for (const filename of AGENT_COMPANION_FILES) {
    files[filename] = await getFile(opts, filename);
  }
  return files;
}

// ---------------------------------------------------------------------------
// Agent installers
// ---------------------------------------------------------------------------

function installClaudeCodeAgent(agentMd, agentCompanionFiles, opts) {
  const scope = opts.global ? 'global' : 'project';
  const targetDir = opts.global
    ? path.join(os.homedir(), '.claude', 'agents')
    : path.join(process.cwd(), '.claude', 'agents');
  const source = opts.local ? 'local' : 'github-pages';
  writeFile(path.join(targetDir, 'dev.md'), injectSource(agentMd, source));
  // install-agent.md goes directly in agents/ (not in kdevkit/ subdirectory)
  const { 'install-agent.md': installAgent, ...kdevkitFiles } = agentCompanionFiles;
  if (installAgent) {
    writeFile(path.join(targetDir, 'install-agent.md'), installAgent);
  }
  for (const [filename, content] of Object.entries(kdevkitFiles)) {
    writeFile(path.join(targetDir, 'kdevkit', filename), content);
  }
  console.log(`\nClaude Code (agent): dev agent installed (scope: ${scope})`);
  console.log(`Agents directory: ${targetDir}`);
  console.log('Tell Claude to "use the dev agent" or "enter dev mode for <feature>".');
}

function installClaudeCode(devMd, companionFiles, opts) {
  const scope = opts.global ? 'global' : 'project';
  const targetDir = opts.global
    ? path.join(os.homedir(), '.claude', 'commands')
    : path.join(process.cwd(), '.claude', 'commands');
  const source = opts.local ? 'local' : 'github-pages';
  writeFile(path.join(targetDir, 'dev.md'), injectSource(devMd, source));
  for (const [filename, content] of Object.entries(companionFiles)) {
    writeFile(path.join(targetDir, 'kdevkit', filename), content);
  }
  console.log(`\nClaude Code: dev command installed (scope: ${scope})`);
  console.log('Invoke with /dev [feature]');
}

function installGemini(devMd, companionFiles, opts) {
  const scope = opts.global ? 'global' : 'project';
  const targetFile = opts.global
    ? path.join(os.homedir(), '.gemini', 'GEMINI.md')
    : path.join(process.cwd(), 'GEMINI.md');
  const source = opts.local ? 'local' : 'github-pages';
  appendSection(targetFile, '## kdevkit: dev', injectSource(devMd, source));
  for (const [filename, content] of Object.entries(companionFiles)) {
    const sectionName = filename.replace('.md', '');
    appendSection(targetFile, `## kdevkit: ${sectionName}`, content);
  }
  console.log(`\nGemini CLI: dev section in ${targetFile} (scope: ${scope})`);
  console.log('Activate by asking the model to apply the kdevkit dev section.');
}

function installKiro(devMd, companionFiles, opts) {
  if (opts.global) {
    console.warn('Warning: Kiro does not support global steering files. Installing at project scope.');
  }
  const targetDir = path.join(process.cwd(), '.kiro', 'steering');
  const source = opts.local ? 'local' : 'github-pages';
  writeFile(path.join(targetDir, 'dev.md'), injectSource(devMd, source));
  for (const [filename, content] of Object.entries(companionFiles)) {
    writeFile(path.join(targetDir, 'kdevkit', filename), content);
  }
  console.log(`\nKiro: dev steering file installed → ${path.join(targetDir, 'dev.md')}`);
  console.log('Active in every Kiro session for this project.');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (!opts.agent) { printHelp(); process.exit(1); }

  const scopeLabel = opts.global ? ' (global)' : ' (project)';
  const sourceLabel = opts.local ? ' [local build]' : ' [GitHub Pages]';
  console.log(`Installing kdevkit dev for: ${opts.agent}${scopeLabel}${sourceLabel}`);
  console.log('');

  if (opts.agent === 'claude-code-agent') {
    const agentMd = await getAgentMd(opts);
    const agentCompanionFiles = await getAgentCompanionFiles(opts);
    installClaudeCodeAgent(agentMd, agentCompanionFiles, opts);
  } else {
    const devMd = await getDevMd(opts);
    const companionFiles = await getCompanionFiles(opts);
    switch (opts.agent) {
      case 'claude-code': installClaudeCode(devMd, companionFiles, opts); break;
      case 'gemini':      installGemini(devMd, companionFiles, opts);     break;
      case 'kiro':        installKiro(devMd, companionFiles, opts);       break;
      default: die(`unknown agent '${opts.agent}'.\nAvailable: claude-code-agent, claude-code, gemini, kiro`);
    }
  }
}

main().catch(err => { console.error(`Error: ${err.message}`); process.exit(1); });
