.PHONY: build test test-install test-dev-mode test-agent \
        install-claude install-claude-global \
        install-gemini install-gemini-global \
        install-kiro

# Build build/dev.md from src/ and run all tests
build:
	npm run build

# Run all test suites (requires build/dev.md — run 'make build' first)
test:
	bash tests/run.sh

test-install:
	bash tests/run.sh tests/install/claude-code.sh tests/install/gemini.sh tests/install/kiro.sh

test-dev-mode:
	bash tests/run.sh tests/dev-mode/prompt.sh tests/dev-mode/references.sh

test-agent:
	bash tests/run.sh tests/agent/dev-command.sh

# Install into the current project using local build (requires 'make build' first)
install-claude:
	node install.js claude-code --local

install-claude-global:
	node install.js claude-code --global --local

install-gemini:
	node install.js gemini --local

install-gemini-global:
	node install.js gemini --global --local

install-kiro:
	node install.js kiro --local
