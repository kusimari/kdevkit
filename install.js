#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

// ---------------------------------------------------------------------------
// Argument parsing
// ---------------------------------------------------------------------------

function printHelp() {
  console.log(`k-mcp-devkit installer

Usage:
  node install.js --agent <name> [--global] [--local]

  # From a GitHub clone or via npx:
  npx github:kusimari/k-mcp-devkit --agent claude-code

  # From a local clone:
  node install.js --agent claude-code

  # Install the full local build (no network fetch at runtime):
  node install.js --agent claude-code --local

Agents:
  claude-code   Claude Code  (.claude/commands/ or ~/.claude/commands/)
  gemini        Gemini CLI   (GEMINI.md or ~/.gemini/GEMINI.md)
  kiro          Amazon Kiro  (.kiro/steering/)

Flags:
  --global      Install at user scope rather than project scope
                (not supported by all agents)
  --local       Install the full built command file (commands/dev.md) instead
                of the default stub. The stub fetches the latest instructions
                from GitHub Pages at runtime; --local works offline and pins
                to the version you have checked out.

Examples:
  node install.js --agent claude-code
  node install.js --agent claude-code --global
  node install.js --agent claude-code --local
  node install.js --agent gemini
  node install.js --agent kiro
`);
}

function parseArgs(argv) {
  const opts = { agent: null, global: false, local: false };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--agent') {
      if (!argv[i + 1]) { die('--agent requires a value'); }
      opts.agent = argv[++i];
    } else if (arg === '--global') {
      opts.global = true;
    } else if (arg === '--local') {
      opts.local = true;
    } else if (arg === '--help' || arg === '-h') {
      printHelp();
      process.exit(0);
    } else {
      die(`Unknown option: ${arg}`);
    }
  }
  return opts;
}

function die(msg) {
  console.error(`Error: ${msg}`);
  console.error('Run node install.js --help for usage.');
  process.exit(1);
}

// ---------------------------------------------------------------------------
// File helpers
// ---------------------------------------------------------------------------

function installFile(src, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
  console.log(`  installed: ${dest}`);
}

function appendSection(targetFile, heading, content) {
  const existing = fs.existsSync(targetFile) ? fs.readFileSync(targetFile, 'utf8') : '';
  if (existing.includes(heading)) {
    const name = heading.replace('## k-mcp-devkit: ', '');
    console.log(`  skipped (already present): ${name} in ${targetFile}`);
    return false;
  }
  fs.appendFileSync(targetFile, `\n${heading}\n\n${content}`);
  const name = heading.replace('## k-mcp-devkit: ', '');
  console.log(`  appended: ${name} → ${targetFile}`);
  return true;
}

// ---------------------------------------------------------------------------
// Agent installers
// ---------------------------------------------------------------------------

function installClaudeCode(commandFiles, opts) {
  const scope = opts.global ? 'global' : 'project';
  const targetDir = opts.global
    ? path.join(os.homedir(), '.claude', 'commands')
    : path.join(process.cwd(), '.claude', 'commands');

  for (const { name, src } of commandFiles) {
    installFile(src, path.join(targetDir, name));
  }

  const names = commandFiles.map(f => path.basename(f.name, '.md')).join(' ');
  console.log(`\nClaude Code: ${commandFiles.length} command(s) installed (scope: ${scope})`);
  console.log(`Invoke with /${names}`);
}

function installGemini(commandFiles, opts) {
  const scope = opts.global ? 'global' : 'project';
  const targetFile = opts.global
    ? path.join(os.homedir(), '.gemini', 'GEMINI.md')
    : path.join(process.cwd(), 'GEMINI.md');

  if (opts.global) {
    fs.mkdirSync(path.dirname(targetFile), { recursive: true });
  }

  let count = 0;
  for (const { name, src } of commandFiles) {
    const commandName = path.basename(name, '.md');
    const heading = `## k-mcp-devkit: ${commandName}`;
    const content = fs.readFileSync(src, 'utf8');
    if (appendSection(targetFile, heading, content)) count++;
  }

  console.log(`\nGemini CLI: ${count} command(s) added to ${targetFile} (scope: ${scope})`);
  console.log('Activate in a session by asking the model to apply the relevant section.');
}

function installKiro(commandFiles, opts) {
  if (opts.global) {
    console.warn('Warning: Kiro does not support global steering files. Installing at project scope.');
  }

  const targetDir = path.join(process.cwd(), '.kiro', 'steering');

  for (const { name, src } of commandFiles) {
    installFile(src, path.join(targetDir, name));
  }

  console.log(`\nKiro: ${commandFiles.length} steering file(s) installed → ${targetDir}`);
  console.log('These are active in every Kiro session for this project.');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

const opts = parseArgs(process.argv.slice(2));

if (!opts.agent) {
  die('--agent is required.');
}

// --local installs the full built file; default installs the fetch stub
const SOURCE_DIR = opts.local
  ? path.join(__dirname, 'commands')
  : path.join(__dirname, 'stub');

if (!fs.existsSync(SOURCE_DIR)) {
  if (opts.local) {
    die('commands/dev.md not found. Run `node build.js` first to generate the local build.');
  } else {
    die(`stub directory not found at ${SOURCE_DIR}`);
  }
}

const commandFiles = fs.readdirSync(SOURCE_DIR)
  .filter(f => f.endsWith('.md'))
  .sort()
  .map(f => ({ name: f, src: path.join(SOURCE_DIR, f) }));

const scopeLabel = opts.global ? ' (global)' : '';
const modeLabel = opts.local ? ' [local build]' : ' [stub → GitHub Pages]';
console.log(`Installing for: ${opts.agent}${scopeLabel}${modeLabel}`);
console.log('');

switch (opts.agent) {
  case 'claude-code': installClaudeCode(commandFiles, opts); break;
  case 'gemini':      installGemini(commandFiles, opts);      break;
  case 'kiro':        installKiro(commandFiles, opts);        break;
  default:
    die(`unknown agent '${opts.agent}'.\nAvailable: claude-code, gemini, kiro`);
}
