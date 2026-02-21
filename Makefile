.PHONY: build test test-install test-dev-mode test-agent \
        install-claude install-claude-global install-claude-local \
        install-gemini install-gemini-local \
        install-kiro install-kiro-local

# Build commands/dev.md from src/ source files
build:
	node build.js

# Run all test suites
test:
	bash tests/run.sh

test-install:
	bash tests/run.sh tests/install/claude-code.sh tests/install/gemini.sh tests/install/kiro.sh

test-dev-mode:
	bash tests/run.sh tests/dev-mode/prompt.sh tests/dev-mode/references.sh

test-agent:
	bash tests/run.sh tests/agent/dev-command.sh

# Install stub (fetches latest from GitHub Pages at runtime)
install-claude:
	node install.js --agent claude-code

install-claude-global:
	node install.js --agent claude-code --global

install-gemini:
	node install.js --agent gemini

install-kiro:
	node install.js --agent kiro

# Install local build (offline, pins to current commands/dev.md)
install-claude-local:
	node install.js --agent claude-code --local

install-gemini-local:
	node install.js --agent gemini --local

install-kiro-local:
	node install.js --agent kiro --local
