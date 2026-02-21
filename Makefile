.PHONY: test test-install test-dev-mode install-claude install-gemini install-kiro

test:
	bash tests/run.sh

test-install:
	bash tests/run.sh tests/install/claude-code.sh tests/install/gemini.sh tests/install/kiro.sh

test-dev-mode:
	bash tests/run.sh tests/dev-mode/prompt.sh tests/dev-mode/references.sh

install-claude:
	node install.js --agent claude-code

install-claude-global:
	node install.js --agent claude-code --global

install-gemini:
	node install.js --agent gemini

install-kiro:
	node install.js --agent kiro
