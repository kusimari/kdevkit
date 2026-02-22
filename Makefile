.PHONY: build test test-install test-dev-mode test-agent \
        install-claude install-claude-global \
        install-gemini install-gemini-global \
        install-kiro

# Build build/dev.md and build/install.js from src/ source files
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

# Install into the current project (run `make build` first if src/ changed)
install-claude:
	node build/install.js claude-code

install-claude-global:
	node build/install.js claude-code --global

install-gemini:
	node build/install.js gemini

install-gemini-global:
	node build/install.js gemini --global

install-kiro:
	node build/install.js kiro
